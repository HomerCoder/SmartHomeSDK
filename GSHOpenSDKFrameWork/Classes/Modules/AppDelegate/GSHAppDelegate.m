//
//  AppDelegate.m
//  SmartHome
//
//  Created by gemdale on 2018/4/3.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAppDelegate.h"
#import "GSHMainTabBarViewController.h"
#import "GSHLoginVC.h"
#import "TZMPushManager.h"
#import "GSHAppConfig.h"
#import "UIViewController+TZM.h"
#import "GSHAlertManager.h"
#import <iflyMSC/iflyMSC.h> // 科大讯飞
#import <OpenShareHeader.h> //OpenShare
#import <CloudPushSDK/CloudPushSDK.h>   // 阿里云推送
#import <Bugly/Bugly.h>     // Bugly
#import "TZMPushManager.h"
#import "RealReachability.h"
#import "GSHVersionCheckUpdateVC.h"
#import "GSHYingShiCameraVC.h"
#import <UINavigationController+TZM.h>
#import <EnjoyHomeOpenSDK.h>
#import <JdPlaySdk/JdPlaySdk.h>
#import "GSHGuideViewController.h"

// iOS 10 notification
#import <UserNotifications/UserNotifications.h>

#import <AFNetworking.h>
#import "WXApi.h"

#import "GSHSDKTransitionViewController.h"

NSString * const GSHVersionMIgnoreVersion = @"GSHVersionMIgnoreVersion";

@interface GSHAppDelegate ()<WXApiDelegate>
//是否支持屏幕转向
@property (nonatomic,assign)NSInteger allowRotate;
@end

@implementation GSHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self initConfig];
    [self initUIStyle];
    [self setRootVC];
    [self checkVersion];
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [self application:application didReceiveRemoteNotification:userInfo];
    }
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [self application:application didReceiveLocalNotification:localNotification];
    }
    
    [CloudPushSDK sendNotificationAck:launchOptions];   // 返回推送通知ACK到服务器
    
    // 设置网络监测
    GLobalRealReachability.hostForPing = @"www.baidu.com";
    GLobalRealReachability.hostForCheck = @"www.apple.com";
    [GLobalRealReachability startNotifier];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self observerNotifications];
   
    
    return YES;
}

-(void)observerNotifications{
    [self observerNotification:GSHUserMChangeNotification];
    [self observerNotification:GSHYingShiNeedOpenLandscapeNotification];
    [self observerNotification:GSHYingShiNeedCloseLandscapeNotification];
    [self observerNotification:AFNetworkingReachabilityDidChangeNotification];
}
-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHUserMChangeNotification]) {
        if ([notification.object isKindOfClass:GSHUserM.class]) {
            [CloudPushSDK bindAccount:((GSHUserM*)notification.object).userId withCallback:^(CloudPushCallbackResult *res) {
                NSLog(@"res : %d",res.success);
            }];
        }else{
            [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
                NSLog(@"res : %d",res.success);
            }];
        }
    }
    if ([notification.name isEqualToString:GSHYingShiNeedOpenLandscapeNotification]) {
        self.allowRotate = 1;
    }
    if ([notification.name isEqualToString:GSHYingShiNeedCloseLandscapeNotification]) {
        self.allowRotate = 0;
    }
    if ([notification.name isEqualToString:AFNetworkingReachabilityDidChangeNotification]) {
        NSNumber *status = [notification.userInfo numverValueForKey:AFNetworkingReachabilityNotificationStatusItem default:nil];
        if (status.intValue == AFNetworkReachabilityStatusReachableViaWiFi) {
            JdPlay_appOnNetChange(0);
            JdPlay_appOnNetChange(1);
        }else{
            JdPlay_appOnNetChange(0);
        }
    }
}
//已经进入活跃
- (void)applicationDidBecomeActive:(UIApplication *)application {
}

//已经进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application{
}

//将要辞去活跃状态
- (void)applicationWillResignActive:(UIApplication *)application {
}

//将要进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
}

//程序将要结束
- (void)applicationWillTerminate:(UIApplication *)application {
    [[GSHWebSocketClient shared] clearWebSocket]; // 在程序结束时，主动断开WebSocket连接
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)option {
    NSLog(@"openURL: %@ option: %@",url,option);
    if ([OpenShare handleOpenURL:url]) {
        return YES;
    }
    if ([WXApi handleOpenURL:url delegate:self]) {
        return YES;
    }
    NSString *key = [option stringValueForKey:UIApplicationOpenURLOptionsSourceApplicationKey default:nil];
    if ([key isEqualToString:@"com.ienjoys.ehome"]) {
        [EnjoyHomeOpenSDK handleOpenURL:url];
        return YES;
    }
    return [self handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    
    return NO;
}

// 成功获取deviceToken  系统自动回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[TZMPushManager shared] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Register deviceToken success, deviceToken: %@", [CloudPushSDK getApnsDeviceToken]);
        } else {
            NSLog(@"Register deviceToken failed, error: %@", res.error);
        }
    }];
    if ([GSHUserManager currentUser].userId) {
        // 阿里云推送 -- 绑定帐号
        [CloudPushSDK bindAccount:[GSHUserManager currentUser].userId withCallback:^(CloudPushCallbackResult *res) {
            NSLog(@"res : %d",res.success);
        }];
    }
}

// 如果获取deviceToken失败 那么调这个方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[TZMPushManager shared] didFailToRegisterForRemoteNotificationsWithError:error];
}

// 接收到本地推送通知  系统自动回调
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
}

// 收到远程推送通知  系统自动回调
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *flagValue = @"";
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // 在应用页面收到通知
        NSLog(@"noti userInfo : %@",userInfo);
        flagValue = @"1";
    } else {
        // 应用在后台模式或关闭时 收到通知
        NSLog(@"back model noti userInfo : %@",userInfo);
        flagValue = @"2";
    }
    [dic setObject:flagValue forKey:@"flag"];
    [dic setObject:userInfo forKey:@"userInfo"];
    [self postNotification:TZMRemoteNotification object:dic];
    
    [[GSHOpenSDKShare share] handleNotificationWithApplication:application
                                  didReceiveRemoteNotification:userInfo];
}

//注册后台任务执行
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
}

//此方法会在设备横竖屏变化的时候调用
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (self.allowRotate == 1) {
        return UIInterfaceOrientationMaskAll;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark - method
//初始化配置信息
static BOOL showLoginOut = NO;
- (void)initConfig {
    JdPlayManagerInit();
    JdPlay_appOnNetChange(0);
    JdPlay_appOnNetChange(1);
    
    if ([GSHAppConfig config].type != GSHAppConfigTypeProduction) {
        [[GSHOpenSDKShare share]updateHttpDomain:[GSHAppConfig config].httpDomainString port:[GSHAppConfig config].type == GSHAppConfigTypeIP || [GSHAppConfig config].type == GSHAppConfigTypeTest ? [GSHAppConfig config].httpPort : nil];
        [[GSHOpenSDKShare share] updateOssDomain:[GSHAppConfig config].ossDomainString];
    }
    
    [[GSHOpenSDKShare share] setResponseBlock:^(NSError *error) {
//        if (error.code == 29) {
//            if (!(showLoginOut || [GSHUserManager currentUser].userId.length == 0)) {
//                showLoginOut = YES;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
//                        [GSHUserManager setCurrentUser:nil];
//                        showLoginOut = NO;
//                    } textFieldsSetupHandler:NULL andTitle:@"警告" andMessage:@"您的账号已在其它手机上登录，您已被迫下线。为保障账号安全，如非本人操作，请立即修改密码。" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"确认",nil];
//                });
//            }
//        }
        if (error.code == 117) {
            if (!(showLoginOut || [GSHUserManager currentUser].userId.length == 0)) {
                showLoginOut = YES;
                NSString *message = error.localizedDescription;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                        [GSHUserManager setCurrentUser:nil];
                        showLoginOut = NO;
                    } textFieldsSetupHandler:NULL andTitle:@"警告" andMessage:message image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"确认",nil];
                });
            }
        }
    }];
    [GSHYingShiManager initEZOpenSDK:kYingShiAppID];
    [GSHInfraredControllerManager initKuKongSDKWithUserAuthority:@"88ED3C305D0DE7EADCD7F70BD3F493D1"];
    [GSHVoiceManager initIFlyAppId:XunFei_AppId];
    
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:100 * 1024 * 1024 diskPath:@"NSURLCache"];
    [NSURLCache setSharedURLCache:cache];
    
    [WXApi registerApp:WX_App_ID];   // 设置微信appId
    [OpenShare connectWeixinWithAppId:WX_App_ID];   // 设置微信appId
    [OpenShare connectQQWithAppId:QQ_App_ID];   // qq
    [Bugly startWithAppId:Bugly_App_ID];    // Bugly
    // 初始化阿里云推送SDK
    [CloudPushSDK asyncInit:AliPush_AppKey appSecret:AliPush_AppSecret callback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
        } else {
            NSLog(@"Push SDK init failed, error: %@", res.error);
        }
    }];
    [[TZMPushManager shared]getDeviceTokenWithBlock:^(NSString *deviceToken, NSError *error) {
    }];
}

//初始化UI配置
- (void)initUIStyle {
    [[UITableView appearance] setSeparatorColor:[UIColor colorWithHexString:@"#eaeaea"]];
    UINavigationBar *navBar = [UINavigationBar appearance];
    //样式
    navBar.barStyle = UIBarStyleDefault;
    //是否半透明
    navBar.translucent = NO;
    //背景颜色(背景图片优先颜色)
    navBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //阴影图片
    navBar.shadowImage = [UIImage imageWithColor:[UIColor clearColor]];
    // title
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#222222"],NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18]};
    //返回按钮
    UIImage *backImage = [UIImage ZHImageNamed:@"app_icon_blackback_normal"];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navBar.backIndicatorImage = backImage;
    navBar.backIndicatorTransitionMaskImage = backImage;
    dispatch_async_on_main_queue(^{
        [UIViewController tzm_appearance].tzmBackBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
    
    UITabBar *tabbar = [UITabBar appearance];
    tabbar.translucent = YES;
    tabbar.shadowImage = [UIImage imageWithColor:[UIColor colorWithRGB:0xe8e8e8] size:CGSizeMake(10, 0.5)];
    tabbar.backgroundImage = [UIImage imageWithColor:[UIColor colorWithRGB:0xffffff alpha:0.9] size:CGSizeMake(10, 10)];
    
    [UIViewController tzm_exchangeImplementationsViewWillAppearBlock:^BOOL(UIViewController *vc) {
        NSLog(@"-------------%@",vc.className);
        if ([vc.className rangeOfString:@"GSH"].location != NSNotFound) {
            return YES;
        }
        return NO;
    }];

}

- (void)setRootVC {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 从过渡页进入app
    GSHSDKTransitionViewController *transitionVC = [[GSHSDKTransitionViewController alloc] init];
    [self.window setRootViewController:transitionVC];
    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isShowGuideVC"]) {
//        // 显示过引导页,不再显示
//         if ([GSHUserManager currentUser]) {
//             // 有登录信息，说明是已登录状态
//             GSHMainTabBarViewController *mainTabBarVC = [[GSHMainTabBarViewController alloc] init];
//             [self.window setRootViewController:mainTabBarVC];
//         } else {
//             // 未登录
//             GSHLoginVC *loginVC = [GSHLoginVC loginVC];
//             UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
//             nav.navigationBar.translucent = NO;
//             [self.window setRootViewController:nav];
//         }
//    } else {
//        // 没显示过引导页,显示引导页
//        GSHGuideViewController *guideVc = [[GSHGuideViewController alloc] init];
//        [self.window setRootViewController:guideVc];
//    }
    
    [self.window makeKeyAndVisible];

}

- (void)changeRootController:(UIViewController *)controller animate:(BOOL)animate {
    CATransition *transition = [CATransition animation];
    transition.duration = animate ? 0.5 : 0;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    if (self.window.rootViewController) {
        self.window.rootViewController = nil;
    }
    [self.window setRootViewController:controller];
    [self.window.layer addAnimation:transition forKey:@"animation"];
}

- (void)checkVersion{
    [GSHVersionM getVersionWithBlock:^(GSHVersionM *version, NSError *error) {
        //如果有最新版本大于本地版本
        if([version versionGreaterThan:[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]]){
            NSString *title = [NSString stringWithFormat:@"发现新版本 %@",version.version];
            //是否强制更新
            if (version.force.integerValue == 2) {
                GSHVersionCheckUpdateVC *vc = [GSHVersionCheckUpdateVC versionCheckUpdateVCWithTitle:title content:version.ext type:GSHVersionCheckUpdateVCTypeApp cancelTitle:@"关闭APP" cancelBlock:^{
                    exit(0);
                } updateBlock:NULL];
                [vc show];
            }else if(version.force.integerValue == 1){
                //如果最新版本号大于本地忽略版本
                NSString *ignored =  [[NSUserDefaults standardUserDefaults] objectForKey:GSHVersionMIgnoreVersion];
                if([version versionGreaterThan:ignored]){
                    GSHVersionCheckUpdateVC *vc = [GSHVersionCheckUpdateVC versionCheckUpdateVCWithTitle:title content:version.ext type:GSHVersionCheckUpdateVCTypeApp cancelTitle:@"忽略此版本" cancelBlock:^{
                        [[NSUserDefaults standardUserDefaults] setObject:version.version forKey:GSHVersionMIgnoreVersion];
                    } updateBlock:NULL];
                    [vc show];
                }
            }else{
            }
        }
    }];
}
@end
