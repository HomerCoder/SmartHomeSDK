//
//  GSHNewSinglePasswordVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHNewSinglePasswordVC.h"
#import "GSHSinglePasswordListVC.h"
#import "GSHAlertManager.h"
#import "GSHDoorLockManager.h"
#import "GSHSinglePasswordVC.h"

@interface GSHNewSinglePasswordVC ()
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
- (IBAction)touchRandom:(id)sender;
- (IBAction)touchSure:(id)sender;
- (IBAction)touchNav:(id)sender;
- (IBAction)touchTime:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic)GSHDeviceM *device;
@property (assign, nonatomic)NSInteger time;
@end

@implementation GSHNewSinglePasswordVC
+(instancetype)newSinglePasswordVCWithDevice:(GSHDeviceM*)device{
    GSHNewSinglePasswordVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoorLackSB" andID:@"GSHNewSinglePasswordVC"];
    vc.device = device;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)touchRandom:(id)sender {
    long ran = random();
    ran = ran % 99999999;
    NSString *string;
    if (ran < 1000000) {
        string = [NSString stringWithFormat:@"%06ld",ran];
    }else{
        string = [NSString stringWithFormat:@"%ld",ran];
    }
    self.tfPassword.text = string;
}

- (IBAction)touchSure:(id)sender {
    if (self.tfPassword.text.length < 6) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入正确密码" inView:self.view];
        return;
    }
    if (self.time < 5) {
        [TZMProgressHUDManager showErrorWithStatus:@"请选择有效期" inView:self.view];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [GSHDoorLockManager postSetLockSecretWithDeviceSn:self.device.deviceSn secretName:@"" secretValue:self.tfPassword.text secretType:GSHDoorLockSecretTypePassword usedType:GSHDoorLockUsedTypeSingle validMinis:self.time block:^(NSError * _Nonnull error, GSHDoorLockPassWordM *model) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [weakSelf.navigationController pushViewController:[GSHSinglePasswordVC singlePasswordVCWithPassword:model device:self.device] animated:YES];
        }
    }];
}

- (IBAction)touchNav:(id)sender {
    GSHSinglePasswordListVC *vc = [GSHSinglePasswordListVC singlePasswordListVCWithDevice:self.device];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)touchTime:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1) {
            weakSelf.time = 5;
            weakSelf.lblTime.text = @"5分钟";
        }else if (buttonIndex == 2){
            weakSelf.time = 10;
            weakSelf.lblTime.text = @"10分钟";
        }else if (buttonIndex == 3){
            weakSelf.time = 15;
            weakSelf.lblTime.text = @"15分钟";
        }
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
    } andTitle:@"" andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:@"" cancelButtonTitle:@"取消" otherButtonTitles:@"5分钟",@"10分钟",@"15分钟",nil];
}
@end
