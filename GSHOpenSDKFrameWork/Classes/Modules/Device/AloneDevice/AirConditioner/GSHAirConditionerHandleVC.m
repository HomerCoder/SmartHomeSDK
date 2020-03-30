//
//  GSHAirConditionerHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/6.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAirConditionerHandleVC.h"
#import "UIView+TZM.h"
#import "UINavigationController+TZM.h"
#import "TZMButton.h"
#import "GSHDeviceEditVC.h"
#import "JKCircleView.h"
#import "NSObject+TZM.h"

@interface GSHAirConditionerHandleVC ()

@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;   // 开关按钮
@property (weak, nonatomic) IBOutlet UIView *temperatureView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIButton *subButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *airConditionerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelShowLabel;   // 显示模式
@property (weak, nonatomic) IBOutlet UILabel *speedShowLabel;   // 显示风速
@property (weak, nonatomic) IBOutlet UIButton *btnBig;
@property (weak, nonatomic) IBOutlet UIView *viewControl;

@property (nonatomic,strong) NSArray *modelValueArray;
@property (nonatomic,strong) NSMutableDictionary *meteIdDic;
@property (nonatomic,strong) JKCircleView *circleView;
@property (nonatomic,assign) CGFloat currentTemperatureValue;
@property (nonatomic,strong) NSArray *exts;
@property (nonatomic,strong) NSArray *btnTypeArray;

@end

@implementation GSHAirConditionerHandleVC

+ (instancetype)airConditionerHandleVCWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHAirConditionerHandleVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAirConditionerHandleSB" andID:@"GSHAirConditionerHandleVC"];
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
    self.btnTypeArray = @[@"低风",@"中风",@"高风",@"制冷模式",@"制热模式",@"除湿模式",@"送风模式"];
    
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"" : @"确定";
    NSString *buttonImageName = self.deviceEditType == GSHDeviceVCTypeControl ? @"device_set_btn" : @"";
    [self.rightNaviButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    [self.rightNaviButton setImage:[UIImage ZHImageNamed:buttonImageName] forState:UIControlStateNormal];
    self.rightNaviButton.hidden = ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    self.modelValueArray = @[@"1",@"2",@"3",@"3",@"4",@"8",@"7"];
    
    [self initUI];
    
    [self getDeviceDetailInfo];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        [self observerNotifications];
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

#pragma mark - UI
- (void)initUI {
    self.currentTemperatureValue = 16;
    self.temperatureLabel.text = @"16";
    
    self.circleView = [[JKCircleView alloc] initWithFrame:CGRectMake(0, 0, self.temperatureView.frame.size.width, self.temperatureView.frame.size.height) startAngle:225 endAngle:315];
    self.circleView.minNum = 16;
    self.circleView.maxNum = 32;
    self.circleView.enableCustom = YES;

    [self.circleView setProgressWithProgress:(self.currentTemperatureValue - 16) / 16.0 isSendRequest:NO];
    [self.circleView setIsCanSlideTemperature:YES];
    @weakify(self);
    [self.circleView setProgressChange:^(NSString *result, BOOL isSendRequest) {
        @strongify(self)
        self.temperatureLabel.text = result;
        self.currentTemperatureValue = result.floatValue;
        if (self.deviceEditType == GSHDeviceVCTypeControl) {
            if (isSendRequest) {
                // 控制空调温度
                [self controlAirConditionerWithBasMeteId:GSHAirConditioner_TemperatureMeteId value:result failBlock:^(NSError *error) {
                } successBlock:^() {
                }];
            }
        } else {
        }
    }];
    [self.temperatureView addSubview:self.circleView];
    
}

#pragma mark - Lazy
- (NSMutableDictionary *)meteIdDic {
    if (!_meteIdDic) {
        _meteIdDic = [NSMutableDictionary dictionary];
    }
    return _meteIdDic;
}

#pragma mark - method

- (IBAction)enterDeviceButtonClick:(id)sender {
    
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
        extM.basMeteId = GSHAirConditioner_SwitchMeteId;
        extM.conditionOperator = @"==";
        if (self.switchButton.selected) {
            // 关
            extM.rightValue = @"0";
        } else {
            // 开
            extM.rightValue = @"10";
            
            for (int i = 4; i < 8; i ++) {
                UIButton *tmpButton = [self.view viewWithTag:i];
                if (tmpButton.selected) {
                    // 有模式按钮选中
                    GSHDeviceExtM *modelExtM = [[GSHDeviceExtM alloc] init];
                    modelExtM.basMeteId = GSHAirConditioner_ModelMeteId;
                    modelExtM.conditionOperator = @"==";
                    modelExtM.rightValue = self.modelValueArray[i-1];
                    [exts addObject:modelExtM];
                    break;
                }
            }
            for (int i = 1; i < 4; i ++) {
                UIButton *tmpButton = [self.view viewWithTag:i];
                if (tmpButton.selected) {
                    // 有风量按钮选中
                    GSHDeviceExtM *speedExtM = [[GSHDeviceExtM alloc] init];
                    speedExtM.basMeteId = GSHAirConditioner_WindSpeedMeteId;
                    speedExtM.conditionOperator = @"==";
                    speedExtM.rightValue = [NSString stringWithFormat:@"%d",i];
                    [exts addObject:speedExtM];
                    break;
                }
            }
            
            GSHDeviceExtM *temperatureExtM = [[GSHDeviceExtM alloc] init];
            temperatureExtM.basMeteId = GSHAirConditioner_TemperatureMeteId;
            temperatureExtM.conditionOperator = @"==";
            temperatureExtM.rightValue = [NSString stringWithFormat:@"%d",(int)self.currentTemperatureValue];
            [exts addObject:temperatureExtM];
        }
        [exts addObject:extM];
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self closeWithComplete:^{
            
        }];
    }
}

// 减温度按钮点击
- (IBAction)subButtonClick:(id)sender {
    if (self.switchButton.selected) {
        return;
    }
    if (self.currentTemperatureValue > 16) {
        self.currentTemperatureValue --;
        [self.circleView setProgressWithProgress:(self.currentTemperatureValue - 16) / 16.0 isSendRequest:YES];
    }
}

// 加温度按钮点击
- (IBAction)addButtonClick:(id)sender {
    if (self.switchButton.selected) {
        return;
    }
    if (self.currentTemperatureValue < 32) {
        self.currentTemperatureValue ++;
        [self.circleView setProgressWithProgress:(self.currentTemperatureValue - 16) / 16.0 isSendRequest:YES];
    }
}

// 开关按钮点击
- (IBAction)switchButtonClick:(UIButton *)button1 {
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        NSString *value;
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            // 离线控制模式 -- 开关按钮点击首先修改UI
            [self switchButtonClickToRefreshUIWithButton:self.switchButton];
            value = self.switchButton.selected ? @"0" : @"10";
        } else {
            value = self.switchButton.selected ? @"10" : @"0";
        }
        __weak typeof(self.switchButton) weakButton = self.switchButton;
        @weakify(self)
        [self controlAirConditionerWithBasMeteId:GSHAirConditioner_SwitchMeteId value:value failBlock:^(NSError *error) {

        } successBlock:^() {
            __strong typeof(weakButton) strongButton = weakButton;
            @strongify(self)
            [self switchButtonClickToRefreshUIWithButton:strongButton];
        }];
    } else {
        [self switchButtonClickToRefreshUIWithButton:self.switchButton];
    }
}

- (void)switchButtonClickToRefreshUIWithButton:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        // 关空调
        for (int i = 1; i < 8; i ++) {
            UIButton *tmpButton = [self.view viewWithTag:i];
            tmpButton.selected = NO;
        }
        self.modelShowLabel.text = @"";
        self.speedShowLabel.text = @"";
        
        self.currentTemperatureValue = 16;
        [self.circleView setProgressWithProgress:(self.currentTemperatureValue - 16) / 16.0 isSendRequest:NO];
    }
    self.subButton.enabled = button.selected ? NO : YES;
    self.addButton.enabled = button.selected ? NO : YES;
    [self.circleView setIsCanSlideTemperature:!button.selected];
    if (self.switchButton.selected) {
        self.btnBig.hidden = NO;
        self.temperatureView.hidden = YES;
        self.addButton.hidden = YES;
        self.subButton.hidden = YES;
        self.switchButton.hidden = YES;
        self.viewControl.alpha = 0.5;
    }else{
        self.btnBig.hidden = YES;
        self.temperatureView.hidden = NO;
        self.addButton.hidden = NO;
        self.subButton.hidden = NO;
        self.switchButton.hidden = NO;
        self.viewControl.alpha = 1;
    }
}

// 操作按钮点击
- (IBAction)handleButtonClick:(UIButton *)button {
    
    if (button.selected) {
        return;
    }
    if (self.switchButton.selected) {
        return;
    }
    NSInteger tag = button.tag;
    NSString *value = self.modelValueArray[tag - 1];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        @weakify(self)
        __weak typeof(button) weakButton = button;
        if (tag <= 7 && tag >= 4) {
            // 空调模式按钮点击
            [self controlAirConditionerWithBasMeteId:GSHAirConditioner_ModelMeteId value:value failBlock:^(NSError *error) {

            } successBlock:^() {
                @strongify(self)
                __strong typeof(weakButton) strongButton = weakButton;
                for (int i = 4; i < 8; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
                strongButton.selected = YES;
                self.modelShowLabel.text = self.btnTypeArray[tag-1];    // 模式名称显示
            }];
        } else {
            // 空调风速按钮点击
            [self controlAirConditionerWithBasMeteId:GSHAirConditioner_WindSpeedMeteId value:value failBlock:^(NSError *error) {

            } successBlock:^() {
                @strongify(self)
                __strong typeof(weakButton) strongButton = weakButton;
                for (int i = 1; i < 4; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
                strongButton.selected = YES;
                self.speedShowLabel.text = self.btnTypeArray[tag-1];    // 风速名称显示
            }];
        }
    } else {
        // 联动 -- 执行动作 -- 设备设置
        if (tag <= 7 && tag >= 4) {
            for (int i = 4; i < 8; i ++) {
                UIButton *tmpButton = [self.view viewWithTag:i];
                tmpButton.selected = NO;
            }
            self.modelShowLabel.text = self.btnTypeArray[tag-1];    // 模式名称显示
        } else {
            for (int i = 1; i < 4; i ++) {
                UIButton *tmpButton = [self.view viewWithTag:i];
                tmpButton.selected = NO;
            }
            self.speedShowLabel.text = self.btnTypeArray[tag-1];    // 风速名称显示
        }
        button.selected = YES;
    }
}

// 接收到实时数据的通知后的处理方法
- (void)notiHandle {
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
            for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                NSString *key = [NSString stringWithFormat:@"%@%@",attributeM.meteType,attributeM.meteIndex];
                [self.meteIdDic setObject:attributeM.basMeteId forKey:key];
            }
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
            }
            [self refreshUI];
        }
    }];
}

// 设备控制
- (void)controlAirConditionerWithBasMeteId:(NSString *)basMeteId
                                     value:(NSString *)value
                                 failBlock:(void(^)(NSError *error))failBlock
                              successBlock:(void(^)(void))successBlock {
    
    [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue deviceSN:self.deviceM.deviceSn familyId:[GSHOpenSDKShare share].currentFamily.familyId basMeteId:basMeteId value:value block:^(NSError *error) {
        
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
                if (failBlock) {
                    failBlock(error);
                }
            } else {
                if (successBlock) {
                    successBlock();
                }
            }
        }
        
    }];
}

- (void)refreshUI {
    
    self.airConditionerNameLabel.text = self.deviceM.deviceName;
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        NSDictionary *dic = [self.deviceM realTimeDic];
        NSLog(@"real time : %@",dic);
        id value = [dic objectForKey:GSHAirConditioner_SwitchMeteId];
        if (value) {
            // 开关状态有值
            [self.circleView setIsCanSlideTemperature:[value intValue] == 0 ? NO : YES];
            if ([value intValue] == 0) {
                // 空调 关
                self.switchButton.selected = YES;
                for (int i = 1; i < 8; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
                [self.circleView setIsCanSlideTemperature:NO];
            } else if ([value intValue] == 10) {
                // 空调 开
                self.switchButton.selected = NO;
                [self.circleView setIsCanSlideTemperature:YES];
                // 温度
                id temperatureValue = [dic objectForKey:GSHAirConditioner_TemperatureMeteId];
                if (temperatureValue) {
                    [self.circleView setProgressWithProgress:([temperatureValue intValue] - 16) / 16.0 isSendRequest:NO];
                    self.currentTemperatureValue = [temperatureValue floatValue];
                }
                // 风速
                id windSpeedValue = [dic objectForKey:GSHAirConditioner_WindSpeedMeteId];
                if (windSpeedValue) {
                    for (int i = 1; i < 4; i ++) {
                        UIButton *tmpButton = [self.view viewWithTag:i];
                        tmpButton.selected = NO;
                    }
                    if ([windSpeedValue intValue] == 1 || [windSpeedValue intValue] == 2 || [windSpeedValue intValue] == 3) {
                        UIButton *openButton = [self.view viewWithTag:[windSpeedValue intValue]];
                        openButton.selected = YES;
                        self.speedShowLabel.text = self.btnTypeArray[[windSpeedValue intValue]-1];    // 风速名称显示
                    }
                }
                // 模式
                id modelValue = [dic objectForKey:GSHAirConditioner_ModelMeteId];
                if (modelValue) {
                    for (int i = 4; i < 8; i ++) {
                        UIButton *tmpButton = [self.view viewWithTag:i];
                        tmpButton.selected = NO;
                    }
                    if ([modelValue intValue] == 3 || [modelValue intValue] == 4 || [modelValue intValue] == 8 || [modelValue intValue] == 7) {
                        int tag = 4;
                        if ([modelValue intValue] == 4) {
                            tag = 5;
                        } else if ([modelValue intValue] == 8) {
                            tag = 6;
                        } else if ([modelValue intValue] == 7) {
                            tag = 7;
                        } else {
                            tag = 4;
                        }
                        UIButton *openButton = [self.view viewWithTag:tag];
                        openButton.selected = YES;
                        self.modelShowLabel.text = self.btnTypeArray[tag-1];    // 模式名称显示
                    }
                }
            }
        }
    } else {
        if (self.deviceM.exts.count > 0) {
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                if ([extM.basMeteId isEqualToString:GSHAirConditioner_SwitchMeteId]) {
                    if (extM.rightValue) {
                        self.switchButton.selected = [extM.rightValue isEqualToString:@"0"] ? YES : NO;
                    }
                    if (self.deviceEditType != GSHDeviceVCTypeSceneSet && extM.param) {
                        self.switchButton.selected = [extM.param isEqualToString:@"0"] ? YES : NO;
                    }
                }
            }
            if (!self.switchButton.selected && self.deviceM.exts.count > 1) {
                // 空调开
                [self.circleView setIsCanSlideTemperature:YES];
                for (GSHDeviceExtM *extM in self.deviceM.exts) {
                    if ([extM.basMeteId isEqualToString:GSHAirConditioner_ModelMeteId]) {
                        // 模式
                        for (int i = 4; i < 8; i ++) {
                            UIButton *tmpButton = [self.view viewWithTag:i];
                            tmpButton.selected = NO;
                        }
                        NSString *modelValue = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                        if (modelValue.length > 0) {
                            if ([modelValue intValue] == 3 ||
                                [modelValue intValue] == 4 ||
                                [modelValue intValue] == 8 ||
                                [modelValue intValue] == 7) {
                                int tag = 4;
                                if ([modelValue intValue] == 4) {
                                    tag = 5;
                                } else if ([modelValue intValue] == 8) {
                                    tag = 6;
                                } else if ([modelValue intValue] == 7) {
                                    tag = 7;
                                } else {
                                    tag = 4;
                                }
                                UIButton *selectModelButton = [self.view viewWithTag:tag];
                                selectModelButton.selected = YES;
                                self.modelShowLabel.text = self.btnTypeArray[tag-1];    // 模式名称显示
                            }
                        }
                    } else if ([extM.basMeteId isEqualToString:GSHAirConditioner_WindSpeedMeteId]) {
                        // 风速
                        for (int i = 1; i < 4; i ++) {
                            UIButton *tmpButton = [self.view viewWithTag:i];
                            tmpButton.selected = NO;
                        }
                        NSString *windSpeedValue = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                        if (windSpeedValue.length > 0) {
                            UIButton *selectWindSpeedButton = [self.view viewWithTag:windSpeedValue.integerValue];
                            selectWindSpeedButton.selected = YES;
                            self.speedShowLabel.text = self.btnTypeArray[[windSpeedValue intValue]-1];    // 风速名称显示
                        }
                    } else if ([extM.basMeteId isEqualToString:GSHAirConditioner_TemperatureMeteId]) {
                        // 温度
                        NSString *temValue = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                        if (temValue.length > 0) {
                            self.currentTemperatureValue = temValue.floatValue;
                            [self.circleView setProgressWithProgress:(temValue.floatValue-16)/16.0 isSendRequest:NO];
                        }
                    }
                }
            } else {
                // 关
                for (int i = 1; i < 8; i ++) {
                    UIButton *tmpButton = [self.view viewWithTag:i];
                    tmpButton.selected = NO;
                }
                self.subButton.enabled = NO;
                self.addButton.enabled = NO;
                [self.circleView setIsCanSlideTemperature:NO];
            }
        }
    }
    if (self.switchButton.selected) {
        self.btnBig.hidden = NO;
        self.temperatureView.hidden = YES;
        self.addButton.hidden = YES;
        self.subButton.hidden = YES;
        self.switchButton.hidden = YES;
        self.viewControl.alpha = 0.5;
    }else{
        self.btnBig.hidden = YES;
        self.temperatureView.hidden = NO;
        self.addButton.hidden = NO;
        self.subButton.hidden = NO;
        self.switchButton.hidden = NO;
        self.viewControl.alpha = 1;
    }
}


@end
