//
//  GSHChangePasswordVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/15.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHChangePasswordVC.h"
#import "NSString+TZM.h"

@interface GSHChangePasswordVC ()
@property (weak, nonatomic) IBOutlet UITextField *tfOldPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfPasswordAgain;
- (IBAction)touchChange:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnShowOld;
@property (weak, nonatomic) IBOutlet UIButton *btnShowNew;
@property (weak, nonatomic) IBOutlet UIButton *btnShowNewAgain;
- (IBAction)touchShow:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *viewOldPassword1;
@property (weak, nonatomic) IBOutlet UIView *viewOldPassword2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcTopY;
@end

@implementation GSHChangePasswordVC

+(instancetype)changePasswordVC{
    GSHChangePasswordVC *vc = [GSHPageManager viewControllerWithSB:@"SettingSB" andID:@"GSHChangePasswordVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([GSHUserManager currentUserInfo].hasLoginPwd.intValue == 1) {
        self.viewOldPassword1.hidden = NO;
        self.viewOldPassword2.hidden = NO;
        self.lcTopY.constant = 154;
    }else{
        self.viewOldPassword1.hidden = YES;
        self.viewOldPassword2.hidden = YES;
        self.lcTopY.constant = 40;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchShow:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender == self.btnShowNew) {
        self.tfPassword.secureTextEntry = !sender.selected;
    }
    if (sender == self.btnShowOld) {
        self.tfOldPassword.secureTextEntry = !sender.selected;
    }
    if (sender == self.btnShowNewAgain) {
        self.tfPasswordAgain.secureTextEntry = !sender.selected;
    }
}

- (IBAction)touchChange:(UIButton *)sender {
    NSString *oldPassword = self.tfOldPassword.text;
    NSString *password = self.tfPassword.text;
    NSString *passwordAgain = self.tfPasswordAgain.text;
    if ([GSHUserManager currentUserInfo].hasLoginPwd.intValue == 1) {
        if (oldPassword.length == 0) {
            [TZMProgressHUDManager showErrorWithStatus:@"请输入原始密码" inView:self.view];
            return;
        }
    }
    NSString *pattern = @"^[a-zA-Z0-9]{6,18}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    if (![pred evaluateWithObject:password]) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入6-18位数字或字母组成的新密码" inView:self.view];
        return;
    }
    if (![password isEqualToString:passwordAgain]) {
        [TZMProgressHUDManager showErrorWithStatus:@"新密码不一致" inView:self.view];
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"更改中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHUserManager postUpdatePassWordWithPhoneNumber:[GSHUserManager currentUserInfo].phone passWord:password oldPassWord:oldPassword block:^(GSHUserInfoM *userInfo, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"修改成功" inView:weakSelf.view];
            [GSHUserManager currentUserInfo].hasLoginPwd = @(1);
            [GSHUserManager setCurrentUserInfo:[GSHUserManager currentUserInfo]];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}
@end
