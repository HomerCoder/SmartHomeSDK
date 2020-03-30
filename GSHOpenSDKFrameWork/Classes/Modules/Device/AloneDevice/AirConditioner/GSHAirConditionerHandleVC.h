//
//  GSHAirConditionerHandleVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/6.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"


@interface GSHAirConditionerHandleVC : GSHDeviceVC

+ (instancetype)airConditionerHandleVCWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType;

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

@end
