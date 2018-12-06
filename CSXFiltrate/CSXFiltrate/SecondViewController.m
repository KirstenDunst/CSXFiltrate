//
//  SecondViewController.m
//  filter
//
//  Created by 曹世鑫 on 2018/12/4.
//  Copyright © 2018 曹世鑫. All rights reserved.
//

#import "SecondViewController.h"
#import "FBFiltrateView.h"
#import "ICMacro.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    FBFiltrateView *filtrateView = [[FBFiltrateView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+44, W_WIDTH, self.view.frame.size.height-([UIApplication sharedApplication].statusBarFrame.size.height+44)) filterDic:@{@"1":@"支付宝",@"2":@"微信",@"3":@"京东",@"4":@"测试"} titleArr:@[@"订单类型",@"选择时间"] allKey:@"0"];
    filtrateView.selectedBack = ^(NSArray *keys, NSArray *values, NSString *begainTimeStr, NSString *endTimeStr) {
         NSLog(@">>>>>>>>>>>%@>>>>>>>>>%@>>>>>>>>>%@>>>>>>>%@",keys,values,begainTimeStr,endTimeStr);
    };
    [self.view addSubview:filtrateView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
