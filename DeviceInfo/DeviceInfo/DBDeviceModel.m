//
//  DBDeviceModel.m
//  DeviceInfo
//
//  Created by dengbin on 17/6/7.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBDeviceModel.h"
#import <objc/runtime.h>
@implementation DBDeviceModel
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
- (NSDictionary *)properties_jsonDictionary
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
    return props;
}
@end
