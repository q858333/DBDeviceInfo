//
//  DBStorageInfo.h
//  DeviceInfo
//
//  Created by dengbin on 17/6/9.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBStorageInfo : NSObject

+ (instancetype)shareStorageInfo;

/**
 *  已使用大小 单位B
 *
 *  @return string
 */
- (NSString *)getDiskUsed;

/**
 *  空闲大小 单位B
 *
 *  @return string
 */
- (NSString *)getDiskFreeSize;

/**
 *  总共 单位B
 *
 *  @return string
 */
- (NSString *)getDiskTotalSize;

/**
 *  内存大小 单位B
 *
 *  @return string
 */
- (NSString *)getMemoryTotal;

@end
