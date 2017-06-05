//
//  DBTools.h
//  DeviceInfo
//
//  Created by dengbin on 17/5/26.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBTools : NSObject

///重装app值不会变，只有重置系统会发生变化，adiv存在钥匙串中
+ (NSString *)getIDFV;


@end
