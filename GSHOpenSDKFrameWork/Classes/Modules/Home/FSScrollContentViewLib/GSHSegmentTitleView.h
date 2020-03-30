//
//  FSSegmentTitleView.h
//  FSScrollContentViewDemo
//
//  Created by huim on 2017/5/3.
//  Copyright © 2017年 fengshun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GSHSegmentTitleView;

@protocol GSHSegmentTitleViewDelegate <NSObject>

@optional

/**
 切换标题

 @param titleView FSSegmentTitleView
 @param startIndex 切换前标题索引
 @param endIndex 切换后标题索引
 */
- (void)FSSegmentTitleView:(GSHSegmentTitleView *)titleView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;

/**
 将要开始滑动
 
 @param titleView FSSegmentTitleView
 */
- (void)FSSegmentTitleViewWillBeginDragging:(GSHSegmentTitleView *)titleView;

/**
 将要停止滑动
 
 @param titleView FSSegmentTitleView
 */
- (void)FSSegmentTitleViewWillEndDragging:(GSHSegmentTitleView *)titleView;

@end

@interface GSHSegmentTitleView : UIView

@property (nonatomic, weak) id<GSHSegmentTitleViewDelegate>delegate;

/**
 当前选中标题索引，默认0
 */
@property (nonatomic, assign) NSInteger selectIndex;

/**
 标题字体大小，默认15
 */
@property (nonatomic, strong) UIFont *titleFont;

/**
 标题选中字体大小，默认15
 */
@property (nonatomic, strong) UIFont *titleSelectFont;

/**
 标题正常颜色，默认black
 */
@property (nonatomic, strong) UIColor *titleNormalColor;

/**
 标题选中颜色，默认red
 */
@property (nonatomic, strong) UIColor *titleSelectColor;

/**
 标题选中背景
 */
@property (nonatomic, strong) UIImage *bgSelectImage;

/**
 对象方法创建FSSegmentTitleView

 @param frame frame
 @param titlesArr 标题数组
 @param delegate delegate
 @return FSSegmentTitleView
 */
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titlesArr delegate:(id<GSHSegmentTitleViewDelegate>)delegate;

- (void)refreshTitle:(NSArray *)titlesArr;

@end
