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
//定位回调里执行重启定位和关闭定位
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{

    [manager stopUpdatingLocation];
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
