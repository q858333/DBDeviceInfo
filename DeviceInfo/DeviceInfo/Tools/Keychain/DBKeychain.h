//
//  DBKeychain.h
//  DeviceInfo
//
//  Created by dengbin on 17/6/7.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBKeychain : NSObject
///重装app值不会变，只有重置系统会发生变化，adiv存在钥匙串中
+ (NSString *)getUUID;

@end
