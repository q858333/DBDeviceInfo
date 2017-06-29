//
//  DBDeviceInfo.h
//  DeviceInfo
//
//  Created by dengbin on 17/5/25.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBDeviceInfo : NSObject
/**
 *  获取对象
 */
+ (instancetype )shareDeviceInfo ;

/**
 *  设备型号
 *
 *  @return string  --->:iphone ipad
 */
- (NSString *)getDeviceModel;

/**
 *  系统版本
 *
 *  @return string  --->:8.0.1
 */
- (NSString *)getSystemVersion;

/**
 *  手机名称
 *
 *  @return string
 */
- (NSString *)getCurrentDeviceName;





/**
 *  模拟器或者真机
 *
 *  @return string
 */
- (NSString *)isSimulator;

/**
 *  内核信息
 *
 *  @return string
 */
- (NSString *)getDarwinBuildDescription;


/**
 *  当前时间yyyyMMdd HHmmss
 *
 *  @return string
 */
-(NSString *)getDateFormatterString;
/**
 *  时区
 *
 *  @return string
 */
-(NSString *)getZoneGMT;

/**
 *  语言环境
 *
 *  @return string
 */
- (NSString *)getCurrentLanguage;

/**
 *  得到屏幕亮度
 *
 *  @return string 0-1
 */
- (NSString *)getScreenBrightness;


/**
 * systemUptime 开机运行时间 单位毫秒
 *
 *  @return string
 */
-(NSString *)deviceUptime;

/**
 *  currentTime 当前时间 单位毫秒
 *
 *  @return string
 */
-(NSString *)currentTime;

/**
 *  bootTime  开机时间 单位毫秒
 *
 *  @return string
 */
-(NSString *)bootTime;

@end
