//
//  DBNetWorkInfo.h
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/9.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, DBNetWorkInfoType) {
    DBNetWorkInfoTypeIPAddress = -1,
    DBNetWorkInfoTypeNetMask = 0,
    DBNetWorkInfoTypeNetwarkNames ,
};

@interface DBNetWorkInfo : NSObject

+ (instancetype)shareNetWorkInfo;



/**
 *  网络状态
 *
 *  WWAN,2G,3G,4G,WIFI,没网
 *
 *  @return string
 */
- (NSString *)networkType;

/**
 *  网络状态
 *
 *  IPAddress    :  IP地址
 *
 *  NetMask      :  子网掩码
 *
 *  NetworkNames :  网络接口列表
 *
 *  @return dictionary
 */
- (NSDictionary *)getNetWorkInfo;

/**
 *  MAC
 *
 *  @return string
 */
- (NSString *)getMacAddress;

/**
 *  DNS
 *
 *  182.18.32.18,114.114.114.114
 *
 *  @return string
 */
- (NSString *)getDNSServers;

/**
 *
 *  BSSID = "74:1f:4a:4c:2d:80";
 *  SSID = "Rkylin_C2_3"; //当前wifi名称
 *  SSIDDATA = <526b796c 696e5f43 325f33>;
 *
 *  @return dic
 */
- (id)fetchSSIDInfo;


/**
 *  代理ip和类型
 *  type,host
 *
 *  @return dic
 */
-(NSDictionary *)getProxieInfo;

@end
