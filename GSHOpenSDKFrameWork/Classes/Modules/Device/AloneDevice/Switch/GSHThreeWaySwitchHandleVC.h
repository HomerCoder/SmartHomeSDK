//
//  GSHThreeWaySwitchHandleVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/6.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"


typedef NS_ENUM(NSInteger, SwitchHandleVCType) {
    SwitchHandleVCTypeOneWay  = 0,  // 一路智能开关
    SwitchHandleVCTypeTwoWay   = 1,  // 二路智能开关
    SwitchHandleVCTypeThreeWay  = 2,  // 三路智能开关
};

@interface GSHThreeWaySwitchHandleVC : GSHDeviceVC

@property (nonatomic, assign) SwitchHandleVCType switchType;

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

+ (instancetype)threeWaySwitchHandleVCWithDeviceM:(GSHDeviceM*)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType;

@end
