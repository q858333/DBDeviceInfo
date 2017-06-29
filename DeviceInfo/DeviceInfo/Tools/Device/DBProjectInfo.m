//
//  DBProjectInfo.m
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/8.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBProjectInfo.h"

@interface DBProjectInfo ()

@property (nonatomic,strong)NSDictionary *projectInfoDic;
@end

@implementation DBProjectInfo

+ (instancetype)shareProjectInfo {

    static DBProjectInfo *deviveInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        deviveInfo = [[DBProjectInfo alloc] init];

    });
    return deviveInfo;
}



- (NSString *)getProjectName {
    return self.projectInfoDic[@"CFBundleName"];
}
- (NSString *)getProjectBuildVersion {
    return self.projectInfoDic[@"CFBundleVersion"];
}
- (NSString *)getProjectVersion {
    return self.projectInfoDic[@"CFBundleShortVersionString"];
}

- (NSString *)getBundleIdentifier
{
   return  self.projectInfoDic[@"CFBundleIdentifier"];
}


#pragma mark - Lazy load
- (NSDictionary *)projectInfoDic {
    if (!_projectInfoDic) {
        _projectInfoDic = [[NSBundle mainBundle] infoDictionary];
    }
    return _projectInfoDic;
}
@end
