//
//  GSHGateMagnetismSetVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/11/12.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHGateMagnetismSetVC : GSHDeviceVC

+ (instancetype)gateMagnetismSetVCWithDeviceM:(GSHDeviceM *)deviceM;

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

@end

NS_ASSUME_NONNULL_END
