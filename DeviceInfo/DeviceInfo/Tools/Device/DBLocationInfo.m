//
//  DBLocationInfo.m
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/12.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBLocationInfo.h"
#import <UIKit/UIKit.h>
#import "RCConfig.h"
@interface DBLocationInfo ()<CLLocationManagerDelegate>

@property (nonatomic,strong)CLLocationManager *locationManager;
@property (nonatomic,unsafe_unretained)BOOL    startUpdatingLocation;

@end
@implementation DBLocationInfo

+ (instancetype)currentLocation {
    static DBLocationInfo *locationInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationInfo = [[self alloc] init];
    });
    return locationInfo;
}



- (void)getCurrentLocation:(GetLocationBlock)block {
    self.blockLocation = block;
    _startUpdatingLocation = YES;


    int state = [self getLocationState];

    if ([self getLocationEnabled])
    {

        if (state > 2 || state == 0)
        {
            //请求权限
            if (IOS_VERSION >= 8.0)
            {
                NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
                //判断用户填写了哪个授权信息
                if (infoDic[@"NSLocationWhenInUseUsageDescription"]) {
                    [self.locationManager requestAlwaysAuthorization];//只在前台开启定位
                }else if (infoDic[@"NSLocationAlwaysUsageDescription"]) {
                    [self.locationManager requestWhenInUseAuthorization];//在后台也可定位
                }else {
                }


            }

            self.locationManager.delegate = self;
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            [self.locationManager startUpdatingLocation];
        }
        else
        {
            if (self.blockLocation) {
                self.blockLocation(nil,@"定位失败");
                self.blockLocation = nil;
                
            }

        }


    }
    else
    {
        if (self.blockLocation) {
            self.blockLocation(nil,@"定位失败");
            self.blockLocation = nil;

        }

    }



    
}
- (BOOL)getLocationEnabled
{

    //定位服务是否可用
    BOOL enable=[CLLocationManager locationServicesEnabled];

    if (enable )
    {
        return YES;
    }
    
    return NO;
    
}

//一、第一个枚举值：kCLAuthorizationStatusNotDetermined的意思是：定位服务授权状态是用户没有决定是否使用定位服务。
//二、第二个枚举值：kCLAuthorizationStatusRestricted的意思是：定位服务授权状态是受限制的。可能是由于活动限制定位服务，用户不能改变。这个状态可能不是用户拒绝的定位服务。
//三、第三个枚举值：kCLAuthorizationStatusDenied的意思是：定位服务授权状态已经被用户明确禁止，或者在设置里的定位服务中关闭。
//四、第四个枚举值：kCLAuthorizationStatusAuthorizedAlways的意思是：定位服务授权状态已经被用户允许在任何状态下获取位置信息。包括监测区域、访问区域、或者在有显著的位置变化的时候。
//五、第五个枚举值：kCLAuthorizationStatusAuthorizedWhenInUse的意思是：定位服务授权状态仅被允许在使用应用程序的时候。
//六、第六个枚举值：kCLAuthorizationStatusAuthorized的意思是：这个枚举值已经被废弃了。他相当于
//kCLAuthorizationStatusAuthorizedAlways这个值。
- (int)getLocationState
{
    //是否具有定位权限
    int status=[CLLocationManager authorizationStatus];

    return status;

}



#pragma mark - lazy load
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];  //创建一个位置管理器
    }
    return _locationManager;
}
#pragma mark - CLLocationManageDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{

    if (_startUpdatingLocation)
    {
        CLLocation *currentLocation = newLocation;
        if (IOS_VERSION > 9.0 && IOS_VERSION < 10.0) {

            CLLocationCoordinate2D coordinate2D = gcj2wgs(CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude));

            CLLocation *wgsLocation = [[CLLocation alloc]initWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];

            currentLocation = wgsLocation;


        }
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];

        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
            if(error == nil && [placemarks count]>0)
            {
                CLPlacemark *placemark=[placemarks firstObject];

               // NSString * addName = placemark.addressDictionary[@"Name"];//详细

              //  NSString *country = placemark.addressDictionary[@"Country"];//国家
                NSString *province = placemark.addressDictionary[@"State"];//省
                NSString *city = placemark.addressDictionary[@"City"];//城市
               // NSString *district = placemark.addressDictionary[@"SubLocality"];//小城市
               // NSString *street = placemark.addressDictionary[@"Street"];//街道


                NSMutableDictionary *addressDic = [[NSMutableDictionary alloc]init];
               // [addressDic setObject:addName forKey:@"Address"];
             //   [addressDic setObject:country ? country:@"" forKey:@"Country"];
                [addressDic setObject:province ? province:@"" forKey:@"Province"];
                [addressDic setObject:city ? city:@"" forKey:@"City"];
              //  [addressDic setObject:district forKey:@"District"];
             //   [addressDic setObject:street forKey:@"Street"];
                NSString *lat = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];

                NSString *lon = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];

                [addressDic setObject:lat ? lat : @"0" forKey:@"lat"];
                [addressDic setObject:lon ? lon : @"0" forKey:@"lon"];


                //这里是将NSString转化为json类型,相信很多都会用到
             //   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:addressDic options:NSJSONWritingPrettyPrinted error:nil];
              //  NSString *jsonString  = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                if (self.blockLocation) {
                    self.blockLocation(addressDic,@"定位成功");
                    self.blockLocation = nil;

                }
            }
            else
            {

                if (self.blockLocation) {
                    self.blockLocation(nil,@"定位失败");
                    self.blockLocation = nil;

                }
            }
        }];
        [_locationManager stopUpdatingLocation];
        _startUpdatingLocation = NO;

    }



}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{

    if (self.blockLocation) {
        self.blockLocation(nil,@"定位失败");
        self.blockLocation = nil;

    }
    _locationManager = nil;

}

#pragma mark - GCJ->WGS  火星坐标转地球坐标

// 地球坐标系 (WGS-84) <- 火星坐标系 (GCJ-02)
CLLocationCoordinate2D gcj2wgs(CLLocationCoordinate2D coordinate) {
    if (outOfChina(coordinate)) {
        return coordinate;
    }
    CLLocationCoordinate2D c2 = wgs2gcj(coordinate);
    return CLLocationCoordinate2DMake(2 * coordinate.latitude - c2.latitude, 2 * coordinate.longitude - c2.longitude);
}

BOOL outOfChina(CLLocationCoordinate2D coordinate)
{
    if (coordinate.longitude < 72.004 || coordinate.longitude > 137.8347)
        return YES;
    if (coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271)
        return YES;
    return NO;
}
CLLocationCoordinate2D wgs2gcj(CLLocationCoordinate2D coordinate) {
    if (outOfChina(coordinate)) {
        return coordinate;
    }
    double wgLat = coordinate.latitude;
    double wgLon = coordinate.longitude;
    double dLat = transformLat(wgLon - 105.0, wgLat - 35.0);
    double dLon = transformLon(wgLon - 105.0, wgLat - 35.0);
    double radLat = wgLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    return CLLocationCoordinate2DMake(wgLat + dLat, wgLon + dLon);
}
const double a = 6378245.0;
const double ee = 0.00669342162296594323;
double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

static double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}
@end
