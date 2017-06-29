//
//  DBIDentifierInfo.h
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/9.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBIDentifierInfo : NSObject
/**
 *  IDFV
 *
 *  @return string
 */
+ (NSString *)getIDFV;

/**
 *  IDFA
 *
 *  @return string
 */
+ (NSString *)getIDFA;

/**
 *  UUID 存储在keychain
 *
 *  @return string
 */
+ (NSString *)getUUID;
@end
