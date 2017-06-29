//
//  DBProjectInfo.h
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/8.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBProjectInfo : NSObject

+ (instancetype)shareProjectInfo;



/**
 *  项目版本号
 *
 *  @return string
 */
- (NSString *)getProjectVersion;

/**
 *  bundle id
 *
 *  @return string
 */
- (NSString *)getBundleIdentifier;

@end
