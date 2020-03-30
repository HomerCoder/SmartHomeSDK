//
//  GSHAirConditionerSetVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/10/30.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHAirConditionerSetVC : GSHDeviceVC

+ (instancetype)airConditionerSetVCWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType;

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

@end

NS_ASSUME_NONNULL_END
