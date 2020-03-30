//
//  GSHDefenceAlarmAuthVC.m
//  SmartHome
//
//  Created by zhanghong on 2020/2/27.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDefenceAlarmAuthVC.h"
#import "GSHDefenceAlarmAuthBindHouseListVC.h"
#import "GSHPickerView.h"
#import "GSHAlertManager.h"

@interface GSHDefenceAlarmAuthVC ()

@property (weak, nonatomic) IBOutlet UIButton *selectSmartHomeHouseButton;
@property (weak, nonatomic) IBOutlet UIButton *selectEnjoyHomeHouseButton;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;
@property (weak, nonatomic) IBOutlet UISwitch *authSwitch;

@property (strong , nonatomic) NSNumber *selectSmartHomeFamilyId;
@property (strong , nonatomic) NSNumber *selectMhouseId;


@end

@implementation GSHDefenceAlarmAuthVC

+(instancetype)defenceAlarmAuthVC {
    GSHDefenceAlarmAuthVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDefenceAlarmAuthSB" andID:@"GSHDefenceAlarmAuthVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.selectSmartHomeFamilyId = [GSHOpenSDKShare share].currentFamily.familyId.numberValue;
    
    [self.selectSmartHomeHouseButton setTitle:[GSHOpenSDKShare share].currentFamily.familyName forState:UIControlStateNormal];
    
    // 获取绑定详情
    [self getFamilyBindDetailInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId];
    
}

#pragma mark - UI
// 有绑定房屋 的按钮UI状态
- (void)refreshUIWhenBindHouse {
    [self.selectEnjoyHomeHouseButton setTitleColor:[UIColor colorWithHexString:@"#07C683"] forState:UIControlStateNormal];
    self.selectEnjoyHomeHouseButton.layer.borderColor = [UIColor colorWithHexString:@"#07C683"].CGColor;
    [self.selectEnjoyHomeHouseButton setImage:nil forState:UIControlStateNormal];
    self.bindButton.selected = YES;
}

// 无绑定房屋 的按钮UI状态
- (void)refreshUIWhenNoBindHouse {
    [self.selectEnjoyHomeHouseButton setTitle:@"绑定房屋" forState:UIControlStateNormal];
    [self.selectEnjoyHomeHouseButton setTitleColor:[UIColor colorWithHexString:@"#3C4366"] forState:UIControlStateNormal];
    self.selectEnjoyHomeHouseButton.layer.borderColor = [UIColor colorWithHexString:@"#3C4366"].CGColor;
    [self.selectEnjoyHomeHouseButton setImage:[UIImage ZHImageNamed:@"defenceAuth_add"] forState:UIControlStateNormal];
    self.bindButton.selected = NO;
}

#pragma mark - method

// 家居家庭选择
- (IBAction)selectSmartHomeFamilyClick:(id)sender {
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < [GSHOpenSDKShare share].familyList.count; i ++) {
        GSHFamilyM *familyM = [GSHOpenSDKShare share].familyList[i];
        [arr addObject:familyM.familyName];
    }
    
    [GSHPickerView
    showPickerViewContainResetButtonWithDataArray:arr
    cancelBenTitle:@"取消"
    cancelBenTitleColor:[UIColor colorWithHexString:@"#999999"]
    sureBtnTitle:@"确定"
    cancelBlock:^{
       // 取消
       
    } completion:^(NSString *selectContent , NSArray *selectRowArray) {
        NSInteger index = [arr indexOfObject:selectContent];
        self.selectSmartHomeFamilyId = [GSHOpenSDKShare share].familyList[index].familyId.numberValue;
        [self.selectSmartHomeHouseButton setTitle:selectContent forState:UIControlStateNormal];
        // 请求相应家庭 与享家房屋的绑定详情
        [self getFamilyBindDetailInfoWithFamilyId:self.selectSmartHomeFamilyId.stringValue];
    }];
}

// 享家房屋选择
- (IBAction)selectEnjoyHomeHouseClick:(id)sender {
    GSHDefenceAlarmAuthBindHouseListVC *defenceAlarmAuthBindHouseListVC = [GSHDefenceAlarmAuthBindHouseListVC defenceAlarmAuthBindHouseListVCWithSmartHomeFamilyId:self.selectSmartHomeFamilyId SelectHouseId:self.selectMhouseId];
    @weakify(self)
    defenceAlarmAuthBindHouseListVC.saveBlock = ^(GSHSDKEnjoyHomeHouseM *houseM) {
        @strongify(self)
        self.selectMhouseId = houseM.userHouseId;
        [self.selectEnjoyHomeHouseButton setTitle:houseM.houseName forState:UIControlStateNormal];
        [self.selectEnjoyHomeHouseButton setTitleColor:[UIColor colorWithHexString:@"#07C683"] forState:UIControlStateNormal];
        self.selectEnjoyHomeHouseButton.layer.borderColor = [UIColor colorWithHexString:@"#07C683"].CGColor;
        [self.selectEnjoyHomeHouseButton setImage:nil forState:UIControlStateNormal];
        self.bindButton.selected = YES;
    };
    [self.navigationController pushViewController:defenceAlarmAuthBindHouseListVC animated:YES];
}

- (IBAction)bindButtonClick:(UIButton *)button {
    if (button.selected) {
        // 解绑
        @weakify(self)
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            @strongify(self)
            if (buttonIndex == 1) {
                // 确定 -- 执行解绑操作
                [self unBindHouseWithHouseId:self.selectMhouseId.stringValue];
            }
        } textFieldsSetupHandler:NULL andTitle:@"确认解绑享家房屋?" andMessage:@"解绑后物业中心将无法收到安防告警消息" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
    }
}

- (IBAction)authSwitchClick:(UISwitch *)authSwitch {
    
    if (!self.selectMhouseId) {
        [TZMProgressHUDManager showInfoWithStatus:@"请先绑定享家房屋" inView:self.view];
        authSwitch.on = NO;
        return;
    }
    [self changeAlarmSwitchStatusWithPropertySwitch:[NSString stringWithFormat:@"%d",authSwitch.on]];
}


#pragma mark - request
// 获取绑定详情
- (void)getFamilyBindDetailInfoWithFamilyId:(NSString *)familyId {
    
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [GSHSDKEnjoyHomeHouseManager getBindDetailInfoWithFamilyId:familyId block:^(GSHSDKEnjoyHomeHouseBindInfoM *bindInfoM, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            // 请求到绑定结果
            if (bindInfoM.mhomeId && bindInfoM.mhomeName.length > 0) {
                // 有绑定享家房屋
                [self.selectEnjoyHomeHouseButton setTitle:bindInfoM.mhomeName forState:UIControlStateNormal];
                [self refreshUIWhenBindHouse];
                self.authSwitch.on = bindInfoM.propertySwitch.intValue == 0 ? NO : YES;
                self.selectMhouseId = bindInfoM.mhomeId;
            } else {
                // 没有绑定享家房屋
                self.selectMhouseId = bindInfoM.mhomeId;
                [self refreshUIWhenNoBindHouse];
                self.authSwitch.on = NO;
            }
        }
    }];
    
}

// 解绑
- (void)unBindHouseWithHouseId:(NSString *)mHouseId {
    
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"解绑中" inView:self.view];
    [GSHSDKEnjoyHomeHouseManager unBindEnjoyHomeHouseWithMHouseId:mHouseId block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"解绑成功" inView:self.view];
            self.selectMhouseId = nil;
            [self refreshUIWhenNoBindHouse];
            self.authSwitch.on = NO;
        }
    }];
}

// 改变通知物业告警消息的开关状态
- (void)changeAlarmSwitchStatusWithPropertySwitch:(NSString *)propertySwitch {
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"修改中" inView:self.view];
    [GSHSDKEnjoyHomeHouseManager changeAlarmSwitchStatusWithFamilyId:self.selectSmartHomeFamilyId.stringValue propertySwitch:propertySwitch block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"修改成功" inView:self.view];
        }
    }];
    
}



@end
