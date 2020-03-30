//
//  GSHLoginVerificationCodeVC.m
//  SmartHome
//
//  Created by gemdale on 2019/11/7.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHLoginVerificationCodeVC.h"
#import <UINavigationController+TZM.h>
#import "GSHLoginResetPasswordVC.h"

@interface GSHLoginVerificationCodeVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblDaoJiShi;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *viewCode;
- (IBAction)touchGetCode:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnGetCode;

@property (nonatomic,copy)NSString *phone;
@property (nonatomic,assign)NSInteger second;
@property (nonatomic,copy)void(^block)(void);
@end

@implementation GSHLoginVerificationCodeVC

+(instancetype)loginVerificationCodeVCWithPhone:(NSString*)phone second:(NSInteger)second getCodeBlock:(void(^)(void))block{
    GSHLoginVerificationCodeVC *vc = [GSHPageManager viewControllerWithSB:@"loginSB" andID:@"GSHLoginVerificationCodeVC"];
    vc.phone = phone;
    vc.second = second;
    vc.block = block;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tzm_navigationBarTintColor = [UIColor whiteColor];
    self.lblPhoneNumber.text = [NSString stringWithFormat:@"验证码已发送至%@",self.phone];
    [self refreshSecond];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}

-(void)refreshUI{
    if (self.second <= 0) {
        self.btnGetCode.hidden = NO;
        self.lblLabel.hidden = YES;
        self.lblDaoJiShi.hidden = YES;
    }else{
        self.btnGetCode.hidden = YES;
        self.lblLabel.hidden = NO;
        self.lblDaoJiShi.hidden = NO;
        self.lblDaoJiShi.text = [NSString stringWithFormat:@"%ds",(int)self.second];
    }
}

-(void)refreshSecond{
    [self refreshUI];
    if (self.second <= 0) {
    }else{
        __weak  typeof(self)weakSelf = self;
        self.second--;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf refreshSecond];
        });
    }
}

- (IBAction)touchGetCode:(UIButton *)sender {
    if (self.second <= 0) {
        [self getVcodeWithMobile:[self.phone stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
}

-(void)getVcodeWithMobile:(NSString*)mobile{
    [TZMProgressHUDManager showWithStatus:@"验证码获取中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHUserManager postVerifyCodeWithPhoneNumber:mobile type:GSHGetVerifyCodeTypeLogin block:^(NSError *error) {
        if (error) {
            // 请求失败
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        } else {
            // 请求成功
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.second = 60;
            [weakSelf refreshSecond];
            if (weakSelf.block) {
                weakSelf.block();
            }
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf inputCode];
    });
    return YES;
}
-(void)inputCode{
    NSString *code = self.textField.text;
    if (code.length >= 6) {
        __weak typeof(self)weakSelf = self;
        [TZMProgressHUDManager showWithStatus:@"校验验证码" inView:self.view];
        [GSHUserManager postResetPwdValidateWithPhone:[self.phone stringByReplacingOccurrencesOfString:@" " withString:@""] vcode:code block:^(NSString *token, NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [weakSelf.navigationController pushViewController:[GSHLoginResetPasswordVC loginResetPasswordVCWithPhone:weakSelf.phone code:token] animated:YES];
            }
        }];
    }
    for (int i = 0; i < 6; i++) {
        UILabel *label = [self.viewCode viewWithTag:i + 1001];
        UIView *line = [self.viewCode viewWithTag:i + 2001];
        if ([label isKindOfClass:[UILabel class]]) {
            if (code.length > i) {
                NSString *num = [code substringWithRange:NSMakeRange(i, 1)];
                label.text = num;
                line.backgroundColor = [UIColor colorWithRGB:0x1C93FF];
            }else{
                label.text = nil;
                line.backgroundColor = [UIColor colorWithRGB:0xE8E8E8];
            }
        }
    }
}
@end
