//
//  GSHSDKTransitionViewController.h
//  SmartHome
//
//  Created by zhanghong on 2020/3/15.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHSDKTransitionViewController : UIViewController

@property (copy , nonatomic) void (^jumpSuccessBlock)(void);

@end

NS_ASSUME_NONNULL_END
