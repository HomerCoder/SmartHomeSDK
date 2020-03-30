//
//  FSPageContentView.m
//  Huim
//
//  Created by huim on 2017/4/28.
//  Copyright © 2017年 huim. All rights reserved.
//

#import "GSHPageContentView.h"
#import "Masonry.h"

static NSString *collectionCellIdentifier = @"collectionCellIdentifier";

@interface GSHPageContentView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UIViewController *parentVC;//父视图
@property (nonatomic, strong) NSArray *childsVCs;//子视图数组
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat startOffsetX;
@property (nonatomic, assign) BOOL isSelectBtn;//是否是滑动

@property (nonatomic, assign) CGFloat collectionHeight;


@end

@implementation GSHPageContentView

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"bounds"];
}

- (instancetype)initWithFrame:(CGRect)frame childVCs:(NSArray *)childVCs parentVC:(UIViewController *)parentVC delegate:(id<GSHPageContentViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parentVC = parentVC;
        self.childsVCs = childVCs;
        self.delegate = delegate;
        [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [self setupSubViews];
    }
    return self;
}

- (void)refreshChildVCs:(NSArray *)childVCs{
    self.childsVCs = childVCs;
    [self setupSubViews];
}

#pragma mark --LazyLoad

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = self.bounds.size;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:flowLayout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.bounces = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
        [self addSubview:collectionView];
        __weak typeof(self)weakSelf = self;
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf);
        }];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

#pragma mark --setup
- (void)setupSubViews
{
    _startOffsetX = 0;
    _isSelectBtn = NO;
    _contentViewCanScroll = YES;
    
    [self.parentVC.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    for (UIViewController *childVC in self.childsVCs) {
        [self.parentVC addChildViewController:childVC];
    }
    [self.collectionView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"bounds"]) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.childsVCs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIViewController *childVC = self.childsVCs[indexPath.item];
    [cell.contentView addSubview:childVC.view];
    [childVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.bounds.size.width, self.bounds.size.height);
}

#pragma mark UIScrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isSelectBtn = NO;
    _startOffsetX = scrollView.contentOffset.x;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(FSContentViewWillBeginDragging:)]) {
        [self.delegate FSContentViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isSelectBtn) {
        return;
    }
    CGFloat scrollView_W = scrollView.bounds.size.width;
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    NSInteger startIndex = floor(_startOffsetX/scrollView_W);
    NSInteger endIndex;
    CGFloat progress;
    if (currentOffsetX > _startOffsetX) {//左滑left
        progress = (currentOffsetX - _startOffsetX)/scrollView_W;
        endIndex = startIndex + 1;
        if (endIndex > self.childsVCs.count - 1) {
            endIndex = self.childsVCs.count - 1;
        }
    }else if (currentOffsetX == _startOffsetX){//没滑过去
        progress = 0;
        endIndex = startIndex;
    }else{//右滑right
        progress = (_startOffsetX - currentOffsetX)/scrollView_W;
        endIndex = startIndex - 1;
        endIndex = endIndex < 0?0:endIndex;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(FSContentViewDidScroll:startIndex:endIndex:progress:)]) {
        [self.delegate FSContentViewDidScroll:self startIndex:startIndex endIndex:endIndex progress:progress];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat scrollView_W = scrollView.bounds.size.width;
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    NSInteger startIndex = floor(_startOffsetX/scrollView_W);
    NSInteger endIndex = floor(currentOffsetX/scrollView_W);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(FSContenViewDidEndDecelerating:startIndex:endIndex:)]) {
        [self.delegate FSContenViewDidEndDecelerating:self startIndex:startIndex endIndex:endIndex];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(FSContenViewDidEndDragging:)]) {
            [self.delegate FSContenViewDidEndDragging:self];
        }
    }
}

#pragma mark setter

- (void)setContentViewCurrentIndex:(NSInteger)contentViewCurrentIndex
{
    if (self.childsVCs.count == 0) {
        return;
    }
    if (contentViewCurrentIndex < 0||contentViewCurrentIndex > self.childsVCs.count-1) {
        return;
    }
    _isSelectBtn = YES;
    _contentViewCurrentIndex = contentViewCurrentIndex;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:contentViewCurrentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)setContentViewCanScroll:(BOOL)contentViewCanScroll
{
    _contentViewCanScroll = contentViewCanScroll;
    _collectionView.scrollEnabled = _contentViewCanScroll;
}

#pragma mark get

-(UIViewController *)currentVC{
    return [self childsVCWithIndex:self.contentViewCurrentIndex];
}

-(UIViewController *)nextVC{
    return [self childsVCWithIndex:self.contentViewCurrentIndex + 1];
}

-(UIViewController *)previousVC{
    return [self childsVCWithIndex:self.contentViewCurrentIndex - 1];
}

-(UIViewController *)childsVCWithIndex:(NSInteger)index{
    if (self.childsVCs.count == 0 ) {
        return nil;
    }
    if (index < 0 || index > self.childsVCs.count - 1) {
        return nil;
    }
    return self.childsVCs[index];
}

@end
