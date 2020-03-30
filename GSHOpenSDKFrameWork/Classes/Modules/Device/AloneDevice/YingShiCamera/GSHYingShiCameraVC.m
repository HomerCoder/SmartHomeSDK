//
//  GSHYingShiCameraVC.m
//  SmartHome
//
//  Created by gemdale on 2018/7/12.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiCameraVC.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#import "GSHAlertManager.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "TZMPhotoLibraryManager.h"
#import "GSHYingShiDeviceEditVC.h"
#import "GSHHuoDongJianCeSettingVC.h"
#import "GSHGaoJingDetailVC.h"
#import "GSHYingShiGaoJingListVC.h"
#import "UIScrollView+TZMRefreshAndLoadMore.h"
#import "GSHYingShiLiXianVC.h"
#import "GSHSpreadAnimationView.h"
#import "TZMProgressBar.h"
#import "GSHYingShiVideoListVC.h"
#import "GSHYingShiPlayerVC.h"
#import "GSHYingshiSettingVC.h"
#import "UIImageView+WebCache.h"

NSString *const GSHYingShiNeedOpenLandscapeNotification = @"GSHYingShiNeedOpenLandscapeNotification";
NSString *const GSHYingShiNeedCloseLandscapeNotification = @"GSHYingShiNeedCloseLandscapeNotification";

@interface GSHYingShiCameraVCGaoJingCell()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *downLine;
@property (weak, nonatomic) IBOutlet UIImageView *imageStart;
@end

@implementation GSHYingShiCameraVCGaoJingCell
-(void)setModel:(GSHYingShiGaoJingM *)model{
    _model = model;
    if(model){
        self.lblTime.hidden = NO;
        if ([model.alarmTimeDate isToday]) {
            self.lblTime.text = [model.alarmTimeDate stringWithFormat:@"今天 HH:mm:ss" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }else if ([[model.alarmTimeDate dateByAddingDays:1] isToday]){
            self.lblTime.text = [model.alarmTimeDate stringWithFormat:@"昨天 HH:mm:ss" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }else if ([[model.alarmTimeDate dateByAddingDays:2] isToday]){
            self.lblTime.text = [model.alarmTimeDate stringWithFormat:@"前天 HH:mm:ss" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }else{
            self.lblTime.text = [model.alarmTimeDate stringWithFormat:@"yyyy-MM-dd HH:mm:ss" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }
        self.lblTitle.textColor = [UIColor colorWithHexString:@"#222222"];
        self.imageStart.hidden = model.collectState == 0;
        self.lblTitle.text = model.alarmName;
        [self.lblTime setContentHuggingPriority:252 forAxis:UILayoutConstraintAxisHorizontal];
        [self.lblTime setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
        self.downLine.hidden = NO;
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:NO animated:YES];
}
@end

@interface GSHYingShiCameraVCDoorBellCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPic;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewUnread;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWeijie;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIImageView *imageShouCang;
@end
@implementation GSHYingShiCameraVCDoorBellCell
-(void)setModel:(GSHYingShiGaoJingM *)model{
    _model = model;
    if(model){
        [self.imageViewPic sd_setImageWithURL:[NSURL URLWithString:model.alarmPicUrl]];
        self.imageViewUnread.hidden = model.isChecked == 1;
        self.lblTitle.text = @"有人按门铃";
        self.imageShouCang.hidden = model.collectState == 0;
        if (model.isPicked) {
            self.lblWeijie.backgroundColor = [UIColor colorWithRGB:0x4CD664];
            self.lblWeijie.text = @"已接";
        }else{
            self.lblWeijie.backgroundColor = [UIColor colorWithRGB:0xE64430];
            self.lblWeijie.text = @"未接";
        }
        if ([model.alarmTimeDate isToday]) {
            self.lblTime.text = [model.alarmTimeDate stringWithFormat:@"今天 HH:mm:ss" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }else if ([[model.alarmTimeDate dateByAddingDays:1] isToday]){
            self.lblTime.text = [model.alarmTimeDate stringWithFormat:@"昨天 HH:mm:ss" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }else if ([[model.alarmTimeDate dateByAddingDays:2] isToday]){
            self.lblTime.text = [model.alarmTimeDate stringWithFormat:@"前天 HH:mm:ss" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }else{
            self.lblTime.text = [model.alarmTimeDate stringWithFormat:@"yyyy-MM-dd HH:mm:ss" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:NO animated:YES];
}
@end

@interface GSHYingShiCameraVC ()<EZPlayerDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)GSHDeviceM *device;
@property(nonatomic, strong)NSTimer *updataProgressTimer;
@property(nonatomic, strong)NSArray<GSHYingShiGaoJingM*> *gaoJingList;
@property(nonatomic, strong)NSArray<GSHYingShiGaoJingM*> *doorbellList;
@property(nonatomic, strong)EZStorageInfo *storageInfo;
@property(nonatomic, strong)EZDeviceInfo *deviceInfo;
@property(nonatomic, strong)NSDate *refreshDate;
@property(nonatomic, assign)NSInteger cameraNo;
@property(nonatomic, strong)GSHYingShiPlayerVC *playerVC;
@property(nonatomic, strong)NSMutableDictionary *IPCDic;
@property(nonatomic, assign)BOOL isShield;

@property (weak, nonatomic) IBOutlet UIView *mainView;
//云台告警公用
- (IBAction)seleYunTaiHuoGaoJing:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *viewYunTaiHuoGaoJing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcSeleViewHeight;
//云台
@property (weak, nonatomic) IBOutlet UIView *viewYunTai;
@property (weak, nonatomic) IBOutlet UIButton *btnYunTai;
- (IBAction)startXuanZhuang:(UIButton *)sender;
- (IBAction)endXuanZhuang:(UIButton *)sender;
//告警
@property (weak, nonatomic) IBOutlet UIButton *btnGaoJing;
@property (weak, nonatomic) IBOutlet UITableView *tableViewGaoJing;
@property (weak, nonatomic) IBOutlet UIView *viewGaoJing;
@property (weak, nonatomic) IBOutlet UIView *viewGaoJingLoadStatus;
- (IBAction)touchGaojingMore:(UIButton *)sender;
//门铃
@property (weak, nonatomic) IBOutlet UIButton *btnDoorbell;
@property (weak, nonatomic) IBOutlet UIView *viewDoorbell;
@property (weak, nonatomic) IBOutlet UITableView *tableViewDoorbell;
@property (weak, nonatomic) IBOutlet UIView *viewDoorBellLoadStatus;
- (IBAction)touchDoorbellMore:(UIButton *)sender;

//设备升级状态
@property (weak, nonatomic) IBOutlet UIView *viewUpdate;
@property (weak, nonatomic) IBOutlet TZMProgressBar *progressBar;

//当前状态
@property (weak, nonatomic) IBOutlet UIView *viewLiXian;
- (IBAction)touchLiXian:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

//电量
@property (weak, nonatomic) IBOutlet UIView *viewEnergy;
@property (weak, nonatomic) IBOutlet UILabel *lblEnergy;
@property (weak, nonatomic) IBOutlet UIProgressView *progressEnergy;

//屏蔽
@property (weak, nonatomic) IBOutlet UIView *viewShield;
- (IBAction)touchShield:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnShieldOn;
@property (weak, nonatomic) IBOutlet UIButton *btnShieldOff;

@end

@implementation GSHYingShiCameraVC

+(instancetype)yingShiCameraVCWithDevice:(GSHDeviceM*)device{
    GSHYingShiCameraVC *vc = [GSHPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingShiCameraVC"];
    vc.device = device;
    return vc;
}

- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = self.device.deviceName;
    [NSObject postNotification:GSHYingShiNeedOpenLandscapeNotification object:nil];

    if (self.deviceInfo.status == 2) {
        [self initDevice];
    }
    if (self.refreshDate) {
        if ([self.refreshDate timeIntervalSinceNow] < -60) {
            [self refreshAlarm];
            self.refreshDate = [NSDate date];
        }
    }else{
        self.refreshDate = [NSDate date];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [NSObject postNotification:GSHYingShiNeedCloseLandscapeNotification object:nil];

    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

-(void)setDeviceInfo:(EZDeviceInfo *)deviceInfo{
    _deviceInfo = deviceInfo;
    
    self.btnYunTai.hidden = !(self.deviceInfo.isSupportPTZ && deviceInfo.status == 1);
    self.btnDoorbell.hidden = self.device.deviceType.integerValue != 15;
    
    if ((!(deviceInfo.isSupportPTZ && deviceInfo.status == 1)) && self.device.deviceType.integerValue != 15) {
        self.lcSeleViewHeight.constant = 0;
        self.viewYunTaiHuoGaoJing.hidden = YES;
    }else{
        self.lcSeleViewHeight.constant = 50;
        self.viewYunTaiHuoGaoJing.hidden = NO;
    }
    
    if (self.deviceInfo.isSupportPTZ && deviceInfo.status == 1) {
        [self seleYunTaiHuoGaoJing:self.btnYunTai];
    }else if (self.device.deviceType.integerValue == 15){
        [self seleYunTaiHuoGaoJing:self.btnDoorbell];
    }else{
        [self seleYunTaiHuoGaoJing:self.btnGaoJing];
    }
    
    if (deviceInfo.status == 1) {
        self.lblStatus.text = @"在线";
        self.viewLiXian.hidden = YES;
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithImage:[UIImage ZHImageNamed:@"yingShiCameraVC_navbar_rigthItem_icom"] style:UIBarButtonItemStyleDone target:self action:@selector(touchNavbarRightItem)],[[UIBarButtonItem alloc]initWithImage:[UIImage ZHImageNamed:@"yingShiCameraVC_jianceSD_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(checkDeviceStorage)]];
    }else{
        self.lblStatus.text = @"离线";
        self.viewLiXian.hidden = NO;
        if([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsManager){
            self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithImage:[UIImage ZHImageNamed:@"yingShiCameraVC_navbar_rigthItem_icom"] style:UIBarButtonItemStyleDone target:self action:@selector(touchNavbarRightItem)]];
        }
    }
    
    [self.playerVC updateDeviceInfo:deviceInfo];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (self.deviceInfo) {
        if ((!(self.deviceInfo.isSupportPTZ && self.deviceInfo.status == 1)) && self.device.deviceType.integerValue != 15) {
            self.lcSeleViewHeight.constant = 0;
        }else{
            self.lcSeleViewHeight.constant = 50;
        }
    }else{
        self.lcSeleViewHeight.constant = 0;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (size.width > size.height) {
        // 横屏
        self.navigationController.navigationBarHidden = YES;
    } else {
        // 竖屏布局
        self.navigationController.navigationBarHidden = NO;
    }
}

-(void)dealloc{
    [self.updataProgressTimer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [GSHYingShiManager updataAccessTokenWithBlock:NULL];
    self.cameraNo = 1;
    
    self.title = self.device.deviceName;
    if([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsManager){
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithImage:[UIImage ZHImageNamed:@"yingShiCameraVC_navbar_rigthItem_icom"] style:UIBarButtonItemStyleDone target:self action:@selector(touchNavbarRightItem)]];
    }

    self.playerVC = [GSHYingShiPlayerVC yingShiPlayerVCWithDevice:self.device];
    [self addChildViewController:self.playerVC];
    [self.mainView insertSubview:self.playerVC.view atIndex:0];
    __weak typeof(self)weakSelf = self;
    [self.playerVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.mainView);
    }];

    [self initDevice];
    [self refreshIPCData];
    [self refreshAlarm];

    self.updataProgressTimer = [NSTimer timerWithTimeInterval:5 block:^(NSTimer * _Nonnull timer) {
        [weakSelf checkDeviceUpdataProgress];
    } repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.updataProgressTimer forMode:NSRunLoopCommonModes];
    self.updataProgressTimer.fireDate = [NSDate distantPast];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma --mark --------------------初始化方法-----------------------------

- (void)initDevice{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"初始化设备中" inView:self.view];
    [EZOpenSDK getDeviceInfo:self.device.deviceSn completion:^(EZDeviceInfo *deviceInfo, NSError *error) {
        if (deviceInfo) {
            weakSelf.deviceInfo = deviceInfo;
            [TZMProgressHUDManager dismissInView:weakSelf.view];
        }else{
            if(error.code == EZ_HTTPS_ACCESS_TOKEN_INVALID ||
               error.code == EZ_HTTPS_ACCESS_TOKEN_EXPIRE){
                //token错误
                [TZMProgressHUDManager showWithStatus:@"更新token中" inView:weakSelf.view];
                [GSHYingShiManager updataAccessTokenWithBlock:^(NSString *token, NSError *error) {
                    if(error){
                        //获取token错误
                        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                    }else{
                        //获取token成功
                        [weakSelf initDevice];
                    }
                }];
            }else{
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }
        }
    }];
    [EZOpenSDK setDeviceEncryptStatus:self.device.deviceSn verifyCode:self.device.validateCode encrypt:NO completion:^(NSError *error) {
    }];
}

-(void)refreshIPCData{
    __weak typeof(self)weakSelf = self;
    [GSHYingShiManager getIPCStatusWithDeviceSerial:self.device.deviceSn block:^(NSDictionary *data, NSError *error) {
        if (data) {
            weakSelf.IPCDic = [NSMutableDictionary dictionaryWithDictionary:data];
            [weakSelf refreshIPCUI];
        }
    }];
}

-(void)refreshIPCUI{
    self.viewEnergy.hidden = !(self.device.deviceType.integerValue == 15);
    NSNumber *batteryStatus = [self.IPCDic numverValueForKey:@"batteryStatus" default:nil];
    if (batteryStatus) {
        self.lblEnergy.text = [NSString stringWithFormat:@"%d%%",batteryStatus.intValue];
        self.progressEnergy.progress = batteryStatus.floatValue / 100.0;
    }
    
    NSNumber *sceneSwitchStatus = [self.IPCDic numverValueForKey:@"sceneSwitchStatus" default:nil];
    if (sceneSwitchStatus) {
        if (sceneSwitchStatus.integerValue == 1) {
            self.btnShieldOn.hidden = YES;
            self.viewShield.hidden = NO;
            self.isShield = YES;
            self.playerVC.isShield = YES;
        }else{
            self.viewShield.hidden = YES;
            self.btnShieldOn.hidden = NO;
            self.isShield = NO;
            self.playerVC.isShield = NO;
        }
    }
}

#pragma --mark --------------------操作方法-----------------------------
-(void)controlPTZWithTag:(NSInteger)tag action:(EZPTZAction)action block:(void(^)(NSError *error))block{
    EZPTZCommand command = 0;
    switch (tag) {
        case 1:
            command = EZPTZCommandUp;
            break;
        case 2:
            command = EZPTZCommandRight;
            break;
        case 3:
            command = EZPTZCommandDown;
            break;
        default:
            command = EZPTZCommandLeft;
            break;
    }
    [EZOpenSDK controlPTZ:self.device.deviceSn cameraNo:self.cameraNo command:command action:action speed:1 result:block];
}

-(void)refreshAlarm{
    if (self.device.deviceType.intValue == 15) {
        [self refreshAlarmWithType:GSHYingShiGaoJingMAlarmTypeDoorbell];
        [self refreshAlarmWithType:GSHYingShiGaoJingMAlarmTypeRenTiGanYing];
    }else{
        [self refreshAlarmWithType:GSHYingShiGaoJingMAlarmTypeYiDong];
    }
}

-(void)refreshAlarmWithType:(GSHYingShiGaoJingMAlarmType)type{
    __weak typeof(self)weakSelf = self;
    [GSHYingShiManager getAlarmListWithDeviceSerial:self.device.deviceSn alarmType:type alarmTime:nil startTime:nil endTime:nil block:^(NSArray<GSHYingShiGaoJingM *> *list, NSError *error) {
        UIView *viewLoadStatus;
        UITableView *tableView;
        if (type == GSHYingShiGaoJingMAlarmTypeDoorbell) {
            viewLoadStatus = weakSelf.viewDoorBellLoadStatus;
            tableView = weakSelf.tableViewDoorbell;
        }else{
            viewLoadStatus = weakSelf.viewGaoJingLoadStatus;
            tableView = weakSelf.tableViewGaoJing;
        }
        if (error) {
            if ((type == GSHYingShiGaoJingMAlarmTypeDoorbell ? weakSelf.doorbellList : weakSelf.gaoJingList).count > 0) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [viewLoadStatus showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"yingShiCameraVC_gaojing_get_error"] title:@"加载失败，请重试" desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                    [weakSelf refreshAlarmWithType:type];
                }];
            }
        }else{
            if (list.count > 0) {
                [viewLoadStatus dismissPageStatusView];
                if (list.count > 5) {
                    if (type == GSHYingShiGaoJingMAlarmTypeDoorbell) {
                        weakSelf.doorbellList = [list subarrayWithRange:NSMakeRange(0, 5)];
                    }else{
                        weakSelf.gaoJingList = [list subarrayWithRange:NSMakeRange(0, 5)];
                    }
                }else{
                    if (type == GSHYingShiGaoJingMAlarmTypeDoorbell) {
                        weakSelf.doorbellList = list;
                    }else{
                        weakSelf.gaoJingList = list;
                    }
                }
                [tableView reloadData];
            }else{
                [viewLoadStatus showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"yingShiCameraVC_gaojing_get_error"] title:type == GSHYingShiGaoJingMAlarmTypeDoorbell ? @"最近7天暂无门铃记录" : @"最近7天暂无告警记录" desc:nil buttonText:@"历史告警记录" didClickButtonCallback:^(TZMPageStatus status) {
                    GSHYingShiGaoJingListVC *vc = [GSHYingShiGaoJingListVC yingShiGaoJingListVCWithtype:GSHYingShiGaoJingListVCTypeAll device:weakSelf.device alarmType:type];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }];
            }
        }
        [tableView.tzm_refreshControl stopIndicatorAnimation];
    }];
}

-(void)pushDeviceEdit{
    GSHYingShiDeviceEditVC *deviceEditVC = [GSHYingShiDeviceEditVC yingShiDeviceEditVCWithDevice:self.device];
    [self.navigationController pushViewController:deviceEditVC animated:YES];
}

-(void)checkDeviceStorage{
    if (!self.viewUpdate.hidden) {
        return;
    }
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"检测存储中" inView:self.view];
    [EZOpenSDK getStorageStatus:self.device.deviceSn completion:^(NSArray *storageStatus, NSError *error) {
        weakSelf.storageInfo = storageStatus.firstObject;
        if (weakSelf.storageInfo) {
            if (weakSelf.storageInfo.status == 0) {
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [weakSelf.navigationController pushViewController:[GSHYingShiVideoListVC yingShiVideoListVCWithDeviceInfo:weakSelf.deviceInfo verifyCode:weakSelf.device.validateCode] animated:YES];
                //跳转
            } else if (weakSelf.storageInfo.status == 1) {
                [TZMProgressHUDManager showErrorWithStatus:@"存储介质错误" inView:weakSelf.view];
            } else if (weakSelf.storageInfo.status == 2) {
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        [TZMProgressHUDManager showWithStatus:@"初始化中" inView:weakSelf.view];
                        [EZOpenSDK formatStorage:weakSelf.device.deviceSn storageIndex:weakSelf.storageInfo.index completion:^(NSError *error) {
                            if (error) {
                                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                            } else {
                                [TZMProgressHUDManager dismissInView:weakSelf.view];
                                weakSelf.storageInfo.status = 3;
                                weakSelf.storageInfo.formatRate = 0;
                                [weakSelf checkDeviceStorageProgressWithStorageInfo:weakSelf.storageInfo];
                            }
                        }];
                    }
                } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"内存卡必须进行初始化后才能开始录像，初始化将会删除内存卡中原有文件，确认初始化吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
            } else if (weakSelf.storageInfo.status == 3) {
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [weakSelf checkDeviceStorageProgressWithStorageInfo:weakSelf.storageInfo];
            } else {
                [TZMProgressHUDManager showErrorWithStatus:@"未检测到内存卡" inView:weakSelf.view];
            }
        }else{
            [TZMProgressHUDManager showErrorWithStatus:@"未检测到内存卡" inView:weakSelf.view];
        }
    }];
}

-(void)checkDeviceStorageProgressWithStorageInfo:(EZStorageInfo*)storageInfo{
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        if (storageInfo.status == 3) {
            weakSelf.viewUpdate.hidden = NO;
            weakSelf.progressBar.text = @"内存卡初始化中，请稍候";
            weakSelf.progressBar.progress = (storageInfo.formatRate * 1.0) / 100;
        }else{
            weakSelf.viewUpdate.hidden = YES;
        }
    });
    if (storageInfo.status != 3) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [EZOpenSDK getStorageStatus:weakSelf.device.deviceSn completion:^(NSArray *storageStatus, NSError *error) {
            for (EZStorageInfo *info in storageStatus) {
                if (info.index == storageInfo.index) {
                    [weakSelf checkDeviceStorageProgressWithStorageInfo:info];
                    return;
                }
            }
            [weakSelf checkDeviceStorageProgressWithStorageInfo:storageInfo];
        }];
    });
}

-(void)checkDeviceUpdata{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"设备版本检测中" inView:self.view];
    [EZOpenSDK getDeviceVersion:self.device.deviceSn completion:^(EZDeviceVersion *version, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if (version.isUpgrading == 0) {
                if (version.isNeedUpgrade == 0) {
                    [TZMProgressHUDManager showSuccessWithStatus:@"当前已是最新版本" inView:weakSelf.view];
                }else{
                    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                        if (buttonIndex == 1) {
                            [EZOpenSDK upgradeDevice:weakSelf.device.deviceSn completion:^(NSError *error) {
                                if (error) {
                                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                                }else{
                                    weakSelf.viewUpdate.hidden = NO;
                                    weakSelf.progressBar.text = @"设备固件正在更新中…";
                                    weakSelf.progressBar.progress = 0;
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        weakSelf.updataProgressTimer.fireDate = [NSDate distantPast];
                                    });
                                }
                            }];
                        }
                    } textFieldsSetupHandler:NULL andTitle:@"发现设备新版本" andMessage:@"是否立即进行更新？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
                }
            }else{
                [TZMProgressHUDManager showInfoWithStatus:@"正在升级" inView:weakSelf.view];
            }
        }
    }];
}

-(void)checkDeviceUpdataProgress{
    __weak typeof(self)weakSelf = self;
    [EZOpenSDK getDeviceUpgradeStatus:self.device.deviceSn completion:^(EZDeviceUpgradeStatus *status, NSError *error) {
//        NSLog(@"EZDeviceUpgradeStatus = %d_%d,error = %@",status.upgradeProgress,status.upgradeStatus,error);
        if (error) {
            if (weakSelf.viewUpdate) {
                if (weakSelf.viewUpdate.hidden == NO) {
                    weakSelf.viewUpdate.hidden = YES;
                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                }
            }
            weakSelf.updataProgressTimer.fireDate = [NSDate distantFuture];
        }else{
            /// 升级状态： 0：正在升级 1：设备重启 2：升级成功 3：升级失败
            if (status.upgradeStatus == 0) {
                weakSelf.viewUpdate.hidden = NO;
                weakSelf.progressBar.text = @"设备固件正在更新中…";
                weakSelf.progressBar.progress = (status.upgradeProgress * 1.0) / 100;
            }else if(status.upgradeStatus == 1){
                weakSelf.viewUpdate.hidden = NO;
                weakSelf.progressBar.text = @"设备重启中";
                weakSelf.progressBar.progress = 0.99;
            }else if(status.upgradeStatus == 2){
                if (weakSelf.viewUpdate) {
                    if (weakSelf.viewUpdate.hidden == NO) {
                        weakSelf.viewUpdate.hidden = YES;
                        [TZMProgressHUDManager showSuccessWithStatus:@"升级成功" inView:weakSelf.view];
                    }
                }
                weakSelf.updataProgressTimer.fireDate = [NSDate distantFuture];
            }else if(status.upgradeStatus == 3){
                if (weakSelf.viewUpdate) {
                    if (weakSelf.viewUpdate.hidden == NO) {
                        weakSelf.viewUpdate.hidden = YES;
                        [TZMProgressHUDManager showErrorWithStatus:@"升级失败" inView:weakSelf.view];
                    }
                }
                weakSelf.updataProgressTimer.fireDate = [NSDate distantFuture];
            }
        }
    }];
}

-(void)openSetting{
    if (self.IPCDic) {
        GSHYingshiSettingVC *vc = [GSHYingshiSettingVC yingshiSettingVCWithIPC:self.IPCDic device:self.device];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        __weak typeof(self)weakSelf = self;
        [TZMProgressHUDManager showWithStatus:@"获取常用设置信息" inView:self.view];
        [GSHYingShiManager getIPCStatusWithDeviceSerial:self.device.deviceSn block:^(NSDictionary *data, NSError *error) {
            if (data) {
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                weakSelf.IPCDic = [NSMutableDictionary dictionaryWithDictionary:data];
                [weakSelf refreshIPCUI];
                GSHYingshiSettingVC *vc = [GSHYingshiSettingVC yingshiSettingVCWithIPC:weakSelf.IPCDic device:weakSelf.device];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else{
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }
        }];
    }
}

-(void)controlVideoFlip{
    [TZMProgressHUDManager showWithStatus:@"翻转中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [EZOpenSDK controlVideoFlip:self.device.deviceSn cameraNo:self.cameraNo command:EZDisplayCommandCenter result:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"翻转成功" inView:weakSelf.view];
        }
    }];
}

#pragma --mark --------------------tableView代理-----------------------------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableViewGaoJing) {
        return self.gaoJingList.count;
    }else{
        return self.doorbellList.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableViewGaoJing) {
        GSHYingShiCameraVCGaoJingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        if (self.gaoJingList.count > indexPath.row) {
            GSHYingShiGaoJingM *model = self.gaoJingList[indexPath.row];
            cell.model = model;
        }
        return cell;
    }else{
        GSHYingShiCameraVCDoorBellCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        if (self.doorbellList.count > indexPath.row) {
            GSHYingShiGaoJingM *model = self.doorbellList[indexPath.row];
            cell.model = model;
        }
        return cell;
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHYingShiCameraVCGaoJingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.model) {
        GSHGaoJingDetailVC *vc = [GSHGaoJingDetailVC gaoJingDetailVCWithModel:cell.model verifyCode:self.device.validateCode deviceSerial:self.deviceInfo.deviceSerial modelList:tableView == self.tableViewGaoJing ? self.gaoJingList : self.doorbellList];
        [self.navigationController pushViewController:vc animated:YES];
    }
    return nil;
}

#pragma --mark --------------------点击事件-----------------------------
- (void)touchNavbarRightItem{
    if (!self.viewUpdate.hidden) {
        return;
    }
    __weak typeof(self)weakSelf = self;
    if(self.deviceInfo.status == 1){
        if (self.device.deviceType.integerValue == 15) {
            if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        [weakSelf openSetting];
                    }
                } textFieldsSetupHandler:NULL andTitle:nil andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"常用设置",nil];
            }else{
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    switch (buttonIndex) {
                        case 1:
                            [weakSelf pushDeviceEdit];
                            break;
                        case 2:
                            [weakSelf openSetting];
                            break;
                        case 3:
                            [weakSelf checkDeviceUpdata];
                            break;
                        default:
                            break;
                    }
                } textFieldsSetupHandler:NULL andTitle:nil andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"进入设备",@"常用设置",@"固件检查更新",nil];
            }
        }else{
            if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        [weakSelf openSetting];
                    }
                } textFieldsSetupHandler:NULL andTitle:nil andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"常用设置",nil];
            }else{
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    switch (buttonIndex) {
                        case 1:
                            [weakSelf pushDeviceEdit];
                            break;
                        case 2:
                            [weakSelf openSetting];
                            break;
                        case 3:
                            [weakSelf checkDeviceUpdata];
                            break;
                        case 4:
                            [weakSelf controlVideoFlip];
                            break;
                        default:
                            break;
                    }
                } textFieldsSetupHandler:NULL andTitle:nil andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"进入设备",@"常用设置",@"固件检查更新",@"画面翻转",nil];
            }
        }
    }else{
        if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                switch (buttonIndex) {
                    case 1:
                        [weakSelf openSetting];
                        break;
                    default:
                        break;
                }
            } textFieldsSetupHandler:NULL andTitle:nil andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"常用设置",nil];
        }else{
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                switch (buttonIndex) {
                    case 1:
                        [weakSelf pushDeviceEdit];
                        break;
                    default:
                        break;
                }
            } textFieldsSetupHandler:NULL andTitle:nil andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"进入设备",nil];
        }
    }
}

- (IBAction)seleYunTaiHuoGaoJing:(UIButton *)sender {
    self.viewGaoJing.hidden = YES;
    self.btnGaoJing.selected = NO;
    self.viewYunTai.hidden = YES;
    self.btnYunTai.selected = NO;
    self.viewDoorbell.hidden = YES;
    self.btnDoorbell.selected = NO;
    if (sender == self.btnGaoJing) {
        self.viewGaoJing.hidden = NO;
        self.btnGaoJing.selected = YES;
    }else if (sender == self.btnDoorbell) {
        self.viewDoorbell.hidden = NO;
        self.btnDoorbell.selected = YES;
    }else{
        self.viewYunTai.hidden = NO;
        self.btnYunTai.selected = YES;
    }
}

- (IBAction)startXuanZhuang:(UIButton *)sender{
    if (self.isShield) {
        [TZMProgressHUDManager showErrorWithStatus:@"请开启镜头后再使用此功能" inView:self.view];
        return;
    }
    NSInteger tag = sender.tag - 1000; //1是上，2是右，3是下，4是左
    [self controlPTZWithTag:tag action:EZPTZActionStart block:^(NSError *error) {
        if (error) {
            if (error.code == 160002) {
                [TZMProgressHUDManager showErrorWithStatus:@"设备云台旋转达到上限位" inView:self.view];
            } else if (error.code == 160003) {
                [TZMProgressHUDManager showErrorWithStatus:@"设备云台旋转达到下限位" inView:self.view];
            } else if (error.code == 160004) {
                [TZMProgressHUDManager showErrorWithStatus:@"设备云台旋转达到左限位" inView:self.view];
            } else if (error.code == 160005) {
                [TZMProgressHUDManager showErrorWithStatus:@"设备云台旋转达到右限位" inView:self.view];
            } else {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            }
        }
    }];
}

- (IBAction)endXuanZhuang:(UIButton *)sender{
    if (self.isShield) {
        [TZMProgressHUDManager showErrorWithStatus:@"请开启镜头后再使用此功能" inView:self.view];
        return;
    }
    NSInteger tag = sender.tag - 1000; //1是上，2是右，3是下，4是左
    [self controlPTZWithTag:tag action:EZPTZActionStop block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        }
    }];
}
- (IBAction)touchGaojingMore:(UIButton *)sender {
    GSHYingShiGaoJingListVC *vc = [GSHYingShiGaoJingListVC yingShiGaoJingListVCWithtype:GSHYingShiGaoJingListVCTypeAll device:self.device alarmType:self.device.deviceType.intValue == 15 ? GSHYingShiGaoJingMAlarmTypeRenTiGanYing : GSHYingShiGaoJingMAlarmTypeYiDong];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)touchDoorbellMore:(UIButton *)sender {
    GSHYingShiGaoJingListVC *vc = [GSHYingShiGaoJingListVC yingShiGaoJingListVCWithtype:GSHYingShiGaoJingListVCTypeAll device:self.device alarmType:GSHYingShiGaoJingMAlarmTypeDoorbell];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)touchLiXian:(UIButton *)sender {
    GSHYingShiLiXianVC *vc = [GSHYingShiLiXianVC yingShiLiXianVCWithDevice:self.device];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)touchShield:(UIButton *)sender {
    BOOL on = sender == self.btnShieldOn;
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"设置中" inView:self.view];
    [GSHYingShiManager postSceneSwitchStatusWithDeviceSerial:weakSelf.device.deviceSn on:on block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [weakSelf.IPCDic setValue:on ? @(1) : @(0) forKey:@"sceneSwitchStatus"];
            [weakSelf refreshIPCUI];
            [TZMProgressHUDManager dismissInView:weakSelf.view];
        }
    }];
}
@end
