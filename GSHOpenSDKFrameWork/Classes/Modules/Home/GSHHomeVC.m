//
//  GSHHomeVC.m
//  SmartHome
//
//  Created by gemdale on 2018/4/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHHomeVC.h"
#import "GSHCreateFamilyVC.h"
#import "GSHHomeRoomVC.h"
#import "GSHDeviceCategoryVC.h"
#import "GSHSensorListVC.h"

#import "UINavigationController+TZM.h"
#import "UIView+TZMPageStatusViewEx.h"
#import <MJRefresh.h>

#import "IQKeyboardManager.h"
#import "GSHAlertManager.h"

#import "LGAlertView.h"
#import "PopoverView.h"
#import "GSHSegmentTitleView.h"
#import "GSHPageContentView.h"
#import <JdPlaySdk/JdPlaySdk.h>
#import "GSHVersionCheckUpdateVC.h"
#import "ELCycleVerticalView.h"

NSString *const GSHRefreshHomeDataNotifacation = @"GSHRefreshHomeDataNotifacation";

@interface GSHHomeVC ()<UIScrollViewDelegate,GSHSegmentTitleViewDelegate,GSHPageContentViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewNav;
@property (weak, nonatomic) IBOutlet UIButton *btnFangYu;
@property (weak, nonatomic) IBOutlet UIButton *btnAddDevice;
- (IBAction)touchRightNavItemAdd:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;

@property (weak, nonatomic) IBOutlet UIView *viewTou;
@property (weak, nonatomic) IBOutlet UIView *viewNoFamily;
@property (weak, nonatomic) IBOutlet UIView *viewSubRoom;
@property (weak, nonatomic) IBOutlet UIView *viewRoom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcHeight;
//----------------------
@property (weak, nonatomic) IBOutlet UILabel *lblFamilyName;
@property (weak, nonatomic) IBOutlet UIImageView *viewJiaTingJianTou;
- (IBAction)touchChangeFamily:(UIButton *)sender;
//----------------------
@property (weak, nonatomic) IBOutlet UIView *viewLouCeng;
@property (weak, nonatomic) IBOutlet UILabel *lblLouCeng;
@property (weak, nonatomic) IBOutlet UIImageView *viewLouCengJianTou;
- (IBAction)touchLouCeng:(UIButton *)sender;
//----------------------
@property (weak, nonatomic) IBOutlet UILabel *lblHuangJing;
@property (weak, nonatomic) IBOutlet UILabel *lblAnFang;
- (IBAction)touchFamilyIndex:(UIButton *)sender;
//----------------------
@property (weak, nonatomic) IBOutlet UIView *viewDian;
@property (weak, nonatomic) IBOutlet UILabel *lblZhuangTai;
@property (weak, nonatomic) IBOutlet ELCycleVerticalView *viewZhuangTai;

@property (weak, nonatomic) IBOutlet UIView *viewRoomContent;

@property (weak, nonatomic) IBOutlet UIView *gatewayUnLinkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gatewayUnLinkViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblGatewayUnlink;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewArrow;
- (IBAction)pushGatewayUnlinkVC:(UIButton *)sender;

@property (nonatomic, strong) NSArray<GSHBannerM*> *bannerList;
@property (nonatomic, strong) GSHFloorM *floor;
@property (nonatomic, strong) GSHRoomM *room;
@property (nonatomic, strong) NSMutableArray<PopoverAction *> *actionsFamily;
@property (nonatomic, strong) NSMutableArray<PopoverAction *> *actionsFloor;
@property (nonatomic, strong) GSHPageContentView *pageContentView;
@property (nonatomic, strong) GSHSegmentTitleView *titleView;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, strong) NSMutableDictionary *familyIndex;
@property (nonatomic, assign) BOOL canCheckGW;
@end

@implementation GSHHomeVC
+(instancetype)homeVC{
    return [GSHPageManager viewControllerWithSB:@"HomeSB" andID:@"GSHHomeVC"];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return self.statusBarStyle;
}

#pragma mark - 基础方法
-(void)dealloc{
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [JdShareClass sharedInstance];
    
    self.tzm_prefersNavigationBarHidden = YES;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    self.rootScrollView.scrollsToTop = NO;
    self.canCheckGW = YES;

    __weak typeof(self)weakSelf = self;

    self.titleView = [[GSHSegmentTitleView alloc]initWithFrame:CGRectZero titles:nil delegate:self];
    self.titleView.titleFont = [UIFont systemFontOfSize:14];
    self.titleView.titleSelectFont = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.titleView.titleNormalColor = [UIColor colorWithRGB:0x999999];
    self.titleView.titleSelectColor = [UIColor colorWithRGB:0x3C4366];
    self.titleView.bgSelectImage = [UIImage ZHImageNamed:@"homeVC_bg_romeItem"];
    [self.viewRoom addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.viewRoom);
    }];

    self.pageContentView = [[GSHPageContentView alloc]initWithFrame:CGRectZero childVCs:nil parentVC:self delegate:self];
    [self.viewRoomContent addSubview:self.pageContentView];
    [self.pageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.viewRoomContent);
    }];

    self.rootScrollView.mj_header = [GSHPullDownHeader headerWithRefreshingBlock:^{
        [weakSelf refreshFamilyList];
        [weakSelf refreshAdList];
    }];

    [self.viewZhuangTai configureShowTime:1.5  animationTime:0.9 direction:ELCycleVerticalViewScrollDirectionUp backgroundColor:[UIColor clearColor] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];

    UIImage *image = [UIImage ZHImageNamed:@"list_icon_arrow_right"];
    self.imageViewArrow.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self changeNetworkTypeRefrsh];
    [self refreshFamilyList];
    [self refreshAdList];
    [self observerNotifications];
    
}

// 刷新导航栏右边按钮图标
- (void)changeNetworkTypeRefrsh{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN || [GSHOpenSDKShare share].familyList.count == 0) {
        self.btnAddDevice.hidden = YES;
        self.btnFangYu.hidden = YES;
    } else {
        self.btnAddDevice.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember;
         self.btnFangYu.hidden = NO;
    }
}

#pragma mark - 通知
-(void)observerNotifications{
    [self observerNotification:GSHOpenSDKFamilyListUpdataNotification];                         // 家庭列表更新
    [self observerNotification:GSHOpenSDKFamilyUpdataNotification];                             // 当前家庭改变
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];     // ws实时数据更新
    [self observerNotification:TZMRemoteNotification];                                          // 收到推送
    [self observerNotification:GSHControlSwitchSuccess];                                        // 收到切换控制成功的通知
    [self observerNotification:GSHChangeNetworkManagerWebSocketOpenNotification];               // websocket 连接成功通知
    [self observerNotification:GSHChangeNetworkManagerWebSocketCloseNotification];              // websocket 连接失败
    [self observerNotification:GSHOpenSDKFamilyGatewayChangeNotification];                      // 网关替换中
    [self observerNotification:GSHRefreshHomeDataNotifacation];                                 // 收到通知刷新首页数据
    [self observerNotification:GSHOpenSDKDeviceUpdataNotification];                             // 设备更新（会带上一个数组，改动相关房间的roomId）
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHOpenSDKFamilyUpdataNotification]) {
        [self familyChangeRefreshUI];
    }
    if ([notification.name isEqualToString:GSHOpenSDKFamilyListUpdataNotification]) {
        [self familyListChangeRefreshUI];
    }
    if ([notification.name isEqualToString:GSHOpenSDKDeviceUpdataNotification]) {
        __weak typeof(self)weakSelf = self;
        [GSHFloorManager getHomeVCFloorListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId flag:@(1) block:^(NSArray<GSHFloorM *> *floorList, NSError *error, NSString *gatewayId, NSString *onlineStatus, NSInteger familyDeviceCount) {
            if (!error) {
                [GSHOpenSDKShare share].currentFamily.familyDevcieCount = @(familyDeviceCount);
                [((GSHHomeRoomVC*)weakSelf.pageContentView.currentVC) refreshAdList:weakSelf.bannerList];
            }
        }];
    }
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification]) {
        NSDictionary *gatewayDic = [[GSHWebSocketClient shared].realTimeDic objectForKey:[GSHOpenSDKShare share].currentFamily.gatewayId];
        NSString *gatewayLinkValue = [gatewayDic objectForKey:GSHDeviceOnLineStateMeteId];
        if (gatewayLinkValue) {
            if ([GSHOpenSDKShare share].currentFamily.onlineStatus != gatewayLinkValue.intValue) {
                if ([GSHWebSocketClient shared].networkType != GSHNetworkTypeLAN) {
                    [GSHOpenSDKShare share].currentFamily.onlineStatus = gatewayLinkValue.intValue;
                    [self showOrHiddenGatewayUnLinkView];
                }
                
            }
        }
    }
    if ([notification.name isEqualToString:TZMRemoteNotification]) {
        // 收到告警推送 ，刷新传感器
        NSDictionary *dic = (NSDictionary *)notification.object;
        NSDictionary *userInfoDic = [dic objectForKey:@"userInfo"];
        NSString *deviceSn = [userInfoDic stringValueForKey:@"deviceSn" default:nil];
        if ([GSHOpenSDKShare share].currentFamily.gatewayId && [deviceSn isEqualToString:[GSHOpenSDKShare share].currentFamily.gatewayId]) {
            // 网关在线离线告警 -- 刷新当前家庭
            [self refreshRoomManagement:[GSHOpenSDKShare share].currentFamily];
        }
    }
    if ([notification.name isEqualToString:GSHControlSwitchSuccess]) {
        // 收到切换控制成功的通知
        [self changeNetworkTypeRefrsh];
        [GSHOpenSDKShare share].currentFamily = (GSHFamilyM *)notification.object;
        [[GSHUserManager currentUser]updataCurrentFamilyId:[GSHOpenSDKShare share].currentFamily.familyId];
        [self refreshFamilyList];
        
    }
    if ([notification.name isEqualToString:GSHOpenSDKFamilyGatewayChangeNotification]) {
        //网关替换中 刷新网关在线离线状态
        [self showOrHiddenGatewayUnLinkView];
    }
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketOpenNotification]) {
        // websocket 连接成功通知 刷新网关在线离线状态
        [GSHOpenSDKShare share].currentFamily.onlineStatus = GSHFamilyMGWStatusOnLine;
        [self showOrHiddenGatewayUnLinkView]; 
    }
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketCloseNotification]) {
        // websocket 连接失败通知 刷新网关在线离线状态
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            if ([GSHOpenSDKShare share].currentFamily.onlineStatus == GSHFamilyMGWStatusOnLine) {
                [GSHOpenSDKShare share].currentFamily.onlineStatus = GSHFamilyMGWStatusNoNetwork;
            }
        }else{
            [GSHOpenSDKShare share].currentFamily.onlineStatus = GSHFamilyMGWStatusOffLine;
        }
        [self showOrHiddenGatewayUnLinkView];
    }
    if ([notification.name isEqualToString:GSHRefreshHomeDataNotifacation]) {
        // 收到通知，刷新首页数据
        [self refreshFamilyList];
    }
}

-(void)switchoverRoomWithRoomId:(NSString*)roomId{
    GSHFamilyM *family = [GSHOpenSDKShare share].currentFamily;
    for (GSHFloorM *floor in family.floor) {
        for (GSHRoomM *room in floor.rooms) {
            if (roomId && [room.roomId.stringValue isEqualToString:roomId]) {
                if(floor.floorId && [self.floor.floorId isEqualToNumber:floor.floorId] && self.room == nil){
                    return;
                }
                self.floor = floor;
                [self floorChangeRefreshUI:@(roomId.integerValue)];
                return;
            }
        }
    }
}

#pragma mark - 刷新界面UI
//家庭列表改变刷新界面
-(void)familyListChangeRefreshUI{
    __weak typeof(self)weakSelf = self;
    self.actionsFamily = [NSMutableArray array];
    for (GSHFamilyM *family in [GSHOpenSDKShare share].familyList) {
        PopoverAction *action = [PopoverAction actionWithImage:[UIImage ZHImageNamed:@"app_sele_b"] title:family.familyName handler:^(PopoverAction *action) {
            [weakSelf refreshRoomManagement:family];
        }];
        [self.actionsFamily addObject:action];
    }
}

//当前家庭改变刷新界面
-(void)familyChangeRefreshUI{
    self.lblFamilyName.text = [GSHOpenSDKShare share].currentFamily.familyName;
    [self changeNetworkTypeRefrsh];
    if ([GSHOpenSDKShare share].currentFamily.gatewayId.length > 0) {
        [[GSHWebSocketClient shared] getWebSocketIpAndPortToConnectWithGWId:[GSHOpenSDKShare share].currentFamily.gatewayId];
    } else {
        [[GSHWebSocketClient shared] clearWebSocket];
    }
    
    if ([GSHOpenSDKShare share].currentFamily.floor.count > 1) {
        self.viewLouCeng.hidden = NO;
        GSHFloorM *seleFloor = nil;
        NSNumber *currentFloorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"GSHCurrentFloorId"];
        if (![currentFloorId isKindOfClass:NSNumber.class]) {
            currentFloorId = nil;
        }
        self.actionsFloor = [NSMutableArray array];
        for (GSHFloorM *floor in [GSHOpenSDKShare share].currentFamily.floor) {
            if (floor.floorId && [currentFloorId isEqualToNumber:floor.floorId]) {
                seleFloor = floor;
            }
            if(!seleFloor && [floor.floorName isEqualToString:@"一楼"]){
                seleFloor = floor;
            }
            __weak typeof(self)weakSelf = self;
            PopoverAction *action = [PopoverAction actionWithImage:[UIImage ZHImageNamed:@"app_sele_b"] title:floor.floorName handler:^(PopoverAction *action) {
                weakSelf.floor = floor;
                [weakSelf floorChangeRefreshUI:nil];
            }];
            [self.actionsFloor addObject:action];
        }
        if (seleFloor) {
            self.floor = seleFloor;
        } else {
            self.floor = [GSHOpenSDKShare share].currentFamily.floor.firstObject;
        }
    } else {
        self.viewLouCeng.hidden = YES;
        self.floor = [GSHOpenSDKShare share].currentFamily.floor.firstObject;
    }
    [self floorChangeRefreshUI:nil];
    [self showOrHiddenGatewayUnLinkView];
}

// 刷新楼层
-(void)floorChangeRefreshUI:(NSNumber*)roomId{
    self.lblLouCeng.text = self.floor.floorName;
    if (self.floor.floorId) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.floor.floorId forKey:@"GSHCurrentFloorId"];
        [userDefaults synchronize];
    }
    //设置房间按钮
    NSInteger seleIndex = 0;
    NSMutableArray<NSString*> *titles = [NSMutableArray array];
    NSMutableArray<UIViewController*> *VCs = [NSMutableArray array];
    NSNumber *seleRoomId;
    if (roomId) {
        seleRoomId = roomId;
    }else{
        seleRoomId = self.room.roomId;
    }
    
    [titles addObject:@"全部"];
    [VCs addObject:[GSHHomeRoomVC homeRoomVCWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId room:nil floor:self.floor]];
    for (NSInteger i = 0; i < self.floor.rooms.count; i++) {
        GSHRoomM *room = self.floor.rooms[i];
        [titles addObject:room.roomName];
        [VCs addObject:[GSHHomeRoomVC homeRoomVCWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId room:room floor:self.floor]];
        if ([room.roomId isEqual:seleRoomId]) {
            seleIndex = i + 1;
        }
    }
    [self.titleView refreshTitle:titles];
    self.titleView.selectIndex = seleIndex;
    [self.pageContentView refreshChildVCs:VCs];
    self.pageContentView.contentViewCurrentIndex = seleIndex;
    [((GSHHomeRoomVC*)self.pageContentView.currentVC) refreshAdList:self.bannerList];
    if (self.floor.rooms.count > (seleIndex - 1) && (seleIndex - 1) >= 0) {
        self.room = self.floor.rooms[seleIndex - 1];
    }else{
        self.room = nil;
    }
}

// 根据网关在线状态 显示网关是否离线标识
- (void)showOrHiddenGatewayUnLinkView {
    if ([GSHOpenSDKShare share].currentFamily.gatewayId) {
        // 有网关
        if ([GSHOpenSDKShare share].currentFamily.onlineStatus != GSHFamilyMGWStatusOnLine) {
            // 网关离线
            self.gatewayUnLinkView.hidden = NO;
            self.gatewayUnLinkViewHeight.constant = 36.0;
            if ([GSHOpenSDKShare share].currentFamily.onlineStatus == GSHFamilyMGWStatusOffLine) {
                if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                    self.lblGatewayUnlink.text = @"网关已离线";
                }else{
                    self.lblGatewayUnlink.text = @"未检测到网关";
                }
                self.imageViewArrow.hidden = NO;
            }else if ([GSHOpenSDKShare share].currentFamily.onlineStatus == GSHFamilyMGWStatusNoNetwork) {
                self.lblGatewayUnlink.text = @"网络不给力，请检查网络设置";
                self.imageViewArrow.hidden = YES;
            }else{
                self.lblGatewayUnlink.text = @"网关正在替换，网关不得断电断网";
                self.imageViewArrow.hidden = YES;
            }
        } else {
            // 网关在线
            self.gatewayUnLinkView.hidden = YES;
            self.gatewayUnLinkViewHeight.constant = 0;
            [[GSHWebSocketClient shared] sendGetRealTimeMsg]; // 重发301
        }
    } else {
        // 无网关
        self.gatewayUnLinkView.hidden = YES;
        self.gatewayUnLinkViewHeight.constant = 0;
    }
}

-(void)refreshFamilyIndexUI{
    NSString *envScore,*envColor,*envAlarmColor,*envAlarmTip,*securityScore,*securityColor,*securityAlarmColor,*securityAlarmTip,*tip;
    NSArray *alarms;
    
    envScore = [self.familyIndex stringValueForKey:@"envScore" default:@"0"];
    envColor = [self.familyIndex stringValueForKey:@"envColor" default:@"222222"];
    NSDictionary *envAlarm = [self.familyIndex objectForKey:@"envAlarm"];
    if ([envAlarm isKindOfClass:NSDictionary.class]) {
        envAlarmColor = [envAlarm stringValueForKey:@"color" default:nil];
        envAlarmTip = [envAlarm stringValueForKey:@"tip" default:nil];
    }

    securityScore = [self.familyIndex stringValueForKey:@"securityScore" default:@"0"];
    securityColor = [self.familyIndex stringValueForKey:@"securityColor" default:@"222222"];
    NSDictionary *securityAlarm = [self.familyIndex objectForKey:@"securityAlarm"];
    if ([securityAlarm isKindOfClass:NSDictionary.class]) {
        securityAlarmColor = [securityAlarm stringValueForKey:@"color" default:nil];
        securityAlarmTip = [securityAlarm stringValueForKey:@"tip" default:nil];
    }
    
    tip = [self.familyIndex stringValueForKey:@"tip" default:@""];
    if ([[self.familyIndex objectForKey:@"alarms"] isKindOfClass:NSArray.class]) {
        alarms = [self.familyIndex objectForKey:@"alarms"];
    }
    
    if (envAlarmTip.length > 0) {
        self.lblHuangJing.text = envAlarmTip;
        self.lblHuangJing.textColor = [UIColor colorWithHexString:envAlarmColor];
    }else{
        self.lblHuangJing.text = envScore;
        self.lblHuangJing.textColor = [UIColor colorWithHexString:envColor];
    }
    
    if (securityAlarmTip.length > 0) {
        self.lblAnFang.text = securityAlarmTip;
        self.lblAnFang.textColor = [UIColor colorWithHexString:securityAlarmColor];
    }else{
        self.lblAnFang.text = securityScore;
        self.lblAnFang.textColor = [UIColor colorWithHexString:securityColor];
    }
    alarms = @[@"1111111111",@"2222222222",@"3333333333"];
    if (alarms.count > 0) {
        self.viewZhuangTai.dataSource = alarms;
    }else{
        self.viewZhuangTai.dataSource = @[tip];
    }
    self.lblZhuangTai.hidden = YES;
    self.viewDian.hidden = YES;
}

-(void)refreshNoFamilyUI:(NSError*)error{
    __weak typeof(self)weakSelf = self;
    TZMPageStatusView *view;
    if (error) {
        view = [weakSelf.viewNoFamily showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"homeRoomVC_icon_noHaveFamily"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
            [weakSelf refreshFamilyList];
        }];
    }else{
        view = [weakSelf.viewNoFamily showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"homeRoomVC_icon_noHaveFamily"] title:@"暂无家庭" desc:nil buttonText:@"添加家庭" didClickButtonCallback:^(TZMPageStatus status) {
            GSHFamilyListVC *vc = [GSHFamilyListVC familyListVC];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
        [GSHOpenSDKShare share].familyList = nil;
        [GSHOpenSDKShare share].currentFamily = nil;
        [[GSHUserManager currentUser]updataCurrentFamilyId:nil];
    }
    view.backgroundColor = [UIColor clearColor];
}

#pragma mark -刷新界面数据
-(void)refreshAdList{
    __weak typeof(self)weakself = self;
    [GSHBannerManager getBannerListWithBannerType:GSHBannerMTypeShouYe block:^(NSArray<GSHBannerM *> *bannerList, NSError *error) {
        if (bannerList) {
            weakself.bannerList = bannerList;
            if ([weakself.pageContentView.currentVC isKindOfClass:GSHHomeRoomVC.class]) {
                [((GSHHomeRoomVC*)weakself.pageContentView.currentVC) refreshAdList:bannerList];
            }
        }
    }];
}

-(void)refreshFamilyIndex{
    __weak typeof(self)weakself = self;
    if (GSHNetworkTypeLAN == [GSHWebSocketClient shared].networkType || [GSHOpenSDKShare share].currentFamily.familyId == nil) {
        self.familyIndex = nil;
        self.lblHuangJing.text = @"0";
        self.lblAnFang.text = @"0";
        return;
    }
    weakself.familyIndex = [NSMutableDictionary dictionary];
    [GSHFamilyManager getFamilyIndexWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSDictionary *familyIndex, NSError *error) {
        weakself.familyIndex = [NSMutableDictionary dictionaryWithDictionary:familyIndex];
        [weakself refreshFamilyIndexUI];
    }];
}

-(void)refreshFamilyList{
    __weak typeof(self)weakSelf = self;
    if ([GSHOpenSDKShare share].familyList.count == 0) {
        if ([UIViewController visibleTopViewController] == self) [TZMProgressHUDManager showWithStatus:@"加载家庭列表中" inView:self.view];
    }
    [GSHFamilyManager getHomeVCFamilyListWithblock:^(NSArray<GSHFamilyM *> *familyList, NSError *error) {
        [TZMProgressHUDManager dismissInView:weakSelf.view];
        if (familyList.count > 0) {
            [weakSelf.view dismissPageStatusView];
            [weakSelf familyListChangeRefreshUI];
            GSHFamilyM *seleFamily;
            for (GSHFamilyM *family in [GSHOpenSDKShare share].familyList) {
                if ([family.familyId isEqualToString:[GSHUserManager currentUser].currentFamilyId]) {
                    seleFamily = family;
                    break;
                }
            }
            if (!seleFamily) {
                seleFamily = familyList.firstObject;
            }
            [GSHOpenSDKShare share].currentFamily = seleFamily;
            [[GSHUserManager currentUser]updataCurrentFamilyId:[GSHOpenSDKShare share].currentFamily.familyId];
            [weakSelf refreshRoomManagement:[GSHOpenSDKShare share].currentFamily];

            weakSelf.viewNoFamily.hidden = YES;
            weakSelf.viewRoom.hidden = NO;
            weakSelf.viewSubRoom.hidden = NO;
            weakSelf.viewJiaTingJianTou.hidden = NO;
            weakSelf.lcHeight.priority = UILayoutPriorityDragThatCannotResizeScene;
        } else {
            [weakSelf.rootScrollView.mj_header endRefreshing];
            if (error == nil || [GSHOpenSDKShare share].familyList.count == 0) {
                [GSHOpenSDKShare share].currentFamily = nil;
                [weakSelf refreshNoFamilyUI:error];
                [weakSelf refreshFamilyIndex];
                weakSelf.viewNoFamily.hidden = NO;
                weakSelf.viewRoom.hidden = YES;
                weakSelf.viewSubRoom.hidden = YES;
                weakSelf.viewLouCeng.hidden = YES;
                weakSelf.lblFamilyName.text = @"暂无家庭";
                weakSelf.viewJiaTingJianTou.hidden = YES;
                weakSelf.viewDian.hidden = YES;
                weakSelf.lblZhuangTai.hidden = YES;
                weakSelf.familyIndex = nil;
                weakSelf.lcHeight.priority = UILayoutPriorityDragThatCanResizeScene;
            }
        }
        [weakSelf changeNetworkTypeRefrsh];
    }];
}

// 获取当前家庭下楼层房间信息
-(void)refreshRoomManagement:(GSHFamilyM*)family{
    if (!(self.rootScrollView.mj_header.state == MJRefreshStateRefreshing)) {
        if ([UIViewController visibleTopViewController] == self) [TZMProgressHUDManager showWithStatus:@"加载家庭详情中" inView:self.view];
    }
    __weak typeof(self)weakSelf = self;
    [GSHFloorManager getHomeVCFloorListWithFamilyId:family.familyId flag:@(1) block:^(NSArray<GSHFloorM *> *floorList, NSError *error, NSString *gatewayId, NSString *onlineStatus, NSInteger familyDeviceCount) {
        [TZMProgressHUDManager dismissInView:weakSelf.view];
        [weakSelf.rootScrollView.mj_header endRefreshing];
        if (error) {
            if ([UIViewController visibleTopViewController] == weakSelf) [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        } else {
            [GSHOpenSDKShare share].currentFamily = family;
            [[GSHUserManager currentUser]updataCurrentFamilyId:[GSHOpenSDKShare share].currentFamily.familyId];
            [weakSelf refreshFamilyIndex];
            if (gatewayId) {
                [GSHOpenSDKShare share].currentFamily.gatewayId = gatewayId;
            }
            if ([GSHWebSocketClient shared].networkType != GSHNetworkTypeLAN) {
                if (onlineStatus) {
                    [GSHOpenSDKShare share].currentFamily.onlineStatus = onlineStatus.integerValue;
                }
            }
            [GSHOpenSDKShare share].currentFamily.floor = [NSMutableArray arrayWithArray:floorList];
            [GSHOpenSDKShare share].currentFamily.familyDevcieCount = @(familyDeviceCount);
            [weakSelf checkGWVersion];
            [weakSelf familyChangeRefreshUI];
            [weakSelf getGlobalDefenceState];
        }
    }];
}

#pragma mark -点击事件
- (IBAction)touchFamilyIndex:(UIButton *)sender {
    GSHSensorListVC *list = [GSHSensorListVC sensorListVCWithFloor:self.floor familyIndex:self.familyIndex];
    [self.navigationController pushViewController:list animated:YES];
}

- (IBAction)touchRightNavItemAdd:(UIButton *)sender{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        return;
    }
    GSHDeviceCategoryVC *vc = [GSHDeviceCategoryVC deviceCategoryVC];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)touchChangeFamily:(UIButton *)sender {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN || [GSHOpenSDKShare share].familyList.count == 0) {
        return;
    }
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.arrowStyle = PopoverViewArrowStyleTriangle;
    popoverView.showShade = YES;
    popoverView.footText = @"管理家庭";
    popoverView.headText = @"切换家庭";
    popoverView.viewWight = self.view.frame.size.width - 32;
    __weak typeof(self)weakSelf = self;
    popoverView.touchFootBlock = ^{
        GSHFamilyListVC *vc = [GSHFamilyListVC familyListVC];
        [weakSelf.navigationController pushViewController:vc animated:YES];
        weakSelf.canCheckGW = YES;
    };
    popoverView.seleNumber = [[GSHOpenSDKShare share].familyList indexOfObject:[GSHOpenSDKShare share].currentFamily];
    [popoverView showToView:self.lblFamilyName isLeftPic:NO isTitleLabelCenter:NO withActions:self.actionsFamily hideBlock:NULL];
}

- (IBAction)touchLouCeng:(UIButton *)sender {
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.arrowStyle = PopoverViewArrowStyleTriangle;
    popoverView.showShade = YES;
    popoverView.seleNumber = [[GSHOpenSDKShare share].currentFamily.floor indexOfObject:self.floor];
    [popoverView showToView:self.viewLouCeng isLeftPic:NO isTitleLabelCenter:NO withActions:self.actionsFloor hideBlock:NULL];
}

- (IBAction)pushGatewayUnlinkVC:(UIButton *)sender {
    if ([GSHOpenSDKShare share].currentFamily.onlineStatus == GSHFamilyMGWStatusOffLine) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            UIViewController *vc = [GSHPageManager viewControllerWithSB:@"HomeSB" andID:@"GSHHomeSBOnlinkVC"];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            GSHConfigLocalControlVC *localControlVC = [GSHConfigLocalControlVC configLocalControlVC];
            localControlVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:localControlVC animated:YES];
        }
    }
}

#pragma mark - Delegate
- (void)FSSegmentTitleView:(GSHSegmentTitleView *)titleView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex{
    self.pageContentView.contentViewCurrentIndex = endIndex;
    if (self.floor.rooms.count > (endIndex - 1) && (endIndex - 1) >= 0) {
        self.room = self.floor.rooms[endIndex - 1];
    }else{
        self.room = nil;
    }
    if ([self.pageContentView.currentVC isKindOfClass:GSHHomeRoomVC.class]) {
        [((GSHHomeRoomVC*)self.pageContentView.currentVC) refreshAdList:self.bannerList];
        [((GSHHomeRoomVC*)self.pageContentView.currentVC) refreshYingShiDeviceOnlineStatus];
    }
}

- (void)FSContenViewDidEndDecelerating:(GSHPageContentView *)contentView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex{
    self.titleView.selectIndex = endIndex;
    self.pageContentView.contentViewCurrentIndex = endIndex;
    if (self.floor.rooms.count > (endIndex - 1) && (endIndex - 1) >= 0) {
        self.room = self.floor.rooms[endIndex - 1];
    }else{
        self.room = nil;
    }
    if ([self.pageContentView.currentVC isKindOfClass:GSHHomeRoomVC.class]) {
        [((GSHHomeRoomVC*)self.pageContentView.currentVC) refreshAdList:self.bannerList];
        [((GSHHomeRoomVC*)self.pageContentView.currentVC) refreshYingShiDeviceOnlineStatus];
    }
}

static CGFloat rootScrollViewContentOffsetY = 0;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.rootScrollView) {
        if ([self.pageContentView.currentVC isKindOfClass:GSHHomeRoomVC.class]) {
            CGFloat topViewHeight = self.viewTou.frame.size.height - self.viewNav.frame.origin.y;
            UICollectionView *collectionView = ((GSHHomeRoomVC*)self.pageContentView.currentVC).collectionView;
            if (self.rootScrollView.contentOffset.y > rootScrollViewContentOffsetY) {
                //向上滑动
                if (self.rootScrollView.contentOffset.y > topViewHeight){
                    self.rootScrollView.contentOffset = CGPointMake(0, topViewHeight);
                }else{
                    collectionView.contentOffset = CGPointZero;
                }
            }else{
                if (collectionView.contentOffset.y > 0){
                    self.rootScrollView.contentOffset = CGPointMake(0, rootScrollViewContentOffsetY);
                }else{
                    collectionView.contentOffset = CGPointZero;
                }
            }
            
            CGFloat alpha = 1 - (self.rootScrollView.contentOffset.y / topViewHeight);
            alpha = alpha > 1 ? 1 : (alpha < 0 ? 0 : alpha);
            self.viewTou.alpha = alpha;
            UIStatusBarStyle statusBarStyle = alpha < 0.5 ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
            if (statusBarStyle != self.statusBarStyle) {
                self.statusBarStyle = statusBarStyle;
                [self setNeedsStatusBarAppearanceUpdate];
            }
        }
        rootScrollViewContentOffsetY = self.rootScrollView.contentOffset.y;
    }
}

#pragma mark - 防御
- (void)getGlobalDefenceState {
    @weakify(self)
    [GSHDefenseDeviceTypeManager getGlobalDefenceStateWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSNumber * _Nonnull defenceState, NSError * _Nonnull error) {
        @strongify(self)
        if (!error) {
            if (defenceState) {
                self.btnFangYu.selected = defenceState.intValue == 1 ? NO : YES;
            }
        }
    }];
}

- (void)checkGWVersion{
    if ([GSHOpenSDKShare share].currentFamily.gatewayId.length == 0) {
        return;
    }
    if (!self.canCheckGW) {
        return;
    }
    self.canCheckGW = NO;
    [GSHGatewayManager getGatewayUpdateMsgWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId gatewayId:[GSHOpenSDKShare share].currentFamily.gatewayId block:^(GSHGatewayVersionM *gateWayVersionM, NSError *error) {
        if (gateWayVersionM.updateFlag == nil) {
            return ;
        }
        NSInteger updateFlag = gateWayVersionM.updateFlag.integerValue;
        NSString *title = [NSString stringWithFormat:@"发现网关新版本 %@",gateWayVersionM.versionTarget.length > 0 ? gateWayVersionM.versionTarget : @""];
        if (updateFlag == 0) {
            GSHVersionCheckUpdateVC *vc = [GSHVersionCheckUpdateVC versionCheckUpdateVCWithTitle:title content:gateWayVersionM.descInfo type:GSHVersionCheckUpdateVCTypeGW cancelTitle:nil cancelBlock:^{
            } updateBlock:^{
                [GSHGatewayManager updateGatewayWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId gatewayId:[GSHOpenSDKShare share].currentFamily.gatewayId versionId:gateWayVersionM.versionId block:^(NSError *error) {
                    
                }];
            }];
            [vc show];
        }
    }];
}
@end
