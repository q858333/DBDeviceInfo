//
//  DBSIMInfo.m
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/9.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBCarrierInfo.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface DBCarrierInfo ()

@property (nonatomic,strong)CTCarrier *simCarrier;
@end


@implementation DBCarrierInfo


+ (instancetype)shareCarrierInfo {

    static DBCarrierInfo *simInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        simInfo = [[DBCarrierInfo alloc] init];

    });
    return simInfo;
}




#pragma mark - 运行商

- (NSString *)getCarrierName{



    NSString *carrierName = [self.simCarrier carrierName];


    return carrierName;
}


#pragma mark - iso国家码

- (NSString *)getISOCode{

    NSString *carrierName = [self.simCarrier isoCountryCode];

    return carrierName;
}


#pragma mark - MCC

- (NSString *)getMCC{


    NSString *mcc = [self.simCarrier mobileCountryCode];


    return mcc;
}

#pragma mark - MNC

- (NSString *)getMNC{



    NSString *mnc = [self.simCarrier mobileNetworkCode];


    return mnc;
}
#pragma mark - IMSI

- (NSString *)getIMSI{



    NSString *mcc = [self getMCC] ?[self getMCC]:@"";
    NSString *mnc = [self getMNC] ?[self getMNC]:@"";




    NSString *imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];

    return imsi;
}

- (NSString *)getWWANState
{
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];

    if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
        return @"2G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
        return @"2G";
    }else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        return @"2G";
    }  else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        return @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        return @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        return @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        return @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        return @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        return @"3G";
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        return @"3G";

    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        return @"4G";
    }else
    {
        return @"WWAN";
    }
}

#pragma mark - Lazy load
//        Carrier name: [中国移动]
//        Mobile Country Code: [460]
//        Mobile Network Code:[00]
//        ISO Country Code:[cn]
//        Allows VOIP? [YES]

- (CTCarrier *)simCarrier{
    if (!_simCarrier) {
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        _simCarrier = [info subscriberCellularProvider];

    }
    return _simCarrier;
}
@end
