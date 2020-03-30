//
//  TZMSlider.m
//  SmartHome
//
//  Created by gemdale on 2019/10/11.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "TZMSlider.h"

@interface TZMSlider ()
@property(nonatomic,strong)CAGradientLayer *gradientLayer;

@end

@implementation TZMSlider

-(CGRect)trackRectForBounds:(CGRect)bounds{
    CGRect rect = [super trackRectForBounds:bounds];
    rect.size.height = bounds.size.height / 3;
    rect.origin.y = bounds.size.height / 3;
    return rect;
}

-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value{
    CGRect rect1 = [super thumbRectForBounds:bounds trackRect:rect value:value];
    if (self.isClose) {
        rect1.origin.x = -1000;
    }
    return rect1;
}

-(void)setIsClose:(BOOL)isClose{
    _isClose = isClose;
    if (!isClose) {
        self.gradientLayer.hidden = NO;
        if (_isGradual) {
            self.maximumTrackTintColor = [UIColor clearColor];
        }else{
            self.maximumTrackTintColor = [UIColor colorWithRGB:0xDEDEDE];
        }
    }else{
        self.maximumTrackTintColor = [UIColor colorWithRGBA:0x2828384d];
        self.gradientLayer.hidden = YES;
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.gradientLayer.frame = [self trackRectForBounds:self.bounds];
    self.gradientLayer.cornerRadius = self.gradientLayer.size.height / 2;
}

-(void)setIsGradual:(BOOL)isGradual{
    _isGradual = isGradual;
    if (_isGradual) {
        self.minimumTrackTintColor = [UIColor clearColor];
        if (!self.gradientLayer) {
            self.gradientLayer =  [CAGradientLayer layer];
            [self.gradientLayer setColors:@[(id)[UIColor colorWithRGB:0xFFD88A].CGColor,(id)[UIColor colorWithRGB:0xF0FAFF].CGColor]];
            [self.gradientLayer setStartPoint:CGPointMake(0, 0)];
            [self.gradientLayer setEndPoint:CGPointMake(1, 0)];
            [self.layer insertSublayer:self.gradientLayer atIndex:0];
        }
        if (_isClose) {
            self.gradientLayer.hidden = YES;
            self.maximumTrackTintColor = [UIColor colorWithRGBA:0x2828384d];
        }else{
            self.maximumTrackTintColor = [UIColor clearColor];
            self.gradientLayer.hidden = NO;
        }
    }
}
@end
