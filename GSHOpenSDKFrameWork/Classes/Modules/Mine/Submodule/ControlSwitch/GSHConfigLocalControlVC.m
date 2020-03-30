//
//  GSHConfigLocalControlVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/2/21.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHConfigLocalControlVC.h"
#import "GSHLocalConfigingView.h"
#import "LGAlertView.h"
#import <SDWebImage/UIImage+GIF.h>
#import "GSHConfigLocalColFailureVC.h"
#import "RealReachability.h"

NSString * const GSHControlSwitchSuccess = @"GSHControlSwitchSuccess";

@interface GSHConfigLocalControlVC () <LGAlertViewDelegate>

@property (strong, nonatomic) LGAlertView *alertView;
@property (strong, nonatomic) GSHLocalConfigingView *localConfigingView;

@property (nonatomic, strong) GSHAsyncUdpSocketTask *task;

@end

@implementation GSHConfigLocalControlVC

+ (instancetype)configLocalControlVC {
    GSHConfigLocalControlVC *vc = [GSHPageManager viewControllerWithSB:@"GSHControlSwitchSB" andID:@"GSHConfigLocalControlVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)nextButtonClick:(id)sender {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        if ([[GSHWebSocketClient shared] isConnect]) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [TZMProgressHUDManager showErrorWithStatus:@"请配置手机和网关在同一个网络下" inView:self.view];
            [[GSHWebSocketClient shared] getWebSocketIpAndPortToConnectWithGWId:[GSHOpenSDKShare share].currentFamily.gatewayId];
        }
    }else{
        if (GLobalRealReachability.currentReachabilityStatus == RealStatusViaWiFi) {
            // 有wifi
            [self showConfigingView];
        } else {
            // 无wifi
            [TZMProgressHUDManager showErrorWithStatus:@"请配置手机和网关在同一个网络下" inView:self.view];
        }
    }
}

- (void)showConfigingView {
    
    self.localConfigingView = [[NSBundle mainBundle] loadNibNamed:@"GSHLocalConfigingView" owner:self options:nil][0];
    self.localConfigingView.frame = CGRectMake(0, 0, 270, 290);
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"localConfig_gif@2x" ofType:@"gif"];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage sd_animatedGIFWithData:imageData];
    [self.localConfigingView.gifImageView setImage:image];
    @weakify(self)
    self.localConfigingView.closeButtonClickBlock = ^(void){
        // 关闭配网弹框
        @strongify(self)
        [self.alertView dismiss];
        [self.task cancel];
    };

    self.alertView = [[LGAlertView alloc] initWithViewAndTitle:nil
                                       message:nil
                                         style:LGAlertViewStyleAlert
                                          view:self.localConfigingView
                                  buttonTitles:nil
                             cancelButtonTitle:nil
                        destructiveButtonTitle:nil
                                      delegate:self];
    
    self.alertView.backgroundColor = [UIColor whiteColor];
    self.alertView.cancelOnTouch = NO;
    [self.alertView showAnimated:NO completionHandler:^{
        self.task = [[GSHWebSocketClient shared] changType:GSHNetworkTypeLAN gatewayId:self.familyM.gatewayId block:^(NSError * _Nonnull error) {
            @strongify(self)
            if (error) {
                // 配置失败
                if (error.code == GSHAsyncUdpSocketErrorCancelled) {
                    // udp请求取消
                    NSLog(@"udp 请求取消");
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.alertView dismiss];
                        GSHConfigLocalColFailureVC *configLocalColFailureVC = [GSHConfigLocalColFailureVC configLocalColFailureVC];
                        configLocalColFailureVC.familyM = self.familyM;
                        [self.navigationController pushViewController:configLocalColFailureVC animated:YES];
                    });
                }
            } else {
                // 配置成功
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.localConfigingView.receiveBroadCastView.hidden = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.localConfigingView.configSuccessView.hidden = NO;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.alertView dismiss];
                            [self.navigationController popToRootViewControllerAnimated:NO];
                            [self postNotification:GSHControlSwitchSuccess object:self.familyM];
                        });
                    });
                });
                [[GSHWebSocketClient shared] getWebSocketIpAndPortToConnectWithGWId:[GSHOpenSDKShare share].currentFamily.gatewayId];
            }
        }];
    }];
}




@end
