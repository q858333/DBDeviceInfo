//
//  DBJailBreak.m
//  RongCapitalSDK
//
//  Created by dengbin on 17/6/8.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "DBJailBreak.h"
#import <UIkit/UIKit.h>
#include <stdlib.h>
#include <string.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>
#import <objc/runtime.h>
#import <dlfcn.h>
@implementation DBJailBreak

//这里用多个判断方式判断，确保判断更加准确
+ (BOOL)isJailBreak {
    return [self p_judgeByOpenAppFolder] || [self p_judgeByOpenUrl] || [self p_judgeByFolderExists] || [self p_judgeByReadDYLD_INSERT_LIBRARIES];
}



#pragma mark - private method
+ (BOOL)p_judgeByReadDYLD_INSERT_LIBRARIES {
    char *env = getenv("DYLD_INSERT_LIBRARIES");

    if (env) {
        return YES;
    }
    return NO;
}
//通过能否打开软件安装文件夹判断
+ (BOOL)p_judgeByOpenAppFolder {
    NSError *error;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSRange rang = [path rangeOfString:@"Application/"];
    NSString *appPath = [path substringToIndex:rang.location+ rang.length];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appPath]) {
        NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appPath error:&error];
        if (arr && [arr count]!=0) {
            return YES;
        }else {
            return NO;
        }

        return YES;
    }
    return NO;
}
//通过能否打开cydia：//来判断，YES说明可以打开，就是越狱的，NO表示不可以打开
+ (BOOL)p_judgeByOpenUrl {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        return YES;
    }
    return NO;
}


//通过文件夹判断，如果boo为YES说明有以下的一些文件夹，则说明已经越狱
+ (BOOL)p_judgeByFolderExists {
    __block BOOL boo = NO;
    NSArray *arr = @[@"/Applications/Cydia.app",@"/Library/MobileSubstrate/MobileSubstrate.dylib",@"/bin/bash",@"/usr/sbin/sshd",@"/etc/apt"];
    [arr enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:obj]) {
            boo = YES;
            *stop = YES;
        }
    }];
    return boo;
}

//未安装越狱防护的越狱机，安装插件后，会安装在/Library/MobileSubstrate目录下，

//在安装ZNT插件后，检测时会将所有越狱文件伪装成

bool printDYLD(){

    //Get count of all currently loaded DYLD
    uint32_t count = _dyld_image_count();
    //安装NZT插件后会把原有的越狱文件名称统一修改成在/usr/lib/目录下的libSystem.B.dylib
    NSString *jtpath=@"/usr/lib/libSystem.B.dylib";

    uint32_t countyueyu=0;

    for(uint32_t i = 0; i < count; i++)
    {
        //Name of image (includes full path)
        const char *dyld = _dyld_get_image_name(i);

        //Get name of file
        int slength = strlen(dyld);

        int j;
        for(j = slength - 1; j>= 0; --j)
            if(dyld[j] == '/') break;

        NSString *name = [[NSString alloc]initWithUTF8String:_dyld_get_image_name(i)];
        if([name compare:jtpath] == NSOrderedSame)
        {
            countyueyu++;
        }
        if([name containsString:@"/Library/MobileSubstrate"])
        {
            return YES;
        }
    }
    if( countyueyu > 2 )
        return YES;
    return NO;
    printf("\n");
}

//-(BOOL)getYueYu
//{
//    NSMutableArray *proState = [NSMutableArray array];
//
//    //获取用户手机已安装app
//    Class LSApplicationWorkspace_class =objc_getClass("LSApplicationWorkspace");
//
//    SEL mydefault =NSSelectorFromString(@"defaultWorkspace");
//
//    NSObject* workspace =[LSApplicationWorkspace_class performSelector:mydefault];
//
//    SEL myappinfoinstall =NSSelectorFromString(@"allApplications");
//
//    NSString *appinfostring= [NSString stringWithFormat:@"%@",[workspace performSelector:myappinfoinstall]];
//
//    NSLog(@"----foo89789-----%@",appinfostring);
//
//    appinfostring =[appinfostring stringByReplacingOccurrencesOfString:@"<" withString:@""];
//    appinfostring =[appinfostring stringByReplacingOccurrencesOfString:@">" withString:@""];
//    appinfostring =[appinfostring stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//    appinfostring =[appinfostring stringByReplacingOccurrencesOfString:@"(" withString:@""];
//    appinfostring =[appinfostring stringByReplacingOccurrencesOfString:@")" withString:@""];
//    NSLog(@"----foo0000-----:%@",appinfostring);
//    NSArray* foo = [appinfostring componentsSeparatedByString:@","];
//    NSLog(@"----foo-----");
//    BOOL isyueyu          = NO;
//    NSString *cydia       = @"com.saurik.Cydia";
//    NSString *chudong     = @"com.touchsprite.ios";
//    NSString *nzt         = @"NZT";
//    for (NSString *dic in foo)
//    {
//        NSLog(@"----foo222-----");
//        NSString* childstring = [NSString stringWithFormat:@"%@",dic ];
//        // NSLog(@"----foo222-----%@",childstring);
//        childstring  = [childstring stringByReplacingOccurrencesOfString:@" " withString:@"&"];
//        //childstring =[childstring stringByReplacingOccurrencesOfString:@"-" withString:@"."];
//        NSLog(@"----foo222-----%@",childstring);
//        NSArray* foo2 = [childstring componentsSeparatedByString:@"&"];
//        NSString *appname;
//        @try {
//            appname = [NSString stringWithFormat:@"%@",[foo2 objectAtIndex: 6]];
//        }
//        @catch (NSException *exception) {
//
//            appname = [NSString stringWithFormat:@"%@",[foo2 objectAtIndex: 5]];
//        }
//        if([appname compare:cydia] == NSOrderedSame)
//        {
//            isyueyu = YES;
//            break;
//        }
//        if([appname compare:chudong] == NSOrderedSame)
//        {
//            isyueyu = YES;
//            break;
//        }
//        if([appname compare:nzt]==NSOrderedSame)
//        {
//            isyueyu = YES;
//            break;
//        }
//
//        // NSLog(@"----foo222yyyy-----%@",appname);
//        NSString *msg = [NSString stringWithFormat:@"{\"name\":\"%@\",\"index\":\"%@\"}",appname, @""];
//        [proState addObject:msg];
//        NSLog(@"----foo3333-----");
//    } 
//    return isyueyu;    
//}



//static void logMethodInfo(const char *className, const char *sel)
//{
//    Dl_info info;
//    IMP imp = class_getMethodImplementation(objc_getClass(className),sel_registerName(sel));
//    if(dladdr(imp,&info)) {
//        NSLog(@"method %s %s:", className, sel);
//        NSLog(@"dli_fname:%s",info.dli_fname);
//        NSLog(@"dli_sname:%s",info.dli_sname);
//        NSLog(@"dli_fbase:%p",info.dli_fbase);
//        NSLog(@"dli_saddr:%p",info.dli_saddr);
//    } else {
//        NSLog(@"error: can't find that symbol.");
//    }
//}
//
//static inline BOOL validate_methods(const char *cls,const char *fname) __attribute__ ((always_inline));
//
//BOOL validate_methods(const char *cls,const char *fname){
//    Class aClass = objc_getClass(cls);
//    Method *methods;
//    unsigned int nMethods;
//    Dl_info info;
//    IMP imp;
//    char buf[128];
//    Method m;
//
//    if(!aClass)
//        return NO;
//    methods = class_copyMethodList(aClass, &nMethods);
//    while (nMethods--) {
//        m = methods[nMethods];
//        printf("validating [%s %s]\n",(const char *)class_getName(aClass),(const char *)method_getName(m));
//
//        imp = method_getImplementation(m);
//        //imp = class_getMethodImplementation(aClass, sel_registerName("allObjects"));
//        if(!imp){
//            printf("error:method_getImplementation(%s) failed\n",(const char *)method_getName(m));
//            free(methods);
//            return NO;
//        }
//
//        if(!dladdr(imp, &info)){
//            printf("error:dladdr() failed for %s\n",(const char *)method_getName(m));
//            free(methods);
//            return NO;
//        }
//
//        /*Validate image path*/
//        if(strcmp(info.dli_fname, fname))
//            goto FAIL;
//
//        if (info.dli_sname != NULL && strcmp(info.dli_sname, "<redacted>") != 0) {
//            /*Validate class name in symbol*/
//            snprintf(buf, sizeof(buf), "[%s ",(const char *) class_getName(aClass));
//            if(strncmp(info.dli_sname + 1, buf, strlen(buf))){
//                snprintf(buf, sizeof(buf),"[%s(",(const char *)class_getName(aClass));
//                if(strncmp(info.dli_sname + 1, buf, strlen(buf)))
//                    goto FAIL;
//            }
//
//            /*Validate selector in symbol*/
//            snprintf(buf, sizeof(buf), " %s]",(const char*)method_getName(m));
//            if(strncmp(info.dli_sname + (strlen(info.dli_sname) - strlen(buf)), buf, strlen(buf))){
//                goto FAIL;
//            }
//        }else{
//            printf("<redacted>  \n");
//        }
//
//    }
//
//    return YES;
//
//FAIL:
//    printf("method %s failed integrity test:\n",
//           (const char *)method_getName(m));
//    printf("    dli_fname:%s\n",info.dli_fname);
//    printf("    dli_sname:%s\n",info.dli_sname);
//    printf("    dli_fbase:%p\n",info.dli_fbase);
//    printf("    dli_saddr:%p\n",info.dli_saddr);
//    free(methods);
//    return NO;
//}
//
//
//-(void)exam
//{
//    const char * className = class_getName([CLLocationManager class]);
//
//
//
//
//    unsigned int count;
//    Method *methods = class_copyMethodList([CLLocationManager class], &count);
//    for (int i = 0; i < count; i++)
//    {
//        Method method = methods[i];
//        SEL selector = method_getName(method);
//        NSString *name = NSStringFromSelector(selector);
//        //        if ([name hasPrefix:@"test"])
//        NSLog(@"方法 名字 ==== %@",name);
//
//
//        logMethodInfo(className, [name cStringUsingEncoding:NSUTF8StringEncoding]);
//    }
//}
@end
