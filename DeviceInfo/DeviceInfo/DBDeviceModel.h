//
//  DBDeviceModel.h
//  DeviceInfo
//
//  Created by dengbin on 17/6/7.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBDeviceModel : NSObject
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *age;
@property(nonatomic,strong)NSString *sex;
@property(nonatomic,strong)NSString *height;

- (NSDictionary *)properties_jsonDictionary;

@end
