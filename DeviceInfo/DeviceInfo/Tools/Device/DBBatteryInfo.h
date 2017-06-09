//
//  DBBatteryInfo.h
//  DeviceInfo
//
//  Created by dengbin on 17/6/8.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBBatteryInfo : NSObject

+ (instancetype)shareBatteryInfo;

/**
 *  电量
 *
 *  @return 0-1
 */
- (NSString *)batteryLevel;

/**
 *   充电状态
 *
 *  @return 未知，正在充电，未充电，充满
 */
- (NSString *)batteryState;


@end
