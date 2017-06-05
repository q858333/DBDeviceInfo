//
//  DBPermissions.h
//  DeviceInfo
//
//  Created by dengbin on 17/6/5.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^PermissionState)(BOOL isGranted);

@interface DBPermissions : NSObject
{
    CLLocationManager *_locationManager;

}
+ (DBPermissions *)sharePermissions;
- (void )getAddressBookState:(PermissionState)block;


@end
