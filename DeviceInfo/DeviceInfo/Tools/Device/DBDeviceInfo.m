//
//  DBDeviceInfo.m
//  DeviceInfo
//
//  Created by dengbin on 17/5/25.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBDeviceInfo.h"

//dns


#import "sys/utsname.h"
#import <net/if.h>







@interface DBDeviceInfo ()

@property (nonatomic,strong)UIDevice *device;

@property (nonatomic,strong)NSDictionary *utsNameDic;

@end

@implementation DBDeviceInfo



+ (instancetype)shareDeviceInfo {

    static DBDeviceInfo *deviveInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        deviveInfo = [[DBDeviceInfo alloc] init];

    });
    return deviveInfo;
}



#pragma mark - 亮度

- (NSString *)getScreenBrightness
{

    CGFloat currentLight = [[UIScreen mainScreen] brightness];

    return [NSString stringWithFormat:@"%0.0lf",currentLight*100];
}

#pragma mark - 是否真机

- (NSString *)isSimulator
{


#if TARGET_IPHONE_SIMULATOR
    return @"true";
#else
    //不定义SIMULATOR_TEST这个宏
    return @"false";
#endif
}






#pragma mark - 设备型号

// 获取设备型号然后手动转化为对应名称
- (NSString *)getDeviceModel
{
    
    NSString *deviceString = self.utsNameDic[kMachine];;

    return deviceString;
}

#pragma mark - 版本
//-----8.0.1
- (NSString *)getSystemVersion {
    return [self.device systemVersion];
}

#pragma mark - 设备名称
//-----** iphone
- (NSString *)getCurrentDeviceName {
    return [self.device name];
}
#pragma mark - 开机时间
//当前时间
- (NSString *)currentTime
{
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;

    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];

    NSString *currentTime = [NSString stringWithFormat:@"%llu",theTime];

    return currentTime;
}

//运行时间
-(NSString *)deviceUptime
{
    NSProcessInfo *info = [NSProcessInfo processInfo];


    NSDate *now = [NSDate date];

    NSTimeInterval interval = [now timeIntervalSince1970]-info.systemUptime;

    return [NSString stringWithFormat:@"%lf",interval*1000 - info.systemUptime*1000];//[self getDateStrFromTimeStep:interval - info.systemUptime];
}
//开机时间
-(NSString *)bootTime
{
    NSProcessInfo *info = [NSProcessInfo processInfo];

    return [NSString stringWithFormat:@"%lf",info.systemUptime*1000];
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

-(NSString *)getDateFormatterString{


    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString *dateString =  [formatter stringFromDate:[NSDate new]];
    return dateString;
    
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

#pragma mark -
- (UIDevice *)device {
    if (!_device) {
        _device = [UIDevice currentDevice];
    }
    return _device;
}
@end
