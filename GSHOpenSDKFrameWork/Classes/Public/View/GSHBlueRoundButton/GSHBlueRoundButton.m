//
//  GSHBlueRoundButton.m
//  SmartHome
//
//  Created by gemdale on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBlueRoundButton.h"

@interface GSHBlueRoundButton ()
@property(nonatomic,strong)CAGradientLayer *gradientLayer;
@end

@implementation GSHBlueRoundButton
-(instancetype)init{
    self = [super init];
    if (self) {
        self.gradientLayer = [CAGradientLayer layer];
        [self.layer addSublayer:self.gradientLayer];
        self.gradientLayer.startPoint = CGPointMake(0, 0);
        self.gradientLayer.endPoint = CGPointMake(1, 0);
        self.gradientLayer.locations = @[@(0.0f), @(1.0f)];
        self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0x3CC5FF].CGColor,
                                      (__bridge id)[UIColor colorWithRGB:0x1C93FF].CGColor];
        
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.clipsToBounds = YES;
        self.gradientLayer.hidden = NO;
        self.backgroundColor = [UIColor clearColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.layer.borderWidth = 0;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.gradientLayer = [CAGradientLayer layer];
        [self.layer addSublayer:self.gradientLayer];
        self.gradientLayer.startPoint = CGPointMake(0, 0);
        self.gradientLayer.endPoint = CGPointMake(1, 0);
        self.gradientLayer.locations = @[@(0.0f), @(1.0f)];
        self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0x3CC5FF].CGColor,
                                      (__bridge id)[UIColor colorWithRGB:0x1C93FF].CGColor];
        
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.clipsToBounds = YES;
        self.gradientLayer.hidden = NO;
        self.backgroundColor = [UIColor clearColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.layer.borderWidth = 0;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.gradientLayer.size = self.size;
}

-(void)setZ_isWhiteGround:(BOOL)z_isWhiteGround{
    _z_isWhiteGround = z_isWhiteGround;
    if (self.enabled) {
        if (_z_isWhiteGround) {
            self.gradientLayer.hidden = YES;
            self.backgroundColor = [UIColor clearColor];
            [self setTitleColor:[UIColor colorWithHexString:@"#2EB0FF"] forState:UIControlStateNormal];
            self.layer.borderColor = [UIColor colorWithHexString:@"#2EB0FF"].CGColor;
            self.layer.borderWidth = 1;
        }else{
            self.gradientLayer.hidden = NO;
            self.backgroundColor = [UIColor clearColor];
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.layer.borderWidth = 0;
        }
    }else{
        if (_z_isWhiteGround) {
            self.gradientLayer.hidden = YES;
            self.backgroundColor = [UIColor clearColor];
            [self setTitleColor:[UIColor colorWithHexString:@"#dedede"] forState:UIControlStateNormal];
            self.layer.borderColor = [UIColor colorWithHexString:@"#dedede"].CGColor;
            self.layer.borderWidth = 1;
        }else{
            self.gradientLayer.hidden = YES;
            self.backgroundColor = [UIColor colorWithRGB:0xBCE3FB];
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.layer.borderWidth = 0;
        }
    }
}

-(void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    if (enabled) {
        if (_z_isWhiteGround) {
            self.gradientLayer.hidden = YES;
            self.backgroundColor = [UIColor clearColor];
            [self setTitleColor:[UIColor colorWithHexString:@"#2EB0FF"] forState:UIControlStateNormal];
            self.layer.borderColor = [UIColor colorWithHexString:@"#2EB0FF"].CGColor;
            self.layer.borderWidth = 1;
        }else{
            self.gradientLayer.hidden = NO;
            self.backgroundColor = [UIColor clearColor];
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.layer.borderWidth = 0;
        }
    }else{
        if (_z_isWhiteGround) {
            self.gradientLayer.hidden = YES;
            self.backgroundColor = [UIColor clearColor];
            [self setTitleColor:[UIColor colorWithHexString:@"#dedede"] forState:UIControlStateNormal];
            self.layer.borderColor = [UIColor colorWithHexString:@"#dedede"].CGColor;
            self.layer.borderWidth = 1;
        }else{
            self.gradientLayer.hidden = YES;
            self.backgroundColor = [UIColor colorWithRGB:0xBCE3FB];
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.layer.borderWidth = 0;
        }
    }
}

@end
