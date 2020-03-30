//
//  GSHAutomateVC.m
//  SmartHome
//
//  Created by gemdale on 2018/4/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutomateVC.h"
#import "GSHAutomateCell.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "UIView+TZMPageStatusViewEx.h"
#import <MJRefresh/MJRefresh.h>
#import "GSHAlertManager.h"
#import "NSObject+TZM.h"
#import "PopoverView.h"

#import "GSHAutoAddVC.h"
#import "GSHAutoCreateVC.h"

#import "GSHAutoTemplateCell.h"
#import "SDCycleScrollView.h"
#import <Lottie/Lottie.h>

#import "GSHAutoErrorCell.h"
#import "GSHWebViewController.h"

@interface GSHAutomateVC ()
<UITableViewDelegate,
UITableViewDataSource,
SDCycleScrollViewDelegate>

@property (nonatomic,strong) UITableView *automateTableView;
@property (nonatomic,strong) NSMutableArray *actions;
@property (nonatomic,strong) NSMutableArray *autoSourceArray;
@property (nonatomic,strong) GSHAutoM *tmpAutoM;
@property (nonatomic,assign) int currPage;

// 无联动，显示推荐联动及banner
@property (nonatomic,strong) UITableView *autoTemplateTableView;
@property (nonatomic,strong) NSMutableArray *autoTemplateArray;

@property (nonatomic,strong) UIView *headView;
@property (nonatomic,strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic,strong) NSMutableArray *autoBannerArray;

@property (nonatomic,assign) NSInteger moreButtonClickIndex;

@property (strong,nonatomic) NSError *autoTemplateError;
@property (strong,nonatomic) NSError *autoBannerError;
@property (nonatomic,strong) UIView *autoBannerErrorHeadView;

@property (nonatomic,assign) __block BOOL isBannerRequest;
@property (nonatomic,assign) __block BOOL isTemplateRequest;

@end

@implementation GSHAutomateVC

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"联动";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.automateTableView setBackgroundColor:[UIColor colorWithHexString:@"#F6F7FA"]];
     
    self.autoTemplateArray = [NSMutableArray array];
    self.autoBannerArray = [NSMutableArray array];
    
    [self createNavigationButton]; // 创建 导航栏 按钮
    
    [self getAutoListWithAutoId:@(0) isShowLoading:YES]; // 获取联动列表 获取第一页
    
    [self observerNotifications];
    
}

- (void)observerNotifications {
    [self observerNotification:GSHOpenSDKFamilyChangeNotification];
}

- (void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHOpenSDKFamilyChangeNotification]) {
        GSHFamilyM *family = notification.object;
        if ([family isKindOfClass:GSHFamilyM.class]) {
            [self getAutoListWithAutoId:@(0) isShowLoading:NO]; // 获取联动列表 获取第一页
        }
    }
}

- (void)dealloc{
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)createNavigationButton {
    // 添加
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage ZHImageNamed:@"sense_icon_add_normal"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addAutoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    
    // 离线模式 或 成员(v3.1.1) 隐藏添加联动按钮
    self.navigationItem.rightBarButtonItem.customView.hidden = ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN || [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) ? YES : NO;
}

- (void)refreshCurrentUIWithData {
    if (self.autoSourceArray.count > 0) {
        // 有联动 -- 显示联动
        if (self.autoTemplateArray.count > 0) {
            [self.autoTemplateArray removeAllObjects];
        }
        if (self.autoBannerArray.count > 0) {
            [self.autoBannerArray removeAllObjects];
        }
        self.autoTemplateTableView.hidden = YES;
        self.automateTableView.hidden = NO;
    } else {
        // 无联动 -- 显示banner 及 联动模版
        self.autoTemplateTableView.hidden = NO;
        self.automateTableView.hidden = YES;
    }
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
                            [self deleteAuto];
                        }
                    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确认要删除该联动吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"删除" cancelButtonTitle:@"取消" otherButtonTitles:nil];
                }
            }];
            [_actions addObject:action];
        }
    }
    return _actions;
}

- (NSMutableArray *)autoSourceArray {
    if (!_autoSourceArray) {
        _autoSourceArray = [NSMutableArray array];
    }
    return _autoSourceArray;
}

- (UITableView *)automateTableView {
    if (!_automateTableView) {
        _automateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KNavigationBar_Height) style:UITableViewStyleGrouped];
        _automateTableView.dataSource = self;
        _automateTableView.delegate = self;
        _automateTableView.sectionHeaderHeight = 16;
        _automateTableView.sectionFooterHeight = 0;
        [_automateTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)]];
        [_automateTableView registerNib:[UINib nibWithNibName:@"GSHAutomateCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"automateCell"];
        
        _automateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_automateTableView];
        
        @weakify(self)
        _automateTableView.mj_header = [GSHPullDownHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self getAutoListWithAutoId:@(0) isShowLoading:NO]; // 获取联动列表 获取第一页
        }];
        
        _automateTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            if (self.autoSourceArray.count > 0) {
                GSHAutoM *autoM = self.autoSourceArray.lastObject;
                [self getAutoListWithAutoId:autoM.ruleId isShowLoading:NO];
            }
        }];
    }
    return _automateTableView;
}

- (UITableView *)autoTemplateTableView {
    if (!_autoTemplateTableView) {
        _autoTemplateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KStatusBar_Height - 50) style:UITableViewStyleGrouped];
        _autoTemplateTableView.backgroundColor = [UIColor whiteColor];
        _autoTemplateTableView.delegate = self;
        _autoTemplateTableView.dataSource = self;
        _autoTemplateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_autoTemplateTableView registerNib:[UINib nibWithNibName:@"GSHAutoTemplateCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"templateCell"];
        [_autoTemplateTableView registerNib:[UINib nibWithNibName:@"GSHAutoErrorCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"autoErrorCell"];
        [self.view addSubview:_autoTemplateTableView];
        @weakify(self)
        _autoTemplateTableView.mj_header = [GSHPullDownHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self getAutoListWithAutoId:@(0) isShowLoading:NO]; // 获取联动列表 获取第一页
        }];
        
    }
    return _autoTemplateTableView;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * (166 / 375.0))];
        _headView.backgroundColor = [UIColor whiteColor];
        
        self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:nil];
        self.cycleScrollView.autoScroll = NO;
        self.cycleScrollView.layer.cornerRadius = 12.0f;
        self.cycleScrollView.clipsToBounds = YES;
        [_headView addSubview:self.cycleScrollView];
        [self.cycleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_headView);
            make.centerY.equalTo(_headView);
            make.width.equalTo(_headView).with.offset(-24);
            make.height.equalTo(_headView).with.offset(-16);
        }];
    }
    return _headView;
}

- (UIView *)autoBannerErrorHeadView {
    if (!_autoBannerErrorHeadView) {
        _autoBannerErrorHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * (150 / 375.0))];
        GSHAutoErrorCell *errorView = [[NSBundle mainBundle] loadNibNamed:@"GSHAutoErrorCell" owner:self options:nil][0];
        @weakify(self)
        errorView.refreshButtonClickBlock = ^{
            // 请求联动banner
            @strongify(self)
            [self getAutoBannerIsShowAlert:YES];
        };
        errorView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * (150 / 375.0));
        [_autoBannerErrorHeadView addSubview:errorView];
    }
    return _autoBannerErrorHeadView;
}

- (GSHAutoM *)tmpAutoM {
    if (!_tmpAutoM) {
        _tmpAutoM = [[GSHAutoM alloc] init];
    }
    return _tmpAutoM;
}

#pragma mark - method
// 添加联动按钮点击
- (void)addAutoButtonClick:(UIButton *)button {
    
    if ([GSHOpenSDKShare share].currentFamily.familyId.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请先创建家庭" inView:self.view];
        return ;
    }
    @weakify(self)
    GSHAutoAddVC *autoAddVC = [GSHAutoAddVC autoAddVC];
    autoAddVC.hidesBottomBarWhenPushed = YES;
    autoAddVC.addAutoSuccessBlock = ^(GSHOssAutoM *ossAutoM) {
        @strongify(self)
        [self.autoSourceArray insertObject:ossAutoM atIndex:0];
        if (self.autoSourceArray.count > 0) {
            [self dismissPageStatusView];
            self.autoTemplateTableView.hidden = YES;
            self.automateTableView.hidden = NO;
            [self.automateTableView reloadData];
        }
    };
    [self.navigationController pushViewController:autoAddVC animated:YES];
    
}

- (void)hideBlankView {
    [self dismissPageStatusView];
}

// 编辑联动
- (void)editAuto {
    if (self.autoSourceArray.count > self.moreButtonClickIndex) {
        @weakify(self)
        GSHOssAutoM *ossAutoM = self.autoSourceArray[self.moreButtonClickIndex];
        NSString *json = [[GSHFileManager shared] readDataWithFileType:LocalStoreFileTypeAuto fileName:ossAutoM.fid];
        NSLog(@"===========本地取得的json : %@",json);
        @strongify(self)
        if (json) {
            // 编辑 本地有文件
            NSString *md5 = [json md5String];
            if (![md5 isEqualToString:ossAutoM.md5]) {
                // md5 改变，需要重新从服务器请求数据，更新到本地
                [self getFileFromSeverWithFid:ossAutoM.fid ossAutoM:ossAutoM rowIndex:(int)self.moreButtonClickIndex];
            } else {
                [self editButtonClickWithJson:json ossAutoM:ossAutoM rowIndex:(int)self.moreButtonClickIndex];
            }
        } else {
            [self getFileFromSeverWithFid:ossAutoM.fid ossAutoM:ossAutoM rowIndex:(int)self.moreButtonClickIndex];
        }
    }
}

- (void)editButtonClickWithJson:(NSString *)json ossAutoM:(GSHOssAutoM *)ossAutoM rowIndex:(int)rowIndex {
    self.tmpAutoM = [GSHAutoM yy_modelWithJSON:json];
    NSMutableArray *deviceIdArr = [NSMutableArray array];
    for (GSHAutoTriggerConditionListM *conditionListM in self.tmpAutoM.trigger.conditionList) {
        if (conditionListM.device) {
            [deviceIdArr addObject:conditionListM.device.deviceId];
        }
    }
    for (GSHAutoTriggerConditionListM *conditionListM in self.tmpAutoM.trigger.optionalConditionList) {
        if (conditionListM.device) {
            [deviceIdArr addObject:conditionListM.device.deviceId];
        }
    }
    NSMutableArray *tmpDeviceIdArr = [NSMutableArray array];
    NSMutableArray *tmpSceneArr = [NSMutableArray array];
    NSMutableArray *tmpAutoArr = [NSMutableArray array];
    for (GSHAutoActionListM *actionListM in self.tmpAutoM.actionList) {
        if (actionListM.device && ![deviceIdArr containsObject:actionListM.device.deviceId]) {
            [tmpDeviceIdArr addObject:actionListM.device.deviceId];
        }
        if (actionListM.businessId) {
            [tmpSceneArr addObject:actionListM.businessId];
        }
        if (actionListM.ruleId) {
            [tmpAutoArr addObject:actionListM.ruleId];
        }
    }
    [deviceIdArr addObjectsFromArray:tmpDeviceIdArr];

    @weakify(self)
    __weak typeof(ossAutoM) weakOssAutoM = ossAutoM;
    [TZMProgressHUDManager showWithStatus:@"数据校验中" inView:self.view];
    [GSHAutoManager checkDevicesFromServerWithDeviceIdArray:deviceIdArr sceneArray:tmpSceneArr autoArray:tmpAutoArr familyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSArray <GSHNameIdM*> *deviceArr,NSArray <GSHNameIdM*> *sceneArr,NSArray <GSHNameIdM*> *autoArr, NSError *error) {
        @strongify(self)
        __strong typeof(weakOssAutoM) strongOssAutoM = weakOssAutoM;
        [TZMProgressHUDManager dismissInView:self.view];
        if (!error) {
            NSMutableArray *notInDeviceArray = [NSMutableArray array];
            BOOL isAlert = NO;
            for (GSHAutoTriggerConditionListM *conditionListM in self.tmpAutoM.trigger.conditionList) {
                if (conditionListM.device) {
                    BOOL isIn = NO;
                    for (GSHNameIdM *tmpNameIdM in deviceArr) {
                        if ([conditionListM.device.deviceId isEqual:tmpNameIdM.idStr]) {
                            isIn = YES;
                            if (![conditionListM.device.deviceName isEqualToString:tmpNameIdM.nameStr]) {
                                conditionListM.device.deviceName = tmpNameIdM.nameStr;
                                isAlert = YES;
                            }
                        }
                    }
                    if (!isIn) {
                        [notInDeviceArray addObject:conditionListM];
                    }
                }
            }
            if (notInDeviceArray.count > 0) {
                [self.tmpAutoM.trigger.conditionList removeObjectsInArray:notInDeviceArray];
                isAlert = YES;
            }
            
            NSMutableArray *optNotInDeviceArray = [NSMutableArray array];
            for (GSHAutoTriggerConditionListM *conditionListM in self.tmpAutoM.trigger.optionalConditionList) {
                if (conditionListM.device) {
                    BOOL isIn = NO;
                    for (GSHNameIdM *tmpNameIdM in deviceArr) {
                        if ([conditionListM.device.deviceId isEqual:tmpNameIdM.idStr]) {
                            isIn = YES;
                            if (![conditionListM.device.deviceName isEqualToString:tmpNameIdM.nameStr]) {
                                conditionListM.device.deviceName = tmpNameIdM.nameStr;
                                isAlert = YES;
                            }
                        }
                    }
                    if (!isIn) {
                        [optNotInDeviceArray addObject:conditionListM];
                    }
                }
            }
            if (optNotInDeviceArray.count > 0) {
                [self.tmpAutoM.trigger.optionalConditionList removeObjectsInArray:optNotInDeviceArray];
                isAlert = YES;
            }
            
            NSMutableArray *notInDeviceActionArray = [NSMutableArray array];
            NSMutableArray *notInSceneActionArray = [NSMutableArray array];
            NSMutableArray *notInAutoActionArray = [NSMutableArray array];
            for (GSHAutoActionListM *actionListM in self.tmpAutoM.actionList) {
                if (actionListM.device) {
                    BOOL isIn = NO;
                    for (GSHNameIdM *tmpNameIdM in deviceArr) {
                        if ([actionListM.device.deviceId isEqual:tmpNameIdM.idStr]) {
                            isIn = YES;
                            if (![actionListM.device.deviceName isEqualToString:tmpNameIdM.nameStr]) {
                                actionListM.device.deviceName = tmpNameIdM.nameStr;
                                isAlert = YES;
                            }
                        }
                    }
                    if (!isIn) {
                        [notInDeviceActionArray addObject:actionListM];
                    }
                }
                if (actionListM.businessId) {
                    BOOL isIn = NO;
                    for (GSHNameIdM *tmpNameIdM in sceneArr) {
                        if ([actionListM.businessId isEqual:tmpNameIdM.idStr]) {
                            isIn = YES;
                            if (![actionListM.scenarioName isEqualToString:tmpNameIdM.nameStr]) {
                                actionListM.scenarioName = tmpNameIdM.nameStr;
                                isAlert = YES;
                            }
                        }
                    }
                    if (!isIn) {
                        [notInSceneActionArray addObject:actionListM];
                    }
                }
                if (actionListM.ruleId) {
                    BOOL isIn = NO;
                    for (GSHNameIdM *tmpNameIdM in autoArr) {
                        if ([actionListM.ruleId isEqual:tmpNameIdM.idStr]) {
                            isIn = YES;
                            if (![actionListM.ruleName isEqualToString:tmpNameIdM.nameStr]) {
                                actionListM.ruleName = tmpNameIdM.nameStr;
                                isAlert = YES;
                            }
                        }
                    }
                    if (!isIn) {
                        [notInAutoActionArray addObject:actionListM];
                    }
                }
            }
            if (notInDeviceActionArray.count > 0) {
                [self.tmpAutoM.actionList removeObjectsInArray:notInDeviceActionArray];
                isAlert = YES;
            }
            if (notInSceneActionArray.count > 0) {
                [self.tmpAutoM.actionList removeObjectsInArray:notInSceneActionArray];
                isAlert = YES;
            }
            if (notInAutoActionArray.count > 0) {
                [self.tmpAutoM.actionList removeObjectsInArray:notInAutoActionArray];
                isAlert = YES;
            }
            [self jumpToAutoEditVCWithAutoM:self.tmpAutoM ossAutoM:strongOssAutoM rowIndex:rowIndex isAlert:isAlert];
        } else {
            [self jumpToAutoEditVCWithAutoM:self.tmpAutoM ossAutoM:strongOssAutoM rowIndex:rowIndex isAlert:NO];
        }
    }];
}

- (void)jumpToAutoEditVCWithAutoM:(GSHAutoM *)autoM ossAutoM:(GSHOssAutoM *)ossAutoM rowIndex:(int)rowIndex isAlert:(BOOL)isAlert {
    
    GSHAutoCreateVC *autoCreateVC = [GSHAutoCreateVC autoCreateVCWithAutoVCType:AddAutoVCTypeEdit oldAutoM:autoM oldOssAutoM:ossAutoM];
    autoCreateVC.isAlertToNotiUser = isAlert;
    autoCreateVC.hidesBottomBarWhenPushed = YES;
    @weakify(self)
    autoCreateVC.updateAutoSuccessBlock = ^(GSHOssAutoM *ossAutoM) {
        @strongify(self)
        if (self.autoSourceArray.count > rowIndex) {
            [self.autoSourceArray removeObjectAtIndex:rowIndex];
        }
        [self.autoSourceArray insertObject:ossAutoM atIndex:rowIndex];
        [self.automateTableView reloadData];
    };
    [self.navigationController pushViewController:autoCreateVC animated:YES];

}

// 删除联动
- (void)deleteAuto {
    if (self.autoSourceArray.count > self.moreButtonClickIndex) {
        [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
        GSHOssAutoM *ossAutoM = self.autoSourceArray[self.moreButtonClickIndex];
        @weakify(self)
        [GSHAutoManager deleteAutoWithOssAutoM:ossAutoM familyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSError *error) {
            @strongify(self)
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            } else {
                [TZMProgressHUDManager showSuccessWithStatus:@"删除成功" inView:self.view];
                if (self.autoSourceArray.count > self.moreButtonClickIndex) {
                    [self.autoSourceArray removeObjectAtIndex:self.moreButtonClickIndex];
                    [self.automateTableView reloadData];
                    if (self.autoSourceArray.count == 0) {
                        // 请求联动模版列表 及 banner
                        [self getAutoTemplateListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId];
                        [self getAutoBannerIsShowAlert:NO];
                    }
                }
            }
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.automateTableView) {
        return 1;
    } else {
        if (self.autoTemplateError) {
            // 模版列表请求出错
            return 1;
        }
        return self.autoTemplateArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.automateTableView) {
        return self.autoSourceArray.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.automateTableView) {
        return 134.0f;
    } else {
        if (self.autoTemplateError) {
            // 模版列表请求出错
            return 300.0f;
        }
        return (SCREEN_WIDTH - 32) * (100 / 343.0);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.automateTableView) {
        GSHAutomateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"automateCell" forIndexPath:indexPath];
        if (self.autoSourceArray.count > indexPath.row) {
            __block GSHOssAutoM *ossAutoM = self.autoSourceArray[indexPath.row];
            [cell setAutoCellValueWithOssAutoM:ossAutoM];
            @weakify(self)
            __weak typeof(ossAutoM) weakOssAutoM = ossAutoM;
            cell.openSwitchClickBlock = ^(UISwitch *openSwitch) {
                @strongify(self)
                __strong typeof(weakOssAutoM) strongOssAutoM = weakOssAutoM;
                [self updateAutoWithSwitch:openSwitch ossAutoM:strongOssAutoM];
            };
            // more button click
            __weak typeof(cell) weakCell = cell;
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                cell.moreButtonClickBlock = ^{
                    @strongify(self)
                    __strong typeof(weakCell) strongCell = weakCell;
                    NSLog(@"more button click");
                    self.moreButtonClickIndex = indexPath.row;
                    [[PopoverView popoverView] showToView:strongCell.moreButton
                                                isLeftPic:NO
                                       isTitleLabelCenter:YES
                                              withActions:self.actions
                                                hideBlock:NULL];
                };
            }
        }
        return cell;
    } else {
        if (self.autoTemplateError) {
            // 模版列表请求出错
            GSHAutoErrorCell *errorCell = [tableView dequeueReusableCellWithIdentifier:@"autoErrorCell" forIndexPath:indexPath];
            @weakify(self)
            errorCell.refreshButtonClickBlock = ^{
                // 请求模版列表
                @strongify(self)
                [self getAutoTemplateListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId];
            };
            return errorCell;
        } else {
            GSHAutoTemplateCell *autoTemplateCell = [tableView dequeueReusableCellWithIdentifier:@"templateCell" forIndexPath:indexPath];
            if (self.autoTemplateArray.count > indexPath.section) {
                GSHAutoM *autoM = self.autoTemplateArray[indexPath.section];
                [autoTemplateCell.templateImageView sd_setImageWithURL:[NSURL URLWithString:autoM.picPath]];
            }
            return autoTemplateCell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.autoTemplateTableView) {
        if (section == 0) {
            return 45.0f;
        }
        return 8.0f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.autoTemplateTableView && section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
         
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, 200, 25)];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18.0];
        label.text = @"联动模板";
        [view addSubview:label];
        return view;
    } else {
        return [[UIView alloc] init];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 联动模版点击
    if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
        // v3.1.1 成员点击联动模版,提示不可点击
        [TZMProgressHUDManager showErrorWithStatus:@"成员无此权限" inView:self.view];
    } else {
        if (self.autoTemplateArray.count > indexPath.section) {
            GSHAutoM *autoM = self.autoTemplateArray[indexPath.section];
            GSHAutoCreateVC *autoCreateVC = [GSHAutoCreateVC autoCreateVCWithAutoVCType:AddAutoVCTypeTemplate oldAutoM:autoM oldOssAutoM:nil];
            autoCreateVC.hidesBottomBarWhenPushed = YES;
            @weakify(self)
            autoCreateVC.addAutoSuccessBlock = ^(GSHOssAutoM *ossAutoM) {
                @strongify(self)
                [self.autoSourceArray insertObject:ossAutoM atIndex:0];
                if (self.autoSourceArray.count > 0) {
                    [self dismissPageStatusView];
                    self.autoTemplateTableView.hidden = YES;
                    self.automateTableView.hidden = NO;
                    [self.automateTableView reloadData];
                }
            };
            [self.navigationController pushViewController:autoCreateVC animated:YES];
        }
    }
}

#pragma mark - request

// 获取联动列表
- (void)getAutoListWithAutoId:(NSNumber *)autoId isShowLoading:(BOOL)isShowLoading {
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if (self == [UIViewController visibleTopViewController] && isShowLoading) {
        [TZMProgressHUDManager showWithStatus:@"获取联动列表中" inView:self.view];
    }
    __weak typeof(self)weakSelf = self;
    [GSHAutoManager getAutoListNewWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId lastAutoId:autoId block:^(NSArray<GSHOssAutoM *> *list, NSError *error) {
        [self.automateTableView.mj_header endRefreshing];
        [self.automateTableView.mj_footer endRefreshing];
        [self.autoTemplateTableView.mj_header endRefreshing];
        [self.view dismissPageStatusView];
        if (error) {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [weakSelf.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [weakSelf getAutoListWithAutoId:autoId isShowLoading:isShowLoading];
            }];
        } else {
            if (autoId.intValue == 0 && weakSelf.autoSourceArray.count > 0) {
                [weakSelf.autoSourceArray removeAllObjects];
            }
            if (list.count < 12) {
                weakSelf.automateTableView.mj_footer.state = MJRefreshStateNoMoreData;
                weakSelf.automateTableView.mj_footer.hidden = YES;
            } else {
                weakSelf.automateTableView.mj_footer.state = MJRefreshStateIdle;
                weakSelf.automateTableView.mj_footer.hidden = NO;
            }
            [weakSelf.autoSourceArray addObjectsFromArray:list];
            
            if (weakSelf.autoSourceArray.count == 0) {
                // 请求联动模版列表 及 banner
                [weakSelf getAutoTemplateListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId];
                [weakSelf getAutoBannerIsShowAlert:NO];
            } else {
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [weakSelf hideBlankView];
                [weakSelf.automateTableView reloadData];
            }
        }
    }];
    
}

// 获取联动模版列表
- (void)getAutoTemplateListWithFamilyId:(NSString *)familyId {
    if (self == [UIViewController visibleTopViewController]) {
        [TZMProgressHUDManager showWithStatus:@"获取联动模板中" inView:self.view];
    }
    self.isTemplateRequest = NO;
    self.autoTemplateError = nil;
    __weak typeof(self)weakSelf = self;
    [GSHAutoManager getAutoTemplateListWithFamilyId:familyId isOnlyRecommend:@"1" block:^(NSArray<GSHAutoM *> *autoTemplateList, NSError *error) {
        [TZMProgressHUDManager dismissInView:weakSelf.view];
        if (error) {
            weakSelf.autoTemplateError = error;
        } else {
            self.isTemplateRequest = YES;
            if (weakSelf.autoTemplateArray.count > 0) {
                [weakSelf.autoTemplateArray removeAllObjects];
            }
            [weakSelf.autoTemplateArray addObjectsFromArray:autoTemplateList];
        }
        weakSelf.autoTemplateTableView.hidden = NO;
        weakSelf.automateTableView.hidden = YES;
        [weakSelf.autoTemplateTableView reloadData];
        [weakSelf refreshUIAfterRequestComplete];
    }];
}

// 获取联动banner
- (void)getAutoBannerIsShowAlert:(BOOL)isShowAlert {
    
    @weakify(self)
    if (isShowAlert) {
        [TZMProgressHUDManager showWithStatus:@"获取广告页中" inView:self.view];
    }
    self.isBannerRequest = NO;
    [GSHBannerManager getBannerListWithBannerType:GSHBannerMTypeLianDong block:^(NSArray<GSHBannerM *> *bannerList, NSError *error) {
        @strongify(self)
        if (isShowAlert) {
            [TZMProgressHUDManager dismissInView:self.view];
        }
        if (error) {
            self.autoBannerError = error;
            [self.autoTemplateTableView setTableHeaderView:self.autoBannerErrorHeadView];
        } else {
            self.isBannerRequest = YES;
            if (self.autoBannerArray.count > 0) {
                [self.autoBannerArray removeAllObjects];
            }
            [self.autoBannerArray addObjectsFromArray:bannerList];
            if (bannerList.count > 0) {
                NSMutableArray *bannerImageArray = [NSMutableArray array];
                for (GSHBannerM *bannerM in bannerList) {
                    [bannerImageArray addObject:bannerM.picUrl];
                }
                [self.autoTemplateTableView setTableHeaderView:self.headView];
                self.cycleScrollView.imageURLStringsGroup = bannerImageArray;
                @weakify(self)
                self.cycleScrollView.clickItemOperationBlock = ^(NSInteger currentIndex) {
                    @strongify(self)
                    if (bannerList.count > currentIndex) {
                        GSHBannerM *bannerM = bannerList[currentIndex];
                        NSURL *url = [NSURL URLWithString:bannerM.content];
                        [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
                    }
                };
            }
            [self refreshUIAfterRequestComplete];
        }
    }];
}

- (void)refreshUIAfterRequestComplete {
    if (self.isBannerRequest && self.isTemplateRequest && self.autoTemplateArray.count == 0 && self.autoBannerArray.count == 0) {
        // 广告页和模版都请求成功,且无广告页和模版 -- 显示空白页

        NSString *desc = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsManager ? @"点击右上方\"+\"按钮，添加联动" : @"";
        TZMPageStatusView *statusView = [self.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_homeautomation"] title:@"暂无联动" desc:desc buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
            [self getAutoListWithAutoId:@(0) isShowLoading:YES]; // 获取联动列表 获取第一页
        }];
        statusView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)updateAutoWithSwitch:(UISwitch *)openSwitch ossAutoM:(GSHOssAutoM *)ossAutoM {
    
    NSString *status = [NSString stringWithFormat:@"%d",openSwitch.on];
    __weak typeof(ossAutoM) weakOssAutoM = ossAutoM;
    [TZMProgressHUDManager showWithStatus:@"操作中" inView:self.view];
    @weakify(self)
    [GSHAutoManager updateAutoSwitchWithRuleId:ossAutoM.ruleId.stringValue status:status gateWayId:[GSHOpenSDKShare share].currentFamily.gatewayId familyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            openSwitch.on = !openSwitch.on;
        } else {
            __strong typeof(weakOssAutoM) strongOssAutoM = weakOssAutoM;
            [TZMProgressHUDManager showSuccessWithStatus:@"操作成功" inView:self.view];
            openSwitch.on = [status intValue];
            strongOssAutoM.status = @(openSwitch.on);
        }
    }];
    
}

- (void)getFileFromSeverWithFid:(NSString *)fid ossAutoM:(GSHOssAutoM *)ossAutoM rowIndex:(int)rowIndex {
    if (fid.length == 0) {
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"获取文件数据中" inView:self.view];
    @weakify(self)
    [GSHAutoManager getAutoFileFromOssWithFid:fid block:^(NSString *json, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            [self editButtonClickWithJson:json ossAutoM:ossAutoM rowIndex:rowIndex];
        }
    }];
}

@end
