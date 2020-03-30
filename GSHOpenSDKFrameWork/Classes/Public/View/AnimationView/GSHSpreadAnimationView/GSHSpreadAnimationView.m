//
//  GSHSpreadAnimationView.m
//  SmartHome
//
//  Created by gemdale on 2018/9/5.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSpreadAnimationView.h"

@interface GSHSpreadAnimationView ()
@property(nonatomic,strong)UIView *gardenView1;
@property(nonatomic,strong)UIView *gardenView2;
@property(nonatomic,strong)UIView *gardenView3;
@property (nonatomic, strong) CAAnimationGroup *imageViewAnimation1;
@property (nonatomic, strong) CAAnimationGroup *imageViewAnimation2;
@property (nonatomic, strong) CAAnimationGroup *imageViewAnimation3;
@end

@implementation GSHSpreadAnimationView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self buildData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self buildData];
    }
    return self;
}

//初始化数据
-(void)buildData{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:self.bounds.size];
    
    //缩放动画
    CABasicAnimation *scaleAnima = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnima.fromValue = [NSNumber numberWithFloat:0.0f];
    scaleAnima.toValue = [NSNumber numberWithFloat:1.0f];
    //旋转动画
    CABasicAnimation *opacityAnima = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnima.fromValue = [NSNumber numberWithFloat:1.0f];
    opacityAnima.toValue = [NSNumber numberWithFloat:0.0f];
    //组动画
    self.imageViewAnimation1 = [CAAnimationGroup animation];
    self.imageViewAnimation1.animations = [NSArray arrayWithObjects:scaleAnima,opacityAnima,nil];
    self.imageViewAnimation1.duration = 2.0f;
    self.imageViewAnimation1.repeatCount = HUGE_VALF;
    self.imageViewAnimation1.beginTime = CACurrentMediaTime() + 0;
    
    //组动画
    self.imageViewAnimation2 = [CAAnimationGroup animation];
    self.imageViewAnimation2.animations = [NSArray arrayWithObjects:scaleAnima,opacityAnima,nil];
    self.imageViewAnimation2.duration = 2.0f;
    self.imageViewAnimation2.repeatCount = HUGE_VALF;
    self.imageViewAnimation2.beginTime = CACurrentMediaTime() + 0.66;
    
    //组动画
    self.imageViewAnimation3 = [CAAnimationGroup animation];
    self.imageViewAnimation3.animations = [NSArray arrayWithObjects:scaleAnima,opacityAnima,nil];
    self.imageViewAnimation3.duration = 2.0f;
    self.imageViewAnimation3.repeatCount = HUGE_VALF;
    self.imageViewAnimation3.beginTime = CACurrentMediaTime() + 1.32;
    
    self.gardenView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.gardenView1.backgroundColor = [UIColor colorWithHexString:@"#1c93ff"];
    [self addSubview:self.gardenView1];
    CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc]init];
    maskLayer1.frame = self.gardenView1.bounds;
    maskLayer1.path = maskPath.CGPath;
    self.gardenView1.layer.mask = maskLayer1;
    
    self.gardenView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.gardenView2.backgroundColor = [UIColor colorWithHexString:@"#1c93ff"];
    [self addSubview:self.gardenView2];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc]init];
    maskLayer2.frame = self.gardenView2.bounds;
    maskLayer2.path = maskPath.CGPath;
    self.gardenView2.layer.mask = maskLayer2;

    self.gardenView3 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.gardenView3.backgroundColor = [UIColor colorWithHexString:@"#1c93ff"];
    [self addSubview:self.gardenView3];
    CAShapeLayer *maskLayer3 = [[CAShapeLayer alloc]init];
    maskLayer3.frame = self.gardenView3.bounds;
    maskLayer3.path = maskPath.CGPath;
    self.gardenView3.layer.mask = maskLayer3;
}

-(void)stop{
    self.animation = NO;
    [self.gardenView1.layer removeAnimationForKey:@"imageViewAnimation1"];
    [self.gardenView2.layer removeAnimationForKey:@"imageViewAnimation2"];
    [self.gardenView3.layer removeAnimationForKey:@"imageViewAnimation3"];
}

-(void)start{
    self.animation = YES;
    [self.gardenView1.layer addAnimation:self.imageViewAnimation1 forKey:@"imageViewAnimation1"];
    [self.gardenView2.layer addAnimation:self.imageViewAnimation2 forKey:@"imageViewAnimation2"];
    [self.gardenView3.layer addAnimation:self.imageViewAnimation3 forKey:@"imageViewAnimation3"];
}

@end
