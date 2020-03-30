//
//  GSHAddGWGuideVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAddGWGuideVC.h"
#import "GSHBlueRoundButton.h"
#import "GSHAddGWSearchVC.h"
#import <AFNetworking.h>
#import "GSHQRCodeScanningVC.h"
#import "GSHAddGWApIntroVC.h"

@interface GSHAddGWGuideVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblChang;
- (IBAction)touchNext:(GSHBlueRoundButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btnAp;
- (IBAction)touchAp:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *apLine;

@property(strong,nonatomic)GSHFamilyM *family;
@property(strong,nonatomic)GSHDeviceModelM *model;
@property(nonatomic,copy)NSString *deviceSn;
@end

@implementation GSHAddGWGuideVC
+(instancetype)addGWGuideVCWithFamily:(GSHFamilyM*)family deviceModel:(GSHDeviceModelM*)model sn:(NSString*)sn{
    GSHAddGWGuideVC *vc = [GSHPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHAddGWGuideVC"];
    vc.family = family;
    vc.model = model;
    vc.deviceSn = sn;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lblChang.hidden = self.family.gatewayId.length == 0;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.model.introPic] placeholderImage:[UIImage ZHImageNamed:@"addGWGuideVC_image_icon"]];
    
    if ([self.model.deviceModelStr isEqualToString:@"GEM_GATEWAY_V2.0"]) {
        self.btnAp.hidden = NO;
        self.apLine.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchNext:(GSHBlueRoundButton *)sender {
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        [self pushSearchVC];
    } else {
        [TZMProgressHUDManager showErrorWithStatus:@"请切换到wifi环境下搜索网关" inView:self.view];
    }
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];

}

- (void)pushSearchVC {
    [self.navigationController pushViewController:[GSHAddGWSearchVC addGWSearchVCWithFamily:self.family deviceModel:self.model] animated:YES];
}

- (IBAction)touchAp:(UIButton *)sender {
    if (self.deviceSn.length > 0) {
        GSHAddGWApIntroVC *vc = [GSHAddGWApIntroVC addGWApIntroVCWithSn:self.deviceSn deviceModel:self.model bind:NO];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    __weak typeof(self)weakSelf = self;
    UINavigationController *nav = [GSHQRCodeScanningVC qrCodeScanningNavWithText:@"请扫描网关背面或说明书上的二维码添加网关" title:@"扫描网关二维码" block:^BOOL(NSString *code, GSHQRCodeScanningVC *vc) {
        [weakSelf dismissViewControllerAnimated:NO completion:NULL];
        [TZMProgressHUDManager showWithStatus:@"解析二维码中" inView:weakSelf.view];
        [GSHDeviceManager postDeviceModelListWithQRCode:code block:^(NSArray<GSHDeviceModelM *> *list, NSString *sn, NSError *error) {
            if (error) {
                if (error.code == 205) {
                    [TZMProgressHUDManager dismissInView:weakSelf.view];
                    if (code.length > 15) {
                        GSHAddGWApIntroVC *vc = [GSHAddGWApIntroVC addGWApIntroVCWithSn:[code substringFromIndex:15] deviceModel:weakSelf.model bind:YES];
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    }
                }else{
                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                }
            }else{
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                GSHAddGWApIntroVC *vc = [GSHAddGWApIntroVC addGWApIntroVCWithSn:sn deviceModel:weakSelf.model bind:NO];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        }];
        return NO;
    }];
    [self presentViewController:nav animated:YES completion:NULL];
}
@end
