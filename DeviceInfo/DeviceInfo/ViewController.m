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
#import <CoreLocation/CoreLocation.h>

#import "DBPermissions.h"
#import "DBKeychain.h"
//cpu
#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/machine.h>

#import "DBInternetInfo.h"

#import "DBDeviceModel.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <NetworkExtension/NEVPNManager.h>
@interface ViewController ()
{
    CLLocationManager *_locationManager;

}

@end

@implementation ViewController



-(NSString *)proxyName
{



    

    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();

    const CFStringRef proxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef,
                                                                           (const void*)kCFNetworkProxiesHTTPProxy);
    
    return  (__bridge NSString *)proxyCFstr;
    
}




- (NSString *)getHardParam  // 返回CPU类型
{
    NSMutableString *cpu = [[NSMutableString alloc] init];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);

    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);

    // values for cputype and cpusubtype defined in mach/machine.h
    if (type == CPU_TYPE_X86)
    {
        [cpu appendString:@"x86 "];
        // check for subtype ...

    } else if (type == CPU_TYPE_ARM)
    {
        [cpu appendString:@"ARM"];
        [cpu appendFormat:@",Type:%d",subtype];
    }
    return cpu;
}
- (NSString *) getSysInfoByName:(char *)typeSpecifier

{

    size_t size;

    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);

    char *answer = malloc(size);

    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);

    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    free(answer);

    return results;
}


- (void)viewDidLoad {
    [super viewDidLoad];

   // [[DBPermissions sharePermissions] getMediaState];
        //connection type

        
    NEVPNManager *vpnManager = [NEVPNManager sharedManager];
    NSLog(@"vpnManager.localizedDescription---%@",vpnManager.localizedDescription);

    [[DBInternetInfo shareInternetInfo] getProxieInfo];
    
    NSLog(@"getAppIPAddress--%@",[[DBInternetInfo shareInternetInfo] getAppIPAddress:YES]);
    NSLog(@"%@",[[DBDeviceInfo shareDeviceInfo] currentTime]);

    DBDeviceModel *model = [[DBDeviceModel alloc]init];
    model.name=@"123";
    [DBKeychain getUUID];
    NSLog(@"%@",[model properties_jsonDictionary]);
    //    NSDictionary *version = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
//    NSString *productVersion = [version objectForKey:@"ProductVersion"];

    NSLog(@"proxyName-%@",[self proxyName]);
//    NSDictionary *dic = [[NSProcessInfo processInfo] environment];
//    NSString *buildConfiguration = dic[@"BUILD_CONFIGURATION"];


   
    //语言列表
    NSArray *localeIdentifiers = [NSLocale availableLocaleIdentifiers];





    





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
