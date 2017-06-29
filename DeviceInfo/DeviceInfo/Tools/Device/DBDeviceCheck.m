//
//  DBDeviceCheck.m
//  DeviceInfo
//
//  Created by dengbin on 17/6/29.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBDeviceCheck.h"
#import <CoreMotion/CoreMotion.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>

@implementation DBDeviceCheck




//检查录像支持 MobileCoreServices.framework <MobileCoreServices/MobileCoreServices.h>
- (BOOL)isvideoCameraAvailable
{
    //简单检查所有的可用的媒体资源类型，然后检查返回的数组，如果其中包含了kUTTypeMovie的NSString类型对象，就证明摄像头支持录像
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];//返回所支持的media的类型数组

    if (![sourceTypes containsObject:(NSString *)kUTTypeMovie]) {//containsObject确定数组中是否包含后面的对象
        return NO;
    }
    return YES;
}

//检查陀螺仪可用 CoreMotion.framework <CoreMotion/CoreMotion.h>
- (BOOL) isGyroscopeAvailable
{
#ifdef __IPHONE_4_0//4.0之后才有
    CMMotionManager *motionManager = [[CMMotionManager alloc]init];
    BOOL gyroscopeAvailable = motionManager.gyroAvailable;
    return gyroscopeAvailable;
#else
    return NO;
#endif
}
@end
