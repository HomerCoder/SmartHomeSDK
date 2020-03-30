//
//  GSHSettingVC.m
//  SmartHome
//
//  Created by gemdale on 2019/11/19.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHSettingVC.h"
#import "GSHAlertManager.h"
#import "GSHUserSafetyVC.h"
#import "GSHGateWayUpdateVC.h"
#import "GSHAddGWGuideVC.h"
#import "GSHGatewayCopyRestoreVC.h"
#import "GSHAboutVC.h"
#import "GSHControlSwitchVC.h"
#import "GSHVoiceSettingVC.h"

@interface GSHSettingVCCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@end
@implementation GSHSettingVCCell
@end

@interface GSHSettingVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *loginOutButton;
- (IBAction)touchLogout:(UIButton *)sender;

@end

@implementation GSHSettingVC

+(instancetype)settingVC{
    return [GSHPageManager viewControllerWithSB:@"SettingSB" andID:@"GSHSettingVC"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        self.loginOutButton.alpha = 0.2;
        self.loginOutButton.enabled = NO;
    } else {
        self.loginOutButton.alpha = 1;
        self.loginOutButton.enabled = YES;
    }
}

- (IBAction)touchLogout:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1) {
            [TZMProgressHUDManager showWithStatus:@"退出登录中" inView:weakSelf.view];
            [GSHUserManager postLogoutWithBlock:^(NSError *error) {
                if(error){
                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                }else{
                    [TZMProgressHUDManager showSuccessWithStatus:@"已退出" inView:weakSelf.view];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"退出登录后将无法控制设备，\n您确认要退出吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else if (section == 1){
        return 4;
    }else{
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section == 1 && indexPath.row == 3) || (indexPath.section == 1 && indexPath.row == 1)) {
        if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
            return 0;
        } else {
            return 55;
        }
    }else{
        return 55;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHSettingVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.lblText.text = @"账号与安全";
                break;
            case 1:
                cell.lblText.text = @"语音设置";
                break;
            default:
                break;
        }
    }else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                cell.lblText.text = @"控制切换";
                break;
            case 1:
                cell.lblText.text = @"网关重启";
                break;
            case 2:
                cell.lblText.text = @"固件更新";
                break;
            case 3:
                cell.lblText.text = @"网关替换";
                break;
            case 4:
                cell.lblText.text = @"备份与恢复";
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                cell.lblText.text = @"关于智享Home";
                break;
            default:
                break;
        }
    }
    if (!(indexPath.section == 1 && indexPath.row == 0)) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            cell.contentView.alpha = 0.2;
        } else {
            cell.contentView.alpha = 1;
        }
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN && !(indexPath.section == 1 && indexPath.row == 0)) {
        return nil;
    }
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self.navigationController pushViewController:[GSHUserSafetyVC userSafetyVC] animated:YES];
                break;
            case 1:
                [self.navigationController pushViewController:[GSHVoiceSettingVC voiceSettingVC] animated:YES];
                break;
            default:
                break;
        }
    }else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                [self.navigationController pushViewController:[GSHControlSwitchVC controlSwitchVC] animated:YES];
                break;
            case 1:
                if ([GSHOpenSDKShare share].currentFamily.gatewayId.length > 0) {
                    __weak typeof(self)weakSelf = self;
                    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                        if (buttonIndex == 1) {
                            [TZMProgressHUDManager showWithStatus:@"重启网关中" inView:weakSelf.view];
                            [GSHGatewayManager resetGatewayWithGatewayId:[GSHOpenSDKShare share].currentFamily.gatewayId block:^(NSError *error) {
                                if (error) {
                                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                                }else{
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [TZMProgressHUDManager dismissInView:weakSelf.view];
                                    });
                                }
                            }];
                        }
                    } textFieldsSetupHandler:NULL andTitle:@"确定重启网关吗？" andMessage:@"重启网关中设备将无法控制" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"立即重启",nil];
                }else{
                    [TZMProgressHUDManager showErrorWithStatus:@"请先添加网关" inView:self.view];
                }
                break;
            case 2:
                if ([GSHOpenSDKShare share].currentFamily.gatewayId.length > 0) {
                    [self.navigationController pushViewController:[GSHGateWayUpdateVC gateWayUpdateVC] animated:YES];
                }else{
                    [TZMProgressHUDManager showErrorWithStatus:@"请先添加网关" inView:self.view];
                }
                break;
            case 3:
                if ([GSHOpenSDKShare share].currentFamily.gatewayId.length > 0) {
                    [self.navigationController pushViewController:[GSHAddGWGuideVC addGWGuideVCWithFamily:[GSHOpenSDKShare share].currentFamily deviceModel:nil sn:nil] animated:YES];
                }else{
                    [TZMProgressHUDManager showErrorWithStatus:@"请先添加网关" inView:self.view];
                }
                break;
            case 4:
                if ([GSHOpenSDKShare share].currentFamily.gatewayId.length > 0) {
                    [self.navigationController pushViewController:[GSHGatewayCopyRestoreVC gateWayCopyRestoreVC] animated:YES];
                }else{
                    [TZMProgressHUDManager showErrorWithStatus:@"请先添加网关" inView:self.view];
                }
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                [self.navigationController pushViewController:[GSHAboutVC aboutVC] animated:YES];
                break;
            default:
                break;
        }
    }
    return nil;
}
@end
