//
//  RCPhoneInfoModel.h
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/13.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^FinallyBlock)(void);


@interface RCPhoneInfoModel : NSObject



/** 手机号 SDK接受调用方上送*/
@property (nonatomic, copy) NSString *phone;








/** 当前位置  */
@property(nonatomic,copy)NSString *gpslocation;

/** 设备指纹tokenid*/
@property(nonatomic,copy)NSString *tokenid;

/** APK签名文件的md5*/
@property(nonatomic,copy)NSString *signmd5;

/** 环境变量*/
@property(nonatomic,copy)NSString *env;

/** 动态链接库*/
@property(nonatomic,copy)NSString *attached;

/** ip地址信息*/
@property(nonatomic,copy)NSString *geoip;

/** 真实IP地址*/
@property(nonatomic,copy)NSString *trueip;

/** 安全混淆键盘 */
@property(nonatomic,copy)NSString *safeconfusekey;

/** 手指轨迹 */
@property(nonatomic,copy)NSString *fingertrack;

/** 当前VPN连接的本地IP地址*/
@property(nonatomic,copy)NSString *vpnip;

/** 当前VPN连接的子网掩码*/
@property(nonatomic,copy)NSString *vpnnetmask;

//h5 数据
///**用户代理*/
//@property(nonatomic,copy)NSString *userproxy;
///**语言*/
//@property(nonatomic,copy)NSString *h5language;
///**颜色深度*/
//@property(nonatomic,copy)NSString *colordepth;
///**已安装的flash字体列表**/
//@property(nonatomic,copy)NSString *flashfont;
///**IE是否指定AddBehavior*/
//@property(nonatomic,copy)NSString *addbehavior;
///**屏幕分辨率*/
//@property(nonatomic,copy)NSString *h5screenRes;
///**时区*/
//@property(nonatomic,copy)NSString *h5timezone;
///**是否有会话存储*/
//@property(nonatomic,copy)NSString *sessionstorage;
///**是否有本地存储*/
//@property(nonatomic,copy)NSString *localstorage;
///**索引_数据库*/
//@property(nonatomic,copy)NSString *indexdatabase;
///**是否有本地存储*/
//@property(nonatomic,copy)NSString *opendatabase;
//@property(nonatomic,copy)NSString *h5cpu;
//@property(nonatomic,copy)NSString *h5platform;
//@property(nonatomic,copy)NSString *donottrack;
//@property(nonatomic,copy)NSString *plugin;
//@property(nonatomic,copy)NSString *canvafinger;
//@property(nonatomic,copy)NSString *webglfinger;
//@property(nonatomic,copy)NSString *installadblock;
//@property(nonatomic,copy)NSString *tamperlanager,*tamperscreen,*tamperos,*tamperbrowser,*detecttouchscreen,*jsfont;





//配置数据
- (void)configDataWithFinallyBlock:(FinallyBlock)block;

- (NSMutableDictionary *)properties_jsonDictionary;

@end
