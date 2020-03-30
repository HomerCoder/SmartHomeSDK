//
//  GSHMineVC.m
//  SmartHome
//
//  Created by gemdale on 2018/4/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHMineVC.h"

#import "GSHUserInfoVC.h"
#import "GSHFamilyListVC.h"
#import "GSHAboutVC.h"
#import "GSHQRCodeScanningVC.h"
#import "GSHScanLoginVC.h"
#import "GSHAppConfig.h"
#import "GSHWebViewController.h"
#import "GSHControlSwitchVC.h"
#import "GSHInfraredControllerInfoVC.h"
#import "GSHDefenceAlarmAuthVC.h"

#import "GSHDefenseListVC.h"
#import "GSHDeviceManagerVC.h"
#import "GSHSettingVC.h"
#import "GSHAutomateVC.h"
#import "GSHDefenseListVC.h"
#import "GSHMessageVC.h"
#import "GSHContactWayVC.h"
#import "GSHFamilyMemberInfoVC.h"
#import "GSHYingShiDeviceDetailVC.h"
#import "GSHDeviceModelListVC.h"
#import "GSHAddGWApIntroVC.h"
#import "GSHAddGWGuideVC.h"
#import "WXApi.h"

@interface GSHMineItemCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewItem;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@end

@implementation GSHMineItemCell
-(void)setImage:(UIImage*)image title:(NSString*)title{
    self.imageViewItem.image = image;
    self.lblTitle.text = title;
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    }else{
        self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    }
}
@end


@interface GSHMineVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) GSHUserInfoM *userInfo;
@property (nonatomic, strong) GSHFamilyM *family;
@property (nonatomic, strong) NSArray *cellNameArray;
@property (nonatomic, strong) NSArray *cellImageArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPhoneLabel;
@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet UIView *messageDotView;
@property (weak, nonatomic) IBOutlet UIButton *btnScan;

@property (weak, nonatomic) IBOutlet UIView *autoView;
@property (weak, nonatomic) IBOutlet UIView *defenseView;
@property (weak, nonatomic) IBOutlet UIView *messageView;


- (IBAction)touchRightNavBut:(UIButton *)sender;
- (IBAction)touchAuto:(UIButton *)sender;
- (IBAction)touchDefense:(UIButton *)sender;
- (IBAction)touchMessage:(UIButton *)sender;
- (IBAction)touchHeadImage:(UIButton *)sender;
@end

@implementation GSHMineVC
+(instancetype)mineVC{
    return [GSHPageManager viewControllerWithSB:@"MineSB" andID:@"GSHMineVC"];
}

-(void)setUserInfo:(GSHUserInfoM *)userInfo{
    _userInfo = userInfo;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:_userInfo.picPath] placeholderImage:[UIImage ZHImageNamed:@"app_headImage_default_icon"]];
    self.userNameLabel.text = _userInfo.nick;
    self.userPhoneLabel.text = _userInfo.phone;
}

-(void)setFamily:(GSHFamilyM *)family{
    _family = family;
    self.cellNameArray =  @[@[@"我的家庭",@"我的设备"],@[@"设置",@"安防告警授权"],@[@"智享商城",@"使用帮助",@"联系我们"]];
    self.cellImageArray = @[@[@"mineVC_cell_family_icon",@"mineVC_cell_device_icon"],@[@"mineVC_cell_setting_icon",@"mineVC_cell_defenceAuth"],@[@"mineVC_cell_store_icon",@"mineVC_cell_help_icon",@"mineVC_cell_contact_icon"]];
    [self refreshUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tzm_prefersNavigationBarHidden = YES;
    self.userInfo = [GSHUserManager currentUserInfo];
    self.family = [GSHOpenSDKShare share].currentFamily;
    [self observerNotifications];
    
    [self queryIsHasUnReadMsg]; // 查询是否有未读消息
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self)weakSelf = self;
    if (![GSHUserManager currentUserInfo]) {
        [GSHUserManager getUserInfoWithBlock:^(GSHUserInfoM *userInfo, NSError *error) {
            if (userInfo) {
                weakSelf.userInfo = userInfo;
            }
        }];
    }
}

-(void)dealloc{
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)observerNotifications{
    [self observerNotification:GSHUserInfoMChangeNotification];
    [self observerNotification:GSHOpenSDKFamilyChangeNotification];
    [self observerNotification:GSHControlSwitchSuccess];
    [self observerNotification:GSHQueryIsHasUnReadMsgNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHOpenSDKFamilyChangeNotification]) {
        GSHFamilyM *family = notification.object;
        if ([family isKindOfClass:GSHFamilyM.class]) {
            self.family = family;
        }
    }
    if ([notification.name isEqualToString:GSHUserInfoMChangeNotification]) {
        GSHUserInfoM *userInfo = notification.object;
        if ([userInfo isKindOfClass:GSHUserInfoM.class]) {
            self.userInfo = userInfo;
        }
    }
    if ([notification.name isEqualToString:GSHControlSwitchSuccess]) {
        [self refreshUI];
    }
    if ([notification.name isEqualToString:GSHQueryIsHasUnReadMsgNotification]) {
        [self queryIsHasUnReadMsg];
    }
}

-(void)refreshUI{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        self.viewHead.userInteractionEnabled = NO;
        self.viewHead.alpha = 0.2;
        self.btnScan.enabled = NO;
//        self.defenseView.userInteractionEnabled = NO;
//        self.defenseView.alpha = 0.2;
//        self.messageView.userInteractionEnabled = NO;
//        self.messageView.alpha = 0.2;
    }else{
        self.viewHead.userInteractionEnabled = YES;
        self.viewHead.alpha = 1;
        self.btnScan.enabled = YES;
//        self.defenseView.userInteractionEnabled = YES;
//        self.defenseView.alpha = 1;
//        self.messageView.userInteractionEnabled = YES;
//        self.messageView.alpha = 1;
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellNameArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.cellNameArray.count > section) {
        NSArray *arr = self.cellNameArray[section];
        return arr.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([GSHOpenSDKShare share].currentFamily && [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember &&
        indexPath.section == 1 && indexPath.row == 1) {
        // 有家庭且为成员 则隐藏 安防告警授权
        return 0.0f;
    }
    return 60.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.size.width, 10)];
    view.backgroundColor = [UIColor colorWithRGB:0xf6f7fa];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHMineItemCell *itemCell = [tableView dequeueReusableCellWithIdentifier:@"cellItem" forIndexPath:indexPath];
    if (indexPath.section < self.cellNameArray.count && indexPath.section < self.cellImageArray.count) {
        NSArray *titleList = self.cellNameArray[indexPath.section];
        NSArray *imageList = self.cellImageArray[indexPath.section];
        if (indexPath.row < titleList.count && indexPath.row < imageList.count) {
            NSString *title = titleList[indexPath.row];
            NSString *imageName = imageList[indexPath.row];
            [itemCell setImage:[UIImage ZHImageNamed:imageName] title:title];
        }
    }
    if (indexPath.section != 1 && !(indexPath.section == 2 && indexPath.row == 0)) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            itemCell.contentView.alpha = 0.2;
        } else {
            itemCell.contentView.alpha = 1;
        }
    }
    return itemCell;
}

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN &&
        indexPath.section != 1 &&
        !(indexPath.section == 2 && indexPath.row == 0)) {
        return nil;
    }
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.navigationController pushViewController:[GSHFamilyListVC familyListVC] animated:YES];
    }else if (indexPath.section == 0 && indexPath.row == 1){
        if (![GSHOpenSDKShare share].currentFamily) {
            [TZMProgressHUDManager showErrorWithStatus:@"请先添加家庭" inView:self.view];
            return nil;
        }
        [self.navigationController pushViewController:[GSHDeviceManagerVC deviceManagerVC] animated:YES];
    }else if (indexPath.section == 1 && indexPath.row == 0){
        [self.navigationController pushViewController:[GSHSettingVC settingVC] animated:YES];
    }else if (indexPath.section == 1 && indexPath.row == 1){
        // 安防告警授权
        if ([GSHOpenSDKShare share].familyList.count == 0) {
            [TZMProgressHUDManager showInfoWithStatus:@"请先创建家庭" inView:self.view];
            return nil;
        }
        GSHDefenceAlarmAuthVC *defenceAlarmAuthVC = [GSHDefenceAlarmAuthVC defenceAlarmAuthVC];
        defenceAlarmAuthVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:defenceAlarmAuthVC animated:YES];
    }else if (indexPath.section == 2 && indexPath.row == 0){
        WXLaunchMiniProgramReq *launch = [WXLaunchMiniProgramReq object];
        launch.userName = @"gh_9a81fc7a8861";
        launch.miniProgramType = WXMiniProgramTypeRelease;
        [WXApi sendReq:launch];
    }else if (indexPath.section == 2 && indexPath.row == 1){
        NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypeHelp parameter:nil];
        UIViewController *vc = [[GSHWebViewController alloc] initWithURL:url];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 2 && indexPath.row == 2){
        [self.navigationController pushViewController:[GSHContactWayVC contactWayVC] animated:YES];
    }
    return nil;
}

// 扫码登录
- (void)authPadToLoginWithQRCode:(NSString *)code {
    if (code.length > 10) {
        NSString *flagStr = [code substringToIndex:9];
        NSString *deviceIdStr = [code substringFromIndex:10];
        if ([flagStr isEqualToString:@"ScanLogin"]) {
            GSHScanLoginVC *scanLoginVC = [GSHScanLoginVC scanLoginVCWithDeviceId:deviceIdStr];
            [self.navigationController presentViewController:scanLoginVC animated:YES completion:NULL];
        } else {
            [TZMProgressHUDManager showErrorWithStatus:@"二维码错误" inView:self.view];
        }
    } else {
        [TZMProgressHUDManager showErrorWithStatus:@"二维码错误" inView:self.view];
    }
}

-(void)analysisQRCode:(NSString*)qrCode{
    if (qrCode.length > 10) {
        NSString *flagStr = [qrCode substringToIndex:9];
        NSString *deviceIdStr = [qrCode substringFromIndex:10];
        if ([flagStr isEqualToString:@"ScanLogin"]) {
            GSHScanLoginVC *scanLoginVC = [GSHScanLoginVC scanLoginVCWithDeviceId:deviceIdStr];
            [self.navigationController presentViewController:scanLoginVC animated:YES completion:NULL];
            return;
        }
    }
    if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
        [TZMProgressHUDManager showErrorWithStatus:@"无法识别二维码" inView:self.view];
        return;
    }
    if (qrCode) {
        NSString *jsonString = [NSString stringWithBase64EncodedString:qrCode];
        GSHFamilyMemberM *member = [GSHFamilyMemberM yy_modelWithJSON:jsonString];
        if (member.childUserId) {
            GSHFamilyMemberInfoVC *vc = [GSHFamilyMemberInfoVC familyMemberInfoVCWithFamily:self.family member:member creation:YES];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
    }
    if (qrCode.length > 3) {
        NSString *flagStr = [qrCode substringToIndex:2];
        if ([flagStr isEqualToString:@"GD"]) {
            __weak typeof(self)weakSelf = self;
            [TZMProgressHUDManager showWithStatus:@"解析二维码中" inView:self.view];
            [GSHDeviceManager postDeviceModelListWithQRCode:qrCode block:^(NSArray<GSHDeviceModelM *> *list, NSString *sn, NSError *error) {
                if (error) {
                    if (error.code == 205) {
                        [TZMProgressHUDManager dismissInView:weakSelf.view];
                        if (qrCode.length > 15) {
                            GSHAddGWApIntroVC *vc = [GSHAddGWApIntroVC addGWApIntroVCWithSn:[qrCode substringFromIndex:15] deviceModel:nil bind:YES];
                            vc.hidesBottomBarWhenPushed = YES;
                            [weakSelf.navigationController pushViewController:vc animated:YES];
                        }
                    }else{
                        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                    }
                }else{
                    if (![GSHOpenSDKShare share].currentFamily) {
                        [TZMProgressHUDManager showErrorWithStatus:@"请先添加家庭" inView:weakSelf.view];
                        return;
                    }
                    GSHDeviceModelM *modelM = list.firstObject;
                    if (modelM == nil) {
                        [TZMProgressHUDManager showErrorWithStatus:@"无对应设备" inView:weakSelf.view];
                        return;
                    }
                    if (modelM.deviceType.integerValue == GateWayDeviceType || modelM.deviceType.integerValue == GateWayDeviceType2) {
                        if ([GSHOpenSDKShare share].currentFamily.gatewayId.length > 0) {
                            [TZMProgressHUDManager showErrorWithStatus:@"家庭下已添加网关" inView:weakSelf.view];
                            return;
                        }
                    }else{
                        if ([GSHOpenSDKShare share].currentFamily.gatewayId.length == 0) {
                            [TZMProgressHUDManager showErrorWithStatus:@"请添加智能网关" inView:weakSelf.view];
                            return;
                        }
                    }
                    [TZMProgressHUDManager dismissInView:weakSelf.view];
                    GSHDeviceModelListVC *vc = [GSHDeviceModelListVC deviceModelListVCWithList:list sn:sn];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            }];
            return;
        }
    }
    if (qrCode.length > 0) {
        NSArray<NSString *> *items = [qrCode componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
        if (items.count > 1) {
            if ([items[0] rangeOfString:@"ys7"].location != NSNotFound) {
                  //这个是萤石设备
                  GSHDeviceM *deviceM = [GSHDeviceM new];
                  NSArray<NSString *> *items = [qrCode componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];;
                  if (items.count > 1) {
                      deviceM.deviceSn = items[1];
                  }
                  if (items.count > 2) {
                      deviceM.validateCode = items[2];
                  }
                  if (items.count > 3) {
                      NSString *item3 = items[3];
                      deviceM.deviceModelStr = item3;
                      GSHYingShiDeviceDetailVC *vc = [GSHYingShiDeviceDetailVC yingShiDeviceDetailVCWithDevice:deviceM model:nil];
                      [self.navigationController pushViewController:vc animated:YES];
                      return;
                  }
            }
        }
    }
    [TZMProgressHUDManager showErrorWithStatus:@"无法识别二维码" inView:self.view];
}


- (IBAction)touchRightNavBut:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    UINavigationController *nav = [GSHQRCodeScanningVC qrCodeScanningNavWithText:@"将二维码放入框内" title:@"扫描二维码" block:^BOOL(NSString *code, GSHQRCodeScanningVC *vc) {
        [vc dismissViewControllerAnimated:NO completion:^{
            if (code) {
                [weakSelf analysisQRCode:code];
            }
        }];
        return NO;
    }];
    [self presentViewController:nav animated:YES completion:NULL];
}

// 联动
- (IBAction)touchAuto:(UIButton *)sender {
    if (![GSHOpenSDKShare share].currentFamily.familyId) {
        [TZMProgressHUDManager showErrorWithStatus:@"请先创建家庭" inView:self.view];
        return;
    }
    GSHAutomateVC *autoVC = [[GSHAutomateVC alloc] init];
    autoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:autoVC animated:YES];
}

// 防御
- (IBAction)touchDefense:(UIButton *)sender {
    if (![GSHOpenSDKShare share].currentFamily.familyId) {
        [TZMProgressHUDManager showErrorWithStatus:@"请先创建家庭" inView:self.view];
        return;
    }
    GSHDefenseListVC *defenseListVC = [GSHDefenseListVC defenseListVC];
    defenseListVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:defenseListVC animated:YES];
}

// 消息
- (IBAction)touchMessage:(UIButton *)sender {
    if (![GSHOpenSDKShare share].currentFamily.familyId) {
        [TZMProgressHUDManager showErrorWithStatus:@"请先创建家庭" inView:self.view];
        return;
    }
    GSHMessageVC *messageVC = [[GSHMessageVC alloc] initWithSelectIndex:0];
    messageVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:messageVC animated:YES];
}
- (IBAction)touchHeadImage:(UIButton *)sender {
    GSHUserInfoVC *vc = [GSHUserInfoVC newWithUserInfo:self.userInfo];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - request
// 查询是否有未读消息
- (void)queryIsHasUnReadMsg {
    @weakify(self)
    [GSHMessageManager queryIsHasUnReadMsgWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSArray<NSString *> * _Nonnull list, NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
        } else {
            if (list.count > 0) {
                self.messageDotView.hidden = NO;
            } else {
                self.messageDotView.hidden = YES;
            }
        }
    }];
}

@end
