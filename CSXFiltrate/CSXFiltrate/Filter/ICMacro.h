//
//  ICMacro.h
//  filter
//
//  Created by 曹世鑫 on 2018/12/4.
//  Copyright © 2018 曹世鑫. All rights reserved.
//

#ifndef ICMacro_h
#define ICMacro_h

#define W_WIDTH [UIScreen mainScreen].bounds.size.width
#define H_HIGH  [UIScreen mainScreen].bounds.size.height

//颜色RGBA
#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define SCALE [UIScreen mainScreen].bounds.size.width/375

#define FONT_OF_SIZE(size) [UIFont systemFontOfSize:size*SCALE]

//分割线颜色
#define separeLineColor RGBACOLOR(206,206,206,1)

//cell的点击高亮颜色
#define SELECTHIGHTCOLOR  RGBACOLOR(216,216,216,1)


#define IMAGE(imageName) [UIImage imageNamed:imageName]

#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]

#define APPID @"1205353425"

//当前app的版本号，version不是build
#define APPVERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define STATUEHEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

//读取iOS系统版本
#define SYSTEMVERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//判断是否是iphonex
#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#endif /* ICMacro_h */
