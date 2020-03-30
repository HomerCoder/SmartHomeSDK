//
//  GSHPullDownHeader.m
//  SmartHome
//
//  Created by zhanghong on 2019/11/26.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHPullDownHeader.h"

@implementation GSHPullDownHeader

#pragma mark - 懒加载

- (void)prepare {
    [super prepare];

    // 设置普通状态的动画图片
    NSMutableArray *idleImageArray = [NSMutableArray array];
    for (int i = 0; i < 30; i ++) {
        UIImage *image = [UIImage ZHImageNamed:[NSString stringWithFormat:@"pullDown_idle_%02d",i]];
        [idleImageArray addObject:image];
    }
    [self setImages:idleImageArray duration:1.0 forState:MJRefreshStateIdle];

    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *willRefreshImageArray = [NSMutableArray array];
    [willRefreshImageArray addObject:[UIImage ZHImageNamed:@"pullDown_idle_29"]];
    [self setImages:willRefreshImageArray forState:MJRefreshStatePulling];

    // 设置正在刷新状态的动画图片
    NSMutableArray *refreshingImageArray = [NSMutableArray array];
    for (int i = 0; i < 60; i ++) {
        UIImage *image = [UIImage ZHImageNamed:[NSString stringWithFormat:@"pullDown_refreshing_%02d",i]];
        [refreshingImageArray addObject:image];
    }
    [self setImages:refreshingImageArray duration:1.5 forState:MJRefreshStateRefreshing];
    
    //隐藏时间
    self.lastUpdatedTimeLabel.hidden = YES;
    //隐藏状态
    self.stateLabel.hidden = YES;
        
}

@end
