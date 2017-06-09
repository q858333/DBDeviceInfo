//
//  DBInternet.h
//  DeviceInfo
//
//  Created by dengbin on 17/6/7.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBInternetInfo : NSObject
+ (instancetype)shareInternetInfo;
-(void)getProxieInfo;
- (NSString *)getMacAddress;
-(NSString *)getIPAddress;

@end
