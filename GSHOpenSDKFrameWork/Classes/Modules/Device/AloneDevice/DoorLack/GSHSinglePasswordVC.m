//
//  GSHSinglePasswordVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHSinglePasswordVC.h"
#import "GSHAlertManager.h"

@interface GSHSinglePasswordVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblPassword;
@property (weak, nonatomic) IBOutlet UILabel *lbilme;
- (IBAction)touchCopy:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic)GSHDoorLockPassWordM *model;
@property (strong, nonatomic)GSHDeviceM *device;
@end

@implementation GSHSinglePasswordVC
+(instancetype)singlePasswordVCWithPassword:(GSHDoorLockPassWordM*)model device:(GSHDeviceM*)device{
    GSHSinglePasswordVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoorLackSB" andID:@"GSHSinglePasswordVC"];
    vc.model = model;
    vc.device = device;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lblPassword.text = self.model.secretValue;
    if (self.model.status == GSHDoorLockSinglePasswordStatusUnvalid) {
        self.lblPassword.textColor = [UIColor colorWithRGB:0x999999];
        self.lbilme.textColor = [UIColor colorWithRGB:0x999999];
        self.lbilme.text = [NSString stringWithFormat:@"密码已于%@失效",[self.model.date stringWithFormat:@"yyyy年MM月dd日HH:mm"]];
        [self.button setTitle:@"删除" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor colorWithRGB:0xE60B0D] forState:UIControlStateNormal];
        self.button.layer.borderColor = [UIColor colorWithRGB:0xE60B0D].CGColor;
    }else{
        self.lblPassword.textColor = [UIColor colorWithRGB:0x2EB0FF];
        self.lbilme.textColor = [UIColor colorWithRGB:0x999999];
        self.lbilme.text = [NSString stringWithFormat:@"密码将于%d分钟后（%@）失效，失效前仅可使用一次",(int)([self.model.date timeIntervalSinceNow] / 60),[self.model.date stringWithFormat:@"yyyy年MM月dd日HH:mm"]];
        [self.button setTitle:@"复制密码" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor colorWithRGB:0x2EB0FF] forState:UIControlStateNormal];
        self.button.layer.borderColor = [UIColor colorWithRGB:0x2EB0FF].CGColor;
    }
}

- (void)delete{
    [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHDoorLockManager postDeleteLockSecretWithDeviceSn:self.device.deviceSn secretId:self.model.id block:^(NSError * _Nonnull error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)touchCopy:(id)sender {
    if (self.model.status == GSHDoorLockSinglePasswordStatusUnvalid) {
        __weak typeof(self)weakSelf = self;
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 0) {
                [weakSelf delete];
            }
        } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
            
        } andTitle:nil andMessage:@"确认删除此条密码记录？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"删除" cancelButtonTitle:@"取消" otherButtonTitles:nil];
    }else{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.model.secretValue;
        [TZMProgressHUDManager showSuccessWithStatus:@"复制成功" inView:self.view];
    }
}
@end
