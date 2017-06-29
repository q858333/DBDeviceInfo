//
//  DBSIMInfo.h
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/9.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBCarrierInfo : NSObject

+ (instancetype)shareCarrierInfo;

/**
 *  运营商
 *
 *  @return string
 */
- (NSString *)getCarrierName;

/**
 *  ISO国家码
 *
 *  @return string
 */
- (NSString *)getISOCode;

/**
 *  sim卡网络状态
 *
 *  @return string 2G/3G/4G
 */
- (NSString *)getWWANState;


/**
 *  mcc
 *
 *  @return string
 */
- (NSString *)getMCC;

/**
 *  mnc
 *
 *  @return string
 */
- (NSString *)getMNC;

/**
 *  imsi
 *
 *  @return string
 */
- (NSString *)getIMSI;

@end
