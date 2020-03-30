//
//  GSHDefenseListVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/5/23.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDefenseListVC.h"
#import "GSHDefensePlanListVC.h"
#import "GSHDefenseAddVC.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import <UINavigationController+TZM.h>
#import "IQKeyboardManager.h"
#import "GSHAlertManager.h"
#import "LGAlertView.h"
#import "GSHLackDefenseDeviceListVC.h"

@interface GSHDefenseListVC () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *deviceTypeTableView;
@property (weak, nonatomic) IBOutlet UIButton *defenseButton;
@property (weak, nonatomic) IBOutlet UIView *defenseStateView;
@property (weak, nonatomic) IBOutlet UIImageView *defenseStateImageView;
@property (weak, nonatomic) IBOutlet UILabel *defenseStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *defenseStateDesLabel;

@property (weak, nonatomic) IBOutlet UIButton *planButton;
@property (weak, nonatomic) IBOutlet UIButton *lackDeviceButton;
- (IBAction)addDevice:(UIButton *)sender;

@property (strong , nonatomic) NSMutableArray *deviceTypeArray;
@property (strong , nonatomic) NSArray *lackDeviceTypeArray;


@end

@implementation GSHDefenseListVC

+(instancetype)defenseListVC {
    GSHDefenseListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDefenseSB" andID:@"GSHDefenseListVC"];
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    self.planButton.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember ? YES : NO;
    [self getDeviceTypeList];
    
    [self getGlobalDefenceState];
}

#pragma mark - Lazy
- (IBAction)addDevice:(UIButton *)sender {
    GSHLackDefenseDeviceListVC *vc = [GSHLackDefenseDeviceListVC lackDefenseDeviceListVCWithList:self.lackDeviceTypeArray];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSMutableArray *)deviceTypeArray {
    if (!_deviceTypeArray) {
        _deviceTypeArray = [NSMutableArray array];
    }
    return _deviceTypeArray;
}

#pragma mark - method
- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addDefenseButtonClick:(id)sender {
    GSHDefensePlanListVC *defensePlanListVC = [GSHDefensePlanListVC defensePlanListVC];
    
    [self.navigationController pushViewController:defensePlanListVC animated:YES];
}

// 一键布防/撤防
- (IBAction)defenseButtonClick:(UIButton *)button {
    if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember){
        if (!button.selected) {
            [TZMProgressHUDManager showErrorWithStatus:@"家庭成员无撤防权限" inView:self.view];
        }else{
            [TZMProgressHUDManager showErrorWithStatus:@"家庭成员无开启权限" inView:self.view];
        }
        return;
    }
    if (!button.selected) {
        // 撤防操作
        [[IQKeyboardManager sharedManager] setEnable:NO];
        __weak typeof(self)weakSelf = self;
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            [[IQKeyboardManager sharedManager] setEnable:YES];
            if (buttonIndex == 1) {
                // 确定
                NSString *password;
                if([alert isKindOfClass:LGAlertView.class]){
                    UITextField *tf = (UITextField*)((LGAlertView*)alert).innerView;
                    if ([tf isKindOfClass:UITextField.class]) {
                        password = tf.text;
                    }
                }
                if (password.length > 0) {
                    @weakify(self)
                    // 校验密码
                    [TZMProgressHUDManager showWithStatus:@"操作中" inView:weakSelf.view];
                    [GSHDefenseDeviceTypeManager verifyPasswordWithPsd:password block:^(NSError * _Nonnull error) {
                        @strongify(self)
                        if (error) {
                            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                        } else {
                            [self setGlobalDefenceStateRequestWithDefenceState:@"0"];
                        }
                    }];
                } else {
                    [TZMProgressHUDManager showErrorWithStatus:@"未输入密码" inView:weakSelf.view];
                }
            }
        } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
            textField.placeholder = @"请输入登录密码";
            textField.font = [UIFont systemFontOfSize:14];
            textField.backgroundColor = [UIColor colorWithRGB:0xf0f0f0];
            textField.clipsToBounds = YES;
            textField.layer.cornerRadius = 3;
            textField.clearButtonMode = UITextFieldViewModeNever;
            textField.secureTextEntry = YES;
        } andTitle:@"确认要撤防吗？" andMessage:@"您正在进行撤防操作，撤防后防御设备告警或异常时将自动忽略不再提示，但仍可在消息模块中查看相关记录" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    } else {
        // 布防操作
        [TZMProgressHUDManager showWithStatus:@"操作中" inView:self.view];
        [self setGlobalDefenceStateRequestWithDefenceState:@"1"];
    }
    
}

- (void)refreshUIWithDefenseState:(NSNumber *)defenseState {
    self.view.backgroundColor = defenseState.intValue == 1 ? [UIColor colorWithHexString:@"#07C683"] : [UIColor colorWithHexString:@"#DEA759"];
    self.defenseStateView.backgroundColor = defenseState.intValue == 1 ? [UIColor colorWithHexString:@"#07C683"] : [UIColor colorWithHexString:@"#DEA759"];
    self.defenseStateImageView.image = defenseState.intValue == 1 ? [UIImage ZHImageNamed:@"defense_state_defenceImage"] : [UIImage ZHImageNamed:@"defense_state_unDefenceImage"];
    self.defenseStateLabel.text = defenseState.intValue == 1 ? @"正在防御中" : @"已经撤防";
    self.defenseStateDesLabel.text = defenseState.intValue == 1 ? @"可一键撤防" : @"可一键布防";
    self.defenseButton.selected = !(defenseState.intValue == 1);
}


#pragma mark - request
// 请求设备品类
- (void)getDeviceTypeList {
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHDefenseDeviceTypeManager getDefenseDeviceTypeWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSArray<GSHDefenseDeviceTypeM *> * _Nonnull list, NSArray<GSHDefenseDeviceTypeM *> * _Nonnull lackDeviceList, NSError * _Nonnull error){
        @strongify(self)
        [TZMProgressHUDManager dismissInView:self.view];
        if (error) {
            [self.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [self getDeviceTypeList];
            }];
        } else {
            self.lackDeviceTypeArray = lackDeviceList;
            if (list.count == 0) {
                [self.deviceTypeTableView showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:@"请增加安防设备，提升防御等级" desc:nil buttonText:@"添加" didClickButtonCallback:^(TZMPageStatus status) {
                    [self addDevice:nil];
                }];
                return;
            }
            if (self.lackDeviceTypeArray.count > 0) {
                self.lackDeviceButton.hidden = NO;
                [self.lackDeviceButton setTitle:[NSString stringWithFormat:@"当前暂缺%d款防御设备，请查看！",(int)(self.lackDeviceTypeArray.count)] forState:UIControlStateNormal];
            }else{
                self.lackDeviceButton.hidden = YES;
            }
            [self.view dismissPageStatusView];
            [self.deviceTypeArray addObjectsFromArray:list];
            [self.deviceTypeTableView reloadData];
        }
    }];
}

// 查询全局防御状态
- (void)getGlobalDefenceState {
    @weakify(self)
    [GSHDefenseDeviceTypeManager getGlobalDefenceStateWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSNumber * _Nonnull defenceState, NSError * _Nonnull error) {
        @strongify(self)
        if (!error) {
            [self refreshUIWithDefenseState:defenceState];
        }
    }];
}

// 设置全局防御状态
- (void)setGlobalDefenceStateRequestWithDefenceState:(NSString *)defenceState {
    @weakify(self)
    [GSHDefenseDeviceTypeManager setGlobalDefenceStateWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId defenceState:defenceState block:^(NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            if (defenceState.intValue == 0) {
                [TZMProgressHUDManager showSuccessWithStatus:@"撤防成功" inView:self.view];
                self.defenseButton.selected = defenceState.intValue == YES;
            } else {
                [TZMProgressHUDManager showSuccessWithStatus:@"防御成功" inView:self.view];
                self.defenseButton.selected = defenceState.intValue == NO;
            }
            // 刷新显示界面
            [self refreshUIWithDefenseState:[NSNumber numberWithString:defenceState]];
            for (GSHDefenseDeviceTypeM *defenseDeviceTypeM in self.deviceTypeArray) {
                defenseDeviceTypeM.defenceState = defenceState;
            }
            [self.deviceTypeTableView reloadData];
        }
    }];
}

// 设置防御状态
- (void)setDefenceStateWithDefenseDeviceTypeM:(GSHDefenseDeviceTypeM *)deviceTypeM rowIndex:(int)rowIndex {
    GSHDefenseListCell *cell = [self.deviceTypeTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0]];
    NSString *defenseState = cell.defenceStateButton.selected ? @"1" : @"0";
    __weak typeof(cell) weakCell = cell;
    [TZMProgressHUDManager showWithStatus:@"操作中" inView:self.view];
    @weakify(self)
    [GSHDefenseDeviceTypeManager setDefenceStateWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceType:deviceTypeM.deviceType defenceState:defenseState block:^(NSError * _Nonnull error) {
        __strong typeof(weakCell) strongCell = weakCell;
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"操作成功" inView:self.view];
            strongCell.defenceStateButton.selected = [defenseState isEqualToString:@"0"] ? YES : NO;
            strongCell.defenceStateLabel.text = [defenseState isEqualToString:@"0"] ? @"已撤防" : @"防御中";
            deviceTypeM.defenceState = defenseState;
            [self getGlobalDefenceState];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceTypeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHDefenseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHDefenseListCell" forIndexPath:indexPath];
    if (self.deviceTypeArray.count > indexPath.row) {
        GSHDefenseDeviceTypeM *deviceTypeM = self.deviceTypeArray[indexPath.row];
        [cell layoutCellWithDeviceTypeM:deviceTypeM];
        @weakify(self)
        cell.defenceStateButtonClickBlock = ^(UIButton * _Nonnull button) {
            @strongify(self)
            if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember){
                if (!button.selected) {
                    [TZMProgressHUDManager showErrorWithStatus:@"家庭成员无撤防权限" inView:self.view];
                }else{
                    [TZMProgressHUDManager showErrorWithStatus:@"家庭成员无开启权限" inView:self.view];
                }
                return;
            }
            if (!button.selected) {
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        [self setDefenceStateWithDefenseDeviceTypeM:deviceTypeM rowIndex:(int)indexPath.row];
                    }
                } textFieldsSetupHandler:nil andTitle:nil andMessage:@"撤防后，此类安防设备报警时，将无法收到推送，请谨慎操作" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
            } else {
                [self setDefenceStateWithDefenseDeviceTypeM:deviceTypeM rowIndex:(int)indexPath.row];
            }
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
        return;
    }
    GSHDefenseDeviceTypeM *deviceTypeM = self.deviceTypeArray[indexPath.row];
    if (deviceTypeM.enableFlag.integerValue == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"家庭下无此类设备" inView:self.view];
        return;
    }
    GSHDefenseAddVC *addVC = [GSHDefenseAddVC defenseAddVCWithDefenseDeviceTypeM:deviceTypeM typeName:deviceTypeM.typeName];
    
    [self.navigationController pushViewController:addVC animated:YES];
}

@end


@interface GSHDefenseListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *defenseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *noDeviceFlagLabel;

@end

@implementation GSHDefenseListCell


- (void)layoutCellWithDeviceTypeM:(GSHDefenseDeviceTypeM *)deviceTypeM {
    [self.deviceImageView sd_setImageWithURL:[NSURL URLWithString:deviceTypeM.picPath] placeholderImage:DeviceIconPlaceHoldImage];
    self.defenseNameLabel.text = deviceTypeM.typeName;
    if (deviceTypeM.enableFlag.integerValue == 0) {
        // 无此类设备
        self.noDeviceFlagLabel.hidden = NO;
        self.defenceStateButton.hidden = YES;
        self.defenceStateLabel.text = @"暂无此类设备";
    } else {
        // 有此类设备 判断状态
        self.noDeviceFlagLabel.hidden = YES;
        self.defenceStateButton.hidden = NO;
        self.defenceStateButton.selected = [deviceTypeM.defenceState isEqualToString:@"1"] ? NO : YES;
        self.defenceStateLabel.text = [deviceTypeM.defenceState isEqualToString:@"1"] ? @"防御中" : @"已撤防";
    }
}

- (IBAction)defenceStateButtonClick:(UIButton *)sender {
    if (self.defenceStateButtonClickBlock) {
        self.defenceStateButtonClickBlock(sender);
    }
}

@end
