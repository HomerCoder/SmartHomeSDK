//
//  GSHDeviceVC.m
//  SmartHome
//
//  Created by gemdale on 2019/7/16.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDeviceVC.h"
#import "GSHDeviceShowVC.h"

@interface GSHDeviceVC ()
@property(nonatomic,weak)GSHDeviceShowVC *deviceShowVC;
@end

@implementation GSHDeviceVC

-(void)show{
    GSHDeviceShowVC *vc = [GSHDeviceShowVC deviceShowVCWithVC:self];
    self.deviceShowVC = vc;
    [vc show];
    self.deviceShowVC.view.window.windowLevel = UIWindowLevelStatusBar - 1;
}

-(void)closeWithComplete:(void(^)(void))complete{
    self.deviceShowVC.didCallCloseCallback = ^(TZMBlanketVC *vc) {
        if (complete) complete();
    };
    [self.deviceShowVC close];
}

-(void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self)weakSelf = self;
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceSign:self.deviceM.deviceType.intValue == 18 ? @"01" : nil block:^(GSHDeviceM *device, NSError *error) {
        if(error.code==92){
            if (weakSelf.deviceM.roomId) {
                [NSObject postNotification:GSHOpenSDKDeviceUpdataNotification object:@[weakSelf.deviceM.roomId.stringValue]];
            }
            [weakSelf closeWithComplete:^{
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:[UIViewController visibleTopViewController].view];
            }];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.deviceM.onlineStatus.intValue == 0 &&
        self.isFirstAppear &&
        self.deviceEditType == GSHDeviceVCTypeControl &&
        [GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
        [TZMProgressHUDManager showErrorWithStatus:@"设备已离线" inView:self.view.superview];
    }
}

-(void)hideTopView:(BOOL)hide{
    [self.deviceShowVC hideTopView:hide];
}

@end
