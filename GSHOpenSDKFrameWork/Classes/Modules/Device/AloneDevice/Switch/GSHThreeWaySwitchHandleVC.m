//
//  GSHThreeWaySwitchHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/6.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHThreeWaySwitchHandleVC.h"
#import "UIView+TZM.h"
#import "UINavigationController+TZM.h"
#import "GSHDeviceEditVC.h"
#import "NSObject+TZM.h"

@interface GSHThreeWaySwitchHandleVC ()

@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;
@property (weak, nonatomic) IBOutlet UIView *firstSwitchView;
@property (weak, nonatomic) IBOutlet UILabel *firstSwitchNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *firstSwitch;
@property (weak, nonatomic) IBOutlet UIButton *firstCheckButton;

@property (weak, nonatomic) IBOutlet UIView *secondSwitchView;
@property (weak, nonatomic) IBOutlet UILabel *secondSwitchNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *secondSwitch;
@property (weak, nonatomic) IBOutlet UIButton *secondCheckButton;

@property (weak, nonatomic) IBOutlet UIView *thirdSwitchView;
@property (weak, nonatomic) IBOutlet UILabel *thirdSwitchNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *thirdSwitch;
@property (weak, nonatomic) IBOutlet UIButton *thirdCheckButton;

@property (weak, nonatomic) IBOutlet UILabel *switchNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *switchIconImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstCheckButtonLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondCheckButtonLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdCheckButtonLeading;
@property (nonatomic,strong) NSArray *exts;

@end

@implementation GSHThreeWaySwitchHandleVC

+ (instancetype)threeWaySwitchHandleVCWithDeviceM:(GSHDeviceM*)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHThreeWaySwitchHandleVC *vc = [GSHPageManager viewControllerWithSB:@"GSHThreeWaySwitchHandleSB" andID:@"GSHThreeWaySwitchHandleVC"];
    vc.deviceM = deviceM;
    vc.deviceEditType = deviceEditType;
    vc.exts = deviceM.exts;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tzm_prefersNavigationBarHidden = YES;
    
    [self layoutUI];
    
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
- (void)layoutUI {
    
    if (self.switchType == SwitchHandleVCTypeOneWay) {
        // 一路智能开关
        self.firstSwitchView.hidden = YES;
        self.secondSwitchView.hidden = NO;
        self.thirdSwitchView.hidden = YES;
        self.switchNameLabel.text = @"一路开关";
    } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
        // 二路智能开关
        self.firstSwitchView.hidden = NO;
        self.secondSwitchView.hidden = NO;
        self.thirdSwitchView.hidden = YES;
        self.switchNameLabel.text = @"二路开关";
    } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
        // 三路智能开关
        self.firstSwitchView.hidden = NO;
        self.secondSwitchView.hidden = NO;
        self.thirdSwitchView.hidden = NO;
        self.switchNameLabel.text = @"三路开关";
    }
    
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"" : @"确定";
    NSString *buttonImageName = self.deviceEditType == GSHDeviceVCTypeControl ? @"device_set_btn" : @"";
    [self.rightNaviButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    [self.rightNaviButton setImage:[UIImage ZHImageNamed:buttonImageName] forState:UIControlStateNormal];
    self.rightNaviButton.hidden = ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        self.firstCheckButton.hidden = YES;
        self.secondCheckButton.hidden = YES;
        self.thirdCheckButton.hidden = YES;
        self.firstCheckButtonLeading.constant = 0;
        self.secondCheckButtonLeading.constant = 0;
        self.thirdCheckButtonLeading.constant = 0;
        self.firstSwitch.alpha = 1;
        self.secondSwitch.alpha = 1;
        self.thirdSwitch.alpha = 1;
    }
    
}

- (void)refreshUI {
    
    self.switchNameLabel.text = self.deviceM.deviceName;
    [self.switchIconImageView sd_setImageWithURL:[NSURL URLWithString:self.deviceM.controlPicPath] placeholderImage:GlobalPlaceHoldImage];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        NSDictionary *dic = [self.deviceM realTimeDic];
        if (self.switchType == SwitchHandleVCTypeOneWay) {
            // 一路智能开关
            if (self.deviceM.attribute.count > 0) {
                GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.deviceM.attribute[0];
                self.secondSwitchNameLabel.text = attributeM.meteName;
                id value = [dic objectForKey:attributeM.basMeteId];
                self.secondSwitch.on = value ? [value intValue] : 0;
                self.secondSwitch.tag = 1;
            }
        } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
            // 二路智能开关
            if (self.deviceM.attribute.count > 1) {
                for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                    id value = [dic objectForKey:attributeM.basMeteId];
                    if (attributeM.meteIndex.intValue == 1) {
                        self.firstSwitchNameLabel.text = attributeM.meteName;
                        self.firstSwitch.on = value ? [value intValue] : 0;
                        self.firstSwitch.tag = 1;
                    } else if (attributeM.meteIndex.intValue == 2) {
                        self.secondSwitchNameLabel.text = attributeM.meteName;
                        self.secondSwitch.on = value ? [value intValue] : 0;
                        self.secondSwitch.tag = 2;
                    }
                }
            }
        } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
            // 三路智能开关
            if (self.deviceM.attribute.count > 2) {
                for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                    id value = [dic objectForKey:attributeM.basMeteId];
                    if (attributeM.meteIndex.intValue == 1) {
                        self.firstSwitchNameLabel.text = attributeM.meteName;
                        self.firstSwitch.on = value ? [value intValue] : 0;
                        self.firstSwitch.tag = 1;
                    } else if (attributeM.meteIndex.intValue == 2) {
                        self.secondSwitchNameLabel.text = attributeM.meteName;
                        self.secondSwitch.on = value ? [value intValue] : 0;
                        self.secondSwitch.tag = 2;
                    } else if (attributeM.meteIndex.intValue == 3) {
                        self.thirdSwitchNameLabel.text = attributeM.meteName;
                        self.thirdSwitch.on = value ? [value intValue] : 0;
                        self.thirdSwitch.tag = 3;
                    }
                }
            }
        }
    } else {
        if (self.switchType == SwitchHandleVCTypeOneWay) {
            // 一路智能开关
            if (self.deviceM.attribute.count > 0) {
                GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.deviceM.attribute[0];
                self.secondSwitchNameLabel.text = attributeM.meteName;
                self.secondSwitch.tag = 1;
            }
        } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
            // 二路智能开关
            if (self.deviceM.attribute.count > 1) {
                for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                    if (attributeM.meteIndex.intValue == 1) {
                        self.firstSwitchNameLabel.text = attributeM.meteName;
                        self.firstSwitch.tag = 1;
                    } else if (attributeM.meteIndex.intValue == 2) {
                        self.secondSwitchNameLabel.text = attributeM.meteName;
                        self.secondSwitch.tag = 2;
                    }
                }
            }
        } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
            // 三路智能开关
            if (self.deviceM.attribute.count > 2) {
                for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                    if (attributeM.meteIndex.intValue == 1) {
                        self.firstSwitchNameLabel.text = attributeM.meteName;
                        self.firstSwitch.tag = 1;
                    } else if (attributeM.meteIndex.intValue == 2) {
                        self.secondSwitchNameLabel.text = attributeM.meteName;
                        self.secondSwitch.tag = 2;
                    } else if (attributeM.meteIndex.intValue == 3) {
                        self.thirdSwitchNameLabel.text = attributeM.meteName;
                        self.thirdSwitch.tag = 3;
                    }
                }
            }
        }
    }
}

#pragma mark - method

- (IBAction)switchButtonClick:(UISwitch *)gshSwitch {
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制
        NSInteger tag = gshSwitch.tag;
        if (self.deviceM.attribute.count >= tag && tag > 0) {
            GSHDeviceAttributeM *attributeM;
            for (GSHDeviceAttributeM *tmpAttributeM in self.deviceM.attribute) {
                if (tmpAttributeM.meteIndex.intValue == tag) {
                    attributeM = tmpAttributeM;
                }
            }
            if (!attributeM) {
                return;
            }
            NSString *value = [NSString stringWithFormat:@"%d",gshSwitch.on];
            [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue deviceSN:self.deviceM.deviceSn familyId:[GSHOpenSDKShare share].currentFamily.familyId basMeteId:attributeM.basMeteId value:value block:^(NSError *error) {
                if([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                    if (error) {
                        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
                        gshSwitch.on = !gshSwitch.on;
                    } 
                }
            }];
        }
    }
}

- (IBAction)enterDeviceEdit:(id)sender {

    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制 -- 进入设备
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            [TZMProgressHUDManager showInfoWithStatus:@"离线环境无法查看" inView:self.view];
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
        
        if (self.deviceEditType == GSHDeviceVCTypeSceneSet) {
            // scene set :  rightValue
            if (self.switchType == SwitchHandleVCTypeOneWay) {
                // 一路智能开关
                if (self.secondCheckButton.selected) {
                    // 选中
                    if (self.deviceM.attribute.count > 0) {
                        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                        GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.deviceM.attribute[0];
                        extM.conditionOperator = @"==";
                        extM.basMeteId = attributeM.basMeteId;
                        extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                        [exts addObject:extM];
                    }
                } else {
                    [TZMProgressHUDManager showErrorWithStatus:@"请选中开关按钮" inView:self.view];
                    return;
                }
            } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
                // 二路开关
                if (self.deviceM.attribute.count > 1) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.firstCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.firstSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [TZMProgressHUDManager showErrorWithStatus:@"请选中开关按钮" inView:self.view];
                        return;
                    }
                }
            } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
                // 三路开关
                if (self.deviceM.attribute.count > 2) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.firstCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.firstSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 3 && self.thirdCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [TZMProgressHUDManager showErrorWithStatus:@"请选中开关按钮" inView:self.view];
                        return;
                    }
                }
            }
        } else if (self.deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
            // auto trigger :  operator rightValue
            if (self.switchType == SwitchHandleVCTypeOneWay) {
                // 一路智能开关
                if (self.deviceM.attribute.count > 0) {
                    if (self.secondCheckButton.selected) {
                        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                        GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.deviceM.attribute[0];
                        extM.basMeteId = attributeM.basMeteId;
                        extM.conditionOperator = @"==";
                        extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                        [exts addObject:extM];
                    } else {
                        [TZMProgressHUDManager showErrorWithStatus:@"请选中开关按钮" inView:self.view];
                        return;
                    }
                }
            } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
                // 二路开关
                if (self.deviceM.attribute.count > 1) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.firstCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.firstSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [TZMProgressHUDManager showErrorWithStatus:@"请选中开关按钮" inView:self.view];
                        return;
                    }
                }
            } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
                // 三路开关
                if (self.deviceM.attribute.count > 2) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.firstCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.firstSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 3 && self.thirdCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [TZMProgressHUDManager showErrorWithStatus:@"请选中开关按钮" inView:self.view];
                        return;
                    }
                }
            }
        } else if (self.deviceEditType == GSHDeviceVCTypeAutoActionSet) {
            // auto action :  param
            if (self.switchType == SwitchHandleVCTypeOneWay) {
                // 一路智能开关
                if (self.deviceM.attribute.count > 0) {
                    if (self.secondCheckButton.selected) {
                        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                        GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.deviceM.attribute[0];
                        extM.basMeteId = attributeM.basMeteId;
                        extM.conditionOperator = @"==";
                        extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                        [exts addObject:extM];
                    } else {
                        [TZMProgressHUDManager showErrorWithStatus:@"请选中开关按钮" inView:self.view];
                        return;
                    }
                }
            } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
                // 二路开关
                if (self.deviceM.attribute.count > 1) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.firstCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.firstSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [TZMProgressHUDManager showErrorWithStatus:@"请选中开关按钮" inView:self.view];
                        return;
                    }
                }
            } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
                // 三路开关
                if (self.deviceM.attribute.count > 2) {
                    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                        if (attributeM.meteIndex.intValue == 1 && self.firstCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.firstSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 2 && self.secondCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.secondSwitch.on];
                            [exts addObject:extM];
                        } else if (attributeM.meteIndex.intValue == 3 && self.thirdCheckButton.selected) {
                            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
                            extM.basMeteId = attributeM.basMeteId;
                            extM.conditionOperator = @"==";
                            extM.rightValue = [NSString stringWithFormat:@"%d",self.thirdSwitch.on];
                            [exts addObject:extM];
                        }
                    }
                    if (exts.count == 0) {
                        [TZMProgressHUDManager showErrorWithStatus:@"请选中开关按钮" inView:self.view];
                        return;
                    }
                }
            }
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
    [self refreshUI];
}

- (IBAction)firstCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.firstSwitch.alpha = sender.selected ? 1 : 0.5;
    self.firstSwitch.enabled = sender.selected ? YES : NO;
}

- (IBAction)secondCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.secondSwitch.alpha = sender.selected ? 1 : 0.5;
    self.secondSwitch.enabled = sender.selected ? YES : NO;
}

- (IBAction)thirdCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.thirdSwitch.alpha = sender.selected ? 1 : 0.5;
    self.thirdSwitch.enabled = sender.selected ? YES : NO;
}

#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceSign:nil block:^(GSHDeviceM *device, NSError *error) {
        @strongify(self)
        if (!error) {
            self.deviceM = device;
            [self refreshUI];
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
                [self refreshSwitchOpenStatus];
            }
        }
    }];
}

// 改变开关状态
- (void)refreshSwitchOpenStatus {
    self.firstSwitch.enabled = NO;
    self.secondSwitch.enabled = NO;
    self.thirdSwitch.enabled = NO;
    if (self.switchType == SwitchHandleVCTypeOneWay) {
        // 一路智能开关
        GSHDeviceExtM *extM = self.deviceM.exts[0];
        self.secondSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
        self.secondCheckButton.selected = YES;
        self.secondSwitch.alpha = 1;
        self.secondSwitch.enabled = YES;
    } else if (self.switchType == SwitchHandleVCTypeTwoWay) {
        // 二路智能开关
        for (GSHDeviceExtM *extM in self.deviceM.exts) {
            if ([extM.basMeteId isEqualToString:@"04000100060001"]) {
                // 一路
                self.firstSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
                self.firstCheckButton.selected = YES;
                self.firstSwitch.alpha = 1;
                self.firstSwitch.enabled = YES;
            } else if ([extM.basMeteId isEqualToString:@"04000100060002"]) {
                // 二路
                self.secondSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
                self.secondCheckButton.selected = YES;
                self.secondSwitch.alpha = 1;
                self.secondSwitch.enabled = YES;
            }
        }
    } else if (self.switchType == SwitchHandleVCTypeThreeWay) {
        // 三路智能开关
        for (GSHDeviceExtM *extM in self.deviceM.exts) {
            if ([extM.basMeteId isEqualToString:@"04000200060001"]) {
                // 一路
                self.firstSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
                self.firstCheckButton.selected = YES;
                self.firstSwitch.alpha = 1;
                self.firstSwitch.enabled = YES;
            } else if ([extM.basMeteId isEqualToString:@"04000200060002"]) {
                // 二路
                self.secondSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
                self.secondCheckButton.selected = YES;
                self.secondSwitch.alpha = 1;
                self.secondSwitch.enabled = YES;
            } else if ([extM.basMeteId isEqualToString:@"04000200060003"]) {
                // 三路
                self.thirdSwitch.on = extM.rightValue?[extM.rightValue intValue]:(extM.param?[extM.param intValue]:0);
                self.thirdCheckButton.selected = YES;
                self.thirdSwitch.alpha = 1;
                self.thirdSwitch.enabled = YES;
            }
        }
    }
}

@end
