//
//  FBFiltrateView.h
//  FSFuBei
//
//  Created by 曹世鑫 on 2018/6/11.
//  Copyright © 2018年 曹世鑫. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 筛选返回的条件类型

 @param keys 选择的key，内容是字符串类型
 @param values 选中的value，内容：字符串类型
 @param begainTimeStr 开始的时间戳，精确到毫秒
 @param endTimeStr 结束的时间戳，精确到毫秒
 */
typedef void(^SelectedBack)(NSArray *keys,NSArray *values, NSString *begainTimeStr,NSString *endTimeStr);

@interface FBFiltrateView : UIView

/**
 筛选初始化方法（内部自带scroll，可上下滑动）

 @param frame 尺寸大小
 @param filterDic 筛选的条件字典类型（eg:{请求需要的字段内容：筛选显示的内容}），key是请求的类型，字符串类型，value是现实的内容，字符串类型
 @param titleArr 标题的内容，内容为两个字符串类型。
 @param allKey 筛选条件第一项默认“全部”对应的key，上面的filterDic不包含“全部”的内容
 @return 实例化
 */
- (instancetype)initWithFrame:(CGRect)frame filterDic:(NSDictionary *)filterDic titleArr:(NSArray *)titleArr allKey:(NSString *)allKey;

@property (nonatomic, copy)SelectedBack selectedBack;
@end
