//
//  DBJailBreak.h
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/8.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBJailBreak : NSObject
/**
 *  是否越狱
 *
 *  @return YES表示已经越狱，NO表示没有越狱
 */
+ (BOOL)isJailBreak;

@end
