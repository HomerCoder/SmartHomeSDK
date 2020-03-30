//
//  GSHNewWindHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/9/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHNewWindHandleVC.h"
#import "UINavigationController+TZM.h"

#import "TZMButton.h"
#import "GSHDeviceEditVC.h"
#import "NSObject+TZM.h"

#define NewWindSwitchKey @"112"    // 开关状态
#define NewWindWindSpeedKey @"111"    // 风速

@interface GSHNewWindHandleVC ()

@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet TZMButton *switchButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UIView *viewControl;
@property (weak, nonatomic) IBOutlet UIButton *btnBig;

@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) NSArray *exts;

@end

@implementation GSHNewWindHandleVC

+ (instancetype)newWindHandleVCWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHNewWindHandleVC *vc = [GSHPageManager viewControllerWithSB:@"GSHNewWindHandleSB" andID:@"GSHNewWindHandleVC"];
    vc.deviceM = deviceM;
    vc.deviceEditType = deviceEditType;
    vc.exts = deviceM.exts;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"" : @"确定";
    NSString *buttonImageName = self.deviceEditType == GSHDeviceVCTypeControl ? @"device_set_btn" : @"";
    [self.rightNaviButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    [self.rightNaviButton setImage:[UIImage ZHImageNamed:buttonImageName] forState:UIControlStateNormal];
    self.rightNaviButton.hidden = ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    [self getDeviceDetailInfo];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制模式 注册通知
        [self observerNotifications];
    }else{
        [self refreshUI];
    }
}

-(void)observerNotifications{
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification]) {
        [self notiHandle];
    }
}

-(void)dealloc{
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - method

- (IBAction)switchButtonClick:(UIButton *)button {
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        __weak typeof(self.switchButton) weakButton = self.switchButton;
        @weakify(self)
        NSString *value;
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            // 离线控制模式 -- 开关按钮点击首先修改UI
            [self switchButtonClickToRefreshUIWithButton:self.switchButton];
            value = self.switchButton.selected ? @"0" : @"4";
        } else {
            value = self.switchButton.selected ? @"4" : @"0";
        }
        [self controlDeviceWithBasMeteId:GSHNewWind_SwitchMeteId value:value successBlock:^() {
            __strong typeof(weakButton) strongButton = weakButton;
            @strongify(self)
            [TZMProgressHUDManager dismissInView:self.view];
            [self switchButtonClickToRefreshUIWithButton:strongButton];
        }];
    } else {
        // 联动 -- 设备设置
        [self switchButtonClickToRefreshUIWithButton:self.switchButton];
    }
}

- (void)switchButtonClickToRefreshUIWithButton:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        for (int i = 1; i < 4; i ++) {
            UIButton *tmpButton = [self.view viewWithTag:i];
            tmpButton.selected = NO;
        }
    }
    if (self.switchButton.selected) {
        self.switchButton.hidden = YES;
        self.viewControl.alpha = 0.5;
        self.iconImageView.hidden = YES;
        self.btnBig.hidden = NO;
    }else{
        self.switchButton.hidden = NO;
        self.viewControl.alpha = 1;
        self.iconImageView.hidden = NO;
        self.btnBig.hidden = YES;
    }
}

- (IBAction)handleButtonClick:(UIButton *)button {
    
    if (button.selected) {
        return;
    }
    if (self.switchButton.selected) {
        return;
    }
    NSInteger tag = button.tag;
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            // 离线控制模式 -- 开关按钮点击首先修改UI
            [self handleButtonClickToRefreshUIWithButton:button];
        }
        NSString *value = [NSString stringWithFormat:@"%d",(int)tag];
        @weakify(self)
        __weak typeof(button) weakButton = button;
        [self controlDeviceWithBasMeteId:GSHNewWind_WindSpeedMeteId value:value successBlock:^() {
            @strongify(self)
            __strong typeof(weakButton) strongButton = weakButton;
            [self handleButtonClickToRefreshUIWithButton:strongButton];
        }];
    } else {
        // 情景、联动 -- 设备设置
        [self handleButtonClickToRefreshUIWithButton:button];
    }
}

- (void)handleButtonClickToRefreshUIWithButton:(UIButton *)button {
    for (int i = 1; i < 4; i ++) {
        UIButton *tmpButton = [self.view viewWithTag:i];
        tmpButton.selected = NO;
    }
    button.selected = YES;
}

- (IBAction)enterDevice:(id)sender {
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制 -- 进入设备
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            [TZMProgressHUDManager showInfoWithStatus:@"离线环境无法查看" inView:self.view];
            return;
        }
        if (!self.deviceM) {
            [TZMProgressHUDManager showErrorWithStatus:@"设备数据出错" inView:self.view];
            return;
        }
        GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:self.deviceM type:GSHDeviceEditVCTypeEdit];
        @weakify(self)
        deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
            @strongify(self)
            self.deviceM = deviceM;
            [self refreshUI];
        };
        [self closeWithComplete:^{
            [[UIViewController visibleTopViewController].navigationController pushViewController:deviceEditVC animated:YES];
        }];
        
    } else {
        // 确定
        NSMutableArray *exts = [NSMutableArray array];
        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
        extM.basMeteId = GSHNewWind_SwitchMeteId;
        extM.conditionOperator = @"==";
        if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
            // scene :  rightValue
            if (self.switchButton.selected) {
                // 关
                extM.rightValue = @"0";
            } else {
                // 开
                extM.rightValue = @"4";
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    if (tmpButton.selected) {
                        // 有风量按钮选中
                        GSHDeviceExtM *speedExtM = [[GSHDeviceExtM alloc] init];
                        speedExtM.conditionOperator = @"==";
                        speedExtM.basMeteId = GSHNewWind_WindSpeedMeteId;
                        speedExtM.rightValue = [NSString stringWithFormat:@"%d",i];
                        [exts addObject:speedExtM];
                        break;
                    }
                }
            }
        } else  if (self.deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
            // auto trigger :  operator rightValue
            if (self.switchButton.selected) {
                // 关
                extM.rightValue = @"0";
            } else {
                // 开
                extM.rightValue = @"4";
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    if (tmpButton.selected) {
                        // 有风量按钮选中
                        GSHDeviceExtM *speedExtM = [[GSHDeviceExtM alloc] init];
                        speedExtM.basMeteId = GSHNewWind_WindSpeedMeteId;
                        speedExtM.conditionOperator = @"==";
                        speedExtM.rightValue = [NSString stringWithFormat:@"%d",i];
                        [exts addObject:speedExtM];
                        break;
                    }
                }
            }
        } else  if (self.deviceEditType == GSHDeviceVCTypeAutoActionSet) {
            // auto action :  param
            if (self.switchButton.selected) {
                // 关
                extM.rightValue = @"0";
            } else {
                // 开
                extM.rightValue = @"4";
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    if (tmpButton.selected) {
                        // 有风量按钮选中
                        GSHDeviceExtM *speedExtM = [[GSHDeviceExtM alloc] init];
                        speedExtM.basMeteId = GSHNewWind_WindSpeedMeteId;
                        speedExtM.conditionOperator = @"==";
                        speedExtM.rightValue = [NSString stringWithFormat:@"%d",i];
                        [exts addObject:speedExtM];
                        break;
                    }
                }
            }
        }
        
        [exts addObject:extM];
        
        if (exts.count > 1) {
            // v3.1.1 选择了温度 , 删除开关条件属性
            [exts removeObjectAtIndex:1];
        }
        
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self closeWithComplete:^{
            
        }];
    }
}

// 接收到实时数据的通知后的处理方法
- (void)notiHandle {
    NSLog(@"real time data refresh UI");
    [self refreshUI];
}

#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceSign:nil block:^(GSHDeviceM *device, NSError *error) {
        @strongify(self)
        if (!error) {
            self.deviceM = device;
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
            }
            [self refreshUI];
        }
    }];
}

// 设备控制
- (void)controlDeviceWithBasMeteId:(NSString *)basMeteId
                             value:(NSString *)value
                      successBlock:(void(^)(void))successBlock {
    
    [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue deviceSN:self.deviceM.deviceSn familyId:[GSHOpenSDKShare share].currentFamily.familyId basMeteId:basMeteId value:value block:^(NSError *error) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            if (!error) {
                if (successBlock) {
                    successBlock();
                }
            } else {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            }
        }
    }];
    
}

- (void)refreshUI {
    
    self.deviceNameLabel.text = self.deviceM.deviceName;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.deviceM.controlPicPath] placeholderImage:GlobalPlaceHoldImage];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        NSDictionary *dic = [self.deviceM realTimeDic];
        id value = [dic objectForKey:GSHNewWind_SwitchMeteId];
        if (value) {
            // 开关状态有值
            if ([value intValue] == 0) {
                // 新风 关
                self.switchButton.selected = YES;
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
            } else if ([value intValue] == 4) {
                // 新风 开
                self.switchButton.selected = NO;
                id windSpeedValue = [dic objectForKey:GSHNewWind_WindSpeedMeteId];
                if (windSpeedValue) {
                    for (int i = 1; i < 4; i ++) {
                        UIButton *tmpButton = [self.view viewWithTag:i];
                        tmpButton.selected = NO;
                    }
                    if ([windSpeedValue intValue] == 1 || [windSpeedValue intValue] == 2 || [windSpeedValue intValue] == 3) {
                        UIButton *openButton = [self.view viewWithTag:[windSpeedValue intValue]];
                        openButton.selected = YES;
                    }
                }
            }
        }
    } else {
        if (self.deviceM.exts.count > 0) {
            NSString *switchValue = @"";
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                if ([extM.basMeteId isEqualToString:GSHNewWind_SwitchMeteId]) {
                    if (extM.rightValue) {
                        switchValue = extM.rightValue;
                    }
                    if (self.deviceEditType != GSHDeviceVCTypeSceneSet && extM.param) {
                        switchValue = extM.param;
                    }
                }
            }
            // v3.1.1 新风选了风速,开关不作为条件 因此判断有开关属性且为0即表示关的状态,反之则为开的状态
            if (switchValue.length > 0 && switchValue.integerValue == 0) {
                // 关
                self.switchButton.selected = YES;
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
            } else {
                // 开
                self.switchButton.selected = NO;
                for (GSHDeviceExtM *extM in self.deviceM.exts) {
                    if ([extM.basMeteId isEqualToString:GSHNewWind_WindSpeedMeteId]) {
                        for (int i = 1; i < 4; i ++) {
                            UIButton *tmpButton = [self.view viewWithTag:i];
                            tmpButton.selected = NO;
                        }
                        NSString *value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                        if (value.length>0) {
                            UIButton *selectSpeedButton = [self.view viewWithTag:value.integerValue];
                            selectSpeedButton.selected = YES;
                        }
                    }
                }
            }
        }
    }
    if (self.switchButton.selected) {
        self.switchButton.hidden = YES;
        self.viewControl.alpha = 0.5;
        self.iconImageView.hidden = YES;
        self.btnBig.hidden = NO;
    }else{
        self.switchButton.hidden = NO;
        self.viewControl.alpha = 1;
        self.iconImageView.hidden = NO;
        self.btnBig.hidden = YES;
    }
}

@end
