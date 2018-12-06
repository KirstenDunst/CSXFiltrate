//
//  ViewController.m
//  CSXFiltrate
//
//  Created by 曹世鑫 on 2018/12/6.
//  Copyright © 2018 曹世鑫. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(40, 100, 80, 40);
    [button setTitle:@"测试" forState:UIControlStateNormal];
    [button setTintColor:[UIColor lightGrayColor]];
    [button addTarget:self action:@selector(buttonChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}
- (void)buttonChoose:(UIButton *)sender {
    [self.navigationController pushViewController:[SecondViewController new] animated:YES];
}


@end
