//
//  FBFiltrateModel.h
//  FSFuBei
//
//  Created by 曹世鑫 on 2018/6/12.
//  Copyright © 2018年 曹世鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBFiltrateModel : NSObject
//是否选中
@property (nonatomic, assign)BOOL isSelct;
//标题文字内容
@property (nonatomic, copy)NSString *titleStr;
//支付的方式标记信息
@property (nonatomic, copy)NSString *payType;
@end
