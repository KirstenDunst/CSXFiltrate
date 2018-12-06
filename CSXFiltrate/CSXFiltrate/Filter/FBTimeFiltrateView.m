//
//  FBTimeFiltrateView.m
//  filter
//
//  Created by 曹世鑫 on 2018/12/4.
//  Copyright © 2018 曹世鑫. All rights reserved.
//

#import "FBTimeFiltrateView.h"
#import "ICMacro.h"

typedef enum:NSInteger{
    timeChooseTags = 1000,
}TimeChooseTags;

typedef void(^ChooseTextBlock)(UITextField *chooseTextField,BOOL isEndTime);

@interface FBTimeFiltrateView ()<UITextFieldDelegate>
@property (nonatomic, assign)CGRect reactFrame;
@property (nonatomic, strong)UITextField *begainTimeTextField;
@property (nonatomic, strong)UITextField *endTimeTextField;
@property (nonatomic, strong)UIView *begainTimeSpeView;
@property (nonatomic, strong)UIView *endTimeSpeView;
@property (nonatomic, strong)UIButton *clearBtn;
@property (nonatomic, copy) ChooseTextBlock chooseBlock;
@end

@implementation FBTimeFiltrateView

- (instancetype)initWithFrame:(CGRect)frame placeHoderArr:(NSArray *)placehoderStrArr back:(void(^)(UITextField *chooseTextField,BOOL isEndTime))block {
    self = [super initWithFrame:frame];
    if (self) {
        self.chooseBlock = block;
        self.reactFrame = frame;
        [self createViewWithPlaceHoderArr:placehoderStrArr];
    }
    return self;
}
- (void)createViewWithPlaceHoderArr:(NSArray *)placeHoderArr {
    for (int i = 0; i < placeHoderArr.count; i++) {
        UITextField *contentText = [[UITextField alloc]initWithFrame:CGRectMake((self.reactFrame.size.width/2+14*SCALE)*i, 11*SCALE, self.reactFrame.size.width/2-14*SCALE, 39*SCALE)];
        contentText.placeholder = placeHoderArr[i];
        contentText.tag = timeChooseTags + i;
        contentText.textColor = RGBACOLOR(51, 51, 51, 1);
        contentText.delegate = self;
        contentText.textAlignment = NSTextAlignmentCenter;
        contentText.font = FONT_OF_SIZE(14);
        [self addSubview:contentText];
        UIView *view = [[UIView alloc]init];
        view.frame = CGRectMake((self.reactFrame.size.width/2+14*SCALE)*i, 50*SCALE, self.reactFrame.size.width/2-14*SCALE, 1*SCALE);
        view.backgroundColor = RGBACOLOR(204, 204, 204, 1);
        [self addSubview:view];
        if (i == 0) {
            self.begainTimeTextField = contentText;
            self.begainTimeSpeView = view;
        }else {
            self.endTimeTextField = contentText;
            self.endTimeSpeView = view;
        }
    }
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(self.reactFrame.size.width/2-14*SCALE, 25*SCALE, 28*SCALE, 13*SCALE);
    label.text = @"至";
    label.textColor = RGBACOLOR(102, 102, 102, 1);
    label.font = FONT_OF_SIZE(14);
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    [self addSubview:self.clearBtn];
}
- (void)clearBtnChoose {
    self.begainTimeTextField.text = nil;
    self.endTimeTextField.text = nil;
    self.begainTimeTextField.textColor = RGBACOLOR(51, 51, 51, 1);
    self.begainTimeSpeView.backgroundColor = RGBACOLOR(204, 204, 204, 1);
    self.endTimeTextField.textColor = RGBACOLOR(51, 51, 51, 1);
    self.endTimeSpeView.backgroundColor = RGBACOLOR(204, 204, 204, 1);
    self.clearChoose();
}
#pragma mark ----UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.begainTimeTextField]) {
        self.begainTimeTextField.textColor = RGBACOLOR(240, 65, 68, 1);
        self.begainTimeSpeView.backgroundColor = RGBACOLOR(240, 65, 68, 1);
        self.endTimeTextField.textColor = RGBACOLOR(51, 51, 51, 1);
        self.endTimeSpeView.backgroundColor = RGBACOLOR(204, 204, 204, 1);
    }else {
        self.begainTimeTextField.textColor = RGBACOLOR(51, 51, 51, 1);
        self.begainTimeSpeView.backgroundColor = RGBACOLOR(204, 204, 204, 1);
        self.endTimeTextField.textColor = RGBACOLOR(240, 65, 68, 1);
        self.endTimeSpeView.backgroundColor = RGBACOLOR(240, 65, 68, 1);
    }
    if (self.chooseBlock) {
        self.chooseBlock(textField,textField.tag-timeChooseTags);
    }
    return NO;
}


#pragma mark -----lazy
- (UIButton *)clearBtn {
    if (!_clearBtn) {
        UIImage *clearImage = [UIImage imageNamed:@"filtrate_clear"];
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setImage:clearImage forState:UIControlStateNormal];
        [_clearBtn addTarget:self action:@selector(clearBtnChoose) forControlEvents:UIControlEventTouchUpInside];
        _clearBtn.frame = CGRectMake(self.reactFrame.size.width-clearImage.size.width, (50+45/2)*SCALE-clearImage.size.height/2, clearImage.size.width, clearImage.size.height);
    }
    return _clearBtn;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
