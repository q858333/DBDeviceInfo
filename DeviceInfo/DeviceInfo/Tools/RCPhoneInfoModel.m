//
//  RCPhoneInfoModel.m
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/13.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "RCPhoneInfoModel.h"
#import "DBDeviceInfo.h"
#import "DBProjectInfo.h"
#import "DBCarrierInfo.h"
#import "DBBatteryInfo.h"
#import "DBStorageInfo.h"
#import "DBStorageInfo.h"
#import "DBIDentifierInfo.h"
#import "DBNetWorkInfo.h"
#import "DBJailBreak.h"
#import "DBLocationInfo.h"

#import "RCConfig.h"
#import <objc/runtime.h>

@interface RCPhoneInfoModel ()
{
   FinallyBlock _finallyBlock;

   NSString    *_startTime;

}


/** 操作系统的类型*/
@property(nonatomic,copy)NSString *os;

/** 当前充电状态  电池电量*/
@property(nonatomic,copy)NSString *batterystatus ,*batterylevel;

/** SDK版本*/
@property(nonatomic,copy)NSString *sdkversion;


/** BundleID*/
@property(nonatomic,copy)NSString *bundleid;


/** 手机OS版本*/
@property(nonatomic,copy)NSString *releaseversion;

/** 设备型号*/
@property(nonatomic,copy)NSString *model;

/** 设备名称*/
@property(nonatomic,copy)NSString *devicename;

/** 采集时的当前时间戳(毫秒)*/
@property(nonatomic,copy)NSString *currenttime;

/** 应用版本号*/
@property(nonatomic,copy)NSString *apkversion;

/** 从开机到目前的毫秒数，包括休眠时间   开机时刻的时间戳(毫秒)*/
@property(nonatomic,copy)NSString *uptime, *boottime;

/** 当前时区*/
@property(nonatomic,copy)NSString *timezone;

/** 当前配置的语言*/
@property(nonatomic,copy)NSString *language;

/** 当前屏幕亮度*/
@property(nonatomic,copy)NSString *brightness;

/** 底层Linux内核版本*/
@property(nonatomic,copy)NSString *kernelversion;

/** SIM卡的ISO标准国家码*/
@property(nonatomic,copy)NSString *countryiso;

/** 当前网络的运营商*/
@property(nonatomic,copy)NSString *carrier;


/** 移动国家码  移动网络码*/
@property(nonatomic,copy)NSString *mcc,*mnc,*imsi;

/** 总存储空间字节数 可用存储空间字节数  */
@property(nonatomic,copy)NSString *totalstorage,*availablestorage;

/** 总内存字节数*/
@property(nonatomic,copy)NSString *totalmemory;

/** IDFA IDFV UUID*/
@property(nonatomic,copy)NSString *idfa,*idfv,*uuid;

/** 是否越狱*/
@property(nonatomic,copy)NSString *root;


/** ssid:当前连接的无线网络名称  BSSID*/
@property(nonatomic,copy)NSString *ssid, *bssid;

/** 无线网卡的mac地址*/
@property(nonatomic,copy)NSString *wifimac;

/** 当前活动网络的DNS地址*/
@property(nonatomic,copy)NSString *dnsaddress;

/**网络连接类型  2G/3G/4G网络连接的本地IP地址   无线网ip*/
@property(nonatomic,copy)NSString *networktype, *cellip, *wifiip;

/** 无线网络的子网掩码*/
@property(nonatomic,copy)NSString *wifinetmask;

/** 网络接口列表*/
@property(nonatomic,copy)NSString *networknames;


/** 代理类型   代理地址*/
@property(nonatomic,copy)NSString *proxytype, *proxyurl;


/** 定位开关    定位授权状态*/
@property(nonatomic,copy)NSString *gpsswitch, *gpsauthstatus;



///** 采集设备信息所用的耗时*/
@property(nonatomic,copy)NSString *costTime;

/** 设备ID*/
@property(nonatomic,copy)NSString *deviceid;

/** 设备是否虚拟机*/
@property(nonatomic,copy)NSString *devicevirtual;




@end

@implementation RCPhoneInfoModel


- (instancetype)init
{
    self = [super init];
    if (self) {


    }
    return self;
}


- (void)configDataWithFinallyBlock:(FinallyBlock)block
{


    _finallyBlock=block ;

    self.currenttime = [[DBDeviceInfo shareDeviceInfo] currentTime];//时间戳 毫秒

    self.os = @"iOS"; //系统

   self.deviceid = @"";

    self.sdkversion = SDK_VERSION; // sdk 版本

    if([DBJailBreak isJailBreak])
    {
        self.root = @"true";//是否越狱
    }else
    {
        self.root = @"false";
    }



    [self deviceInfo];

    [self projectInfo];

    [self batteryInfo];

    [self carrierInfo];

    [self storageInfo];

    [self identifierInfo];

    [self networkInfo];
    [self locationInfo];



    
    

}


#pragma mark - 信息获取
- (void)locationInfo
{
    DBLocationInfo *locationInfo = [DBLocationInfo currentLocation];

    self.gpsswitch = [NSString stringWithFormat:@"%d",[locationInfo getLocationEnabled]];


   CLAuthorizationStatus status = [locationInfo getLocationState];
    self.gpsauthstatus = [NSString stringWithFormat:@"%d",status];
//    if (status == kCLAuthorizationStatusNotDetermined) {
//        self.gpsAuthStatus = @"NotDetermined";
//    }else if (status == kCLAuthorizationStatusRestricted){
//        self.gpsAuthStatus = @"Restricted";
//    }else if (status == kCLAuthorizationStatusDenied){
//        self.gpsAuthStatus = @"Denied";
//    }else if (status == kCLAuthorizationStatusAuthorizedAlways){
//        self.gpsAuthStatus = @"Always";
//    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
//        self.gpsAuthStatus = @"WhenInUse";
//    }else if (status == kCLAuthorizationStatusAuthorized)
//    {
//        self.gpsAuthStatus = @"Authorized";
//        if(IOS_VERSION >= 8.0)
//        {
//            self.gpsAuthStatus = @"Always";
//        }
//        
//    }else{
//        self.gpsAuthStatus= @"unkonwn";
//    }

    WS(weakSelf)
    
    [[DBLocationInfo currentLocation] getCurrentLocation:^(NSDictionary *location, NSString *desc) {
        if ([desc isEqualToString:@"定位成功"])
        {//Province,City
            NSString *province = location[@"Province"];
            NSString *city = location[@"City"];
            if (province.length == 0 || city.length == 0)
            {

            }
            else
            {

                weakSelf.gpslocation = [NSString stringWithFormat:@"%@,%@",province,city];
            }


        }
        
        weakSelf.costTime = [weakSelf getCostTime];


        dispatch_async(dispatch_get_main_queue(), ^{
            if (_finallyBlock)
            {
                _finallyBlock();
                _finallyBlock = nil;

            }

            
        });

    //    NSLog(@"%@,%@--%@",location,desc,self.initTime);
        
    }];



}

- (void)networkInfo
{
    DBNetWorkInfo *networkInfo = [DBNetWorkInfo shareNetWorkInfo];

    //*  BSSID = "74:1f:4a:4c:2d:80";
    // *  SSID = "Rkylin_C2_3";
    NSDictionary *ssidDic = [networkInfo fetchSSIDInfo];

    self.ssid = ssidDic[@"SSID"]; //当前wifi名称
    self.bssid = ssidDic[@"BSSID"];


    self.wifimac = [networkInfo getMacAddress];

    self.dnsaddress = [networkInfo getDNSServers];

    NSDictionary *netDic = [networkInfo getNetWorkInfo];//IPAddress  NetMask  NetworkNames
    self.cellip = netDic[@"IPAddress"];
    self.wifiip = netDic[@"IPAddress"];
    self.wifinetmask = netDic[@"NetMask"];


    NSMutableString *mutableNamesString = [[NSMutableString alloc] init];

    for (NSString *string in netDic[@"NetworkNames"])
    {
        [mutableNamesString appendFormat:@"%@,",string];

    }

    [mutableNamesString deleteCharactersInRange:NSMakeRange(mutableNamesString.length-1, 1)];

   self.networknames = mutableNamesString;


    self.networktype = [networkInfo networkType];//网络类型

    //type,host
    NSDictionary *proxiesDic= [networkInfo getProxieInfo];
    self.proxytype = proxiesDic[@"type"];
    self.proxyurl = proxiesDic[@"host"];

}

- (void)identifierInfo
{
    self.uuid = [DBIDentifierInfo getUUID];
    self.idfa = [DBIDentifierInfo getIDFA];
    self.idfv = [DBIDentifierInfo getIDFV];
}
- (void)storageInfo
{
    DBStorageInfo *storageInfo = [DBStorageInfo shareStorageInfo];

    self.totalmemory = [storageInfo getMemoryTotal];

    self.totalstorage = [storageInfo getDiskTotalSize];

    self.availablestorage = [storageInfo getDiskFreeSize];

}

- (void)projectInfo
{
    DBProjectInfo *projectInfo = [DBProjectInfo shareProjectInfo];

    self.bundleid = [projectInfo getBundleIdentifier];//bundle id

    self.apkversion = [projectInfo getProjectVersion]; // app版本号

}

- (void)batteryInfo
{
    DBBatteryInfo *batteryInfo = [DBBatteryInfo shareBatteryInfo];

    self.batterylevel = [batteryInfo batteryLevel];

    self.batterystatus = [batteryInfo batteryState];

}

- (void)deviceInfo
{
    DBDeviceInfo  *deviceInfo = [DBDeviceInfo shareDeviceInfo];

    self.releaseversion = [deviceInfo getSystemVersion]; //手机系统 : 8.0.0

    self.model = [deviceInfo getDeviceModel];//设备型号 :iphone 4s

    self.devicename = [deviceInfo getCurrentDeviceName];//设备名称 : **的iPhone

    self.uptime = [deviceInfo deviceUptime]; // 设备运行时间

    self.boottime = [deviceInfo bootTime]; // 开机时刻

    self.timezone = [deviceInfo getZoneGMT]; // 时区

    self.language = [deviceInfo getCurrentLanguage]; // 当前语言环境

    self.brightness = [deviceInfo getScreenBrightness]; // 亮度

    self.kernelversion = [deviceInfo getDarwinBuildDescription];// 内核信息

    self.devicevirtual = [deviceInfo isSimulator];

}

- (void)carrierInfo
{
    DBCarrierInfo *carrierInfo = [DBCarrierInfo shareCarrierInfo];

    self.countryiso = [carrierInfo getISOCode]; //sim卡 国家码

    self.carrier = [carrierInfo getCarrierName]; //运营商 ：移动

    self.mnc = [carrierInfo getMNC];

    self.mcc = [carrierInfo getMCC];

    self.imsi = [carrierInfo getIMSI];

}





#pragma mark - 属性->json


//获取对象的所有属性
- (NSArray *)getAllProperties
{
    u_int count;
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}

//Model 到字典
- (NSMutableDictionary *)properties_jsonDictionary
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];

        if(propertyValue)
        {
            [props setObject:propertyValue forKey:propertyName];
        }
        else
        {
            [props setObject:@"" forKey:propertyName];
        }
    }
    free(properties);
    if (_costTime)
    {
        [props setObject:_costTime forKey:@"inittime"];
    }else
    {
        [props setObject:[self getCostTime] forKey:@"inittime"];
    }

    return props;
}

#pragma mark - tools

- (NSString *)getCostTime
{
    long long costTime = [[[DBDeviceInfo shareDeviceInfo] currentTime] longLongValue] - [self.currenttime longLongValue];

    return [NSString stringWithFormat:@"%llu",costTime];

}

-(NSString *)getDateFormatterString{


    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"yyyyMMdd HHmmss"];

    return [formatter stringFromDate:[NSDate new]];
    
}



@end
