//
//  DBDeviceInfo.h
//  DeviceInfo
//
//  Created by dengbin on 17/5/25.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBDeviceInfo : NSObject
+ (instancetype)shareDeviceInfo ;

//开机时间
-(NSString *)systemUptime;

//是否越狱
- (BOOL)isJailBreak;
- (BOOL)isDevice;
-(NSDictionary *)getIPAddresses;
-(NSString *)getIPAddress;
//内核信息
- (NSString *)getDarwinBuildDescription ;


- (NSString *)getIMSI;

/**
 *  systemUptime 开机运行时间
 *  currentTime  当前时间
 *  bootTime     开机时间
 *
 *  @return string
 */

-(NSString *)systemUptime;  //
-(NSString *)currentTime;
-(NSString *)bootTime;

@end
