//
//  FBDatePickerView.h
//  filter
//
//  Created by 曹世鑫 on 2018/12/4.
//  Copyright © 2018 曹世鑫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FBDatePickerView;
@protocol FBDatePickerViewDelegate <NSObject>

- (void)DatePickerView:(NSString *)year withMonth:(NSString *)month withDay:(NSString *)day withDate:(NSString *)date withTag:(NSInteger) tag;

@end
typedef NS_ENUM(NSInteger,TimeShowMode){
    /**
     * 只显示今天之前的时间
     */
    ShowTimeBeforeToday = 1,
    /**
     * 显示今天之后的时间
     */
    ShowTimeAfterToday,
    /**
     * 不限制时间
     */
    ShowAllTime,
    
};

@interface FBDatePickerView : UIView

- (instancetype)initWithFrame:(CGRect)frame withTimeShowMode:(TimeShowMode)timeMode withIsShowTodayDate:(BOOL)isShowToday;


/**
 重制方法
 */
- (void)reset;

/**
 回显指定的日期时间

 @param year 年份
 @param month 月份
 @param day 天份
 */
- (void)scrollForAssignYear:(NSString *)year month:(NSString *)month day:(NSString *)day;

@property (nonatomic, assign) id<FBDatePickerViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
