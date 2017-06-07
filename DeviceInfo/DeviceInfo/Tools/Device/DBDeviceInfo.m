//
//  DBDeviceInfo.m
//  DeviceInfo
//
//  Created by dengbin on 17/5/25.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBDeviceInfo.h"

//dns
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <resolv.h>
#include <dns.h>

#import "sys/utsname.h"
#import <net/if.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <CFNetwork/CFNetwork.h>


#import <AdSupport/AdSupport.h>
#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};


@interface DBDeviceInfo ()
@property (nonatomic,strong)NSDictionary *utsNameDic;

@end

@implementation DBDeviceInfo

//亮度 CGFloat currentLight = [[UIScreen mainScreen] brightness];

+(BOOL)isDevice
{

#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    //不定义SIMULATOR_TEST这个宏
    return YES;
#endif
}

+ (DBDeviceInfo *)shareDeviceInfo {

    static DBDeviceInfo *deviveInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        deviveInfo = [[DBDeviceInfo alloc] init];

    });
    return deviveInfo;
}
//是否越狱
+ (BOOL)isJailBreak
{
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            NSLog(@"The device is jail broken!");
            return YES;
        }
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}
//- (BOOL)isJailBreak
//{
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
//        NSLog(@"The device is jail broken!");
//        return YES;
//    }
//    NSLog(@"The device is NOT jail broken!");
//    return NO;
//}
//char* printEnv(void)
//{
//    charchar *env = getenv("DYLD_INSERT_LIBRARIES");
//    NSLog(@"%s", env);
//    return env;
//}
//
//- (BOOL)isJailBreak
//{
//    if (printEnv()) {
//        NSLog(@"The device is jail broken!");
//        return YES;
//    }
//    NSLog(@"The device is NOT jail broken!");
//    return NO;
//}


#pragma mark - 获取相机权限
- (void)getMediaState
{

    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {

                // 用户第一次同意了访问相机权限

            } else {

                // 用户第一次拒绝了访问相机权限
            }
        }];
    } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机


    } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机


    } else if (status == AVAuthorizationStatusRestricted) {
     //未授权，且用户无法更新，如家长控制情况下
    }
    
}
#pragma mark - 电量

//电量 如：0.8
-(NSString *)batteryLevel
{
    [UIDevice currentDevice].batteryMonitoringEnabled = true;

    CGFloat batteryLevel = [[UIDevice currentDevice] batteryLevel];
    [UIDevice currentDevice].batteryMonitoringEnabled = NO;

    return [NSString stringWithFormat:@"%lf",batteryLevel];
}

#pragma mark - 设备型号

// 获取设备型号然后手动转化为对应名称
- (NSString *)getDeviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";

    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";

    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";

    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}


#pragma mark - 开机时间
-(NSString *)systemUptime
{
    NSProcessInfo *info = [NSProcessInfo processInfo];

    NSLog(@"%f", info.systemUptime);

    NSDate *now = [NSDate date];

    NSTimeInterval interval = [now timeIntervalSince1970];

    return [self getDateStrFromTimeStep:interval - info.systemUptime];
}

-(NSString *)getDateStrFromTimeStep:(long long)timestep{

    NSDate *timestepDate = [NSDate dateWithTimeIntervalSince1970:timestep];

    //1377044552->2013-08-21 08:22:32

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    //NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];

    NSTimeZone* timeZone = [NSTimeZone systemTimeZone];

    [formatter setTimeZone:timeZone];



    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];



    return [formatter stringFromDate:timestepDate];
    
}

#pragma mark - IMSI
//#import <CoreTelephony/CTCarrier.h>
//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
- (NSString *)getIMSI{

    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSLog(@"carrier----%@",carrier);

    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];

    NSString *imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];

    return imsi;
}
#pragma mark - 语言环境
- (NSString *)getCurrentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return currentLanguage;

}
#pragma mark - 时区代码
-(NSString *)getZoneGMT
{
    // 获取所有已知的时区名称
  //  NSArray *zoneNames = [NSTimeZone knownTimeZoneNames];
    // NSTimeZone *zone = [NSTimeZone systemTimeZone]; // 获得系统的时区

    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSLog(@"%@",zone);
    // 获取指定时区的名称
 //   NSString *strZoneName = [zone name];

    return [NSString stringWithFormat:@"%ld",[zone secondsFromGMT]];
}

static NSString * const kMachine = @"machine";
static NSString * const kNodeName = @"nodename";
static NSString * const kRelease = @"release";
static NSString * const kSysName = @"sysname";
static NSString * const kVersion = @"version";

- (NSDictionary *)utsNameDic {
    if (!_utsNameDic) {
        struct utsname systemInfo;
        uname(&systemInfo);
        _utsNameDic = @{kSysName:[NSString stringWithCString:systemInfo.sysname encoding:NSUTF8StringEncoding],kNodeName:[NSString stringWithCString:systemInfo.nodename encoding:NSUTF8StringEncoding],kRelease:[NSString stringWithCString:systemInfo.release encoding:NSUTF8StringEncoding],kVersion:[NSString stringWithCString:systemInfo.version encoding:NSUTF8StringEncoding],kMachine:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]};
    }
    return _utsNameDic;
}
- (NSString *)getDarwinBuildDescription {
    return self.utsNameDic[kVersion];
}
@end
