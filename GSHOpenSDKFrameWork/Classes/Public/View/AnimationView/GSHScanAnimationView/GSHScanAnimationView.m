//
//  GSHScanAnimationView.m
//  SmartHome
//
//  Created by gemdale on 2018/7/5.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHScanAnimationView.h"
#import "NSObject+TZM.h"


@interface GSHScanAnimationViewProxy : NSProxy
@property (nonatomic,weak)id obj;
@end

@implementation GSHScanAnimationViewProxy
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *sig = nil;
    sig = [self.obj methodSignatureForSelector:aSelector];
    return sig;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    [anInvocation invokeWithTarget:self.obj];
}
@end

@interface GSHScanAnimationView ()<CAAnimationDelegate>
@property (nonatomic, strong) GSHScanAnimationViewProxy *proxy;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableArray<UIBezierPath*> *pathList;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CABasicAnimation *imageViewAnimation;

@property (nonatomic, assign) CGFloat number;//第几针
@end


@implementation GSHScanAnimationView

- (void)dealloc{
    [self.displayLink invalidate];
    [self removeNotifications];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self buildData];
        [self observerNotifications];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self buildData];
        [self observerNotifications];
    }
    return self;
}

- (void)observerNotifications {
    [self observerNotification:UIApplicationDidBecomeActiveNotification];
}

- (void)handleNotifications:(NSNotification *)notification {
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [self start];
    }
}

//初始化数据
-(void)buildData{
    //以屏幕刷新速度为周期刷新曲线的位置
    self.pathList = [NSMutableArray array];
    
    self.imageView = [[UIImageView alloc]initWithImage:[UIImage ZHImageNamed:@"app_saomiao_slip"]];
    [self addSubview: self.imageView];
    self.imageViewAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    self.imageViewAnimation.fromValue = @(0);
    self.imageViewAnimation.toValue = @(2 * M_PI);
    self.imageViewAnimation.duration = 1;
    self.imageViewAnimation.repeatCount = HUGE_VALF;
    [self.imageView.layer addAnimation:self.imageViewAnimation forKey:@"rotationAnimation"];
    
    self.proxy = [GSHScanAnimationViewProxy alloc];
    self.proxy.obj = self;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self.proxy selector:@selector(updateScan:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.frameInterval = 1;
    self.number = 0;
    
    self.animation = YES;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width / 375 * 320;
    CGFloat height = self.bounds.size.height / 375 * 320;
    CGFloat x = self.bounds.size.width * (1 - 320.0 / 375) / 2;
    CGFloat y = self.bounds.size.height * (1 - 320.0 / 375) / 2;
    self.imageView.frame = CGRectMake(x, y, width, height);
}

-(void)updateScan:(CADisplayLink *)link{
    [self.pathList removeAllObjects];
    if (self.number > 180){
        self.number = 0;
    }else{
        self.number++;
    }
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat scale = self.bounds.size.width / 375;
    
    //第1个圈
    CGFloat progress = self.number / 12.0;
    progress = progress > 1 ? 1 : progress;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:5 * scale * progress startAngle:0 endAngle:2*M_PI clockwise:YES];
    path.lineWidth = 10 * scale * progress;
    [self.pathList addObject:path];
    
    //第2个圈
    if (self.number > 12) {
        CGFloat progress = (self.number - 12) / 24.0;
        progress = progress > 1 ? 1 : progress;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:(10 + 10 * progress) * scale startAngle:0 endAngle:2*M_PI clockwise:YES];
        path.lineWidth = 20 * scale * progress + 0.5;
        [self.pathList addObject:path];
    }
    
    //第3个圈
    if (self.number > 36) {
        CGFloat progress = (self.number - 36) / 29.0;
        progress = progress > 1 ? 1 : progress;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:(30 + 25 * progress) * scale startAngle:0 endAngle:2*M_PI clockwise:YES];
        path.lineWidth = 50 * scale * progress;
        [self.pathList addObject:path];
    }
    
    //第4个圈
    if (self.number > 65) {
        CGFloat progress = (self.number - 65) / 34.0;
        progress = progress > 1 ? 1 : progress;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:(80 + 40 * progress) * scale startAngle:0 endAngle:2*M_PI clockwise:YES];
        path.lineWidth = 80 * scale * progress + 0.5;
        [self.pathList addObject:path];
    }
    
    //第5个圈
    if (self.number > 99) {
        CGFloat progress = (self.number - 99) / 72.0;
        progress = progress > 1 ? 1 : progress;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:(160 + 40 * progress) * scale startAngle:0 endAngle:2*M_PI clockwise:YES];
        path.lineWidth = 80 * scale * progress;
        [self.pathList addObject:path];
    }
    
    //第6个圈
    if (self.number > 123) {
        CGFloat progress = (self.number - 123) / 48.0;
        progress = progress > 1 ? 1 : progress;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:(160 + 40 * progress) * scale startAngle:0 endAngle:2*M_PI clockwise:YES];
        path.lineWidth = 80 * scale * progress;
        [self.pathList addObject:path];
    }
    
    //第7个圈
    if (self.number > 147) {
        CGFloat progress = (self.number - 147) / 48.0;
        progress = progress > 1 ? 1 : progress;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:(160 + 40 * progress) * scale startAngle:0 endAngle:2*M_PI clockwise:YES];
        path.lineWidth = 80 * scale * progress;
        [self.pathList addObject:path];
    }
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    for (int i = 0; i < self.pathList.count; i++) {
        UIBezierPath *path = self.pathList[i];
        CGFloat alpha = 0;
        if (i == 0) {
            alpha = 1;
        }else if (i == 1) {
            alpha = 0.3;
        }else if (i == 2) {
            alpha = 0.2;
        }else if (i == 3) {
            alpha = 0.1;
        }else if (i == 4) {
            CGFloat progress = 1 - (self.number - 99) / 20.0;
            progress = progress > 1 ? 1 : (progress < 0 ? 0 : progress);
            alpha = 0.05 * progress;
        }else if (i == 5) {
            CGFloat progress = 1 - (self.number - 123) / 20.0;
            progress = progress > 1 ? 1 : (progress < 0 ? 0 : progress);
            alpha = 0.05 * progress;
        }else if (i == 6) {
            CGFloat progress = 1 - (self.number - 147) / 20.0;
            progress = progress > 1 ? 1 : (progress < 0 ? 0 : progress);
            alpha = 0.05 * progress;
        }
        UIColor *color = [UIColor colorWithRGB:0x4992ff alpha:alpha];
        [color set];
        [path stroke];
    }
}

-(void)stop{
    self.animation = NO;
    if (self.displayLink) {
        self.displayLink.paused = YES;
    }
    [self.imageView.layer removeAllAnimations];
}

-(void)start{
    self.animation = YES;
    if (self.displayLink) {
        self.displayLink.paused = NO;
    }
    [self.imageView.layer removeAllAnimations];
    [self.imageView.layer addAnimation:self.imageViewAnimation forKey:@"rotationAnimation"];
}


@end
