//
//  GSHVoiceKeyWordVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/24.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHVoiceKeyWordVC.h"
#import "GSHCollectionTagsFlowLayout.h"
#import "GSHVoiceKeyWordTagCell.h"
#import "NSString+TZM.h"
#import "GSHVoiceKeyWordHeadView.h"

@interface GSHVoiceKeyWordVC () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic , strong) UICollectionView *keyWordCollectionView;
@property (nonatomic , strong) GSHCollectionTagsFlowLayout *flowLayout;

@end

@implementation GSHVoiceKeyWordVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.keyWordArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigationView];
    
    [self.view addSubview:self.keyWordCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)initNavigationView {
    
    self.navigationItem.title = @"添加语音关键词";
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(SCREEN_WIDTH - 44, 0, 44, 44);
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"#2EB0FF"] forState:UIControlStateNormal];
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

#pragma mark - Lazy

- (GSHCollectionTagsFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[GSHCollectionTagsFlowLayout alloc] init];
        _flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 141);
    }
    return _flowLayout;
}

- (UICollectionView *)keyWordCollectionView {
    if (!_keyWordCollectionView) {
        _keyWordCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KNavigationBar_Height) collectionViewLayout:self.flowLayout];
        _keyWordCollectionView.backgroundColor = [UIColor whiteColor];
        _keyWordCollectionView.dataSource = self;
        _keyWordCollectionView.delegate = self;
        [_keyWordCollectionView registerClass:[GSHVoiceKeyWordTagCell class] forCellWithReuseIdentifier:@"keyWordCell"];
        [_keyWordCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView"];
    }
    return _keyWordCollectionView;
}

#pragma mark - method
// 保存按钮点击
- (void)saveButtonClick:(UIButton *)button {
//    if (self.keyWordArray.count == 0) {
//        [TZMProgressHUDManager showErrorWithStatus:@"请添加语音关键词" inView:weakSelf.view];
//        return;
//    }
    if (self.setVoiceKeyWordBlock) {
        self.setVoiceKeyWordBlock((NSArray *)self.keyWordArray);
    }
    if (self.keyWordArray.count > 0) {
        [TZMProgressHUDManager showSuccessWithStatus:@"保存成功" inView:self.view];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isSameWithVoiceKeywordInArray:(NSString *)voiceKeyword {
    BOOL isSame = NO;
    for (NSString *str in self.keyWordArray) {
        if ([str isEqualToString:voiceKeyword]) {
            isSame = YES;
        }
    }
    return isSame;
}

#pragma mark - UICollection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1.0f;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.keyWordArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = self.keyWordArray[indexPath.row];
    CGFloat width = [str tzm_getStrWidthWithFontSize:16] + 10 + 47;
    return CGSizeMake(width ,30);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHVoiceKeyWordTagCell *keyWordCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"keyWordCell" forIndexPath:indexPath];
    keyWordCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#F6F7F9"];
    [keyWordCell setValueWithTagName:self.keyWordArray[indexPath.row]];
    @weakify(self)
    keyWordCell.deleteButtonClickBlock = ^{
        @strongify(self)
        if (self.keyWordArray.count > indexPath.row) {
            [self.keyWordArray removeObjectAtIndex:indexPath.row];
            [self.keyWordCollectionView reloadData];
        }        
    };
    return keyWordCell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
    GSHVoiceKeyWordHeadView *headView = [[NSBundle mainBundle] loadNibNamed:@"GSHVoiceKeyWordHeadView" owner:self options:nil][0];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 141);
    @weakify(self)
    headView.addButtonClickBlock = ^(NSString *keyWordStr) {
        // 确定按钮点击
        @strongify(self)
        if ([keyWordStr tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"请输入语音关键词" inView:self.view];
            return ;
        }
        if (self.keyWordArray.count == 6) {
            [TZMProgressHUDManager showErrorWithStatus:@"最多只能添加6个关键词" inView:self.view];
            return ;
        }
        if ([self isSameWithVoiceKeywordInArray:keyWordStr]) {
            [TZMProgressHUDManager showErrorWithStatus:@"该语音关键词已存在" inView:self.view];
            return;
        }
        [self verifyVoiceKeyWord:keyWordStr];
    };
    [reusableview addSubview:headView];
    return reusableview;
    
}

#pragma mark - request

- (void)verifyVoiceKeyWord:(NSString *)voiceKeyWord {
    
    [TZMProgressHUDManager showWithStatus:@"关键词校验中" inView:self.view];
    @weakify(self)
    [GSHSceneManager verifyVoiceKeyWordWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId voiceKeyWord:voiceKeyWord block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            [self.keyWordArray addObject:voiceKeyWord];
            [self.keyWordCollectionView reloadData];
        }
    }];
}



@end
