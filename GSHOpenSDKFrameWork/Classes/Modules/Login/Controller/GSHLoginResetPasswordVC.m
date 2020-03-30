//
//  GSHLoginResetPasswordVC.m
//  SmartHome
//
//  Created by gemdale on 2019/11/7.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHLoginResetPasswordVC.h"
#import "GSHAppDelegate.h"

@interface GSHLoginResetPasswordVC ()
@property (weak, nonatomic) IBOutlet UITextField *tfNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfAgainPassword;
- (IBAction)touchNext:(UIButton *)sender;
@property(nonatomic,copy)NSString *phone;
@property(nonatomic,copy)NSString *code;
@end

@implementation GSHLoginResetPasswordVC

+(instancetype)loginResetPasswordVCWithPhone:(NSString*)phone code:(NSString*)code{
    GSHLoginResetPasswordVC *vc = [GSHPageManager viewControllerWithSB:@"loginSB" andID:@"GSHLoginResetPasswordVC"];
    vc.phone = phone;
    vc.code = code;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)touchNext:(UIButton *)sender {
    NSString *password = self.tfNewPassword.text;
    NSString *password2 = self.tfAgainPassword.text;
    if (password && [password2 isEqualToString:password]) {
        if (password.length == 0) {
            [TZMProgressHUDManager showErrorWithStatus:@"请输入新密码" inView:self.view];
        }else{
            NSString *pattern = @"^[a-zA-Z0-9]{6,18}$";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
            if (![pred evaluateWithObject:password]) {
                [TZMProgressHUDManager showErrorWithStatus:@"请输入6-18位数字或字母组成的新密码" inView:self.view];
                return;
            }
            __weak typeof(self)weakSelf = self;
            [TZMProgressHUDManager showWithStatus:@"修改密码中" inView:self.view];
            [GSHUserManager postResetPassWordWithPhoneNumber:[self.phone stringByReplacingOccurrencesOfString:@" " withString:@""] passWord:password verifyCode:self.code block:^(GSHUserM *user, NSError *error) {
                if (error) {
                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                }else{
                    [TZMProgressHUDManager dismissInView:weakSelf.view];
                    // 登录成功 进入首页
                    GSHMainTabBarViewController *mainTabBarVC = [[GSHMainTabBarViewController alloc] init];
                    [(GSHAppDelegate*)[UIApplication sharedApplication].delegate changeRootController:mainTabBarVC animate:YES];
                }
            }];
        }
    }else{
        [TZMProgressHUDManager showErrorWithStatus:@"两次密码不一致，请重新输入" inView:self.view];
    }
}
@end
