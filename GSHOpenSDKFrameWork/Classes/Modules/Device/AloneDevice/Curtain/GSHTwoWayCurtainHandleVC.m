//
//  GSHTwoWayCurtainHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHTwoWayCurtainHandleVC.h"
#import "UINavigationController+TZM.h"
#import "GSHDeviceEditVC.h"


@interface GSHTwoWayCurtainHandleVC ()

@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIButton *leftSegButton;
@property (weak, nonatomic) IBOutlet UIButton *rightSegButton;
@property (assign, nonatomic) int segmentIndex; // 标识二路窗帘开关 1：一路 ，2：二路

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UILabel *curtainNameLabel;
@property (assign, nonatomic) GSHTwoWayCurtainHandleVCType type;

@property (weak, nonatomic) IBOutlet UISlider *processSlideView;
@property (weak, nonatomic) IBOutlet UILabel *processLabel;
@property (strong, nonatomic) NSString *processValueStr;

@property (strong, nonatomic) NSMutableDictionary *btnSetDic;
@property (copy, nonatomic) NSString *currentBaseMeteId;
@property (nonatomic,strong) NSArray *exts;

@end

@implementation GSHTwoWayCurtainHandleVC

+ (instancetype)twoWayCurtainHandleVCWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType type:(GSHTwoWayCurtainHandleVCType)type {
    GSHTwoWayCurtainHandleVC *vc = [GSHPageManager viewControllerWithSB:@"GSHTwoWayCurtainHandleSB" andID:@"GSHTwoWayCurtainHandleVC"];
    vc.deviceM = deviceM;
    vc.type = type;
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
    
    self.leftSegButton.backgroundColor = [UIColor whiteColor];
    self.rightSegButton.backgroundColor = [UIColor clearColor];
    self.rightSegButton.layer.opacity = 0.5;
    self.segmentIndex = 1;
    
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"" : @"确定";
    NSString *buttonImageName = self.deviceEditType == GSHDeviceVCTypeControl ? @"device_set_btn" : @"";
    [self.rightButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage ZHImageNamed:buttonImageName] forState:UIControlStateNormal];
    self.rightButton.hidden = ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    if (self.type == GSHTwoWayCurtainMotorHandleVC) {
        // 窗帘电机
        self.currentBaseMeteId = GSHCurtain_SwitchMeteId;
        self.segmentView.hidden = YES;
        self.processSlideView.hidden = NO;
        self.processLabel.hidden = NO;
    } else if (self.type == GSHTwoWayCurtainHandleVCOneWay) {
        // 一路窗帘开关
        self.currentBaseMeteId = GSHOneWayCurtain_SwitchMeteId;
        self.segmentView.hidden = YES;
        self.processSlideView.hidden = YES;
        self.processLabel.hidden = YES;
    } else {
        // 二路窗帘开关 -- 进入页面默认是选中一路
        self.currentBaseMeteId = GSHTwoWayCurtain_OneSwitchMeteId;
        self.segmentView.hidden = NO;
        self.processSlideView.hidden = YES;
        self.processLabel.hidden = YES;
    }
    
    [self getDeviceDetailInfo];
    
}

- (void)refreshUI {
    
    self.curtainNameLabel.text = self.deviceM.deviceName;
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:self.deviceM.controlPicPath] placeholderImage:GlobalPlaceHoldImage];
    
    if (self.type == GSHTwoWayCurtainHandleVCTwoWay) {
        // 二路窗帘开关
        for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
            if ([attributeM.basMeteId isEqualToString:GSHTwoWayCurtain_OneSwitchMeteId]) {
                [self.leftSegButton setTitle:attributeM.meteName forState:UIControlStateNormal];
            } else if ([attributeM.basMeteId isEqualToString:GSHTwoWayCurtain_TwoSwitchMeteId]) {
                [self.rightSegButton setTitle:attributeM.meteName forState:UIControlStateNormal];
            }
        }
    }
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制状态 -- 只有窗帘电机需要同步百分比
        NSDictionary *dic = [self.deviceM realTimeDic];
        NSString *value = [dic objectForKey:GSHCurtain_PercentMeteId];
        if (value) {
            // 百分比有值
            self.processLabel.text = [NSString stringWithFormat:@"%@%%",value];
            self.processSlideView.value = value.floatValue / 100.0;
            self.processValueStr = value;
        } else {
            // 无百分比 默认50%
            self.processValueStr = @"50";
        }
    } else {
        // 条件设置状态
        if (self.type == GSHTwoWayCurtainHandleVCTwoWay) {
            // 二路窗帘
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                NSString *value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                int index ;
                if (value.integerValue == 0) {
                    index = 1;
                } else if (value.integerValue == 1) {
                    index = 3;
                } else {
                    index = 2;
                }
                if ([extM.basMeteId isEqualToString:GSHTwoWayCurtain_OneSwitchMeteId]) {
                    [self.btnSetDic setObject:@(index) forKey:@(1)];
                }
                if ([extM.basMeteId isEqualToString:GSHTwoWayCurtain_TwoSwitchMeteId]) {
                    [self.btnSetDic setObject:@(index) forKey:@(2)];
                }
            }
        } else if (self.type == GSHTwoWayCurtainMotorHandleVC) {
            // 窗帘电机 显示百分比
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                if ([extM.basMeteId isEqualToString:GSHCurtain_PercentMeteId]) {
                    NSString *value = extM.rightValue;
                    self.processLabel.text = [NSString stringWithFormat:@"%@%%",value];
                    self.processSlideView.value = value.floatValue / 100.0;
                }
            }
        }
        
        // 开 关 停状态显示
        if (self.deviceM.exts.count > 0) {
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                if ([extM.basMeteId isEqualToString:self.currentBaseMeteId]) {
                    NSString *value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                    int tag = 1;
                    if (value.intValue == 0) {
                        // 开
                        tag = 1;
                    } else if (value.intValue == 1) {
                        // 关
                        tag = 3;
                    } else {
                        tag = 2;
                    }
                    UIButton *button = [self.view viewWithTag:tag];
                    button.selected = YES;
                }
            }
        }
    }
}

#pragma mark - Lazy
- (NSMutableDictionary *)btnSetDic {
    if (!_btnSetDic) {
        _btnSetDic = [NSMutableDictionary dictionary];
    }
    return _btnSetDic;
}

#pragma mark - method

- (IBAction)rightButtonClick:(id)sender {
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
        if (self.type == GSHTwoWayCurtainHandleVCTwoWay) {
            // 二路窗帘开关
            if ([self.btnSetDic objectForKey:@(1)]) {
                NSNumber *index = [self.btnSetDic objectForKey:@(1)];
                [exts addObject:[self extMWithButtonTag:index.intValue basMeteId:GSHTwoWayCurtain_OneSwitchMeteId]];
            }
            if ([self.btnSetDic objectForKey:@(2)]) {
                NSNumber *index = [self.btnSetDic objectForKey:@(2)];
                [exts addObject:[self extMWithButtonTag:index.intValue basMeteId:GSHTwoWayCurtain_TwoSwitchMeteId]];
            }
        } else {
            for (NSInteger i = 1; i < 4; i ++) {
                UIButton *button = [self.view viewWithTag:i];
                if (button.selected) {
                    [exts addObject:[self extMWithButtonTag:(int)i basMeteId:self.currentBaseMeteId]];
                    break;
                }
            }
            if (self.type == GSHTwoWayCurtainMotorHandleVC) {
                // 窗帘电机
                GSHDeviceExtM *processExtM = [[GSHDeviceExtM alloc] init];
                processExtM.basMeteId = GSHCurtain_PercentMeteId;
                processExtM.rightValue = self.processValueStr;
                processExtM.conditionOperator = @"==";
                [exts addObject:processExtM];
                
                if (exts.count == 1) {
                    [TZMProgressHUDManager showErrorWithStatus:@"请选择开关状态" inView:self.view];
                    return;
                }
            }
        }
        if (exts.count == 0) {
            [TZMProgressHUDManager showErrorWithStatus:@"请选择一个操作" inView:self.view];
            return;
        }
        
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self closeWithComplete:^{
        }];
        
    }
}

- (GSHDeviceExtM *)extMWithButtonTag:(int)buttonTag basMeteId:(NSString *)basMeteId {
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = basMeteId;
    extM.conditionOperator = @"=";
    NSString *value = @"";
    if (buttonTag == 1) {
        // 开
        value = @"0";
    } else if (buttonTag == 3) {
        // 关
        value = @"1";
    } else if (buttonTag == 2) {
        // 暂停
        value = @"2";
    }
    extM.rightValue = value;
    return extM;
}


- (IBAction)handleButtonClick:(UIButton *)button {
    // 设备控制
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        NSString *basMeteId = self.currentBaseMeteId;
        NSString *value;
        if (button.tag == 1) {
            // 开
            value = @"0";
        } else if (button.tag == 2) {
            // 停
            value = @"2";
        } else {
            // 关
            value = @"1";
        }
        [self controlCurtainWithBasMeteId:basMeteId value:value failBlock:^(NSError *error) {
            
        } successBlock:^{
            
        }];
    } else {
        for (int i = 1; i < 4; i ++) {
            UIButton *tmpButton = [self.view viewWithTag:i];
            tmpButton.selected = NO;
        }
        button.selected = !button.selected;
        if (self.type == GSHTwoWayCurtainHandleVCTwoWay) {
            // 二路窗帘开关
            int tag = (int)button.tag;
            [self.btnSetDic setObject:@(tag) forKey:@(self.segmentIndex)];
        }
    }
}

- (IBAction)segButtonClick:(UIButton *)button {
    if (button.selected) {
        return;
    }
    NSInteger tag = button.tag;
    self.segmentIndex = (int)tag;
    if (tag == 1) {
        self.leftSegButton.selected = YES;
        self.rightSegButton.selected = NO;
        [self.leftSegButton setBackgroundColor:[UIColor whiteColor]];
        self.leftSegButton.layer.opacity = 1;
        [self.rightSegButton setBackgroundColor:[UIColor clearColor]];
        self.rightSegButton.layer.opacity = 0.5;
    } else {
        self.leftSegButton.selected = NO;
        self.rightSegButton.selected = YES;
        [self.leftSegButton setBackgroundColor:[UIColor clearColor]];
        self.leftSegButton.layer.opacity = 0.5;
        [self.rightSegButton setBackgroundColor:[UIColor whiteColor]];
        self.rightSegButton.layer.opacity = 1;
    }
    
    self.currentBaseMeteId = tag == 1 ? GSHTwoWayCurtain_OneSwitchMeteId : GSHTwoWayCurtain_TwoSwitchMeteId;
    if (self.deviceEditType != GSHDeviceVCTypeControl) {
        for (int i = 1; i < 4; i ++) {
            UIButton *tmpButton = [self.view viewWithTag:i];
            tmpButton.selected = NO;
        }
        if (tag == 1) {
            // 一路
            if ([self.btnSetDic objectForKey:@(1)]) {
                NSNumber *index = [self.btnSetDic objectForKey:@(1)];
                UIButton *btn = [self.view viewWithTag:index.intValue];
                btn.selected = YES;
            }
        } else {
            // 二路
            if ([self.btnSetDic objectForKey:@(2)]) {
                NSNumber *index = [self.btnSetDic objectForKey:@(2)];
                UIButton *btn = [self.view viewWithTag:index.intValue];
                btn.selected = YES;
            }
        }
    }
    
}

- (IBAction)processSlideValueChanged:(UISlider *)sender {
    int value = (int)(sender.value * 100);
    self.processLabel.text = [NSString stringWithFormat:@"%d%%",value];
    NSString *meteValue = [NSString stringWithFormat:@"%d",value];
    self.processValueStr = meteValue;
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制状态时,拖动滑杆控制设备
        [self controlCurtainWithBasMeteId:GSHCurtain_PercentMeteId value:meteValue failBlock:^(NSError *error) {
            
        } successBlock:^{
            
        }];
    } 
}


#pragma mark - request
// 设备控制
- (void)controlCurtainWithBasMeteId:(NSString *)basMeteId
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


@end
