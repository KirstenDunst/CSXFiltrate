//
//  FBDatePickerView.m
//  filter
//
//  Created by 曹世鑫 on 2018/12/4.
//  Copyright © 2018 曹世鑫. All rights reserved.
//

#import "FBDatePickerView.h"
#import "ICMacro.h"

@interface FBDatePickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
/**
 * 数组装年份
 */
@property (nonatomic, strong) NSMutableArray *yearArray;
/**
 * 本年剩下的月份
 */
@property (nonatomic, strong) NSMutableArray *monthRemainingArray;

@property (nonatomic, strong) NSMutableArray *dayRemainingArray;
/**
 * 不是闰年 装一个月多少天
 */
@property (nonatomic, strong) NSArray *NotLeapYearArray;
/**
 * 闰年 装一个月多少天
 */
@property (nonatomic, strong) NSArray *leapYearArray;

/**
 * 是否显示今天的日期 YES 显示 NO 不显示
 */
@property (nonatomic, assign) BOOL isShowTodayDate;

@property (nonatomic, strong) NSMutableArray *yearShowArr;
@property (nonatomic, strong) NSMutableArray *monthShowArr;
@property (nonatomic, strong) NSMutableArray *dayShowArr;
@end

@implementation FBDatePickerView {
    /**
     * 用三个的原因UIPickerView,而不直接用component这个直接返回3个,由于我们需要的时间选择器年月日都有两条横下,如果没这个要求,可以直接用component这儿属性,不用创建3次
     */
    UIPickerView *yearPicker;/**<年>*/
    UIPickerView *monthPicker;/**<月份>*/
    UIPickerView *dayPicker;/**<天>*/
    UIButton *cancelButton;/**<取消按钮>*/
    UIButton *sureButton;/**<确定按钮>*/
    TimeShowMode timeShowMode;/**<时间显示模式>*/
    NSInteger currentYear;
    NSInteger currentMonth;
    NSInteger currentDay;
    NSInteger yearAll;/**年份的显示，这里暂时限定最近的时间两年。需要显示的年数*/
}
- (instancetype)initWithFrame:(CGRect)frame withTimeShowMode:(TimeShowMode)timeMode withIsShowTodayDate:(BOOL)isShowToday{
    if ([super initWithFrame:frame]) {        
        self.isShowTodayDate = isShowToday;
        timeShowMode = timeMode;
        self.yearArray = [NSMutableArray array];
        self.monthRemainingArray = [NSMutableArray array];
        self.dayRemainingArray = [NSMutableArray array];
        self.yearShowArr = [NSMutableArray array];
        self.monthShowArr = [NSMutableArray array];
        self.dayShowArr = [NSMutableArray array];
        yearAll = 2;
        [self initData];
        [self setViews];
    }
    return self;
}
- (void)reset {
    [self.yearShowArr removeAllObjects];
    [self.monthShowArr removeAllObjects];
    [self.dayShowArr removeAllObjects];
    [self instialData];
    [self scrollForAssignYear:[NSString stringWithFormat:@"%ld",currentYear] month:[NSString stringWithFormat:@"%ld",currentMonth] day:[NSString stringWithFormat:@"%ld",currentDay]];
    [self sureAction];
}
- (void)scrollForAssignYear:(NSString *)year month:(NSString *)month day:(NSString *)day {
    [yearPicker selectRow:[self.yearShowArr indexOfObject:year] inComponent:0 animated:YES];
    [monthPicker reloadAllComponents];
    [monthPicker selectRow:[self.monthShowArr indexOfObject:[NSString stringWithFormat:@"%d",([month intValue]-1)]] inComponent:0 animated:YES];
    [dayPicker reloadAllComponents];
    [dayPicker selectRow:[self.dayShowArr indexOfObject:[NSString stringWithFormat:@"%d",([day intValue]-1)]] inComponent:0 animated:YES];
}
- (void)initData{
    //非闰年
    self.NotLeapYearArray = @[@"31",@"28",@"31",@"30",@"31",@"30",@"31",@"31",@"30",@"31",@"30",@"31"];
    //闰年
    self.leapYearArray = @[@"31",@"29",@"31",@"30",@"31",@"30",@"31",@"31",@"30",@"31",@"30",@"31"];
    /**<获得日期>*/
    NSDate *date;
    /**
     * 判断时间显示模式
     *
     */
    if (timeShowMode == ShowTimeBeforeToday){
        if (self.isShowTodayDate) {
            //显示今天的时间
            date = [NSDate date];
        }else{
            //不显示今天的时间
            date = [NSDate dateWithTimeIntervalSinceNow:-(24 * 3600)];
        }
    }else if (timeShowMode == ShowTimeAfterToday){
        if (self.isShowTodayDate) {
            //显示今天的时间
            date = [NSDate date];
        }else{
            //不显示今天的时间
            date = [NSDate dateWithTimeIntervalSinceNow:+(24 * 3600)];
        }
    }else if (timeShowMode == ShowAllTime){
        //显示今天的时间
        date = [NSDate date];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy"];
    currentYear = [[dateFormatter stringFromDate:date] integerValue];
    [dateFormatter setDateFormat:@"MM"];
    currentMonth = [[dateFormatter stringFromDate:date] integerValue];
    [dateFormatter setDateFormat:@"dd"];
    currentDay = [[dateFormatter stringFromDate:date] integerValue];
    
    //判断时间显示模式
    if (timeShowMode == ShowTimeBeforeToday){
        for (NSInteger i = 0; i < yearAll; i++) {
            [self.yearArray addObject:[NSString stringWithFormat:@"%ld",currentYear - i]];
        }
        for (NSInteger i = 0; i < currentMonth; i++) {
            [self.monthRemainingArray addObject:[NSString stringWithFormat:@"%ld",i]];
        }
        for (NSInteger i = 0; i < currentDay; i++) {
            [self.dayRemainingArray addObject:[NSString stringWithFormat:@"%ld",i]];
        }
    }else if (timeShowMode == ShowTimeAfterToday){
        for (NSInteger i = 0; i < yearAll; i++) {
            [self.yearArray addObject:[NSString stringWithFormat:@"%ld",currentYear + i]];
        }
        for (NSInteger i = currentMonth - 1; i < 12; i++) {
            [self.monthRemainingArray addObject:[NSString stringWithFormat:@"%ld",i]];
        }
        NSInteger lastDay = [self LeapYearCompare:currentYear withMonth:currentMonth];
        for (NSInteger i = currentDay - 1; i < lastDay; i++) {
            [self.dayRemainingArray addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }else if (timeShowMode == ShowAllTime){//总年分的上下，中间为当前的年份
        for (NSInteger i = round(yearAll/2); i > 0; i--) {
            [self.yearArray addObject:[NSString stringWithFormat:@"%ld",currentYear - i]];
        }
        for (NSInteger i = 0; i < round(yearAll/2); i++) {
            [self.yearArray addObject:[NSString stringWithFormat:@"%ld",currentYear + i]];
        }
    }
    [self instialData];
}
- (void)instialData {
    self.yearShowArr = [NSMutableArray arrayWithArray:self.yearArray];
    self.monthShowArr = [NSMutableArray arrayWithArray:self.monthRemainingArray];
    self.dayShowArr = [NSMutableArray arrayWithArray:self.dayRemainingArray];
}


#pragma mark - 判断是否是闰年(返回的的值,天数)
- (NSInteger)LeapYearCompare:(NSInteger)year withMonth:(NSInteger)month{
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return [self.leapYearArray[month - 1] integerValue];
    }else{
        return [self.NotLeapYearArray[month - 1] integerValue];
    }
}
- (void)setViews{
    //年
    //时间选择器
    yearPicker = [[UIPickerView alloc]init];
    yearPicker.delegate = self;
    yearPicker.dataSource = self;
    [self addSubview:yearPicker];
    yearPicker.frame = CGRectMake(20, 0, 60, 209);
    
    //月
    monthPicker = [[UIPickerView alloc]init];
    monthPicker.delegate = self;
    yearPicker.dataSource = self;
    [self addSubview:monthPicker];
    monthPicker.frame = CGRectMake(CGRectGetMaxX(yearPicker.frame)+20, 0, 60, 209);

    //日
    dayPicker = [[UIPickerView alloc]init];
    dayPicker.delegate = self;
    dayPicker.dataSource = self;
    [self addSubview:dayPicker];
    dayPicker.frame = CGRectMake(CGRectGetMaxX(monthPicker.frame)+20, 0, 60, 209);
    
    //默认选中某个row
    switch (timeShowMode) {
        case ShowTimeBeforeToday:
            [yearPicker selectRow:0 inComponent:0 animated:YES];
            [monthPicker selectRow:currentMonth - 1 inComponent:0 animated:YES];
            [dayPicker selectRow:currentDay - 1 inComponent:0 animated:YES];
            break;
            
        case ShowTimeAfterToday:
            [yearPicker selectRow:0 inComponent:0 animated:YES];
            [monthPicker selectRow:0 inComponent:0 animated:YES];
            [dayPicker selectRow:0 inComponent:0 animated:YES];
            break;
            
        case ShowAllTime:
            [yearPicker selectRow:round(yearAll/2) inComponent:0 animated:YES];
            [monthPicker selectRow:currentMonth - 1 inComponent:0 animated:YES];
            [dayPicker selectRow:currentDay - 1 inComponent:0 animated:YES];
            break;
        default:
            break;
    }
}
#pragma mark - pickerView的delegate方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView == yearPicker) {
        [monthPicker reloadAllComponents];
        [dayPicker reloadAllComponents];
    }else if (pickerView == monthPicker){
        [dayPicker reloadAllComponents];
    }
    [self sureAction];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView == yearPicker) {
        return self.yearShowArr.count;
    }else if (pickerView == monthPicker){
        return [self MonthInSelectYear];
    }else {
        return [self daysInSelectMonth];
    }
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 48;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 64 ;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *rowLabel = [[UILabel alloc]init];
    rowLabel.textAlignment = NSTextAlignmentCenter;
    rowLabel.backgroundColor = [UIColor clearColor];
    rowLabel.frame = CGRectMake(0, 0, 39,self.frame.size.width);
    rowLabel.textAlignment = NSTextAlignmentCenter;
    rowLabel.font = [UIFont systemFontOfSize:14];
    rowLabel.textColor = [UIColor blackColor];
    
    [pickerView.subviews[1] setBackgroundColor:RGBACOLOR(204, 204, 204, 1)];
    [pickerView.subviews[2] setBackgroundColor:RGBACOLOR(204, 204, 204, 1)];
    [pickerView.subviews[1] setFrame:CGRectMake(0 , 80, 60, 2)];
    [pickerView.subviews[2] setFrame:CGRectMake(0, 130, 60, 2)];
    [rowLabel sizeToFit];
    if (pickerView == yearPicker) {
        rowLabel.text = self.yearShowArr[row];
        return rowLabel;
    }else if(pickerView == monthPicker){
        NSInteger yearRow = [yearPicker selectedRowInComponent:0] % self.yearShowArr.count;
        if (timeShowMode == ShowTimeBeforeToday ||timeShowMode == ShowTimeAfterToday) {
            if ([self.yearShowArr[yearRow] integerValue] == currentYear) {
                rowLabel.text = [NSString stringWithFormat:@"%ld",[self.monthShowArr[row] integerValue] + 1];
            }else{
                rowLabel.text = [NSString stringWithFormat:@"%ld",row%12+1];
            }
        }else {
            rowLabel.text = [NSString stringWithFormat:@"%ld",row%12+1];
        }
        return rowLabel;
    }else {
        NSInteger yearRow = [yearPicker selectedRowInComponent:0] % self.yearShowArr.count;
        NSInteger monthRow = [monthPicker selectedRowInComponent:0] % 12;
        NSInteger monthDays = [self LeapYearCompare:[self.yearShowArr[yearRow] integerValue] withMonth:(monthRow + 1)];
        switch (timeShowMode) {
            case ShowTimeBeforeToday:
                if ([self.yearShowArr[yearRow] integerValue] == currentYear) {
                    if ([self.monthShowArr[monthRow] integerValue] + 1 == currentMonth) {
                        rowLabel.text = [NSString stringWithFormat:@"%ld",[self.dayShowArr[row] integerValue] + 1];
                    }else{
                        NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearShowArr[yearRow] integerValue] withMonth:[self.monthShowArr[monthRow] integerValue] + 1];
                        rowLabel.text = [NSString stringWithFormat:@"%ld", row % monthRemainingDays + 1];
                    }
                }else{
                    rowLabel.text = [NSString stringWithFormat:@"%ld", row % monthDays + 1];
                }
                break;
            case ShowTimeAfterToday:
                if ([self.yearShowArr[yearRow] integerValue] == currentYear) {
                    if ([self.monthShowArr[monthRow] integerValue] + 1 == currentMonth) {
                        rowLabel.text = [NSString stringWithFormat:@"%ld",[self.dayShowArr[row] integerValue] + 1];
                    }else{
                        NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearShowArr[yearRow] integerValue] withMonth:[self.monthShowArr[monthRow] integerValue]];
                        rowLabel.text = [NSString stringWithFormat:@"%ld", row % monthRemainingDays + 1];
                    }
                }else{
                    rowLabel.text = [NSString stringWithFormat:@"%ld", row % monthDays + 1];
                }
                break;
            case ShowAllTime:
                rowLabel.text = [NSString stringWithFormat:@"%ld", row % monthDays + 1];
                break;
                
            default:
                break;
        }
        return rowLabel;
    }
}
/**
 * 返回有多少个月
 */
- (NSInteger)MonthInSelectYear{
    NSInteger yearRow = [yearPicker selectedRowInComponent:0];
    [self.monthShowArr removeAllObjects];
    if (timeShowMode == ShowTimeBeforeToday || timeShowMode == ShowTimeAfterToday) {
        if ([self.yearShowArr[yearRow] integerValue] == currentYear) {
            [self.monthShowArr addObjectsFromArray:self.monthRemainingArray];
        }else{
            for (int i = 0; i < 12; i++) {
                [self.monthShowArr addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
    }else {
        for (int i = 0; i < 12; i++) {
            [self.monthShowArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return self.monthShowArr.count;
}
/**
 * 返回有多少天
 */
- (NSInteger)daysInSelectMonth{
    NSInteger yearRow = [yearPicker selectedRowInComponent:0] % self.yearArray.count;
    NSInteger monthRow = [monthPicker selectedRowInComponent:0] % 12;
    NSInteger monthDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:(monthRow + 1)];
    [self.dayShowArr removeAllObjects];
    if (timeShowMode == ShowTimeAfterToday || timeShowMode == ShowTimeBeforeToday) {
        if ([self.yearShowArr[yearRow] integerValue] == currentYear ) {
            if ([self.monthShowArr[monthRow] integerValue] + 1 == currentMonth) {
                [self.dayShowArr addObjectsFromArray:self.dayRemainingArray];
            }else{
                NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearShowArr[yearRow] integerValue] withMonth:[self.monthShowArr[monthRow] integerValue] + 1];
                for (int i = 0; i < monthRemainingDays; i++) {
                    [self.dayShowArr addObject:[NSString stringWithFormat:@"%d",i]];
                }
            }
        }else{
            for (int i = 0; i < monthDays; i++) {
                [self.dayShowArr addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
    }else{
        NSInteger days = [self LeapYearCompare:[self.yearShowArr[yearRow] integerValue] withMonth:(monthRow + 1)];
        for (int i = 0; i < days; i++) {
            [self.dayShowArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return self.dayShowArr.count;
}

#pragma mark - 确定按钮点击方法

- (void)sureAction{
    NSString *yearStr = @"";
    NSString *monthStr = @"";
    NSString *dayStr = @"";
    NSInteger yearRow = [yearPicker selectedRowInComponent:0]  % self.yearArray.count;
    NSInteger monthRow = [monthPicker selectedRowInComponent:0];
    NSInteger dayRow = [dayPicker selectedRowInComponent:0];
    yearStr = self.yearArray[yearRow];
    
    NSInteger monthDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:(monthRow + 1)];
    switch (timeShowMode) {
        case ShowTimeBeforeToday :
            if ([self.yearArray[yearRow] integerValue] == currentYear) {
                monthStr  =  [NSString stringWithFormat:@"%ld",[self.monthShowArr[monthRow] integerValue] + 1];
                if ([self.monthShowArr[monthRow] integerValue] + 1 == currentMonth) {
                    dayStr = [NSString stringWithFormat:@"%ld",[self.dayShowArr[dayRow] integerValue] + 1];
                }else{
                    NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearShowArr[yearRow] integerValue] withMonth:[self.monthShowArr[monthRow] integerValue] + 1];
                    dayStr = [NSString stringWithFormat:@"%ld", dayRow % monthRemainingDays + 1];
                }
            }else{
                monthStr = [NSString stringWithFormat:@"%ld",monthRow % 12 + 1];
                dayStr = [NSString stringWithFormat:@"%ld", dayRow % monthDays + 1];
            }
            break;
        case ShowTimeAfterToday:
            if ([self.yearShowArr[yearRow] integerValue] == currentYear) {
                monthStr = [NSString stringWithFormat:@"%ld",[self.monthShowArr[monthRow] integerValue] + 1];
                if ([self.monthShowArr[monthRow] integerValue] + 1 == currentMonth) {
                    dayStr = [NSString stringWithFormat:@"%ld",[self.dayShowArr[dayRow] integerValue] + 1];
                }else{
                    NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearShowArr[yearRow] integerValue] withMonth:[self.monthShowArr[monthRow] integerValue]];
                    dayStr = [NSString stringWithFormat:@"%ld", dayRow % monthRemainingDays + 1];
                }
            }else{
                monthStr = [NSString stringWithFormat:@"%ld",monthRow % 12 + 1];
                dayStr = [NSString stringWithFormat:@"%ld", dayRow % monthDays + 1];
            }
            break;
        case ShowAllTime:
            monthStr = [NSString stringWithFormat:@"%ld",monthRow % 12 + 1];
            dayStr = [NSString stringWithFormat:@"%ld", dayRow % monthDays + 1];
            break;
    }
    [self.delegate DatePickerView:yearStr withMonth:monthStr withDay:dayStr withDate:[NSString stringWithFormat:@"%@-%@-%@",yearStr,monthStr,dayStr] withTag:1001];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
