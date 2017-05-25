//
//  DBDeviceInfo.h
//  DeviceInfo
//
//  Created by dengbin on 17/5/25.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBDeviceInfo : NSObject
+ (DBDeviceInfo *)shareDeviceInfo ;

//开机时间
-(NSString *)systemUptime;


@end
