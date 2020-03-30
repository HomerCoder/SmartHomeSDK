//
//  JKCircleView.m
//  JKCircleWidget
//
//
//  Created by kunge on 16/8/31.
//  Copyright © 2016年 kunge. All rights reserved.
//

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * (degrees))/ 180)

#import "JKCircleView.h"
#import <math.h>
#import <QuartzCore/QuartzCore.h>

@interface JKCircleView () <UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer *panGesture;
}

// dial appearance
@property CGFloat dialRadius;

// background circle appeareance
@property CGFloat outerRadius;  // don't set this unless you want some squarish appearance
@property CGFloat arcRadius; // must be less than the outerRadius since view clips to bounds
@property CGFloat arcThickness;
@property CGPoint trueCenter;
@property UILabel *numberLabel;
@property UIImageView *iconImage;

@property int currentNum;
@property double angle;
@property UIImageView *circle;

//圆环弧度(0-360)
@property (nonatomic, assign) CGFloat circleRadian;

@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UIImageView *AdjustLightImageView;

//进度 [0...1]
@property(nonatomic,assign) CGFloat progress;

@property(nonatomic,assign) BOOL isCanSlide;

@property(nonatomic,assign) BOOL isAdjustLight;

@property CGFloat startAngle; // must be less than the outerRadius since view clips to bounds
@property CGFloat endAngle;

@end

@implementation JKCircleView


# pragma mark view appearance setup

- (id)initShengBiKeWithFrame:(CGRect)frame startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    self = [super initWithFrame:frame];
    if(self) {
        // overall view settings
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        self.startAngle = startAngle;
        self.endAngle = endAngle;
        self.circleRadian = startAngle + (360 - endAngle);
        
        // setting default values
        self.minNum = 0;
        self.maxNum = 100;
        self.currentNum = self.minNum;
        self.units = @"";
        self.iconName = @"shengBiKePlayVC_huaKuai_time";
        
        // determine true center of view for calculating angle and setting up arcs
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        self.trueCenter = CGPointMake(width/2, height/2);
        
        // radii settings
        self.dialRadius = 7;
        self.arcRadius = 200;
        self.outerRadius = MIN(width, height)/2;
        self.arcThickness = 2;
        
        _trackLayer = [CAShapeLayer layer];
        _trackLayer.frame = self.bounds;
        _trackLayer.fillColor = [UIColor clearColor].CGColor;
        _trackLayer.strokeColor = [UIColor colorWithRGB:0xDEDEDE].CGColor;
        _trackLayer.opacity = 1;//背景圆环的背景透明度
        _trackLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_trackLayer];
        
        self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);
        UIBezierPath *path=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                          radius:self.arcRadius startAngle:DEGREES_TO_RADIANS(360 - self.startAngle) endAngle:DEGREES_TO_RADIANS(360 - self.endAngle) clockwise:YES];//-210到30的path
        _trackLayer.path = path.CGPath;
        _trackLayer.lineWidth = self.arcThickness;
        
        //2.进度轨道
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [[UIColor clearColor] CGColor];
        _progressLayer.strokeColor = [UIColor colorWithRGB:0x2EB0FF].CGColor;//!!!不能用clearColor
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeEnd = 0.0;
        [self.layer addSublayer:_progressLayer];
        
        self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);

       
        UIBezierPath *path1=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:self.arcRadius startAngle:DEGREES_TO_RADIANS(360 - self.startAngle) endAngle:DEGREES_TO_RADIANS(360 - self.endAngle) clockwise:YES];//-210到30的path

        _progressLayer.path = path1.CGPath;
        _progressLayer.lineWidth = self.arcThickness;
        
        CGPoint newCenter = CGPointMake(width/2, height/2);
        newCenter.y += self.arcRadius * sin(M_PI/180 * (270));
        newCenter.x += self.arcRadius * cos(M_PI/180 * (90));
        
        self.circle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        self.circle.userInteractionEnabled = YES;
        self.circle.layer.cornerRadius = 14;
        self.circle.backgroundColor = [UIColor clearColor];
        self.circle.contentMode = UIViewContentModeCenter;
        self.circle.center = newCenter;
        self.circle.image = [UIImage ZHImageNamed:@"shengBiKePlayVC_huaKuai_time"];
        [self addSubview: self.circle];
        
        // pan gesture detects circle dragging
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    self = [super initWithFrame:frame];
    if(self) {
        // overall view settings
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        // setting default values
        self.minNum = 0;
        self.maxNum = 100;
        self.currentNum = self.minNum;
        self.units = @"";
        self.iconName = @"";
        self.startAngle = startAngle;
        self.endAngle = endAngle;
        self.circleRadian = startAngle + (360 - endAngle);
        
        // determine true center of view for calculating angle and setting up arcs
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        self.trueCenter = CGPointMake(width/2, height/2);
        
        // radii settings
        self.dialRadius = 10;
        self.arcRadius = 80;
        self.outerRadius = MIN(width, height)/2;
        self.arcThickness = 10.0;
        
        _trackLayer = [CAShapeLayer layer];
        _trackLayer.frame = self.bounds;
        _trackLayer.fillColor = [UIColor clearColor].CGColor;
        _trackLayer.strokeColor = [UIColor colorWithRGB:0xDEDEDE].CGColor;
        _trackLayer.opacity = 1;//背景圆环的背景透明度
        _trackLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_trackLayer];
        
        
        self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);
        UIBezierPath *path=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                          radius:self.arcRadius startAngle:DEGREES_TO_RADIANS(360 - self.startAngle) endAngle:DEGREES_TO_RADIANS(360 - self.endAngle) clockwise:YES];//-210到30的path
        _trackLayer.path = path.CGPath;
        _trackLayer.lineWidth = self.arcThickness;
        
        //2.进度轨道
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [[UIColor clearColor] CGColor];
        _progressLayer.strokeColor = [UIColor colorWithRGB:0x2EB0FF].CGColor;//!!!不能用clearColor
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeEnd = 0.0;
        [self.layer addSublayer:_progressLayer];
        
        self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);

       
        UIBezierPath *path1=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:self.arcRadius startAngle:DEGREES_TO_RADIANS(360 - self.startAngle) endAngle:DEGREES_TO_RADIANS(360 - self.endAngle) clockwise:YES];//-210到30的path

        _progressLayer.path = path1.CGPath;
        _progressLayer.lineWidth = self.arcThickness;
        
        CGPoint newCenter = CGPointMake(width/2, height/2);
        newCenter.y += self.arcRadius * sin(M_PI/180 * (45));
        newCenter.x += self.arcRadius * cos(M_PI/180 * (135));
        
        self.circle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        self.circle.userInteractionEnabled = YES;
        self.circle.layer.cornerRadius = 14;
        self.circle.backgroundColor = [UIColor clearColor];
        self.circle.center = newCenter;
        self.circle.image = [UIImage ZHImageNamed:@"conditioner_heating_icon_wendu"];
        [self addSubview: self.circle];
        
        // pan gesture detects circle dragging
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    
    self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);
    
    // label
    self.numberLabel.text = [NSString stringWithFormat:@"%d %@", self.currentNum, self.units];
    
    self.iconImage.image = [UIImage ZHImageNamed:self.iconName];
    
//    [self moveCircleToAngle:0];
    
}

# pragma mark move circle in response to pan gesture
- (void)moveCircleToAngle:(double)angle isSendRequest:(BOOL)isSendRequest {
    double s = 0;
    double e = self.endAngle - self.startAngle;
    double a = angle - self.startAngle;
    if (a < 0) {
        a = a + 360;
    }
    if (e < 0) {
        e = e + 360;
    }
    if (a < e / 2 && a > 0) {
        a = s;
    }
    if (a > e / 2 && a < e) {
        a = e;
    }
    
    if (self.endAngle < self.startAngle) {
        self.currentNum = self.minNum + (self.maxNum - self.minNum) * (a / self.circleRadian) + 0.5;
    }else{
        self.currentNum = self.minNum + (self.maxNum - self.minNum) * ((self.circleRadian - ((a == 0) ? 360 : a)  + e) / self.circleRadian) + 0.5;
    }
    
    angle = a + self.startAngle;
    angle = angle > 360 ? angle - 360 : angle;
    self.angle = angle;

    CGPoint newCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    newCenter.y -= self.arcRadius * sin(M_PI/180 * (angle));
    newCenter.x += self.arcRadius * cos(M_PI/180 * (angle));
    self.circle.center = newCenter;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:1];

    NSLog(@"currentNum = %d",self.currentNum);
    _progressLayer.strokeEnd = (self.currentNum - self.minNum) * 1.0 / (self.maxNum - self.minNum);
    if (self.progressChange) {
        self.progressChange([NSString stringWithFormat:@"%d",self.currentNum],isSendRequest);
    }
    [CATransaction commit];
}

- (void)setProgressWithProgress:(CGFloat)progress isSendRequest:(BOOL)isSendRequest {
    _progress = progress;
    NSLog(@"progress : %f",progress);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:1];
    progress = progress < 0.0 ? 0.0 : progress;
    progress = progress > 1.0 ? 1.0 : progress;
    _progressLayer.strokeEnd = progress;
    
    CGPoint newCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    double angle = self.startAngle - progress * self.circleRadian;
    self.angle = angle;
    newCenter.y -= self.arcRadius * sin(M_PI/180 * (angle));
    newCenter.x += self.arcRadius * cos(M_PI/180 * (angle));
    self.circle.center = newCenter;
    
    self.currentNum = self.minNum + (self.maxNum - self.minNum)*progress;
    self.numberLabel.text = [NSString stringWithFormat:@"%d %@˚C", self.currentNum, self.units];
    if (self.progressChange) {
        self.progressChange([NSString stringWithFormat:@"%d",self.currentNum],isSendRequest);
    }
    [CATransaction commit];
}

-(void)setEnableCustom:(CGFloat)enableCustom{
    _enableCustom = enableCustom;
    if (_enableCustom) {
        self.circle.userInteractionEnabled = YES;
        self.circle.hidden = NO;
        [self addGestureRecognizer:panGesture];
    }else{
        self.circle.userInteractionEnabled = NO;
        self.circle.hidden = YES;
        [self removeGestureRecognizer:panGesture];
    }
    
    if (_isAdjustLight) {
        if (!_enableCustom) {
            self.trackLayer.hidden = NO;
            self.AdjustLightImageView.hidden = YES;
        }else{
            self.trackLayer.hidden = YES;
            self.AdjustLightImageView.hidden = NO;
        }
    }
}

- (void)setIsCanSlideTemperature:(BOOL)isCanSlide {
    self.isCanSlide = isCanSlide;
    self.circle.hidden = !isCanSlide;
}

# pragma mark detect pan and determine angle of pan location vs. center of circular revolution

- (void)handlePan:(UIPanGestureRecognizer *)pv {
    if (!self.isCanSlide) {
        return;
    }
    
    CGPoint translation = [pv locationInView:self];
    CGFloat x_displace = translation.x - self.trueCenter.x;
    CGFloat y_displace = -1.0*(translation.y - self.trueCenter.y);
    
    double angle = 0;
    if (x_displace < 0.01 && x_displace > -0.01) {
        if (y_displace > 0) {
            angle = M_PI / 2;
        }else{
            angle = M_PI / 2 * 3;
        }
    }else{
        angle = atan(y_displace/x_displace);
    }
    if (x_displace < 0 ) {
        angle = angle + M_PI;
    }
    
    if (x_displace > 0 && y_displace < 0) {
        angle = angle + 2 * M_PI;
    }
    BOOL isSendRequest = NO;
    if (pv.state == UIGestureRecognizerStateEnded) {
        isSendRequest = YES;
    }
    angle = angle / M_PI * 180;
    [self moveCircleToAngle:angle isSendRequest:isSendRequest];
}


@end
