//
//  GSHSDKTransitionViewController.m
//  SmartHome
//
//  Created by zhanghong on 2020/3/15.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHSDKTransitionViewController.h"
#import <UIDevice+TZM.h>
#import "GSHNoFamilyVC.h"
#import "GSHOpenSDKShare.h"

#define GSHLoginSuccessMobileNo @"GSHLoginSuccessMobileNo"

@interface GSHSDKTransitionViewController ()

@end

@implementation GSHSDKTransitionViewController

- (instancetype)init
{
    self = [super initWithNibName:@"GSHSDKTransitionViewController" bundle:MYBUNDLE];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tzm_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor redColor];
    
    [[GSHOpenSDKShare share] setAppId:GSHSDKAppId];
    
    // 通知享家判断是否授权 并获取accessToken
    [self postNotification:GSHSDKNotificationAuth object:GSHSDKAppId];
    
    [self observerNotifications];
}

-(void)dealloc {
    [self removeNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getEnjoyHomeUserInfoWithAccessToken:@"1234567890"];
}

#pragma mark - 通知
-(void)observerNotifications{
    [self observerNotification:GSHSDKNotificationAccessToken];    // 获取享家授权结果及accessToken的通知
}

-(void)handleNotifications:(NSNotification *)notification {
    if ([notification.name isEqualToString:GSHSDKNotificationAccessToken]) {
        // 获取新的token , 重新请求房屋列表
        NSDictionary *userInfo = notification.userInfo;
        NSString *result = [userInfo objectForKey:@"result"];
        if ([result isEqualToString:@"01"]) {
            // 同意
            NSString *token = [userInfo objectForKey:@"accessToken"];
            [self getEnjoyHomeUserInfoWithAccessToken:token];
        } else {
            // 拒绝 -- 返回享家
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

#pragma mark - request

// 根据token登录并获取享家信息
- (void)getEnjoyHomeUserInfoWithAccessToken:(NSString *)accessToken {
    
    NSDictionary *dic = @{@"birth":@"20200107",
                          @"currentFamilyId":@"6830",
                          @"hasLoginPwd":@"1",
                          @"nick" : @"你瞅啥瞅你咋地",
                          @"phone" :@"17376868007",
                          @"picPath":@"http://10.34.4.52:8093/2,031d60f267c339",
                          @"sessionId":@"iot_app_b7bb7656f0b64137b0f2a4e3dbc02e5e",
                          @"sex":@"2",
                          @"type":@"1",
                          @"userId":@"96",
                          @"voiceStatus":@"1",
                          @"wechatId":@"1"};
    GSHUserM *userM = [GSHUserM yy_modelWithDictionary:dic];
    if (userM.userId.length > 0 && [userM.userId intValue] != 0) {
        userM.accessToken = accessToken;
        [GSHUserManager setCurrentUser:userM];
        [self loginSuccessToHandleByUserM:userM];
    }
//    [TZMProgressHUDManager showWithStatus:@"获取信息中" inView:self.view];
//    __weak typeof(self)weakSelf = self;
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setValue:accessToken forKey:@"accessToken"];
//    [dic setValue:[UIDevice tzm_getUUID] forKey:@"clientSN"];
//    [dic setValue:@"1" forKey:@"clientType"];
//    [dic setValue:[UIDevice tzm_getIPhoneType] forKey:@"phoneModel"];
//
//    [GSHRequestManager postWithPath:@"user/thirdPartyLoginByToken" parameters:dic block:^(id responseObjec, NSError *error) {
//        if (error) {
//            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
//            [self.navigationController popViewControllerAnimated:NO];
//        } else {
//            [TZMProgressHUDManager dismissInView:weakSelf.view];
//            GSHUserM *userM = [GSHUserM yy_modelWithJSON:responseObjec];
//            if (userM.userId.length > 0 && [userM.userId intValue] != 0) {
//                userM.accessToken = accessToken;
//                [GSHUserManager setCurrentUser:userM];
//                [self loginSuccessToHandleByUserM:userM];
//            }
//        }
//    }];

}

// 登录成功的处理
- (void)loginSuccessToHandleByUserM:(GSHUserM *)userM {
    
    [[NSUserDefaults standardUserDefaults] setObject:userM.phone forKey:GSHLoginSuccessMobileNo];
    if (self.jumpSuccessBlock) {
        self.jumpSuccessBlock();
    }
    // 登录成功 进入首页
    GSHMainTabBarViewController *mainTabBarVC = [[GSHMainTabBarViewController alloc] init];
    mainTabBarVC.modalPresentationStyle = UIModalPresentationFullScreen;
    NSLog(@"模态执行了 1");
    [self presentViewController:mainTabBarVC animated:NO completion:^{
        NSLog(@"模态执行了 2");
    }];

}


@end
