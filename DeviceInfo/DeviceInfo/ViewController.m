//
//  ViewController.m
//  DeviceInfo
//
//  Created by dengbin on 17/5/25.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "ViewController.h"
#import "DBTools.h"
#import "DBDeviceInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CFNetwork/CFNetwork.h>

#import "DBPermissions.h"
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>


//dns
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <resolv.h>
#include <dns.h>

@interface ViewController ()

@end

@implementation ViewController

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

-(NSString *)proxyName
{

    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();

    const CFStringRef proxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef,
                                                                           (const void*)kCFNetworkProxiesHTTPProxy);
    
    return  (__bridge NSString *)proxyCFstr;
    
}

- (NSString *) macaddress
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
- (NSString *)getDNSServers
{
    // dont forget to link libresolv.lib
    NSMutableString *addresses = [[NSMutableString alloc]initWithString:@"DNS Addresses \n"];

    res_state res = malloc(sizeof(struct __res_state));

    int result = res_ninit(res);

    if ( result == 0 )
    {
        for ( int i = 0; i < res->nscount; i++ )
        {
            NSString *s = [NSString stringWithUTF8String :  inet_ntoa(res->nsaddr_list[i].sin_addr)];
            [addresses appendFormat:@"%@\n",s];
            NSLog(@"%@",s);
        }
    }
    else
        [addresses appendString:@" res_init result != 0"];

    return addresses;
}
- (void)viewDidLoad {
    [super viewDidLoad];


    NSLog(@"nds-%@,,",[self getDNSServers]);

    NSLog(@"mac-%@,,",[self macaddress]);
    [DBDeviceInfo getIPAddress];
    [[DBDeviceInfo shareDeviceInfo] getIPAddresses];
    NSDictionary *proxySettings = (__bridge NSDictionary *)CFNetworkCopySystemProxySettings();

    NSArray *proxies = (__bridge NSArray *)CFNetworkCopyProxiesForURL(
                                                                      (__bridge CFURLRef)[NSURL URLWithString:@"http://www.google.com"],
                                                                      (__bridge CFDictionaryRef)proxySettings);

    NSDictionary *settings = [proxies objectAtIndex:0];
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

    [DBTools getIDFV];
    NSLog(@"%@",[self fetchSSIDInfo]);
    
//    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
//    NSURL *url =[NSURL URLWithString:@"http://www.google.com"];
// //  NSArray *proxies =  (__bridge NSArray *)CFNetworkCopyProxiesForURL((__bridge CFURLRef )url , proxySettings);
//    NSArray *proxies = (__bridge NSArray *)((__bridge CFTypeRef )((__bridge NSArray *)CFNetworkCopyProxiesForURL((__bridge CFURLRef)[NSURL URLWithString:@"http://www.google.com"], (CFDictionaryRef)proxySettings))) ;
//
//    NSDictionary *settings = [proxies objectAtIndex:0];
//    NSLog(@"host=%@", [settings objectForKey:(NSString *)kCFProxyHostNameKey]);
//    NSLog(@"port=%@", [settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
//    NSLog(@"type=%@", [settings objectForKey:(NSString *)kCFProxyTypeKey]);
//    NSLog(@"proxyName-%@",[self proxyName]);




    [[DBPermissions sharePermissions] getAddressBookState:^(BOOL isGranted) {
        NSLog(@"%d",isGranted);
    }];

  //  NSLog(@"%d",[DBDeviceInfo isDevice]);
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
