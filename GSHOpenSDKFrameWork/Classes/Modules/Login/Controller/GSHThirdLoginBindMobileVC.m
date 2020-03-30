//
//  GSHThirdLoginBindMobileVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHThirdLoginBindMobileVC.h"
#import "GSHMainTabBarViewController.h"
#import "TZMCountDownButton.h"
#import "GSHAppDelegate.h"

#import "NSString+TZM.h"

#import "GSHNoFamilyVC.h"

static const NSTimeInterval KCountDownDuration = 60.0;

@interface GSHThirdLoginBindMobileVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet TZMCountDownButton *authCodeButton;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *authCodeTextField;

@property (weak, nonatomic) IBOutlet UIView *mobileLineView;
@property (weak, nonatomic) IBOutlet UIView *codeLineView;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;

@end

@implementation GSHThirdLoginBindMobileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"绑定手机号";
    
    self.mobileTextField.delegate = self;
    self.authCodeTextField.delegate = self;
    
    self.bindButton.layer.cornerRadius = self.bindButton.frame.size.height / 2.0;
    [self.mobileTextField addTarget:self action:@selector(mobileTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - method

- (void)mobileTextFieldChanged:(UITextField *)textField {
    if (textField == self.mobileTextField) {
        if (textField.text.length == 11) {
            self.authCodeButton.enabled = YES;
            self.authCodeButton.alpha = 1.0f;
            self.bindButton.enabled = YES;
            self.bindButton.alpha = 1.0f;
        } else {
            self.authCodeButton.enabled = NO;
            self.authCodeButton.alpha = 0.3f;
            self.bindButton.enabled = NO;
            self.bindButton.alpha = 0.3f;
        }
    }
}

// 获取验证码
- (IBAction)authCodeButtonClick:(id)sender {
//    if (![self.mobileTextField.text checkMobileNumber]) {
//        // 手机号不正确
//        [TZMProgressHUDManager showErrorWithStatus:@"请输入正确的手机号码" inView:weakSelf.view];
//        return;
//    }
    [TZMProgressHUDManager showWithStatus:@"验证码获取中" inView:self.view];
    @weakify(self)
    [GSHUserManager postVerifyCodeWithPhoneNumber:self.mobileTextField.text type:GSHGetVerifyCodeTypeThirdBindMobile block:^(NSError *error) {
        @strongify(self)
        if (error) {
            // 请求失败
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            // 请求成功
            [TZMProgressHUDManager dismissInView:self.view];
            [self.authCodeButton startTimeWithDuration:KCountDownDuration]; // 按钮开始倒计时
        }
    }];
}

// 绑定按钮点击
- (IBAction)bindButtonClick:(id)sender {
    
    if (!self.openId) {
        return;
    }
    if ([self.authCodeTextField.text tzm_checkStringIsEmpty]) {
        [TZMProgressHUDManager showErrorWithStatus:@"验证码不能为空" inView:self.view];
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"绑定中" inView:self.view];
    @weakify(self)
    [GSHUserManager postThirdPartyBindPhoneWithOpenId:self.openId
                                       userName:self.userName
                                     headImgUrl:self.headImgUrl
                                           type:self.type
                             userThirdLoginType:self.userThirdLoginType
                                    phoneNumber:self.mobileTextField.text
                                     verifyCode:self.authCodeTextField.text
                                          block:^(GSHUserM *user, NSError *error) {
        @strongify(self)
        if (error) {
            // 请求失败
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            // 请求成功
            [TZMProgressHUDManager showSuccessWithStatus:@"绑定成功" inView:self.view];
            if (user.currentFamilyId.length > 0) {
                // 有家庭 -- 登录成功 进入首页
                GSHMainTabBarViewController *mainTabBarVC = [[GSHMainTabBarViewController alloc] init];
                [(GSHAppDelegate*)[UIApplication sharedApplication].delegate changeRootController:mainTabBarVC animate:YES];
            } else {
                // 无家庭 -- 登录成功 进入添加家庭页面
                GSHNoFamilyVC *noFamilyVC = [[GSHNoFamilyVC alloc] init];
                [self.navigationController pushViewController:noFamilyVC animated:YES];
            }
            
        }
    }];
    
}

#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.mobileTextField && string.length > 0 && textField.text.length >= 11) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.mobileTextField) {
        self.mobileLineView.backgroundColor = [UIColor colorWithHexString:@"#2EB0FF"];
    } else if (textField == self.authCodeTextField) {
        self.codeLineView.backgroundColor = [UIColor colorWithHexString:@"#2EB0FF"];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.mobileTextField) {
//        if (![self.mobileTextField.text checkMobileNumber]) {
//            NSLog(@"mobile error");
//            [self.mobileTextField isFirstResponder];
//        }
        self.mobileLineView.backgroundColor = [UIColor colorWithHexString:@"#DEDEDE"];
    } else if (textField == self.authCodeTextField) {
        self.codeLineView.backgroundColor = [UIColor colorWithHexString:@"#DEDEDE"];
    }
    
}


@end
