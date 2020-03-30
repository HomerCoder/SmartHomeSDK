//
//  GSHOldPhoneVerifyVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/15.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHOldPhoneVerifyVC.h"
#import "GSHNewPhoneVerifyVC.h"
#import "TZMCountDownButton.h"

@interface GSHOldPhoneVerifyVC ()
@property(nonatomic,strong)GSHUserInfoM *userInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet TZMCountDownButton *btnVerifyCode;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UITextField *tfVerifyCode;
- (IBAction)touchVerifyCode:(UIButton *)sender;
- (IBAction)touchNext:(UIButton *)sender;

@end

@implementation GSHOldPhoneVerifyVC

+(instancetype)oldPhoneVerifyVCWithUserInfo:(GSHUserInfoM*)userInfo{
    GSHOldPhoneVerifyVC *vc = [GSHPageManager viewControllerWithSB:@"GSHChangePhoneSB" andID:@"GSHOldPhoneVerifyVC"];
    vc.userInfo = userInfo;
    return vc;
}

-(void)setUserInfo:(GSHUserInfoM *)userInfo{
    _userInfo = userInfo;
    self.lblPhone.text = [NSString stringWithFormat:@"当前手机号：%@****%@",[userInfo.phone substringToIndex:3],[userInfo.phone substringFromIndex:7]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userInfo = self.userInfo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchVerifyCode:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"获取验证码" inView:self.view];
    [GSHUserManager postVerifyCodeWithPhoneNumber:self.userInfo.phone type:GSHGetVerifyCodeTypePhoneUpdate block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"将有验证码发送到你的手机" inView:weakSelf.view];
            [weakSelf.btnVerifyCode startTimeWithDuration:60];
        }
    }];
}

- (IBAction)touchNext:(UIButton *)sender {
    NSString *vcode = self.tfVerifyCode.text;
    if (vcode.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入验证码" inView:self.view];
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"验证中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHUserManager postUpdatePhoneWithOldPhoneNumber:self.userInfo.phone verifyCode:vcode block:^(NSString *token, NSError *error) {
        if (token) {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            if ([vcs.lastObject isKindOfClass:GSHOldPhoneVerifyVC.class]) {
                [vcs removeObject:vcs.lastObject];
            }
            [vcs addObject:[GSHNewPhoneVerifyVC newPhoneVerifyVCWithToken:token userInfo:weakSelf.userInfo]];
            [self.navigationController setViewControllers:vcs animated:YES];
//            [weakSelf.navigationController pushViewController:[GSHNewPhoneVerifyVC newPhoneVerifyVCWithToken:token userInfo:weakSelf.userInfo] animated:YES];
        }else{
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }
    }];
}
@end
