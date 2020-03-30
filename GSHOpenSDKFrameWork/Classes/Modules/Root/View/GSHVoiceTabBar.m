//
//  GSHVoiceTabBar.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHVoiceTabBar.h"
#import "UIView+TZM.h"


@implementation GSHVoiceTabBar

+ (void)load {
    [self swizzleInstanceMethod:@selector(setFrame:) with:@selector(tzm_setFrame:)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        UIButton *voiceBtn = [[UIButton alloc] init];
//        [voiceBtn setAdjustsImageWhenHighlighted:NO];
//        UIImage *image = [UIImage ZHImageNamed:@"tab_voice_normal"];
//        [voiceBtn setImage:image forState:UIControlStateNormal];
//        [voiceBtn setImageEdgeInsets:UIEdgeInsetsMake(-14,0,0,0)];
//        voiceBtn.size = CGSizeMake(image.size.width, 49 + 14);
//        [voiceBtn addTarget:self action:@selector(voiceBtnClick) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:voiceBtn];
//        self.voiceButton = voiceBtn;
    }
    return self;
}

-(void)tzm_setFrame:(CGRect)frame{
    if (frame.size.height < self.frame.size.height) {
        frame.size.height = self.frame.size.height;
        frame.origin.y = self.frame.origin.y;
    }
    if (frame.size.height > 50) {
        if (!self.backgroundColor) {
            self.backgroundColor = [UIColor colorWithRGB:0xf9f9f9];
        }
    }
    [self tzm_setFrame:frame];
}

-(void)voiceBtnClick {
    
    if (self.voiceButtonClickBlock) {
        self.voiceButtonClickBlock();
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
//    self.voiceButton.centerX = SCREEN_WIDTH / 2;
//    self.voiceButton.centerY = 49 - self.voiceButton.frame.size.height * 0.35;
//    CGFloat tabBarButtonW = self.width / 4;
//    CGFloat tabBarButtonIndex = 0;
//    for (UIView *child in self.subviews) {
//        Class class = NSClassFromString(@"UITabBarButton");
//        if ([child isKindOfClass:class]) {
//
//            child.frame = CGRectMake(tabBarButtonIndex * tabBarButtonW, 1, tabBarButtonW, 48);
//            tabBarButtonIndex++;
//            if (tabBarButtonIndex == 2) {
//                tabBarButtonIndex++;
//            }
//        }
//    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (self.isHidden == NO) {
        CGPoint newP = [self convertPoint:point toView:self.voiceButton];
        if ([self.voiceButton pointInside:newP withEvent:event]) {
            return self.voiceButton;
        } else {
            return [super hitTest:point withEvent:event];
        }
    } else {
        return [super hitTest:point withEvent:event];
    }
    
}

@end
