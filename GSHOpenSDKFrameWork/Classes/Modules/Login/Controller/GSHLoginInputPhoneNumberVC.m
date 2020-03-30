//
//  GSHLoginInputPhoneNumberVC.m
//  SmartHome
//
//  Created by gemdale on 2019/11/7.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHLoginInputPhoneNumberVC.h"
#import <UINavigationController+TZM.h>
#import <UITextField+TZM.h>
#import "NSString+TZM.h"
#import "GSHLoginVerificationCodeVC.h"

@interface GSHLoginInputPhoneNumberVC ()
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
- (IBAction)touchNext:(UIButton *)sender;
@property (nonatomic, assign) NSInteger second;
@end

@implementation GSHLoginInputPhoneNumberVC

+(instancetype)loginInputPhoneNumberVC{
    GSHLoginInputPhoneNumberVC *vc = [GSHPageManager viewControllerWithSB:@"loginSB" andID:@"GSHLoginInputPhoneNumberVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tzm_navigationBarTintColor = [UIColor whiteColor];
    self.tfPhoneNumber.tzm_isPhoneNumber = YES;
}

- (IBAction)touchNext:(UIButton *)sender {
    [self.view endEditing:YES];
    NSString *mobile = [self.tfPhoneNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![mobile tzm_checkMobileNumber]) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入正确手机号" inView:self.view];
        return;
    }
    if (self.second <= 0) {
        [self getVcodeWithMobile:mobile];
    }else{
        __weak typeof(self)weakSelf = self;
        [self.navigationController pushViewController:[GSHLoginVerificationCodeVC loginVerificationCodeVCWithPhone:self.tfPhoneNumber.text second:self.second getCodeBlock:^{
            weakSelf.second = 60;
            [weakSelf refreshSecond];
        }] animated:YES];
    }
}

-(void)getVcodeWithMobile:(NSString*)mobile{
    [self.view endEditing:YES];
    [TZMProgressHUDManager showWithStatus:@"验证码获取中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHUserManager postVerifyCodeWithPhoneNumber:mobile type:GSHGetVerifyCodeTypePWDUpdate block:^(NSError *error) {
        if (error) {
            // 请求失败
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        } else {
            // 请求成功
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.second = 60;
            [weakSelf refreshSecond];
            [weakSelf.navigationController pushViewController:[GSHLoginVerificationCodeVC loginVerificationCodeVCWithPhone:self.tfPhoneNumber.text second:self.second getCodeBlock:^{
                weakSelf.second = 60;
                [weakSelf refreshSecond];
            }] animated:YES];
        }
    }];
}

-(void)dealloc{
    
}

-(void)refreshSecond{
    if (self.second <= 0) {
    }else{
        __weak  typeof(self)weakSelf = self;
        self.second--;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf refreshSecond];
        });
    }
}

@end
