//
//  DBInternet.m
//  DeviceInfo
//
//  Created by dengbin on 17/6/7.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBInternetInfo.h"
#import "sys/utsname.h"
#import <net/if.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <resolv.h>
#include <dns.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "Reachability.h"
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#import<SystemConfiguration/CaptiveNetwork.h>

@implementation DBInternetInfo
+ (instancetype)shareInternetInfo {

    static DBInternetInfo *internet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        internet = [[DBInternetInfo alloc] init];

    });
    return internet;
}
#pragma mark ssid Info
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);  //单个数据info[@"SSID"]; info[@"BSSID"];
        if (info && [info count]) { break; }
    }
    return info;
}

- (NSString *)standardFormateMAC:(NSString *)MAC {
    NSArray * subStr = [MAC componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":-"]];
    NSMutableArray * subStr_M = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString * str in subStr) {
        if (1 == str.length) {
            NSString * tmpStr = [NSString stringWithFormat:@"0%@", str];
            [subStr_M addObject:tmpStr];
        } else {
            [subStr_M addObject:str];
        }
    }

    NSString * formateMAC = [subStr_M componentsJoinedByString:@":"];
    return [formateMAC uppercaseString];
}
#pragma mark - mac
+ (NSString *)getMacAddress
{

    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;

    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;

    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }

    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }

    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }

    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];

    //    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];

    NSLog(@"outString:%@", outstring);

    free(buf);

    return [outstring uppercaseString];
}
#pragma mark - DNS

- (NSString *)getDNSServers
{
    // dont forget to link libresolv.lib
    NSMutableString *addresses = [[NSMutableString alloc]initWithString:@""];

    res_state res = malloc(sizeof(struct __res_state));

    int result = res_ninit(res);

    if ( result == 0 )
    {
        for ( int i = 0; i < res->nscount; i++ )
        {
            NSString *s = [NSString stringWithUTF8String :  inet_ntoa(res->nsaddr_list[i].sin_addr)];
            [addresses appendFormat:@"%@,",s];
        }


        [addresses deleteCharactersInRange:NSMakeRange(addresses.length-1, 1)];
        
    }
    else
    {
        [addresses appendString:@"0.0.0.0"];

    }

    return addresses;
}
#pragma mark - wifi名称

//wifiName

- (NSString *)getWifiName

{

    NSString *wifiName = nil;

    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();

    if(!wifiInterfaces) {

        return nil;

    }

    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;

    for(NSString *interfaceName in interfaces) {

        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));

        if(dictRef) {

            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;

            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];

            CFRelease(dictRef);

        }
        
    }
    
    CFRelease(wifiInterfaces);
    
    return wifiName;
    
}
//网络状态
- (void)networkStateChange
{
    // 1.检测wifi状态

    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    Reachability *conn = [Reachability reachabilityForInternetConnection];


    // 3.判断网络状态
    if ([conn currentReachabilityStatus] == ReachableViaWiFi) { // 有wifi
        NSLog(@"有wifi");
    } else if ([conn currentReachabilityStatus] == ReachableViaWWAN) { // 没有使用wifi, 使用手机自带网络进行上网
        NSLog(@"使用手机自带网络进行上网");
    } else { // 没有网络
        NSLog(@"没有网络");
    }

    //
    //    [GLobalRealReachability reachabilityWithBlock:^(ReachabilityStatus status) {
    //        switch (status)
    //        {
    //            case NotReachable:
    //            {
    //                NSLog(@"没有网络");
    //
    //                //  case NotReachable handler
    //                break;
    //            }
    //
    //            case ReachableViaWiFi:
    //            {
    //                NSLog(@"有wifi");
    //
    //                //  case ReachableViaWiFi handler
    //                break;
    //            }
    //
    //            case ReachableViaWWAN:
    //            {
    //                NSLog(@"使用手机自带网络进行上网");
    //
    //                //  case ReachableViaWWAN handler
    //                break;
    //            }
    //            default:
    //                break;
    //        }
    //    }];
}

#pragma mark - ip

//可获取蜂窝ip
- (NSString *)getAppIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;

    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);

    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];

    return address ? address : @"0.0.0.0";
}



- (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";

    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];

    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];

        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}
- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];

    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {


                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                   // "lo0/ipv4"
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                  //  NSString *key = [NSString stringWithFormat:@"%@", name];

                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }


            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
-(NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"utun0"])
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];



                NSLog(@"%s",temp_addr->ifa_name);//端口地址


                NSLog(@"子网掩码:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                NSLog(@"本地IP:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                NSLog(@"广播地址:%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

-(void)getProxieInfo
{
    NSDictionary *proxySettings = (__bridge NSDictionary *)CFNetworkCopySystemProxySettings();

    NSLog(@"%@",proxySettings);

    NSArray *proxies = (__bridge NSArray *)CFNetworkCopyProxiesForURL(
                                                                      (__bridge CFURLRef)[NSURL URLWithString:@"http://www.google.com"],
                                                                      (__bridge CFDictionaryRef)proxySettings);

    NSDictionary *settings = [proxies objectAtIndex:0];
    NSLog(@"proxies[0]---%@",settings);
    NSLog(@"host=%@", [settings objectForKey:(NSString *)kCFProxyHostNameKey]);
    NSLog(@"port=%@", [settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
    NSLog(@"type=%@", [settings objectForKey:(NSString *)kCFProxyTypeKey]);

    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"])
    {
        NSLog(@"没代理");
    }
    else
    {
        NSLog(@"设置了代理");
    }
}



//+ (NSString *)networkingStatesFromStatebar {
//    // 状态栏是由当前app控制的，首先获取当前app
//    UIApplication *app = [UIApplication sharedApplication];
//
//    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
//
//    int type = 0;
//    for (id child in children) {
//        if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
//            type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
//        }
//    }
//
//    NSString *stateString = @"wifi";
//
//    switch (type) {
//        case 0:
//            stateString = @"notReachable";
//            break;
//
//        case 1:
//            stateString = @"2G";
//            break;
//
//        case 2:
//            stateString = @"3G";
//            break;
//
//        case 3:
//            stateString = @"4G";
//            break;
//
//        case 4:
//            stateString = @"LTE";
//            break;
//
//        case 5:
//            stateString = @"wifi";
//            break;
//
//        default:
//            break;
//    }
//
//    return stateString;
//}
@end
