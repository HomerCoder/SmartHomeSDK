//
//  GSHSceneModelBackVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSceneBackgroundVC.h"
#import "GSHSceneBackCell.h"

@interface GSHSceneBackgroundVC () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic , strong) UICollectionView *sceneBackCollectionView;
@property (nonatomic , strong) UICollectionViewFlowLayout *sceneBackFlowLayout;
@property (nonatomic , strong) NSMutableArray *imageArray;
@property (nonatomic , strong) NSNumber *selectBackImgIndex;
@property (nonatomic , strong) GSHSceneBackgroundImageM *selectSceneBackgroundImageM;

@end

@implementation GSHSceneBackgroundVC

- (instancetype)initWithBackImgId:(NSNumber *)backImgIndex;
{
    self = [super init];
    if (self) {
        if (backImgIndex) {
            self.selectBackImgIndex = backImgIndex;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.navigationItem.title = @"选择场景背景";
    
    self.sceneBackCollectionView.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
        
    [self createRightButton];       // 创建 添加场景 按钮
    [self getSceneBackImageList];   // 请求场景背景图
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI
- (void)createRightButton {
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(SCREEN_WIDTH - 44, 0, 44, 44);
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"#2EB0FF"] forState:UIControlStateNormal];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

#pragma mark - Lazy
- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (UICollectionViewFlowLayout *)sceneBackFlowLayout {
    if (!_sceneBackFlowLayout) {
        _sceneBackFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _sceneBackFlowLayout.minimumInteritemSpacing = 10; //cell左右间隔
        _sceneBackFlowLayout.minimumLineSpacing = 10;      //cell上下间隔
        _sceneBackFlowLayout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16);
        CGFloat width = (SCREEN_WIDTH - 53) / 3;
        CGFloat height = (SCREEN_WIDTH - 53) / 3 / 107.5 * 113.5;
        NSLog(@"%f %f",width,height);
        _sceneBackFlowLayout.itemSize = CGSizeMake(width ,height);
    }
    return _sceneBackFlowLayout;
}

- (UICollectionView *)sceneBackCollectionView {
    if (!_sceneBackCollectionView) {
        _sceneBackCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KTabBarHeight) collectionViewLayout:self.sceneBackFlowLayout];
        _sceneBackCollectionView.dataSource = self;
        _sceneBackCollectionView.delegate = self;
        [_sceneBackCollectionView registerNib:[UINib nibWithNibName:@"GSHSceneBackCell" bundle:MYBUNDLE] forCellWithReuseIdentifier:@"sceneBackCell"];
        [self.view addSubview:_sceneBackCollectionView];
    }
    return _sceneBackCollectionView;
}

#pragma mark - method
// 添加场景按钮点击
- (void)sureButtonClick:(UIButton *)button {
    if (!self.selectSceneBackgroundImageM) {
        [TZMProgressHUDManager showInfoWithStatus:@"请选择背景图片" inView:self.view];
        return;
    }
    if (self.selectBackImage) {
        self.selectBackImage(self.selectSceneBackgroundImageM);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - request
- (void)getSceneBackImageList {
    [TZMProgressHUDManager showInfoWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHSceneManager getScenarioBackgroundImageListblock:^(NSArray<GSHSceneBackgroundImageM *> *list, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (self.imageArray.count > 0) {
                [self.imageArray removeAllObjects];
            }
            [self.imageArray addObjectsFromArray:list];
            
            if (self.selectBackImgIndex) {
                // 有选中图片
                for (GSHSceneBackgroundImageM *sceneBackgroundImageM in list) {
                    if ([sceneBackgroundImageM.scenarioBgImgId isEqual:self.selectBackImgIndex]) {
                        self.selectSceneBackgroundImageM = sceneBackgroundImageM;
                    }
                }
            } else {
                // 无选中图片 默认第一张图
                self.selectSceneBackgroundImageM = self.imageArray.firstObject;
            }
            [self.sceneBackCollectionView reloadData];
        }
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GSHSceneBackCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sceneBackCell" forIndexPath:indexPath];
    if (self.imageArray.count > indexPath.row) {
        GSHSceneBackgroundImageM *sceneBackgroundImageM = self.imageArray[indexPath.row];
        [cell.sceneBackImageView sd_setImageWithURL:[NSURL URLWithString:sceneBackgroundImageM.picUrl] placeholderImage:GlobalPlaceHoldImage];
        if ([self.selectSceneBackgroundImageM.scenarioBgImgId isEqual:sceneBackgroundImageM.scenarioBgImgId]) {
            cell.checkBoxImageView.hidden = NO;
        } else {
            cell.checkBoxImageView.hidden = YES;
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.imageArray.count > indexPath.row) {
        GSHSceneBackgroundImageM *sceneBackgroundImageM = self.imageArray[indexPath.row];
        for (int i = 0 ; i < self.imageArray.count ; i ++) {
            GSHSceneBackCell *tmpCell = (GSHSceneBackCell *)[self.sceneBackCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            tmpCell.checkBoxImageView.hidden = YES;
        }
        GSHSceneBackCell *cell = (GSHSceneBackCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.checkBoxImageView.hidden = NO;
        self.selectSceneBackgroundImageM = sceneBackgroundImageM;
        [collectionView reloadData];
    }
}


@end
