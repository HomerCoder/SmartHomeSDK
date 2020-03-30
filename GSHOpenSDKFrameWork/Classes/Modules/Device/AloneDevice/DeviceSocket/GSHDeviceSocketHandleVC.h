//
//  GSHDeviceSocketHandleVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/9/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

@interface GSHDeviceSocketHandleVC : GSHDeviceVC
@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);
+ (instancetype)deviceSocketHandleVCDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType;
@end
