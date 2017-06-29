//
//  DBPermissions.h
//  DeviceInfo
//
//  Created by dengbin on 17/6/5.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum : NSUInteger {
    DBPermissionsStateClose = 0,
    DBPermissionsStateOpen = 1,
    DBPermissionsStateUnknown,
} DBPermissionsState;

typedef void(^PermissionStateBlock)(DBPermissionsState state);

@interface DBPermissions : NSObject
{
    CLLocationManager *_locationManager;

}
+ (DBPermissions *)sharePermissions;

/**
 *   通讯录状态
 */
- (void )getAddressBookState:(PermissionStateBlock)block;
/**
 *   相机状态
 */
- (void )getMediaState:(PermissionStateBlock)block;
/**
 *   定位状态
 */
- (DBPermissionsState )getLocationState;


@end
