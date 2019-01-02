//
//  FBFiltrateView.m
//  FSFuBei
//
//  Created by 曹世鑫 on 2018/6/11.
//  Copyright © 2018年 曹世鑫. All rights reserved.
//

#import "FBFiltrateView.h"
#import "ICMacro.h"
#import "FBFiltrateModel.h"
#import "FBDatePickerView.h"
#import "FBTimeFiltrateView.h"

//时间选择
typedef enum:NSInteger{
    timeChooseTags = 100,
    payTypeTags = 200,
    chooseBtnTags = 300,
}TimeTags;

@interface FBFiltrateView()<FBDatePickerViewDelegate>
//标题的label
@property (nonatomic, strong)UILabel *titleLabel;
//时间选择的标题
@property (nonatomic, strong)UILabel *subLabel;
//提示的标题信息
@property (nonatomic, strong)UILabel *alarmLabel;
//内部包含所有的button按钮
@property (nonatomic, strong)NSMutableArray *selectPayTypeArr;
//数据源包含model
@property (nonatomic, strong)NSMutableArray *dataSourecArr;
@property (nonatomic, strong)UIScrollView *bgScroll;
@property (nonatomic, strong)NSArray *valuesArr;
@property (nonatomic, strong)NSArray *keysArr;
@property (nonatomic, strong)NSDictionary *inceptionDic;
@property (nonatomic, strong)UIView *filterView;
@property (nonatomic, assign)CGRect reactFrame;
@property (nonatomic, copy)NSString *allKeyStr;
@property (nonatomic, strong)UIButton *resetBtn;
@property (nonatomic, strong)UIButton *ensureBtn;
@property (nonatomic, strong)FBDatePickerView *datePickerView;
@property (nonatomic, strong)FBTimeFiltrateView *timeView;
@property (nonatomic, copy)NSString *begainTimeStr;
@property (nonatomic, copy)NSString *endTimeStr;
@property (nonatomic, assign)BOOL isEndTime;
@property (nonatomic, strong)UITextField *chooseTimeTextField;
@property (nonatomic, strong)UIView *timeSpeTopView;
@property (nonatomic, strong)UIView *timeSpeBottomView;
//记录时间选择的输入框
@property (nonatomic, strong)UITextField *oldTextField;
//选中的button
@property (nonatomic, strong)UIButton *selectBtn;
@end

@implementation FBFiltrateView

- (instancetype)initWithFrame:(CGRect)frame filterDic:(NSDictionary *)filterDic titleArr:(NSArray *)titleArr allKey:(NSString *)allKey{
    self = [super initWithFrame:frame];
    if (self) {
        self.allKeyStr = allKey;
        self.reactFrame = frame;
        self.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
        self.inceptionDic = filterDic;
        self.keysArr = [self.inceptionDic allKeys];
        self.valuesArr = [self.inceptionDic allValues];
        [self initData];
        [self createViewWithFrame:frame];
        self.titleLabel.text = [titleArr firstObject];
        self.subLabel.text = [titleArr lastObject];
    }
    return self;
}

- (void)createViewWithFrame:(CGRect)frame {
    [self addSubview:self.bgScroll];
    [self.bgScroll addSubview:self.titleLabel];
    [self createPayTypeWithArr:self.dataSourecArr];
    [self.bgScroll addSubview:self.filterView];
    [self.bgScroll addSubview:self.subLabel];
    [self.bgScroll addSubview:self.timeView];
    __weak typeof(self) weakSelf = self;
    self.timeView.clearChoose = ^{
        //关闭时间选择器
        weakSelf.oldTextField = nil;
        [weakSelf closeDatePickerView];
        weakSelf.begainTimeStr = nil;
        weakSelf.endTimeStr = nil;
        weakSelf.alarmLabel.hidden = YES;
    };
    [self.bgScroll addSubview:self.timeSpeTopView];
    [self.bgScroll addSubview:self.datePickerView];
    [self.bgScroll addSubview:self.timeSpeBottomView];
    [self.bgScroll addSubview:self.alarmLabel];
    CGFloat contentHeight = 0;
    if ((CGRectGetMaxY(self.alarmLabel.frame)+143*SCALE)>self.reactFrame.size.height) {
        contentHeight = CGRectGetMaxY(self.alarmLabel.frame)+143*SCALE;
    }else {
        contentHeight = self.reactFrame.size.height;
    }
    self.bgScroll.contentSize =  CGSizeMake(self.reactFrame.size.width, contentHeight);
    [self.bgScroll addSubview:self.resetBtn];
    [self.bgScroll addSubview:self.ensureBtn];
}
- (void)resetBtnChoose:(UIButton *)sender {
    UIButton *allBtn = [self viewWithTag:payTypeTags+0];
    [self payTypeSelect:allBtn];
    [self.timeView clearBtnChoose];
}
- (void)ensureBtnChoose:(UIButton *)sender {
    //再次验证时间范围，然后没问题就返回筛选条件
    if (self.begainTimeStr == nil && self.endTimeStr == nil) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请选择时间范围（最大范围3个月）" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (![self compareWithOldTimeStr:self.begainTimeStr endTime:self.endTimeStr]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"选择的时间范围超出了3个月， 请缩小范围后重试" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    NSMutableArray *keysArr = [NSMutableArray array];
    NSMutableArray *valuesArr = [NSMutableArray array];
    for (FBFiltrateModel *model in self.dataSourecArr) {
        if (model.isSelct) {
            [keysArr addObject:model.payType];
            [valuesArr addObject:model.titleStr];
        }
    }
    NSString *laseBegainTimeStr = nil,*lastEndTimeStr = nil;
    NSString *begainTimeDateForm = [self nsstringConversionNSDate:self.begainTimeStr hourMinSec:@""];
    NSString *endTimeDateForm = [self nsstringConversionNSDate:self.endTimeStr hourMinSec:@""];
    if ([begainTimeDateForm compare:endTimeDateForm options:NSNumericSearch] == NSOrderedAscending ||[begainTimeDateForm compare:endTimeDateForm options:NSNumericSearch] == NSOrderedSame) {
        laseBegainTimeStr = begainTimeDateForm;
        lastEndTimeStr = [self nsstringConversionNSDate:self.endTimeStr hourMinSec:@"23:59:59"];
    }else {
        laseBegainTimeStr = endTimeDateForm;
        lastEndTimeStr = [self nsstringConversionNSDate:self.begainTimeStr hourMinSec:@"23:59:59"];
    }
    if (self.selectedBack) {
        self.selectedBack(keysArr, valuesArr, laseBegainTimeStr, lastEndTimeStr);
    }
}

//整个界面的多选还是单选
//多选处理逻辑：当后面的全选的时候或者是一个不选的时候会选中全选，其他的为不选状态。（确定的时候可以根据总数据源dataSourecArr选中状态来进一步处理）
//单选处理逻辑：整个界面主要是时间的选择，上面的和下面的自定义时间唯一。
- (void)payTypeSelect:(UIButton *)sender{
    [self.selectBtn setTintColor:[UIColor lightGrayColor]];
    self.selectBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.selectBtn setBackgroundImage:nil forState:UIControlStateNormal];
    FBFiltrateModel *oldModel = self.dataSourecArr[self.selectBtn.tag-payTypeTags];
    oldModel.isSelct = NO;
    
    [sender setBackgroundImage:[UIImage imageNamed:@"filter_selected"] forState:UIControlStateNormal];
    [sender setTintColor:[UIColor redColor]];
    sender.layer.borderColor = [UIColor redColor].CGColor;
    FBFiltrateModel *model = self.dataSourecArr[sender.tag-payTypeTags];
    model.isSelct = YES;
    
    self.selectBtn = sender;
    
    //多选处理方法
//    if ((sender.tag-payTypeTags) == 0) {
//        for (int i = 0; i<self.selectPayTypeArr.count; i++) {
//            UIButton *tempBtn = self.selectPayTypeArr[i];
//            FBFiltrateModel *model = self.dataSourecArr[i];
//            if (i == 0) {
//                model.isSelct = YES;
//                [sender setBackgroundImage:[UIImage imageNamed:@"filter_selected"] forState:UIControlStateNormal];
//                [sender setTintColor:[UIColor redColor]];
//                sender.layer.borderColor = [UIColor redColor].CGColor;
//            }else{
//                model.isSelct = NO;
//                [tempBtn setTintColor:[UIColor lightGrayColor]];
//                tempBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
//                [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
//            }
//        }
//    }else{
//        FBFiltrateModel *model = self.dataSourecArr[sender.tag-payTypeTags];
//        model.isSelct = !model.isSelct;
//        if (model.isSelct) {
//            [sender setBackgroundImage:[UIImage imageNamed:@"filter_selected"] forState:UIControlStateNormal];
//            [sender setTintColor:[UIColor redColor]];
//            sender.layer.borderColor = [UIColor redColor].CGColor;
//        }else{
//            [sender setBackgroundImage:nil forState:UIControlStateNormal];
//            [sender setTintColor:[UIColor lightGrayColor]];
//            sender.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        }
//
//        long chooseCount = self.dataSourecArr.count-1;
//        for (int i = 1; i<self.dataSourecArr.count; i++) {
//            FBFiltrateModel *model = self.dataSourecArr[i];
//            if (!model.isSelct) {
//                chooseCount--;
//            }
//        }
//        if (chooseCount == 0 ||chooseCount == self.dataSourecArr.count-1) {
//            for (int i = 0; i<self.selectPayTypeArr.count;i++) {
//                UIButton *tempBtn = self.selectPayTypeArr[i];
//                FBFiltrateModel *model = self.dataSourecArr[i];
//                if (i == 0) {
//                    model.isSelct = YES;
//                    [tempBtn setTintColor:[UIColor redColor]];
//                    tempBtn.layer.borderColor = [UIColor redColor].CGColor;
//                    [tempBtn setBackgroundImage:[UIImage imageNamed:@"filter_selected"] forState:UIControlStateNormal];
//                }else{
//                    model.isSelct = NO;
//                    [tempBtn setTintColor:[UIColor lightGrayColor]];
//                    tempBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
//                    [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
//                }
//            }
//        }else{
//            FBFiltrateModel *model = self.dataSourecArr[0];
//            model.isSelct = NO;
//            UIButton *tempBtn = self.selectPayTypeArr[0];
//            [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
//            [tempBtn setTintColor:[UIColor lightGrayColor]];
//            tempBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        }
//    }
}


//创建不同的筛选类型
- (void)createPayTypeWithArr:(NSArray *)tempArr{
    self.filterView.frame = CGRectMake(15*SCALE, CGRectGetMaxY(self.titleLabel.frame)+5*SCALE, self.filterView.frame.size.width, 40*SCALE*(tempArr.count/5 +1));
    for (int i = 0; i<tempArr.count; i++) {
        FBFiltrateModel *model = tempArr[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        // 这里限制间距，屏幕大的话可放宽cell或者间距。这里放宽cell
        button.frame = CGRectMake(((self.filterView.frame.size.width-8*SCALE*3)/4+8*SCALE)*(i%4),10*SCALE+40*SCALE*(i/4), (self.filterView.frame.size.width-8*SCALE*3)/4, 30*SCALE);
        [button setTitle:model.titleStr forState:UIControlStateNormal];
        button.titleLabel.font = FONT_OF_SIZE(14);
        button.layer.cornerRadius = 3;
        button.clipsToBounds = YES;
        button.layer.borderWidth = 1;
        [button setBackgroundColor:[UIColor whiteColor]];
        static UIColor *colorNow;
        if (model.isSelct) {
            self.selectBtn = button;
            colorNow = [UIColor redColor];
            [button setBackgroundImage:[UIImage imageNamed:@"filter_selected"] forState:UIControlStateNormal];
        }else{
            colorNow = [UIColor lightGrayColor];
        }
        [button setTintColor:colorNow];
        button.tag = payTypeTags+i;
        button.layer.borderColor = colorNow.CGColor;
        [button addTarget:self action:@selector(payTypeSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self.filterView addSubview:button];
        [self.selectPayTypeArr addObject:button];
    }
}
//初始化数据
- (void)initData{
    [self.dataSourecArr removeAllObjects];
    FBFiltrateModel *firstmodel = [[FBFiltrateModel alloc]init];
    firstmodel.isSelct = YES;
    firstmodel.titleStr = @"全部";
    firstmodel.payType = self.allKeyStr;
    [self.dataSourecArr addObject:firstmodel];
    for (int i = 0; i< self.valuesArr.count; i++) {
        FBFiltrateModel *model = [[FBFiltrateModel alloc]init];
        model.isSelct = NO;
        model.titleStr = self.valuesArr[i];
        model.payType = self.keysArr[i];
        [self.dataSourecArr addObject:model];
    }
}
#pragma mark - DatePickerViewDelegate
- (void)DatePickerView:(NSString *)year withMonth:(NSString *)month withDay:(NSString *)day withDate:(NSString *)date withTag:(NSInteger)tag{
    self.chooseTimeTextField.text = date;
    if (self.isEndTime) {
        self.endTimeStr = date;
    }else {
        self.begainTimeStr = date;
    }
    if (self.begainTimeStr != nil && self.endTimeStr != nil) {
        BOOL isMeet = [self compareWithOldTimeStr:self.begainTimeStr endTime:self.endTimeStr];
        if (!isMeet) {
            self.alarmLabel.hidden = NO;
        }else{
             self.alarmLabel.hidden = YES;
        }
    }
}
//比较开始结束时间的范围是否在3个月时间内
- (BOOL)compareWithOldTimeStr:(NSString *)begainStr endTime:(NSString *)endStr {
    BOOL isContentThree = YES;
    NSString *tempBegainStr = begainStr, *tempEndStr = endStr;
    NSString *begainTimeDateForm = [self nsstringConversionNSDate:begainStr hourMinSec:@""];
    NSString *endTimeDateForm = [self nsstringConversionNSDate:endStr hourMinSec:@""];
    if ([begainTimeDateForm compare:endTimeDateForm options:NSNumericSearch] == NSOrderedDescending) {
        // 保证endstr大于等于begainstr
        begainStr = tempEndStr;
        endStr = tempBegainStr;
    }
    NSArray *endArr = [endStr componentsSeparatedByString:@"-"];
    NSString *endYearStr = endArr[0];
    NSString *endMonthStr = endArr[1];
    NSString *endDayStr = endArr[2];
    NSString *endThreeBeforeYearStr = nil,*endThreeBeforeMonthStr = nil,*endThreeBeforeDayStr = nil;
    endThreeBeforeYearStr = endYearStr;
    endThreeBeforeDayStr = [NSString stringWithFormat:@"%d",([endDayStr intValue]+1)];
    endThreeBeforeMonthStr = [NSString stringWithFormat:@"%d",[endMonthStr intValue]-3];
    if ([endThreeBeforeMonthStr intValue] <= 0) {
        endThreeBeforeYearStr = [NSString stringWithFormat:@"%d",([endYearStr intValue]-1)];
        endThreeBeforeMonthStr = [NSString stringWithFormat:@"%d",(12+[endMonthStr intValue]-3)];
        if ([self accountDaysWithYear:endThreeBeforeYearStr month:endThreeBeforeMonthStr] < [endThreeBeforeDayStr intValue]) {
            endThreeBeforeDayStr = @"1";
            endThreeBeforeMonthStr = [NSString stringWithFormat:@"%d",([endThreeBeforeMonthStr intValue]+1)];
            if ([endThreeBeforeDayStr intValue] > 12) {
                endThreeBeforeMonthStr = @"1";
                endThreeBeforeYearStr = [NSString stringWithFormat:@"%d",[endThreeBeforeYearStr intValue] + 1];
            }
        }
    }else{
        if ([self accountDaysWithYear:endThreeBeforeYearStr month:endThreeBeforeMonthStr] < [endThreeBeforeDayStr intValue]) {
            endThreeBeforeDayStr = @"1";
            endThreeBeforeMonthStr = [NSString stringWithFormat:@"%d",([endThreeBeforeMonthStr intValue]+1)];
        }
    }
    
    NSString *lastThreeDateForm = [self nsstringConversionNSDate:[NSString stringWithFormat:@"%d-%02d-%02d",[endThreeBeforeYearStr intValue],[endThreeBeforeMonthStr intValue],[endThreeBeforeDayStr intValue]] hourMinSec:@""];
    NSString *nextBegainTimeDateForm = [self nsstringConversionNSDate:begainStr hourMinSec:@""];
    if ([nextBegainTimeDateForm compare:lastThreeDateForm options:NSNumericSearch] == NSOrderedAscending) {
        isContentThree = NO;
    }
    return isContentThree;
}
//设置当月的随机一个时间，来计算当月的天数
- (NSInteger)accountDaysWithYear:(NSString *)year month:(NSString *)month {
    NSString *dateStr = [NSString stringWithFormat:@"%@-%02d-05 12:12:12",year,[month intValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *tempDate = [dateFormatter dateFromString:dateStr];
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:tempDate];
    // dayCountOfThisMonth就是date月份的天数
    return daysInLastMonth.length;
}

//字符串转时间戳
- (NSString *)nsstringConversionNSDate:(NSString *)dateStr hourMinSec:(NSString *)lastStr{
    if (lastStr == nil || [lastStr isEqualToString:@""]) {
        lastStr = @"00:00:00";
    }
    dateStr = [NSString stringWithFormat:@"%@ %@",dateStr,lastStr];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *tempDate = [dateFormatter dateFromString:dateStr];
    //字符串转成时间戳,精确到毫秒*1000
    NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)[tempDate timeIntervalSince1970]*1000];
    return timeStr;
}

//显示时间选择器
- (void)showDatePickerView {
    [UIView animateWithDuration:0.25 animations:^{
        self.datePickerView.alpha = 1.0;
        self.timeSpeBottomView.alpha = 1.0;
    }];
}
//关闭时间选择器
- (void)closeDatePickerView {
    [UIView animateWithDuration:0.25 animations:^{
        self.datePickerView.alpha = 0.0;
        self.timeSpeBottomView.alpha = 0.0;
    }];
}


#pragma mark -----------lazy

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(15*SCALE, 20*SCALE, 80*SCALE, 14*SCALE);
        _titleLabel.textColor = RGBACOLOR(153, 153, 153, 1);
        _titleLabel.font = FONT_OF_SIZE(15);
    }
    return _titleLabel;
}
- (UIView *)filterView {
    if (!_filterView) {
        _filterView = [[UIView alloc]initWithFrame:CGRectMake(15*SCALE, CGRectGetMaxY(self.titleLabel.frame)+5*SCALE, self.reactFrame.size.width-30*SCALE, 40*SCALE)];
    }
    return _filterView;
}
- (UILabel *)subLabel {
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.frame = CGRectMake(15*SCALE, CGRectGetMaxY(self.filterView.frame)+40*SCALE, 80*SCALE, 13*SCALE);
        _subLabel.textColor = RGBACOLOR(153, 153, 153, 1);
        _subLabel.font = FONT_OF_SIZE(14);
    }
    return _subLabel;
}
- (FBTimeFiltrateView *)timeView {
    if (!_timeView) {
        _timeView = [[FBTimeFiltrateView alloc]initWithFrame:CGRectMake(15*SCALE, CGRectGetMaxY(self.subLabel.frame), W_WIDTH-30*SCALE, 95*SCALE) placeHoderArr:@[@"开始日期",@"结束日期"] back:^(UITextField * _Nonnull chooseTextField, BOOL isEndTime) {
            NSLog(@">>>>>>>>>>>%@",chooseTextField.text);
            if (self.oldTextField == nil) {
                [self showDatePickerView];
            }
            if (chooseTextField.text != nil && ![chooseTextField.text isEqualToString:@""]) {
                NSArray *dateArr = [chooseTextField.text componentsSeparatedByString:@"-"];
                [self.datePickerView scrollForAssignYear:dateArr[0] month:dateArr[1] day:dateArr[2]];
            }
            self.chooseTimeTextField = chooseTextField;
            self.isEndTime = isEndTime;
            NSString *str = nil;
            if (isEndTime) {
                str = self.endTimeStr;
            }else {
                str = self.begainTimeStr;
            }
            if (![chooseTextField isEqual:self.oldTextField]&&str == nil) {
                [self.datePickerView reset];
            }
            self.oldTextField = chooseTextField;
        }];
    }
    return _timeView;
}
- (UIView *)timeSpeTopView {
    if (!_timeSpeTopView) {
        _timeSpeTopView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.timeView.frame), self.reactFrame.size.width, 1*SCALE)];
        _timeSpeTopView.backgroundColor = RGBACOLOR(229, 229, 229, 1);
    }
    return _timeSpeTopView;
}
- (UIView *)timeSpeBottomView {
    if (!_timeSpeBottomView) {
        _timeSpeBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.datePickerView.frame), self.reactFrame.size.width, 1*SCALE)];
        _timeSpeBottomView.backgroundColor = RGBACOLOR(229, 229, 229, 1);
        _timeSpeBottomView.alpha = 0.0;
    }
    return _timeSpeBottomView;
}
- (UILabel *)alarmLabel {
    if (!_alarmLabel) {
        _alarmLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.timeSpeBottomView.frame)+15*SCALE, W_WIDTH, 13*SCALE)];
        _alarmLabel.textAlignment = NSTextAlignmentCenter;
        _alarmLabel.text = @"目前仅支持查找3个月明细";
        _alarmLabel.textColor = RGBACOLOR(240, 65, 68, 1);
        _alarmLabel.font = FONT_OF_SIZE(14);
        _alarmLabel.hidden = YES;
    }
    return _alarmLabel;
}
- (UIButton *)resetBtn {
    if (!_resetBtn) {
        _resetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _resetBtn.frame = CGRectMake(15*SCALE+W_WIDTH/2*0, self.bgScroll.contentSize.height-42*SCALE-45*SCALE, W_WIDTH/2-30*SCALE, 45*SCALE);
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [_resetBtn setTintColor:RGBACOLOR(102, 102, 102, 102)];
        [_resetBtn setBackgroundColor:[UIColor whiteColor]];
        _resetBtn.layer.cornerRadius = 4;
        _resetBtn.clipsToBounds = YES;
        _resetBtn.titleLabel.font = [UIFont systemFontOfSize:18*SCALE];
        _resetBtn.tag = chooseBtnTags+0;
        [_resetBtn addTarget:self action:@selector(resetBtnChoose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}
- (UIButton *)ensureBtn {
    if (!_ensureBtn) {
        _ensureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _ensureBtn.frame = CGRectMake(15*SCALE+W_WIDTH/2*1, CGRectGetMinY(self.resetBtn.frame), W_WIDTH/2-30*SCALE, self.resetBtn.frame.size.height);
        [_ensureBtn setTitle:@"确认" forState:UIControlStateNormal];
        [_ensureBtn setTintColor:[UIColor whiteColor]];
        [_ensureBtn setBackgroundColor:RGBACOLOR(240, 65, 68, 1)];
        _ensureBtn.layer.cornerRadius = 4;
        _ensureBtn.clipsToBounds = YES;
        _ensureBtn.titleLabel.font = [UIFont systemFontOfSize:18*SCALE];
        _ensureBtn.tag = chooseBtnTags+1;
        [_ensureBtn addTarget:self action:@selector(ensureBtnChoose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ensureBtn;
}
- (UIScrollView *)bgScroll {
    if (!_bgScroll) {
        _bgScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.reactFrame.size.width, self.reactFrame.size.height)];
    }
    return _bgScroll;
}
- (FBDatePickerView *)datePickerView {
    if (!_datePickerView) {
        _datePickerView = [[FBDatePickerView alloc]initWithFrame:CGRectMake(W_WIDTH/2-130, CGRectGetMaxY(self.timeSpeTopView.frame), 260, 220) withTimeShowMode:ShowTimeBeforeToday withIsShowTodayDate:YES ];
        _datePickerView.delegate = self;
        _datePickerView.alpha = 0.0;
    }
    return _datePickerView;
}

- (NSMutableArray *)selectPayTypeArr{
    if (!_selectPayTypeArr) {
        _selectPayTypeArr = [NSMutableArray array];
    }
    return _selectPayTypeArr;
}
- (NSMutableArray *)dataSourecArr{
    if (!_dataSourecArr) {
        _dataSourecArr = [NSMutableArray array];
    }
    return _dataSourecArr;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
