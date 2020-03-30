//
//  GSHScanLoginVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/10/23.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHScanLoginVC.h"


@interface GSHScanLoginVC ()

@property (nonatomic , strong) NSString *deviceId;

@end

@implementation GSHScanLoginVC

+ (instancetype)scanLoginVCWithDeviceId:(NSString *)deviceId {
    GSHScanLoginVC *vc = [GSHPageManager viewControllerWithSB:@"MineSB" andID:@"GSHScanLoginVC"];
    vc.deviceId = deviceId;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

#pragma mark - method

- (IBAction)closeButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sureLoginButtonClick:(id)sender {
    
    if (!self.deviceId || self.deviceId.length == 0) {
        [TZMProgressHUDManager showWithStatus:@"deviceId 错误" inView:self.view];
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"登录中" inView:self.view];
    @weakify(self)
    [GSHUserManager postToScanLoginWithDeviceId:self.deviceId block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"登录成功" inView:self.view];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
}

- (IBAction)cancelLoginButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
