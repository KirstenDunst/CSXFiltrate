//
//  FBTimeFiltrateView.h
//  filter
//
//  Created by 曹世鑫 on 2018/12/4.
//  Copyright © 2018 曹世鑫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClearBtnChoose)(void);

@interface FBTimeFiltrateView : UIView

- (instancetype)initWithFrame:(CGRect)frame placeHoderArr:(NSArray *)placehoderStrArr back:(void(^)(UITextField *chooseTextField,BOOL isEndTime))block;
//清除按钮触发的方法，供外部调用
- (void)clearBtnChoose;
@property (nonatomic, copy)ClearBtnChoose clearChoose;
@end

NS_ASSUME_NONNULL_END
