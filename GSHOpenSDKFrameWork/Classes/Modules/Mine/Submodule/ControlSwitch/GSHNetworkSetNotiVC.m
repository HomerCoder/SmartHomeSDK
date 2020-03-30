//
//  GSHNetworkSetNotiVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/2/19.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHNetworkSetNotiVC.h"
#import "GSHChooseFamilyListVC.h"
#import "GSHConfigLocalControlVC.h"
#import "RealReachability.h"

@interface GSHNetworkSetNotiVC ()

@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *downLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end

@implementation GSHNetworkSetNotiVC

+ (instancetype)networkSetNotiVC {
    GSHNetworkSetNotiVC *vc = [GSHPageManager viewControllerWithSB:@"GSHControlSwitchSB" andID:@"GSHNetworkSetNotiVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)nextButtonClick:(id)sender {
    
    if (self.controlType == 0) {
        // 离线控制
        [self pingNetWork];
    } else {
        // 外网控制
        [TZMProgressHUDManager showWithStatus:@"切换中" inView:self.view];
        @weakify(self)
        [[GSHWebSocketClient shared] changType:GSHNetworkTypeWAN gatewayId:[GSHOpenSDKShare share].currentFamily.gatewayId block:^(NSError * _Nonnull error) {
            @strongify(self)
            if (error) {
                // 失败
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            } else {
                // 切换成功
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TZMProgressHUDManager showSuccessWithStatus:@"切换成功" inView:self.view];
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    [self postNotification:GSHControlSwitchSuccess object:[GSHOpenSDKShare share].currentFamily];
                });
            }
        }];
    }
}

- (void)pingNetWork {
    
    if (GLobalRealReachability.currentReachabilityStatus == RealStatusViaWiFi ||
        GLobalRealReachability.currentReachabilityStatus == RealStatusViaWWAN) {
        // 有外网
        GSHChooseFamilyListVC *chooseFamilyListVC = [GSHChooseFamilyListVC chooseFamilyListVC];
        chooseFamilyListVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chooseFamilyListVC animated:YES];
    } else {
        // 无外网
        self.picImageView.image = [UIImage ZHImageNamed:@"controlSwitch_setnet_pic_wuwang"];
        self.topLabel.text = @"当前无网络，请参考以下方法：";
        self.downLabel.text = @"如果手机网络已连接，请点击重试";
        [self.actionButton setTitle:@"重试" forState:UIControlStateNormal];
        self.actionButton.titleLabel.text = @"重试";
    }

}


@end
