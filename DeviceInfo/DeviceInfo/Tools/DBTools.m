//
//  DBTools.m
//  DeviceInfo
//
//  Created by dengbin on 17/5/26.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBTools.h"
#import "DBKeychain.h"
@implementation DBTools
-(NSString *)getUUID
{
  NSString *uuid = [DBKeychain getUUID];

    return  uuid;
}

@end
