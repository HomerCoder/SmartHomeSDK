//
//  GSHSceneVC.m
//  SmartHome
//
//  Created by gemdale on 2018/4/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSceneVC.h"
#import "GSHSceneCell.h"

#import <MJRefresh.h>
#import "UIViewController+TZMPageStatusViewEx.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "PopoverView.h"
#import "MJRefresh.h"
#import "NSObject+TZM.h"

#import "GSHSceneAddVC.h"
#import <UINavigationController+TZM.h>

#import "GSHRecommendSceneCell.h"
#import "GSHSceneCustomVC.h"
#import "SDCycleScrollView.h"
#import "GSHAlertManager.h"
#import "GSHWebViewController.h"

@interface GSHSceneVC ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UITableViewDelegate,
UITableViewDataSource,
SDCycleScrollViewDelegate>

// 场景列表
@property (nonatomic , strong) UICollectionView *sceneCollectionView;
@property (nonatomic , strong) UICollectionViewFlowLayout *sceneFlowLayout;
@property (nonatomic , strong) NSMutableArray *sourceArray;
@property (nonatomic , strong) NSMutableArray *actions;
@property (nonatomic , assign) int currPage;
@property (nonatomic , strong) NSNumber *sceneTotal;    // 家庭下场景总数量，用于排序时rank赋值

@property (nonatomic , strong) UIView *contentView;
@property (nonatomic , strong) SDCycleScrollView *cycleScrollView;

// 无场景，显示推荐场景及banner
@property (nonatomic , strong) UITableView *recommendSceneTableView;
@property (nonatomic , strong) NSMutableArray *sceneTemplateArray;
@property (nonatomic , strong) UIView *headView;

@property (nonatomic , strong) NSMutableDictionary *execRequestDic; // 保存场景执行请求

@property (nonatomic, assign) NSInteger moreButtonClickIndex;

@property (nonatomic, strong) UIButton *addButton;

@end

@implementation GSHSceneVC

#pragma mark - life circle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self observerNotifications];
    NSLog(@"scene 01");
    self.tzm_prefersNavigationBarHidden = YES;
    [self layoutUI];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.sceneCollectionView setBackgroundColor:[UIColor whiteColor]];
    self.sceneCollectionView.hidden = YES;

    [self.recommendSceneTableView setBackgroundColor:[UIColor whiteColor]];
    self.recommendSceneTableView.hidden = YES;

    self.sceneTemplateArray = [NSMutableArray array];
    self.execRequestDic = [NSMutableDictionary dictionary];
    NSLog(@"scene 02");

    [self querySceneModeListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId isShowLoading:YES];  // 查询 情景模式列表
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void)observerNotifications{
    [self observerNotification:GSHOpenSDKFamilyChangeNotification];
    [self observerNotification:GSHControlSwitchSuccess];                                        // 收到切换控制成功的通知
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHOpenSDKFamilyChangeNotification]) {
        // 成员隐藏添加按钮
        [self refreshAddButtonHiddenState];
        GSHFamilyM *family = notification.object;
        if ([family isKindOfClass:GSHFamilyM.class]) {
            [self querySceneModeListWithFamilyId:family.familyId isShowLoading:NO];
        }
    } else if ([notification.name isEqualToString:GSHControlSwitchSuccess]) {
        // 收到切换控制成功的通知
        [self refreshAddButtonHiddenState];
    }
}

-(void)dealloc{
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)layoutUI {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, KStatusBar_Height, SCREEN_WIDTH, 50)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 100, 50)];
    label.textColor = [UIColor colorWithHexString:@"#222222"];
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"场景";
    [topView addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(SCREEN_WIDTH - 50, 0, 50, 50);
    [button setImage:[UIImage ZHImageNamed:@"sense_icon_add_normal"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addSceneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:button];
    self.addButton = button;
    
    [self refreshAddButtonHiddenState];

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - KTabBarHeight - KStatusBar_Height - 50)];
    self.contentView = contentView;
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];

    UIView *tabHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * (166 / 375.0))];
    tabHeadView.backgroundColor = [UIColor whiteColor];

    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:nil];
    self.cycleScrollView.autoScroll = NO;
    self.cycleScrollView.layer.cornerRadius = 12.0f;
    self.cycleScrollView.clipsToBounds = YES;
    [tabHeadView addSubview:self.cycleScrollView];
    [self.cycleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tabHeadView);
        make.centerY.equalTo(tabHeadView);
        make.width.equalTo(tabHeadView).with.offset(-24);
        make.height.equalTo(tabHeadView).with.offset(-16);
    }];
    [self.recommendSceneTableView setTableHeaderView:tabHeadView];
}

- (void)refreshAddButtonHiddenState {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网模式
        self.addButton.hidden = YES;
    } else {
        // 成员隐藏添加按钮
        self.addButton.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember ? YES : NO;
    }
}

- (UICollectionViewFlowLayout *)sceneFlowLayout {
    if (!_sceneFlowLayout) {
        _sceneFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _sceneFlowLayout.minimumInteritemSpacing = 10; //cell左右间隔
        _sceneFlowLayout.minimumLineSpacing = 10;      //cell上下间隔
        _sceneFlowLayout.sectionInset = UIEdgeInsetsMake(8, 12, 8, 12);
        _sceneFlowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 34) / 2 ,(SCREEN_WIDTH - 34) / 2 * (180 / 170.5));
    }
    return _sceneFlowLayout;
}

- (UICollectionView *)sceneCollectionView {
    if (!_sceneCollectionView) {
        _sceneCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KTabBarHeight - KStatusBar_Height - 50) collectionViewLayout:self.sceneFlowLayout];
        _sceneCollectionView.dataSource = self;
        _sceneCollectionView.delegate = self;
        _sceneCollectionView.showsVerticalScrollIndicator = NO;
        
        [_sceneCollectionView registerNib:[UINib nibWithNibName:@"GSHSceneCell" bundle:MYBUNDLE] forCellWithReuseIdentifier:@"sceneCell"];
        
        [_sceneCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView"];
        [self.contentView addSubview:_sceneCollectionView];
        @weakify(self)
        _sceneCollectionView.mj_header = [GSHPullDownHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self querySceneModeListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId isShowLoading:NO];
        }];
        
        //此处给其增加长按手势，用此手势触发cell移动效果
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
        [_sceneCollectionView addGestureRecognizer:longGesture];

    }
    return _sceneCollectionView;
}

- (UITableView *)recommendSceneTableView {
    if (!_recommendSceneTableView) {
        NSLog(@"tableView 进来了");
        _recommendSceneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KTabBarHeight - KStatusBar_Height - 50) style:UITableViewStyleGrouped];
        _recommendSceneTableView.delegate = self;
        _recommendSceneTableView.dataSource = self;
        _recommendSceneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_recommendSceneTableView registerNib:[UINib nibWithNibName:@"GSHRecommendSceneCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"recommendSceneCell"];
        [self.contentView addSubview:_recommendSceneTableView];
        @weakify(self)
        _recommendSceneTableView.mj_header = [GSHPullDownHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self querySceneModeListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId isShowLoading:NO];
        }];
    }
    return _recommendSceneTableView;
}

- (void)refreshUIWithGSHSceneListM:(GSHSceneListM *)sceneListM {
    if (sceneListM.scenarios.count == 0) {
        // 无场景
        if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
            // 成员显示空白页
            [self showBlankView];
        } else {
            // 管理员 显示场景模版列表
            if (sceneListM.scenarioTpls.count == 0 && sceneListM.banners.count == 0) {
                [self showBlankView];
            } else {
                if (self.sceneTemplateArray.count > 0) {
                    [self.sceneTemplateArray removeAllObjects];
                }
                [self.sceneTemplateArray addObjectsFromArray:sceneListM.scenarioTpls];
                self.sceneCollectionView.hidden = YES;
                self.recommendSceneTableView.hidden = NO;
                
                NSMutableArray *imgArray = [NSMutableArray array];
                for (GSHSceneBannerM *sceneBannerM in sceneListM.banners) {
                    [imgArray addObject:sceneBannerM.picUrl];                    
                }
                self.cycleScrollView.imageURLStringsGroup = imgArray;
                @weakify(self)
                self.cycleScrollView.clickItemOperationBlock = ^(NSInteger currentIndex) {
                    @strongify(self)
                    if (sceneListM.banners.count > currentIndex) {
                        GSHSceneBannerM *sceneBannerM = sceneListM.banners[currentIndex];
                        NSURL *url = [NSURL URLWithString:sceneBannerM.content];
                        [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
                    }
                };
                [self.recommendSceneTableView reloadData];
            }
        }
    } else {
        if (self.sourceArray.count > 0) {
            [self.sourceArray removeAllObjects];
        }
        [self.sourceArray addObjectsFromArray:sceneListM.scenarios];
        if (sceneListM.total) {
            self.sceneTotal = sceneListM.total;
        }
        self.sceneCollectionView.hidden = NO;
        self.recommendSceneTableView.hidden = YES;
        [self.sceneCollectionView reloadData];
        
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
}

- (void)showBlankView {
    NSString *desc = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsManager ? @"点击右上方\"+\"按钮，添加自定义场景" : @"";
    TZMPageStatusView *statusView = [self.contentView showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_homescene"] title:@"暂无场景" desc:desc buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
        [self querySceneModeListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId isShowLoading:YES];
    }];
    statusView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Lazy
- (NSMutableArray *)actions {
    if (!_actions) {
        _actions = [NSMutableArray array];
        NSArray *autoTypeArray = @[@"编辑",@"删除"];
        for (NSString *autoTypeName in autoTypeArray) {
            PopoverAction *action = [PopoverAction actionWithImageUrl:nil title:autoTypeName handler:^(PopoverAction *action) {
                if ([action.title isEqualToString:@"编辑"]) {
                    // 编辑
                    [self editAuto];
                } else {
                    // 删除
                    @weakify(self)
                    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                        if (buttonIndex == 0) {
                            @strongify(self)
                            [self deleteScene];
                        }
                    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确认要删除该场景吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"删除" cancelButtonTitle:@"取消" otherButtonTitles:nil];
                }
            }];
            [_actions addObject:action];
        }
    }
    return _actions;
}

- (NSMutableArray *)sourceArray {
    if (!_sourceArray) {
        _sourceArray = [NSMutableArray array];
    }
    return _sourceArray;
}

#pragma mark - method
#pragma mark 编辑
// 编辑按钮点击
- (void)editAuto {
    
    if (self.sourceArray.count > self.moreButtonClickIndex) {
        GSHOssSceneM *ossSceneM = self.sourceArray[self.moreButtonClickIndex];
        NSString *json = [[GSHFileManager shared] readDataWithFileType:LocalStoreFileTypeScene fileName:ossSceneM.fid];
        if (json) {
            // 本地有文件
            NSString *md5 = [json md5String];
            if (![md5 isEqualToString:ossSceneM.md5]) {
                [self getFileFromSeverWithFid:ossSceneM.fid ossSceneM:ossSceneM];
            } else {
                [self editWithJson:json ossSceneM:ossSceneM];
            }
        } else {
            // 本地无文件 ， 从oss服务器获取文件
            [self getFileFromSeverWithFid:ossSceneM.fid ossSceneM:ossSceneM];
        }
    }
}

- (void)editWithJson:(NSString *)json ossSceneM:(GSHOssSceneM *)ossSceneM {
    
    __block GSHSceneM *sceneM = [GSHSceneM yy_modelWithJSON:json];
    sceneM.scenarioId = ossSceneM.scenarioId;
    sceneM.roomName = ossSceneM.roomName;
    sceneM.floorName = ossSceneM.floorName;
    
    NSMutableArray *deviceIdArr = [NSMutableArray array];
    for (GSHDeviceM *deviceM in sceneM.devices) {
        [deviceIdArr addObject:deviceM.deviceId];
    }
    @weakify(self)
    __weak typeof(ossSceneM) weakOssSceneM = ossSceneM;
    [TZMProgressHUDManager showWithStatus:@"数据校验中" inView:self.view];
    [GSHSceneManager checkDevicesFromServerWithDeviceIdArray:deviceIdArr
                                                  sceneArray:nil
                                                   autoArray:nil
                                                    familyId:[GSHOpenSDKShare share].currentFamily.familyId
                                                       block:^(NSArray<GSHNameIdM*> *arr, NSError *error) {
        @strongify(self)
        __strong typeof(weakOssSceneM) strongOssSceneM = weakOssSceneM;
        [TZMProgressHUDManager dismissInView:self.view];
        if (!error) {
            NSMutableArray *tmpArr = [NSMutableArray array];
            BOOL isAlert = NO;
            for (GSHDeviceM *sceneDeviceM in sceneM.devices) {
                BOOL isIn = NO ;
                for (GSHNameIdM *tmpNameIdM in arr) {
                    if ([sceneDeviceM.deviceId isEqual:tmpNameIdM.idStr]) {
                        isIn = YES;
                        if (![sceneDeviceM.deviceName isEqualToString:tmpNameIdM.nameStr]) {
                            sceneDeviceM.deviceName = tmpNameIdM.nameStr;
                            isAlert = YES;
                        }
                    }
                }
                if (!isIn) {
                    [tmpArr addObject:sceneDeviceM];
                }
            }
            if (tmpArr.count > 0) {
                isAlert = YES;
                [sceneM.devices removeObjectsInArray:tmpArr];
            }
            [self jumpToSceneEditVCWithOssSceneM:strongOssSceneM sceneM:sceneM isAlert:isAlert];
        } else {
            [self jumpToSceneEditVCWithOssSceneM:strongOssSceneM sceneM:sceneM isAlert:NO];
        }
    }];
}

- (void)jumpToSceneEditVCWithOssSceneM:(GSHOssSceneM *)ossSceneM sceneM:(GSHSceneM *)sceneM isAlert:(BOOL)isAlert {
    
    sceneM.picUrl = ossSceneM.backgroundUrl;
    GSHSceneCustomVC *sceneCustomVC = [GSHSceneCustomVC sceneCustomVCWithSceneM:sceneM sceneListM:ossSceneM lastRank:ossSceneM.rank templateId:nil sceneCustomType:SceneCustomTypeEdit];
    sceneCustomVC.hidesBottomBarWhenPushed = YES;
    sceneCustomVC.isAlertToNotiUser = isAlert;
    @weakify(self)
    sceneCustomVC.updateSceneBlock = ^(GSHOssSceneM *ossSceneM) {
        @strongify(self)
        if (self.sourceArray.count > self.moreButtonClickIndex) {
            [self.sourceArray removeObjectAtIndex:self.moreButtonClickIndex];
        }
        [self.sourceArray insertObject:ossSceneM atIndex:self.moreButtonClickIndex];
        [self.sceneCollectionView reloadData];
    };
    [self.navigationController pushViewController:sceneCustomVC animated:YES];
}

// 从服务器拉取场景数据
- (void)getFileFromSeverWithFid:(NSString *)fid ossSceneM:(GSHOssSceneM *)ossSceneM {
    
    if (fid.length == 0) {
        return;
    }
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"数据获取中" inView:self.view];
    [GSHSceneManager getSceneFileFromOssWithFid:fid block:^(NSString *json, NSError *error) {
        @strongify(self)
        if (error) {
            if (error.code == 404) {
                [TZMProgressHUDManager showErrorWithStatus:[NSString stringWithFormat:@"找不到%@文件",fid] inView:self.view];
            } else {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            }
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            [self editWithJson:json ossSceneM:ossSceneM];
        }
    }];
}

#pragma mark 删除场景
// 删除场景
- (void)deleteScene {
    if (self.sourceArray.count > self.moreButtonClickIndex) {
        [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
        GSHOssSceneM *ossSceneM = self.sourceArray[self.moreButtonClickIndex];
        @weakify(self)
        [GSHSceneManager deleteSceneWithOssSceneM:ossSceneM familyId:ossSceneM.familyId.stringValue block:^(NSError *error) {
            @strongify(self)
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            } else {
                [TZMProgressHUDManager showSuccessWithStatus:@"删除成功" inView:self.view];
                if (self.sourceArray.count > self.moreButtonClickIndex) {
                    [self.sourceArray removeObjectAtIndex:self.moreButtonClickIndex];
                }
                [self.sceneCollectionView reloadData];
                if (self.sourceArray.count == 0) {
                    [self querySceneModeListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId isShowLoading:YES];
                } else {
                    // 重新排序rank的值
                    [self alertRankAfterHandleScene];
                }
            }
        }];
    }
}

// 添加场景按钮点击
- (void)addSceneButtonClick:(UIBarButtonItem *)buttonItem {
    
    if ([GSHOpenSDKShare share].currentFamily.familyId.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请先创建家庭" inView:self.view];
        return ;
    }
    NSNumber *lastRank = @(0);
    GSHSceneAddVC *addVc = [GSHSceneAddVC sceneAddVCWithLastRank:lastRank];
    addVc.hidesBottomBarWhenPushed = YES;
    @weakify(self)
    addVc.saveSceneBlock = ^(GSHOssSceneM *ossSceneM) {
        @strongify(self)
        ossSceneM.rank = @((int)self.sourceArray.count + 1);
        [self.sourceArray insertObject:ossSceneM atIndex:0];
        self.sceneTotal = [NSNumber numberWithInt:self.sceneTotal.intValue+1];  // 添加场景，场景总数加1
        [self.contentView dismissPageStatusView];
        self.sceneCollectionView.hidden = NO;
        self.recommendSceneTableView.hidden = YES;
        [self.sceneCollectionView reloadData];
    };
    [self.navigationController pushViewController:addVc animated:YES];
}

// 激活按钮点击
- (void)activeButtonClickWithTemplateId:(NSNumber *)templateId {
    GSHSceneCustomVC *sceneCustomVC = [GSHSceneCustomVC sceneCustomVCWithSceneM:nil sceneListM:nil lastRank:@(0) templateId:templateId sceneCustomType:SceneCustomTypeTemplate];
    sceneCustomVC.hidesBottomBarWhenPushed = YES;
    @weakify(self)
    sceneCustomVC.saveSceneBlock = ^(GSHOssSceneM *ossSceneM) {
        @strongify(self)
        ossSceneM.rank = @((int)self.sourceArray.count + 1);
        [self.sourceArray insertObject:ossSceneM atIndex:0];
        self.sceneTotal = [NSNumber numberWithInt:self.sceneTotal.intValue+1];  // 添加场景，场景总数加1
        [self.contentView dismissPageStatusView];
        self.sceneCollectionView.hidden = NO;
        self.recommendSceneTableView.hidden = YES;
        [self.sceneCollectionView reloadData];
    };
    [self.navigationController pushViewController:sceneCustomVC animated:YES];
}

#pragma mark - long gesture
- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture {
    //判断手势状态
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            //判断手势落点位置是否在路径上
            NSIndexPath *indexPath = [self.sceneCollectionView indexPathForItemAtPoint:[longGesture locationInView:self.sceneCollectionView]];
            if (indexPath == nil) {
                break;
            }
            //在路径上则开始移动该路径上的cell
            if (@available(iOS 9.0, *)) {
                [self.sceneCollectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            } else {
                // Fallback on earlier versions
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            //移动过程当中随时更新cell位置
            if (@available(iOS 9.0, *)) {
                [self.sceneCollectionView updateInteractiveMovementTargetPosition:[longGesture locationInView:self.sceneCollectionView]];
            } else {
                // Fallback on earlier versions
            }
            break;
        case UIGestureRecognizerStateEnded:
            //移动结束后关闭cell移动
            if (@available(iOS 9.0, *)) {
                [self.sceneCollectionView endInteractiveMovement];
            } else {
                // Fallback on earlier versions
            }
            break;
        default:
            if (@available(iOS 9.0, *)) {
                [self.sceneCollectionView cancelInteractiveMovement];
            } else {
                // Fallback on earlier versions
            }
            break;
    }
}

- (void)startShakeWithCell:(GSHSceneCell *)cell {
    CAKeyframeAnimation * keyAnimaion = [CAKeyframeAnimation animation];
    keyAnimaion.keyPath = @"transform.rotation";
    keyAnimaion.values = @[@(-3 / 180.0 * M_PI),@(3 /180.0 * M_PI),@(-3/ 180.0 * M_PI)];//度数转弧度
    keyAnimaion.removedOnCompletion = NO;
    keyAnimaion.fillMode = kCAFillModeForwards;
    keyAnimaion.duration = 0.3;
    keyAnimaion.repeatCount = MAXFLOAT;
    [cell.layer addAnimation:keyAnimaion forKey:@"cellShake"];
}

- (void)stopShakeWithCell:(GSHSceneCell*)cell{
    [cell.layer removeAnimationForKey:@"cellShake"];
}

// 排序操作或删除操作之后，重新按顺序修改rank值
- (void)alertRankAfterHandleScene {
    for (int i = 0; i < self.sourceArray.count ; i ++) {
        GSHOssSceneM *ossSceneM = self.sourceArray[i];
        int rank = (int)self.sourceArray.count - 1 - i;
        ossSceneM.rank = @(rank);
    }
    [self sortSceneListRequest];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHSceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sceneCell" forIndexPath:indexPath];

    GSHOssSceneM *ossSceneM = self.sourceArray[indexPath.row];
    cell.sceneNameLabel.text = ossSceneM.scenarioName;
    NSString *roomStr = @"";
    if([GSHOpenSDKShare share].currentFamily.floor.count == 1) {
        // 只有一个楼层
        roomStr = [NSString stringWithFormat:@"%@",ossSceneM.roomName?ossSceneM.roomName:@""];
    } else {
        if (ossSceneM.roomName && ossSceneM.roomName.length > 0) {
            roomStr = [NSString stringWithFormat:@"%@%@",ossSceneM.floorName,ossSceneM.roomName?ossSceneM.roomName:@""];
        }
    }
    cell.roomLabel.text = roomStr;
    [cell.sceneImageView sd_setImageWithURL:[NSURL URLWithString:ossSceneM.backgroundUrl] placeholderImage:GlobalPlaceHoldImage];

    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网,隐藏编辑按钮
        cell.moreButton.hidden = YES;
    } else {
        cell.moreButton.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember ? YES : NO;
    }
    __weak typeof(cell) weakCell = cell;
    @weakify(self)
    cell.moreButtonClickBlock = ^{
        @strongify(self)
        __strong typeof(weakCell) strongCell = weakCell;
        NSLog(@"more button click");
        self.moreButtonClickIndex = indexPath.row;
        [[PopoverView popoverView] showToView:strongCell.moreButton isLeftPic:NO isTitleLabelCenter:YES withActions:self.actions hideBlock:NULL];
    };

    if ([self.execRequestDic objectForKey:ossSceneM.scenarioId.stringValue]) {
        cell.backView.hidden = NO;
        cell.animationView.hidden = NO;
        [cell.animationView setAnimation:@"animation_scene_exec"];
        cell.animationView.loopAnimation = YES;
        [cell.animationView playFromProgress:0.25 toProgress:1 withCompletion:^(BOOL animationFinished) {
        }];
    } else {
        cell.backView.hidden = YES;
        cell.animationView.hidden = YES;
        [cell.animationView stop];
        cell.animationView.animationProgress = 0.25;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    GSHSceneCell *cell = (GSHSceneCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (!cell.backView.hidden) {
        return;
    }
    if (self.sourceArray.count > indexPath.row) {
        cell.animationView.hidden = NO;
        [cell.animationView setAnimationNamed:@"animation_scene_exec" inBundle:MYBUNDLE];
        cell.animationView.loopAnimation = YES;
        [cell.animationView playFromProgress:0.25 toProgress:1 withCompletion:^(BOOL animationFinished) {

        }];
        cell.backView.hidden = NO;
        GSHOssSceneM *ossSceneM = self.sourceArray[indexPath.row];
        NSURLSessionDataTask *sessionDataTask = [self executeSceneWithSceneListModel:ossSceneM sceneCell:cell];
        if (sessionDataTask) {
            [self.execRequestDic setObject:sessionDataTask forKey:ossSceneM.scenarioId.stringValue];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    //返回YES允许其item移动
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    //取出源item数据
    id objc = [self.sourceArray objectAtIndex:sourceIndexPath.item];
    //从资源数组中移除该数据
    [self.sourceArray removeObject:objc];
    //将数据插入到资源数组中的目标位置上
    [self.sourceArray insertObject:objc atIndex:destinationIndexPath.item];
    
//    self.isAlerted = YES;
    [self alertRankAfterHandleScene];   // 重新排序rank的值
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sceneTemplateArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHRecommendSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recommendSceneCell" forIndexPath:indexPath];
    if (self.sceneTemplateArray.count > indexPath.row) {
        GSHSceneTemplateM *sceneTemplateM = self.sceneTemplateArray[indexPath.row];
        [cell.templateImageView sd_setImageWithURL:[NSURL URLWithString:sceneTemplateM.imgUrl] placeholderImage:DeviceIconPlaceHoldImage];
        cell.templateNameLabel.text = sceneTemplateM.name;
        cell.templateDesLabel.text = sceneTemplateM.descriptionStr;
        @weakify(self)
        cell.activeButtonClickBlock = ^{
            @strongify(self)
            // 激活按钮点击
            [self activeButtonClickWithTemplateId:sceneTemplateM.sceneTemplateId];
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 41.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 41)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 200, 25)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18.0];
    label.text = @"推荐场景";
    [view addSubview:label];
    
    return view;
}

#pragma mark - request
// 查询情景模式列表
- (void)querySceneModeListWithFamilyId:(NSString *)familyId isShowLoading:(BOOL)isShowLoading {
    
    if (!familyId) {
        [self showBlankView];
        return;
    }
    if (self == [UIViewController visibleTopViewController] && isShowLoading) {
        [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    }
    @weakify(self)
    [GSHSceneManager getSceneListWithFamilyId:familyId currPage:@"1" block:^(GSHSceneListM *sceneListM,NSError *error) {
        @strongify(self)
        if (isShowLoading) {
            [TZMProgressHUDManager dismissInView:self.view];
        }
        [self.sceneCollectionView.mj_header endRefreshing];
        [self.recommendSceneTableView.mj_header endRefreshing];
        [self.contentView dismissPageStatusView];
        if (error) {
            TZMPageStatusView *statusView = [self.contentView showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [self querySceneModeListWithFamilyId:familyId isShowLoading:YES];
            }];
            statusView.backgroundColor = [UIColor whiteColor];
        } else {
            [self refreshUIWithGSHSceneListM:sceneListM];
        }
    }];
}

// 执行情景模式
- (NSURLSessionDataTask *)executeSceneWithSceneListModel:(GSHOssSceneM *)ossSceneM sceneCell:(GSHSceneCell *)sceneCell {
    
    __weak typeof(sceneCell) weakCell = sceneCell;
    return [GSHSceneManager executeSceneWithFamilyId:ossSceneM.familyId.stringValue gateWayId:[GSHOpenSDKShare share].currentFamily.gatewayId scenarioId:ossSceneM.scenarioId.stringValue block:^(NSError * _Nonnull error) {
        __strong typeof(weakCell) strongCell = weakCell;
        strongCell.backView.hidden = YES;
        if ([self.execRequestDic objectForKey:ossSceneM.scenarioId.stringValue]) {
            [self.execRequestDic removeObjectForKey:ossSceneM.scenarioId.stringValue];
        }
        if (error) {
            [strongCell.animationView setAnimationNamed:@"animation_scene_execFaild" inBundle:MYBUNDLE];
        } else {
            [strongCell.animationView setAnimationNamed:@"animation_scene_execSuccess" inBundle:MYBUNDLE];
        }
        [strongCell.animationView playFromProgress:0.25 toProgress:1 withCompletion:^(BOOL animationFinished) {
        }];
    }];
    
}

// 情景列表排序
- (void)sortSceneListRequest {
    
    NSMutableArray *scenariosArray = [NSMutableArray array];
    for (int i = 0; i < self.sourceArray.count; i ++) {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        GSHOssSceneM *ossSceneM = self.sourceArray[i];
        [tmpDic setObject:ossSceneM.scenarioId ? ossSceneM.scenarioId : @"" forKey:@"id"];
        [tmpDic setObject:ossSceneM.rank ? ossSceneM.rank : @"" forKey:@"rank"];
        [scenariosArray addObject:tmpDic];
    }
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHSceneManager sortSceneWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId rankArray:scenariosArray block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
        }
    }];
}



@end
