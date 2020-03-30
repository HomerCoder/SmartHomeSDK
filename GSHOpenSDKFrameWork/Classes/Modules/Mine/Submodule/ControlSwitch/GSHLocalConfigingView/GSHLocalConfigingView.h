//
//  GSHLocalConfigingView.h
//  SmartHome
//
//  Created by zhanghong on 2019/2/22.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHLocalConfigingView : UIView

@property (copy, nonatomic) void (^closeButtonClickBlock)(void);

@property (weak, nonatomic) IBOutlet UIImageView *gifImageView;
@property (weak, nonatomic) IBOutlet UIView *receiveBroadCastView;
@property (weak, nonatomic) IBOutlet UIView *configSuccessView;

@end

NS_ASSUME_NONNULL_END
