//
//  FSSegmentTitleView.m
//  FSScrollContentViewDemo
//
//  Created by huim on 2017/5/3.
//  Copyright © 2017年 fengshun. All rights reserved.
//

#import "GSHSegmentTitleView.h"

@interface GSHSegmentTitleView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray<UIButton *> *itemBtnArr;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *itemImageArr;

@property (nonatomic, strong) NSArray *titlesArr;

@end

@implementation GSHSegmentTitleView

-(void)dealloc{
    
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titlesArr delegate:(id<GSHSegmentTitleViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithProperty];
        self.titlesArr = titlesArr;
        self.delegate = delegate;
    }
    return self;
}

- (void)refreshTitle:(NSArray *)titlesArr{
    self.titlesArr = titlesArr;
}

//初始化默认属性值
- (void)initWithProperty
{
    self.selectIndex = 0;
    self.titleNormalColor = [UIColor blackColor];
    self.titleSelectColor = [UIColor redColor];
    self.titleFont = [UIFont systemFontOfSize:15];
    self.titleSelectFont = self.titleFont;
}
//重新布局frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    if (self.itemBtnArr.count == 0) {
        return;
    }
    CGFloat totalBtnWidth = 0.0;
    UIFont *titleFont = _titleSelectFont;
    
    for (NSString *title in self.titlesArr) {
        CGFloat itemBtnWidth = [GSHSegmentTitleView getWidthWithString:title font:titleFont] + 44;
        totalBtnWidth += itemBtnWidth;
    }
    
    CGFloat currentX = 0;
    for (int idx = 0; idx < self.titlesArr.count; idx++) {
        UIButton *btn = self.itemBtnArr[idx];
        CGFloat itemBtnWidth = [GSHSegmentTitleView getWidthWithString:self.titlesArr[idx] font:titleFont] + 44;
        CGFloat itemBtnHeight = CGRectGetHeight(self.bounds);
        btn.frame = CGRectMake(currentX, 0, itemBtnWidth, itemBtnHeight);
        currentX += itemBtnWidth;
        if (self.itemImageArr.count > idx) {
            UIImageView *imageView = self.itemImageArr[idx];
            imageView.center = btn.center;
        }
    }
    self.scrollView.contentSize = CGSizeMake(currentX, CGRectGetHeight(self.scrollView.bounds));
}

- (void)scrollSelectBtnCenter:(BOOL)animated
{
    if (self.selectIndex >= self.itemBtnArr.count) {
        return;
    }
    UIButton *selectBtn = self.itemBtnArr[self.selectIndex];
    CGRect centerRect = CGRectMake(selectBtn.center.x - CGRectGetWidth(self.scrollView.bounds)/2, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    [self.scrollView scrollRectToVisible:centerRect animated:animated];
}

#pragma mark --LazyLoad

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (NSMutableArray<UIButton *>*)itemBtnArr
{
    if (!_itemBtnArr) {
        _itemBtnArr = [[NSMutableArray alloc]init];
    }
    return _itemBtnArr;
}

- (NSMutableArray<UIImageView *>*)itemImageArr
{
    if (!_itemImageArr) {
        _itemImageArr = [[NSMutableArray alloc]init];
    }
    return _itemImageArr;
}

#pragma mark --Setter

- (void)setTitlesArr:(NSArray *)titlesArr
{
    _titlesArr = titlesArr;
    [self.itemImageArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.itemBtnArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.itemImageArr = nil;
    self.itemBtnArr = nil;
    for (NSString *title in titlesArr) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = self.itemBtnArr.count + 1000;
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:_titleNormalColor forState:UIControlStateNormal];
        [btn setTitleColor:_titleSelectColor forState:UIControlStateSelected];
        if (self.itemBtnArr.count == 0) {
            btn.titleLabel.font = _titleSelectFont;
        }else{
            btn.titleLabel.font = _titleFont;
        }
        [self.scrollView addSubview:btn];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (self.itemBtnArr.count == self.selectIndex) {
            btn.selected = YES;
        }
        [self.itemBtnArr addObject:btn];
        
        if (self.bgSelectImage) {
            UIImageView *imageview = [[UIImageView alloc]initWithImage:self.bgSelectImage];
            imageview.contentMode = UIViewContentModeCenter;
            if (self.itemImageArr.count == self.selectIndex) {
                imageview.hidden = NO;
            }else{
                imageview.hidden = YES;
            }
            imageview.tag = self.itemImageArr.count + 2000;
            [self.scrollView addSubview:imageview];
            [self.itemImageArr addObject:imageview];
        }
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    UIButton *lastBtn = [self.scrollView viewWithTag:_selectIndex + 1000];
    UIImageView *lastImage = [self.scrollView viewWithTag:_selectIndex + 2000];
    lastBtn.selected = NO;
    lastBtn.titleLabel.font = _titleFont;
    lastImage.hidden = YES;
    _selectIndex = selectIndex;
    UIButton *currentBtn = [self.scrollView viewWithTag:_selectIndex + 1000];
    UIImageView *currentImage = [self.scrollView viewWithTag:_selectIndex + 2000];
    currentBtn.selected = YES;
    currentBtn.titleLabel.font = _titleSelectFont;
    currentImage.hidden = NO;
    
    [self scrollSelectBtnCenter:YES];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    for (UIButton *btn in self.itemBtnArr) {
        btn.titleLabel.font = titleFont;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setTitleSelectFont:(UIFont *)titleSelectFont
{
    if (_titleFont == titleSelectFont) {
        _titleSelectFont = _titleFont;
        return;
    }
    _titleSelectFont = titleSelectFont;
    for (UIButton *btn in self.itemBtnArr) {
        btn.titleLabel.font = btn.isSelected?titleSelectFont:_titleFont;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setTitleNormalColor:(UIColor *)titleNormalColor
{
    _titleNormalColor = titleNormalColor;
    for (UIButton *btn in self.itemBtnArr) {
        [btn setTitleColor:titleNormalColor forState:UIControlStateNormal];
    }
}

- (void)setTitleSelectColor:(UIColor *)titleSelectColor
{
    _titleSelectColor = titleSelectColor;
    for (UIButton *btn in self.itemBtnArr) {
        [btn setTitleColor:titleSelectColor forState:UIControlStateSelected];
    }
}

#pragma mark --Btn

- (void)btnClick:(UIButton *)btn
{
    NSInteger index = btn.tag - 1000;
    if (index == self.selectIndex) {
        return;
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(FSSegmentTitleView:startIndex:endIndex:)]) {
        [self.delegate FSSegmentTitleView:self startIndex:self.selectIndex endIndex:index];
    }
    self.selectIndex = index;
}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(FSSegmentTitleViewWillBeginDragging:)]) {
        [self.delegate FSSegmentTitleViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(FSSegmentTitleViewWillEndDragging:)]) {
        [self.delegate FSSegmentTitleViewWillEndDragging:self];
    }
}


#pragma mark Private
/**
 计算字符串长度

 @param string string
 @param font font
 @return 字符串长度
 */
+ (CGFloat)getWidthWithString:(NSString *)string font:(UIFont *)font {
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [string boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.width;
}

/**
 随机色

 @return 调试用
 */
+ (UIColor*) randomColor{
    NSInteger r = arc4random() % 255;
    NSInteger g = arc4random() % 255;
    NSInteger b = arc4random() % 255;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}


@end
