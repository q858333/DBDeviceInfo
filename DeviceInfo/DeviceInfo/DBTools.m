//
//  DBTools.m
//  DeviceInfo
//
//  Created by dengbin on 17/5/26.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBTools.h"
#import <UIKit/UIKit.h>
NSString * const KEY_IDFV = @"com.rs.sdk_safe";

@implementation DBTools



+ (NSString *)getIDFV
{

    //测试用 清除keychain中的内容

   // [DBTools delete:KEY_IDFV];

    //读取保存的内容
    NSString *readIDFV= (NSString *)[DBTools load:KEY_IDFV];

    NSLog(@"keychain------>%@",readIDFV);


    if (!readIDFV) {

        //如果为空 说明是第一次安装 做存储操作

        NSString *identifierStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

        NSLog(@"不存在。identifierStr--->C9312013-D127-42E4-86B3-D4096546F77F---->%@",identifierStr);

      

        [DBTools save:KEY_IDFV data:identifierStr];

        return identifierStr;
        
    }else{
        NSLog(@"存在");

        return readIDFV;

    }
    
}


//删除
+ (void)delete:(NSString *)service {

    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];

    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    
}




//取出
+ (id)load:(NSString *)service {

    id ret = nil;

    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];

    //Configure the search setting

    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue

    [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];

    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

    CFDataRef keyData = NULL;

    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {

        @try {

            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];

        } @catch (NSException *e) {

            NSLog(@"Unarchive of %@ failed: %@", service, e);

        } @finally {
            
        }
        
    }
    
    if (keyData)
        
        CFRelease(keyData);
    
    return ret;
    
}

//储存
+ (void)save:(NSString *)service data:(id)data {

    //Get search dictionary

    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];

    //Delete old item before add new item

    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);

    //Add new object to search dictionary(Attention:the data format)

    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];

    //Add item to keychain with the search dictionary

    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);

}



+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {

    return [NSMutableDictionary dictionaryWithObjectsAndKeys:

            (__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass,

            service, (__bridge id)kSecAttrService,

            service, (__bridge id)kSecAttrAccount,

            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible,
            
            nil];
    
}
@end
