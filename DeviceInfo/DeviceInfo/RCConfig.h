//
//  Config.h
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/13.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#ifndef Config_h
#define Config_h


#endif /* Config_h */


#define  SDK_VERSION            @"1.0.4"


#define  IOS_VERSION            [[UIDevice currentDevice].systemVersion floatValue]

#define  WS(weakSelf)           __weak __typeof(&*self)weakSelf = self;


#define  RESOURECE_BUNDLE(name)                 [NSString stringWithFormat:@"RongCapitalSDK.bundle/%@",name]

//返回第三方时发送此通知
#define  NOTIFICATION_FINALLY   @"rc_callback"




#ifdef   DEBUG
#define  DebugLog(format, ...) NSLog((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DebugLog(...);
#endif
