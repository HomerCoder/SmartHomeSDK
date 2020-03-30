//
//  GSHInfraredVirtualDeviceAirConditionerVC.m
//  SmartHome
//
//  Created by gemdale on 2019/4/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHInfraredVirtualDeviceAirConditionerVC.h"
#import <TZMOpenLib/UINavigationController+TZM.h>
#import <TZMOpenLib/TZMButton.h>
#import <TZMExternalPackagLib/IRConstants.h>
#import "GSHInfraredControllerEditVC.h"
#import "JKCircleView.h"

@interface GSHInfraredVirtualDeviceAirConditionerVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnRightNavBtn;
@property (weak, nonatomic) IBOutlet UIView *temperatureView;
- (IBAction)touchBut:(UIButton *)sender;
- (IBAction)touchRigthNavBut:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblWenDu;
@property (weak, nonatomic) IBOutlet TZMButton *btnKaiGuan;
@property (weak, nonatomic) IBOutlet TZMButton *btnDi;
@property (weak, nonatomic) IBOutlet TZMButton *btnZhong;
@property (weak, nonatomic) IBOutlet TZMButton *btnGao;
@property (weak, nonatomic) IBOutlet TZMButton *btnLeng;
@property (weak, nonatomic) IBOutlet TZMButton *btnRe;
@property (weak, nonatomic) IBOutlet TZMButton *btnChuShi;
@property (weak, nonatomic) IBOutlet TZMButton *btnSongFeng;
@property (weak, nonatomic) IBOutlet UIButton *btnJia;
@property (weak, nonatomic) IBOutlet UIButton *btnJian;
@property (weak, nonatomic) IBOutlet UILabel *lblDanwei;
@property (weak, nonatomic) IBOutlet UILabel *lblModel;
@property (weak, nonatomic) IBOutlet UILabel *lblFeng;
@property(nonatomic,strong) GSHKuKongInfraredDeviceM *device;
@property(nonatomic,strong) KKZipACManager *manager;
@property (nonatomic,strong) JKCircleView *circleView;
@end

@implementation GSHInfraredVirtualDeviceAirConditionerVC

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

+ (instancetype)infraredVirtualDeviceAirConditionerVCWithDevice:(GSHKuKongInfraredDeviceM *)device{
    GSHInfraredVirtualDeviceAirConditionerVC *vc = [GSHPageManager viewControllerWithSB:@"GSHInfraredVirtualDeviceSB" andID:@"GSHInfraredVirtualDeviceAirConditionerVC"];
    vc.device = device;
    vc.deviceM = device;
    vc.deviceEditType = GSHDeviceVCTypeControl;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tzm_prefersNavigationBarHidden = YES;
    self.lblTitle.text = self.device.deviceName;
    
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"初始化空调中" inView:self.view];
    [GSHKuKongRemoteM getKuKongDeviceIrDataWithDeviceSn:self.device.deviceSn fileUrl:self.device.fileUrl fid:self.device.fid remoteId:@(7364) block:^(KKZipACManager *manager, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.manager = manager;
            [weakSelf refreshUI];
        }
    }];
    
    self.circleView = [[JKCircleView alloc] initWithFrame:CGRectMake(0, 0, self.temperatureView.frame.size.width, self.temperatureView.frame.size.height) startAngle:225 endAngle:315];
    self.circleView.enableCustom = YES;
    [self.circleView setIsCanSlideTemperature:YES];
    self.circleView.minNum = 16;
    self.circleView.maxNum = 30;
    [self.circleView setProgressChange:^(NSString *result, BOOL isSendRequest) {
        weakSelf.lblWenDu.text = result;
        if (isSendRequest) {
            int temperature = result.intValue;
            [weakSelf.manager changeTemperatureWithTemperature:temperature];
            [weakSelf postKuKongKey];
        }
    }];
    [self.temperatureView addSubview:self.circleView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.lblTitle.text = self.device.deviceName;
    self.btnRightNavBtn.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember;
}

-(void)dealloc{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [self.manager getACAllModeAndStateValue];
    if (arr && self.device.deviceSn) {
        [userDefaults setObject:arr forKey:self.device.deviceSn];
        [userDefaults synchronize];;
    }
}

- (void)refreshUI{
    int off = [self.manager getPowerState];
    if (off == AC_POWER_ON) {
        //开关打开
        self.btnKaiGuan.selected = YES;
        self.btnGao.selected = NO;
        self.btnDi.selected = NO;
        self.btnZhong.selected = NO;
        self.btnChuShi.selected = NO;
        self.btnRe.selected = NO;
        self.btnSongFeng.selected = NO;
        self.btnLeng.selected = NO;
        self.circleView.enableCustom = YES;
        
        self.btnJia.enabled = YES;
        self.btnJian.enabled = YES;
        self.lblDanwei.hidden = NO;
        self.lblWenDu.hidden = NO;
        self.lblFeng.hidden = NO;
        self.lblModel.hidden = NO;
        
        int temperature = [self.manager getTemperature];
        self.lblWenDu.text = [NSString stringWithFormat:@"%d",temperature];
        [self.circleView setProgressWithProgress:(temperature - 16.0) / 14.0 isSendRequest:NO];
        [self.circleView setIsCanSlideTemperature:YES];
        int modeState = [self.manager getModeState];
        switch (modeState) {
            case TAG_AC_MODE_COOL_FUNCTION:
                self.lblModel.text = @"制冷模式";
                break;
            case TAG_AC_MODE_HEAT_FUNCTION:
                self.lblModel.text = @"制热模式";
                break;
            case TAG_AC_MODE_FAN_FUNCTION:
                self.lblModel.text = @"送风模式";
                break;
            case TAG_AC_MODE_DRY_FUNCTION:
                self.lblModel.text = @"除湿模式";
                break;
            default:
                self.lblModel.text = @"";
                break;
        }
        
        int wind = [self.manager getWindPower];
        switch (wind) {
            case AC_WIND_SPEED_LOW:
                self.lblFeng.text = @"低风";
                break;
            case AC_WIND_SPEED_MEDIUM:
                self.lblFeng.text = @"中风";
                break;
            case AC_WIND_SPEED_HIGH:
                self.lblFeng.text = @"高风";
                break;
            default:
                self.lblFeng.text = @"";
                break;
        }
    }else{
        //开关关闭
        self.btnKaiGuan.selected = NO;
        self.btnGao.selected = NO;
        self.btnDi.selected = NO;
        self.btnZhong.selected = NO;
        self.btnLeng.selected = NO;
        self.btnChuShi.selected = NO;
        self.btnRe.selected = NO;
        self.btnSongFeng.selected = NO;
        self.btnJia.enabled = NO;
        self.btnJian.enabled = NO;
        self.lblDanwei.hidden = NO;
        self.lblWenDu.hidden = NO;
        self.lblFeng.hidden = YES;
        self.lblModel.hidden = YES;
        self.circleView.enableCustom = NO;
        int temperature = 16;
        self.lblWenDu.text = [NSString stringWithFormat:@"%d",temperature];
        [self.circleView setProgressWithProgress:(temperature - 16.0) / 14.0 isSendRequest:NO];
        [self.circleView setIsCanSlideTemperature:NO];
    }
}

- (void)postKuKongKey{
    NSMutableString * ACInfrared1=[[NSMutableString alloc] init];
    for (NSNumber * string in [self.manager getAirConditionInfrared]) {
        [ACInfrared1 appendFormat:@"%02X",[string unsignedCharValue]];
    }
    
    NSMutableString * ACInfrared2=[[NSMutableString alloc] init];
    for (NSNumber * number in [self.manager getParams]) {
        [ACInfrared2 appendFormat:@"%02X",[number unsignedCharValue]];//获取遥控器参数
    }
    
//    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
//    __weak typeof(self)weakSelf = self;
    [GSHInfraredControllerManager postKuKongModuleVerifyWithRemoteId:self.device.remoteId deviceSN:self.device.parentDeviceSn familyId:[GSHOpenSDKShare share].currentFamily.familyId operType:1 deviceTypeId:self.device.kkDeviceType remoteParam:ACInfrared2 keyParam:ACInfrared1 keyId:nil block:^(NSError *error) {
//        if (error) {
//            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
//        }else{
//            [TZMProgressHUDManager dismissInView:weakSelf.view];
//        }
    }];
}

- (IBAction)touchBut:(UIButton *)sender{
    if (sender == self.btnKaiGuan) {
        [self.manager changePowerStateWithPowerstate:[self.manager getPowerState] == AC_POWER_ON ? AC_POWER_OFF : AC_POWER_ON];
    }else if (sender == self.btnGao) {
        [self.manager changeWindPowerWithWindpower:AC_WIND_SPEED_HIGH];
    }else if (sender == self.btnZhong) {
        [self.manager changeWindPowerWithWindpower:AC_WIND_SPEED_MEDIUM];
    }else if (sender == self.btnDi) {
        [self.manager changeWindPowerWithWindpower:AC_WIND_SPEED_LOW];
    }else if (sender == self.btnLeng) {
        [self.manager changeModeStateWithModeState:TAG_AC_MODE_COOL_FUNCTION];
    }else if (sender == self.btnRe) {
        [self.manager changeModeStateWithModeState:TAG_AC_MODE_HEAT_FUNCTION];
    }else if (sender == self.btnSongFeng) {
        [self.manager changeModeStateWithModeState:TAG_AC_MODE_FAN_FUNCTION];
    }else if (sender == self.btnChuShi) {
        [self.manager changeModeStateWithModeState:TAG_AC_MODE_DRY_FUNCTION];
    }else if (sender == self.btnJia) {
        int temperature = [self.manager getTemperature];
        if (temperature >= 30) {
            [TZMProgressHUDManager showErrorWithStatus:@"已到达最高温度" inView:self.view];
            return;
        }
        [self.manager changeTemperatureWithTemperature:++temperature];
    }else if (sender == self.btnJian) {
        int temperature = [self.manager getTemperature];
        if (temperature <= 16) {
            [TZMProgressHUDManager showErrorWithStatus:@"已到达最高温度" inView:self.view];
            return;
        }
        [self.manager changeTemperatureWithTemperature:--temperature];
    }else{
        return;
    }
    [self refreshUI];
    [self postKuKongKey];
}

- (IBAction)touchRigthNavBut:(id)sender{
    [self closeWithComplete:^{
        GSHInfraredControllerEditVC *vc = [GSHInfraredControllerEditVC infraredControllerEditVCWithDevice:self.device];
        [[UIViewController visibleTopViewController].navigationController pushViewController:vc animated:YES];
    }];
}
@end
