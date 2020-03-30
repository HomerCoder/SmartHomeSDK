//
//  YSCNewVoiceWaveView.m
//  Waver
//
//  Created by yushichao on 16/8/9.
//  Copyright © 2016年 YSC Inc. All rights reserved.
//

#import "YSCNewVoiceWaveView.h"

@interface YSCNewVoiceWaveViewProxy : NSProxy
@property (nonatomic,weak)id obj;
@end

@implementation YSCNewVoiceWaveViewProxy
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *sig = nil;
    sig = [self.obj methodSignatureForSelector:aSelector];
    return sig;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    [anInvocation invokeWithTarget:self.obj];
}
@end

@interface YSCNewVoiceWaveView ()<CAAnimationDelegate>
@property (nonatomic, strong) YSCNewVoiceWaveViewProxy *proxy;
@property (nonatomic, strong) CADisplayLink *displayLink; 
@property (nonatomic, strong) NSMutableArray<UIBezierPath*> *pathList;

@property (nonatomic, assign) CGFloat cycle;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat volume;
@end

@implementation YSCNewVoiceWaveView {
}

- (void)dealloc{
    [self.displayLink invalidate];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.pathList = [NSMutableArray array];
        [self buildData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.pathList = [NSMutableArray array];
        [self buildData];
    }
    return self;
}

//初始化数据
-(void)buildData{
    //以屏幕刷新速度为周期刷新曲线的位置
    self.proxy = [YSCNewVoiceWaveViewProxy alloc];
    self.proxy.obj = self;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self.proxy selector:@selector(updateWave:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.frameInterval = 1;
    self.cycle = 1;
    self.progress = 0;
}

-(void)updateWave:(CADisplayLink *)link{
    if (self.progress > 0.999999999999) {
        self.progress = 1 / (self.cycle * 60 / self.displayLink.frameInterval);
    }else{
        self.progress += 1 / (self.cycle * 60 / self.displayLink.frameInterval);
    }
    
    [self.pathList removeAllObjects];
    for (NSInteger i = 0; i < 5; i++) {
        [self updateWaveWithIndex:i];
    }
    [self setNeedsDisplay];
}

-(void)updateWaveWithIndex:(NSInteger)index{
    UIBezierPath *quadLine = [UIBezierPath bezierPath];
    quadLine.lineWidth = index == 0 ? 2.5 : 0.5;
    quadLine.lineCapStyle = kCGLineCapRound; //线条拐角
    quadLine.lineJoinStyle = kCGLineJoinRound; //终点处理
    
    CGFloat waterWaveWidth = self.bounds.size.width;
    CGFloat waterWaveHeight = self.bounds.size.height;
    CGFloat waveLength = 200 + index * 40;
    
    
    //初始化运动路径
    CGFloat y = 0.5 * waterWaveHeight * (1 - self.volume * sin(self.progress * 2 * M_PI));
    [quadLine moveToPoint:CGPointMake(0, y)];
    for (float x = 1.0f; x <= waterWaveWidth ; x++) {
        CGFloat progress = self.progress + x / waveLength;
        CGFloat y = 0.5 * waterWaveHeight * (1 - self.volume * sin(progress * 2 * M_PI));
        [quadLine addLineToPoint:CGPointMake(x, y)];
    }
    [self.pathList addObject:quadLine];
}

-(void)drawRect:(CGRect)rect{
    UIColor *color = [UIColor whiteColor];
    [color set];
    for (UIBezierPath *path in self.pathList) {
        [path stroke];
    }
}

-(void)stop{
    if (self.displayLink) {
        self.displayLink.paused = YES;
    }
}

-(void)start{
    if (self.displayLink) {
        self.displayLink.paused = NO;
    }
}

- (void)changeVolume:(CGFloat)volume{
    _volume = volume;
}

@end
