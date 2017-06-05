//
//  ViewController.m
//  DeviceInfo
//
//  Created by dengbin on 17/5/25.
//  Copyright © 2017年 dengbin. All rights reserved.
//

#import "ViewController.h"
#import "DBTools.h"
#import "DBPermissions.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [DBTools getIDFV];


    [[DBPermissions sharePermissions] getAddressBookState:^(BOOL isGranted) {
        NSLog(@"%d",isGranted);
    }];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
