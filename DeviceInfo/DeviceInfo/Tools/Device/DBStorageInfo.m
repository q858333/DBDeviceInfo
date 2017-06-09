//
//  DBStorageInfo.m
//  DeviceInfo
//
//  Created by dengbin on 17/6/9.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBStorageInfo.h"
#import <CoreGraphics/CoreGraphics.h>
#import <sys/mount.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
@interface DBStorageInfo ()

@property (nonatomic,strong)NSProcessInfo *processInfo;
@end

@implementation DBStorageInfo



+ (instancetype)shareStorageInfo {

    static DBStorageInfo *storageInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        storageInfo = [[DBStorageInfo alloc] init];

    });
    return storageInfo;
}
//已用磁盘容量
- (NSString *)getDiskUsed{

    return [NSString stringWithFormat:@"%lld",[self db_getDiskTotalSize]-[self db_getDiskFreeSize]];

}

//可用磁盘容量
- (NSString *)getDiskFreeSize {


    return  [NSString stringWithFormat:@"%lld",[self db_getDiskFreeSize]];


}


//总磁盘容量
- (NSString *)getDiskTotalSize{

    return [NSString stringWithFormat:@"%lld",[self db_getDiskTotalSize]];


}

//内存大小
- (NSString *)getMemoryTotal{
    return [NSString stringWithFormat:@"%llu",self.processInfo.physicalMemory];


}
#pragma mark - private method
//可用内存
-(long long)db_getAvailableMemorySize
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS)
    {
        return NSNotFound;
    }

    return ((vm_page_size * vmStats.free_count + vm_page_size * vmStats.inactive_count));
}
//总磁盘大小
- (long long)db_getDiskTotalSize {
    struct statfs buf;
    unsigned long long totalSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        totalSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return totalSpace;
}

//可用磁盘大小
- (long long)db_getDiskFreeSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace;
}

//内存大小转化
- (NSString *)p_getSizeFromString:(long long)size {
    if (size>1024*1024*1024) {
        return [NSString stringWithFormat:@"%.1fGB",size/1024.f/1024.f/1024.f];   //大于1G转化成G单位字符串
    }
    if (size<1024*1024*1024 && size>1024*1024) {
        return [NSString stringWithFormat:@"%.1fMB",size/1024.f/1024.f];   //转成M单位
    }
    if (size>1024 && size<1024*1024) {
        return [NSString stringWithFormat:@"%.1fkB",size/1024.f]; //转成K单位
    }else {
        return [NSString stringWithFormat:@"%.1lldB",size];   //转成B单位
    }

}
#pragma mark - Lazy Load
- (NSProcessInfo *)processInfo {
    if (!_processInfo) {
        _processInfo = [NSProcessInfo processInfo];
    }
    return _processInfo;
}
@end
