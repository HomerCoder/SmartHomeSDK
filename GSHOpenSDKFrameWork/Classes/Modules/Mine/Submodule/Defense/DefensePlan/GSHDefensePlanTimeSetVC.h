//
//  GSHDefensePlanTimeSetVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/6/4.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHDefensePlanTimeSetVC : UIViewController

@property (copy , nonatomic) void (^sureButtonClickBlock)(NSString *showStr,NSString *timeStr);

+(instancetype)defensePlanTimeSetVCWithTitle:(NSString *)title timeStr:(NSString *)timeStr;

@end

NS_ASSUME_NONNULL_END
