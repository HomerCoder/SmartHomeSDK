//
//  GSHVoiceTabBar.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHVoiceTabBar : UITabBar

@property (nonatomic, weak) UIButton *voiceButton;

@property (nonatomic, copy) void(^voiceButtonClickBlock)(void);

@end
