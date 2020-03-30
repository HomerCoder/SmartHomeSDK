//
//  GSHConfigLocalControlVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/2/21.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const GSHControlSwitchSuccess;

@interface GSHConfigLocalControlVC : UIViewController

@property (nonatomic , strong) GSHFamilyM *familyM;

+ (instancetype)configLocalControlVC;

@end

NS_ASSUME_NONNULL_END
