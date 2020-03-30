//
//  GSHNewPhoneVerifyVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/15.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHNewPhoneVerifyVC.h"
#import "GSHPhoneInfoVC.h"
#import "TZMCountDownButton.h"
#import "GSHUserInfoVC.h"
#import "NSString+TZM.h"

@interface GSHNewPhoneVerifyVC () <UITextFieldDelegate>
@property(nonatomic,strong)NSString *token;
@property(nonatomic,strong)GSHUserInfoM *userInfo;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfVerifyCode;
@property (weak, nonatomic) IBOutlet TZMCountDownButton *btnVerifyCode;
@property (weak, nonatomic) IBOutlet UILabel *lblVerifyCodeState;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
- (IBAction)touchGetVerifyCode:(UIButton *)sender;
- (IBAction)touchNext:(UIButton *)sender;
@end

@implementation GSHNewPhoneVerifyVC

+(instancetype)newPhoneVerifyVCWithToken:(NSString*)token userInfo:(GSHUserInfoM*)userInfo{
    GSHNewPhoneVerifyVC *vc = [GSHPageManager viewControllerWithSB:@"GSHChangePhoneSB" andID:@"GSHNewPhoneVerifyVC"];
    vc.token = token;
    vc.userInfo = userInfo;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tfPhone.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.tfPhone && string.length > 0 && textField.text.length >= 11) {
        return NO;
    }
    return YES;
}

- (IBAction)touchGetVerifyCode:(UIButton *)sender {
    NSString *phone = self.tfPhone.text;
    if (phone.length != 11 || [phone tzm_checkStringIsEmpty]) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入11位有效手机号码" inView:self.view];
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"获取验证码" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHUserManager postVerifyCodeWithPhoneNumber:phone type:GSHGetVerifyCodeTypePhoneUpdate block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [weakSelf.btnVerifyCode startTimeWithDuration:60];
            [TZMProgressHUDManager showErrorWithStatus:@"将有验证码发送到你的手机" inView:weakSelf.view];
        }
    }];
}

- (IBAction)touchNext:(UIButton *)sender {
    NSString *phone = self.tfPhone.text;
    NSString *code = self.tfVerifyCode.text;
    if (phone.length != 11 || [phone tzm_checkStringIsEmpty]) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入11位有效手机号码" inView:self.view];
        return;
    }
    if ([phone isEqualToString:self.userInfo.phone]) {
        [TZMProgressHUDManager showErrorWithStatus:@"该手机号码与当前手机号码相同" inView:self.view];
        return;
    }
    if (code.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入正确验证码" inView:self.view];
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"更换手机" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHUserManager postUpdatePhoneWithOldPhoneNumber:self.userInfo.phone newPhoneNumber:phone token:self.token verifyCode:code block:^(GSHUserInfoM *userInfo, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"手机号更换成功" inView:weakSelf.view];
            [GSHUserManager setCurrentUser:nil];
        }
    }];
}
@end
