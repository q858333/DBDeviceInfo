//
//  DBPermissions.m
//  DeviceInfo
//
//  Created by dengbin on 17/6/5.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBPermissions.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AVFoundation/AVMediaFormat.h>
#import <Photos/Photos.h>
#define IOS_VERSION         [[UIDevice currentDevice].systemVersion floatValue]

@implementation DBPermissions
+ (DBPermissions *)sharePermissions
{
    static DBPermissions *permissions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        permissions = [[DBPermissions alloc] init];

    });
    return permissions;
}

#pragma mark - 获取相机权限
- (BOOL)getMediaState {

    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {

        return NO;

    }else {

        return YES;
    }

}
//#pragma mark - 获取相机权限
//- (void)getMediaState
//{
//
//    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    if (status == AVAuthorizationStatusNotDetermined) {
//        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//            if (granted) {
//
//                // 用户第一次同意了访问相机权限
//
//            } else {
//
//                // 用户第一次拒绝了访问相机权限
//            }
//        }];
//    } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
//
//
//    } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
//
//
//    } else if (status == AVAuthorizationStatusRestricted) {
//        //未授权，且用户无法更新，如家长控制情况下
//    }
//    
//}

- (BOOL)getAlbumState {

    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusRestricted || authStatus ==PHAuthorizationStatusDenied) {

        return NO;

    }else {

        return YES;
    }
    
}
- (void)takePhoto {


    BOOL state =  [self getMediaState];

    if (state) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;//设置不可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //        [self presentViewController:picker animated:YES completion:nil];//进入照相界面
      //  [self presentViewController:picker animated:YES completion:nil];

    }else {
        //[[XRAppHelp shareAppHelp] showAlertViewWithSettingMsg:@"相机"];
    }
    
}
#pragma mark - 定位

-(void)getLocation
{
    // 1. 实例化定位管理器
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];

    }
    // 2. 设置代理
    _locationManager.delegate = self;
    // 3. 定位精度
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];



    UIDevice *device = [UIDevice currentDevice];

    //请求权限
    if ([device.systemVersion floatValue] >= 8)
    {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        //获取授权认证
        // [_locationManager requestAlwaysAuthorization];//只在前台开启定位
        [_locationManager requestWhenInUseAuthorization];//在后台也可定位
    }
    [_locationManager startUpdatingLocation];
    
}

- (BOOL)getLocationState
{

    //定位服务是否可用
    BOOL enable=[CLLocationManager locationServicesEnabled];
    //是否具有定位权限
    int status=[CLLocationManager authorizationStatus];


    if (enable && status>2)
    {

        return YES;
    }else
    {
        if(status == 0)
        {
            [self getLocation];
        }
        
        
    }
    
    return NO;
    
}
#pragma mark - CLLocationManageDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{


        CLLocation *currentLocation = newLocation;
        CLGeocoder *geoCoder = [CLGeocoder new];
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

                NSString *country = placemark.addressDictionary[@"Country"];//国家
                NSString *province = placemark.addressDictionary[@"State"];//省
                NSString *city = placemark.addressDictionary[@"City"];//城市
                // NSString *district = placemark.addressDictionary[@"SubLocality"];//小城市
                // NSString *street = placemark.addressDictionary[@"Street"];//街道


                NSMutableDictionary *addressDic = [[NSMutableDictionary alloc]init];
                // [addressDic setObject:addName forKey:@"Address"];
                [addressDic setObject:country ? country:@"" forKey:@"Country"];
                [addressDic setObject:province ? province:@"" forKey:@"Province"];
                [addressDic setObject:city ? city:@"" forKey:@"City"];
                //  [addressDic setObject:district forKey:@"District"];
                //   [addressDic setObject:street forKey:@"Street"];
                NSString *lat = [NSString stringWithFormat:@"%lld",currentLocation.coordinate.latitude];
                NSString *lon = [NSString stringWithFormat:@"%lld",currentLocation.coordinate.longitude];

                [addressDic setObject:lat ? lat : @"0" forKey:@"lat"];
                [addressDic setObject:lon ? lon : @"0" forKey:@"lon"];
            }

            }];
                //这里是将NSString转化为json类型,相信很多都会用到
                //   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:addressDic options:NSJSONWritingPrettyPrinted error:nil];
                //  NSString *jsonString  = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        [_locationManager stopUpdatingLocation];





}



#pragma mark - GCJ->WGS  火星坐标转地球坐标

const double a = 6378245.0;
const double ee = 0.00669342162296594323;
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




#pragma mark - 通讯录
- (void )getAddressBookState:(PermissionState)block;
{
    // 1.获取授权状态
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();

    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);

    if (status == kABAuthorizationStatusNotDetermined) {


            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
                if(granted){

                    //第一次提示 选择yes
                    [self getAddressBook];
                }else{

                }
                block(granted);


            });








    }else if (status == kABAuthorizationStatusAuthorized){
        [self getAddressBook];
        block(YES);

        // [self loadPerson];
    }else {
        block(NO);
        // 弹窗提示去获取权限
    }
    

}
- (NSString *)getAddressBook
{

    NSMutableArray *allPerson = [NSMutableArray new];
    NSMutableArray *addressBooks = [NSMutableArray new];

    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);

    //取得通讯录访问授权
    ABAuthorizationStatus authorization= ABAddressBookGetAuthorizationStatus();
    //如果未获得授权
    if (authorization!=kABAuthorizationStatusAuthorized) {
        return @"[]";
    }
    //取得通讯录中所有人员记录
    CFArrayRef allPeople= ABAddressBookCopyArrayOfAllPeople(addressBook);
    allPerson = (__bridge NSMutableArray *)allPeople;

    //释放资源
    CFRelease(allPeople);


    for ( int i =0 ;i<allPerson.count;i++)
    {
        NSMutableDictionary *dic = [NSMutableDictionary new];

        //取得一条人员记录
        ABRecordRef recordRef=(__bridge ABRecordRef)allPerson[i];
        //取得记录中得信息
        NSString *firstName=(__bridge NSString *) ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);//注意这里进行了强转，不用自己释放资源
        if (!firstName)
        {
            firstName=@"";
        }

        NSString *lastName=(__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
        if (!lastName)
        {
            lastName=@"";
        }
        //通过ABRecord 查找多值属性
        ABMultiValueRef emailProperty = ABRecordCopyValue(recordRef, kABPersonEmailProperty);
        //将多值属性的多个值转化为数组
        NSArray * emailArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(emailProperty));

        NSMutableArray *emails = [NSMutableArray new];
        for (int index = 0; index < emailArray.count; index++) {
            NSString *email = [emailArray objectAtIndex:index];
            [emails addObject:email];
            //      NSString *emailLabel = CFBridgingRelease(ABMultiValueCopyLabelAtIndex(emailProperty, index));
            //      //判断当前这个值得标签
            //      if ([emailLabel isEqualToString:(NSString *)kABWorkLabel]) {
            //        NSLog(@"%@", email);
            //      }
        }

        ABMultiValueRef phoneNumbersRef= ABRecordCopyValue(recordRef, kABPersonPhoneProperty);//获取手机号，注意手机号是ABMultiValueRef类，有可能有多条
        // NSArray *phoneNumbers=(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneNumbersRef);//取得CFArraryRef类型的手机记录并转化为NSArrary
        long count= ABMultiValueGetCount(phoneNumbersRef);
        // for(int i=0;i<count;++i){
        // NSString *phoneLabel= (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(phoneNumbersRef, i));
        // NSString *phoneNumber=(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbersRef, i));
        // NSLog(@"%@:%@",phoneLabel,phoneNumber);
        // }

        NSMutableArray *phones = [NSMutableArray new];
        for (int x = 0; x<count; x++)
        {
            NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbersRef, x));
            [phones addObject:phone];
        }

        [dic setObject:emails forKey:@"email"];
        [dic setObject:phones forKey:@"mobile"];
        [dic setObject:lastName forKey:@"lastname"];
        [dic setObject:firstName forKey:@"firstname"];
        [addressBooks addObject:dic];

    }

    return [self ObjectTojsonString:addressBooks];

}


-(NSString*)ObjectTojsonString:(id)object
{


    NSString *jsonString = [[NSString alloc]init];

    NSError *error;


    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];


    if (!jsonData) {

        return @"[]";

    } else {

        jsonString = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];


    }


    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];


    NSRange range = {0,jsonString.length};
    
    
    [mutStr replaceOccurrencesOfString:@" "
                            withString:@""
                               options:NSLiteralSearch range:range];
    
    
    NSRange range2 = {0,mutStr.length};
    
    
    [mutStr replaceOccurrencesOfString:@"\n"
                            withString:@""
                               options:NSLiteralSearch range:range2];
    
    
    return mutStr;
    
    
}

@end
