//
//  DBNetWorkInfo.m
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/9.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBNetWorkInfo.h"
#import "RCReachability.h"
#import "DBCarrierInfo.h"

#include <dns.h>
#import "sys/utsname.h"
#import <net/if.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <resolv.h>
#include <sys/sysctl.h>
#include <net/if_dl.h>

#import<SystemConfiguration/CaptiveNetwork.h>

@implementation DBNetWorkInfo

+ (instancetype)shareNetWorkInfo {

    static DBNetWorkInfo *netWorkInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        netWorkInfo = [[DBNetWorkInfo alloc] init];

    });
    return netWorkInfo;
}
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
       // NSLog(@"%@ => %@", ifnam, info);  //单个数据info[@"SSID"]; info[@"BSSID"];
        if (info && [info count]) { break; }
    }
    return info;
}
#pragma mark - 网络类型
//网络类型
- (NSString *)networkType
{
    // 1.检测wifi状态

    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    RCReachability *conn = [RCReachability reachabilityForInternetConnection];


    // 3.判断网络状态
    if ([conn currentReachabilityStatus] == NetworkStatusReachableViaWiFi)
    {
        return @"WIFI";
    }
    else if ([conn currentReachabilityStatus] == NetworkStatusReachableViaWWAN)
    {
        return [[DBCarrierInfo shareCarrierInfo] getWWANState];
        
    } else {
        return @"none";
    }
}

#pragma mark - ip
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
//可获取蜂窝ip
- (NSDictionary *)getNetWorkInfo
{
//yes 为ipv4 地址
    NSArray *searchArray = YES ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;

    NSMutableDictionary *networkInfo = [NSMutableDictionary new];
    NSDictionary *addresses = [self getIPAddresses];
//    "awdl0/ipv6" = "fe80::8c94:a0ff:fe9c:d235---0.0.0.0";
//    "en0/ipv4" = "172.16.35.59---255.255.248.0";
//    "en0/ipv6" = "fe80::a65e:60ff:fed6:3d61---0.0.0.0";
//    "lo0/ipv4" = "127.0.0.1---255.0.0.0";
//    "lo0/ipv6" = "fe80::1---0.0.0.0";
    NSArray *networkNames = addresses.allKeys;


    [networkInfo setObject:networkNames ? networkNames : [NSArray new] forKey:@"NetworkNames"];




    __block NSString *address;
    __block NSString *netMask;

    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         NSString *ipAndMask = addresses[key];
         NSArray *arr = [ipAndMask componentsSeparatedByString:@"---"];
         if (arr && arr[0])
         {
             address= arr[0];
             if (arr.count >0)
             {
                 netMask = arr[1];
             }
             //筛选出IP地址格式
             if([self isValidatIP:address])
             {
                 *stop = YES;

             }

         }

     } ];

    [networkInfo setObject:address ? address : @"0.0.0.0" forKey:@"IPAddress"];


    [networkInfo setObject:netMask ? netMask : @"0.0.0.0" forKey:@"NetMask"];




    return networkInfo;
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

                NSString *netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)interface->ifa_netmask)->sin_addr)];

                if(type) {

                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];

                    NSString *address = [NSString stringWithUTF8String:addrBuf];
                    addresses[key] = [NSString stringWithFormat:@"%@---%@",address,netmask];

                }


            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
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
#pragma mark - mac
- (NSString *)getMacAddress
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


    free(buf);

    return [outstring uppercaseString];
}
#pragma mark - 网络代理
-(NSDictionary *)getProxieInfo
{
    NSDictionary *proxySettings = (__bridge NSDictionary *)CFNetworkCopySystemProxySettings();


    NSArray *proxies = (__bridge NSArray *)CFNetworkCopyProxiesForURL(
                                                                      (__bridge CFURLRef)[NSURL URLWithString:@"http://www.google.com"],
                                                                      (__bridge CFDictionaryRef)proxySettings);

    NSDictionary *settings = [proxies objectAtIndex:0];
    NSMutableDictionary *proxieDic = [NSMutableDictionary new];


    NSString *host =  [settings objectForKey:(NSString *)kCFProxyHostNameKey];
    NSString *type =  [settings objectForKey:(NSString *)kCFProxyTypeKey];
    if (!type)
    {
        [proxieDic setValue:@"" forKey:@"type"];
    }else
    {
        [proxieDic setValue:type forKey:@"type"];
    }

    if (!host)
    {
        [proxieDic setValue:@"0.0.0.0" forKey:@"host"];
    }else
    {
        [proxieDic setValue:host forKey:@"host"];
    }


//    NSLog(@"port=%@", [settings objectForKey:(NSString *)kCFProxyPortNumberKey]);

    return  proxieDic;
//    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"])
//    {
//        NSLog(@"没代理");
//    }
//    else
//    {
//        NSLog(@"设置了代理");
//    }
}
@end
