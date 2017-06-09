//
//  DBBatteryInfo.m
//  DeviceInfo
//
//  Created by dengbin on 17/6/8.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBBatteryInfo.h"
#import <UIKit/UIKit.h>

@interface DBBatteryInfo ()

@property (nonatomic,strong)UIDevice *device;
@end

@implementation DBBatteryInfo
+ (instancetype)shareBatteryInfo {

    static DBBatteryInfo *internet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        internet = [[DBBatteryInfo alloc] init];

    });
    return internet;
}
#pragma mark - 电量

//电量 如：0.8
- (NSString *)batteryLevel
{
    self.device.batteryMonitoringEnabled = true;

    CGFloat batteryLevel = [self.device batteryLevel];
    self.device.batteryMonitoringEnabled = NO;

    return [NSString stringWithFormat:@"%lf",batteryLevel];
}
#pragma mark - 状态

- (NSString *)batteryState {
    switch (self.device.batteryState) {
        case UIDeviceBatteryStateFull:
            return @"充满";
            break;
        case UIDeviceBatteryStateUnknown:
            return @"未知";
            break;
        case UIDeviceBatteryStateCharging:
            return @"正在充电";
            break;
        case UIDeviceBatteryStateUnplugged:
            return @"未充电";
            break;
        default:
            return @"未知";
            break;
    }
}

#pragma mark -
- (UIDevice *)device {
    if (!_device) {
        _device = [UIDevice currentDevice];
    }
    return _device;
}
@end
