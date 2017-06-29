//
//  DBLocationInfo.h
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/12.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^GetLocationBlock) (NSDictionary *location,NSString *desc);

@interface DBLocationInfo : NSObject
@property (nonatomic,copy)GetLocationBlock blockLocation;

+ (instancetype)currentLocation;


- (void)getCurrentLocation:(GetLocationBlock)block;

- (int)getLocationState;

- (BOOL)getLocationEnabled;


@end
