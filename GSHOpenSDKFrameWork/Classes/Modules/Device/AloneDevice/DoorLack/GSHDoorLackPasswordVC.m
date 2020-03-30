//
//  GSHDoorLackPasswordVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDoorLackPasswordVC.h"

@interface GSHDoorLackPasswordVC ()
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UIButton *btnNav;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIView *viewPassword;
- (IBAction)touchName:(UIButton*)sender;
- (IBAction)touchDelete:(id)sender;
- (IBAction)touchSave:(id)sender;
@property (strong, nonatomic)GSHDeviceM *device;
@property (strong, nonatomic)GSHDoorLockPassWordM *password;
@end

@implementation GSHDoorLackPasswordVC
+(instancetype)doorLackPasswordVCWithPassword:(GSHDoorLockPassWordM*)password device:(GSHDeviceM*)device{
    GSHDoorLackPasswordVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoorLackSB" andID:@"GSHDoorLackPasswordVC"];
    vc.device = device;
    vc.password = password;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.password) {
        self.title = self.password.secretName;
        self.tfName.text = self.password.secretName;
        self.tfPassword.text = self.password.secretValue;
        if (self.password.secretType == GSHDoorLockSecretTypePassword) {
            [self.btnNav setTitle:@"保存" forState:UIControlStateNormal];
            self.btnDelete.hidden = NO;
            self.viewPassword.hidden = NO;
            self.lblName.text = @"密码名称";
            self.tfName.placeholder = @"请输入密码名称";
            self.tfPassword.placeholder = @"请输入6-8位数字密码";
        }else{
            [self.btnNav setTitle:@"保存" forState:UIControlStateNormal];
            self.btnDelete.hidden = NO;
            self.viewPassword.hidden = YES;
            self.lblName.text = @"指纹名称";
            self.tfName.placeholder = @"请输入指纹名称";
        }
    }else{
        [self.btnNav setTitle:@"确认" forState:UIControlStateNormal];
        self.btnDelete.hidden = YES;
        self.viewPassword.hidden = NO;
        self.lblName.text = @"密码名称";
        self.tfName.placeholder = @"请输入密码名称";
        self.tfPassword.placeholder = @"请输入6-8位数字密码";
    }
}

- (IBAction)touchName:(UIButton*)sender {
    self.tfName.text = sender.titleLabel.text;
}

- (IBAction)touchDelete:(id)sender {
    [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHDoorLockManager postDeleteLockSecretWithDeviceSn:self.device.deviceSn secretId:self.password.id block:^(NSError * _Nonnull error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)touchSave:(id)sender {
    if (self.tfPassword.text.length < 6) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入正确密码" inView:self.view];
        return;
    }
    if (self.tfName.text.length < 1) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入名称" inView:self.view];
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (self.password) {
        [GSHDoorLockManager postUpdateLockSecretWithDeviceSn:self.device.deviceSn secretId:self.password.id secretName:self.tfName.text secretValue:self.tfPassword.text secretType:self.password.secretType usedType:GSHDoorLockUsedTypePermanent validMinis:0 block:^(NSError * _Nonnull error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }else{
        [GSHDoorLockManager postSetLockSecretWithDeviceSn:self.device.deviceSn secretName:self.tfName.text secretValue:self.tfPassword.text secretType:GSHDoorLockSecretTypePassword usedType:GSHDoorLockUsedTypePermanent validMinis:0 block:^(NSError * _Nonnull error, GSHDoorLockPassWordM *model) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}
@end
