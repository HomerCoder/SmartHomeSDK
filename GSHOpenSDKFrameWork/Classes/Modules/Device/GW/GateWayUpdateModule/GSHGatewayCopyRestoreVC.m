//
//  GSHGatewayCopyRestoreVC.m
//  SmartHome
//
//  Created by gemdale on 2019/6/3.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHGatewayCopyRestoreVC.h"
#import "GSHAlertManager.h"

@interface GSHGatewayCopyRestoreVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblSize;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UIButton *btnHuiFu;
- (IBAction)touchCopy:(UIButton *)sender;
- (IBAction)touchRestore:(UIButton *)sender;
@end

@implementation GSHGatewayCopyRestoreVC

+ (instancetype)gateWayCopyRestoreVC{
    GSHGatewayCopyRestoreVC *vc = [GSHPageManager viewControllerWithSB:@"GSHGateWaySettingSB" andID:@"GSHGatewayCopyRestoreVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self update];
}

-(void)update{
    __weak typeof(self)weakSelf = self;
    [GSHGatewayManager getCopyGatewayWithGatewayId:[GSHOpenSDKShare share].currentFamily.gatewayId familyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSError *error, NSDictionary *dic) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
//            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            NSString *createTime = [dic stringValueForKey:@"createTime" default:nil];
            NSString *fileSize = [dic stringValueForKey:@"fileSize" default:nil];
            if (createTime.intValue > 0) {
                weakSelf.btnHuiFu.enabled = YES;
                weakSelf.lblTime.text = [[NSDate dateWithTimeIntervalSince1970:createTime.doubleValue / 1000] stringWithFormat:@"yyyy/M/d HH:mm"];;
            }else{
                weakSelf.btnHuiFu.enabled = NO;
                weakSelf.lblTime.text = @"无备份文件";
            }
            weakSelf.lblSize.text = fileSize;
        }
    }];
}

-(void)gatewayCopy{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"正在备份数据中" inView:self.view];
    self.lblText.hidden = NO;
    [GSHGatewayManager copyGatewayWithGatewayId:[GSHOpenSDKShare share].currentFamily.gatewayId familyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSError *error) {
        weakSelf.lblText.hidden = YES;
        if (error) {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                if (buttonIndex == 2) {
                    [weakSelf gatewayCopy];
                }
            } textFieldsSetupHandler:NULL andTitle:@"备份失败" andMessage:error.localizedDescription image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"重新备份" otherButtonTitles:@"保持现状",nil];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"备份成功" inView:weakSelf.view];
            [weakSelf update];
        }
    }];
}

-(void)gatewayRestore{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"网关数据恢复中" inView:self.view];
    [GSHGatewayManager recoveryGatewayWithGatewayId:[GSHOpenSDKShare share].currentFamily.gatewayId familyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                if (buttonIndex == 2) {
                    [weakSelf gatewayRestore];
                }
            } textFieldsSetupHandler:NULL andTitle:@"恢复失败" andMessage:error.localizedDescription image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"重新恢复" otherButtonTitles:@"保持现状",nil];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"恢复成功" inView:weakSelf.view];
            [weakSelf.tabBarController setSelectedIndex:0];
            [weakSelf.navigationController popToRootViewControllerAnimated:NO];
        }
    }];
}

- (IBAction)touchCopy:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1) {
            [weakSelf gatewayCopy];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"此操作会备份数据，并替换当前备份文件，仍然进行" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
}

- (IBAction)touchRestore:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1) {
            [weakSelf gatewayRestore];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"此操作会覆盖当前网关所有数据，需谨慎使用，确认恢复" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
}
@end
