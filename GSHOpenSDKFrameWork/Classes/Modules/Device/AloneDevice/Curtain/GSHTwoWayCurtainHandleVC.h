//
//  GSHTwoWayCurtainHandleVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    GSHTwoWayCurtainMotorHandleVC,  // 窗帘电机
    GSHTwoWayCurtainHandleVCOneWay, // 一路窗帘开关
    GSHTwoWayCurtainHandleVCTwoWay, // 二路窗帘开关
} GSHTwoWayCurtainHandleVCType;

@interface GSHTwoWayCurtainHandleVC : GSHDeviceVC

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

+ (instancetype)twoWayCurtainHandleVCWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType type:(GSHTwoWayCurtainHandleVCType)type;


@end

NS_ASSUME_NONNULL_END
