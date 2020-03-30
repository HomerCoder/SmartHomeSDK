//
//  GSHMainTabBarViewController.m
//  SmartHome
//
//  Created by zhanghong on 2018/4/12.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHMainTabBarViewController.h"
#import "GSHNavigationViewController.h"

#import "GSHLoginVC.h"
#import "GSHHomeVC.h"
#import "GSHVoiceTabBar.h"
#import "GSHMineVC.h"

#import "GSHVoiceVC.h"
#import "GSHVersionCheckUpdateVC.h"
#import "GSHAppDelegate.h"

#import <UIImage+YYAdd.h>
#import "UINavigationController+TZM.h"
#import "UIViewController+TZM.h"

#import "GSHAlertManager.h"
#import "GSHMessageVC.h"
#import "TZMPushManager.h"

#import "GSHPushPopoverController.h"
#import "GSHGateWayUpdateVC.h"

#import "TZMVoIPPushManager.h"
#import "GSHYingshiDoorbellVC.h"
#import "GSHVoiceSettingVC.h"
#import "GSHPlayVC.h"
#import <Lottie/Lottie.h>
#import <JhtFloatingBall/JhtFloatingBall.h>
#import <UIView+TZM.h>

@interface GSHMainTabBarViewController ()
<UITabBarControllerDelegate,
UINavigationControllerDelegate,
UITabBarDelegate,JhtFloatingBallDelegate>

@property(nonatomic,strong) GSHHomeVC *homeVC;
@property(nonatomic,strong) NSMutableArray *lottieAnimationArray;

@property(nonatomic,strong) LOTAnimationView *homeAnimationView;
@property(nonatomic,strong) LOTAnimationView *sceneAnimationView;
@property(nonatomic,strong) LOTAnimationView *playAnimationView;
@property(nonatomic,strong) LOTAnimationView *mineAnimationView;

@property(nonatomic,strong) UIWindow *voiceWindow;
@property(nonatomic,strong) JhtFloatingBall *voiceBtn;
@end

@implementation GSHMainTabBarViewController {
    GSHVoiceTabBar *_tabBar;
    NSArray *_titles;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initAnimationView];
    self.delegate = self;
    [self addChildViewControllers];
    [self observerNotifications];

    if (@available(iOS 13.0, *)) {
        // 在iOS 13 中，这个属性设置之后，UITabBar子视图才可正确定位到 （tabbar动画效果有影响）
        [[UITabBar appearance] setUnselectedItemTintColor:[UIColor colorWithRGB:0x8E8E93]];
    }
    
    self.voiceWindow = [[UIWindow alloc] init];
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height + 0.000001);
    self.voiceWindow.frame = frame;
    self.voiceWindow.rootViewController = [UIViewController new];
    self.voiceWindow.rootViewController.view.hidden = YES;
    self.voiceWindow.passTouch = YES;
    self.voiceWindow.hidden = NO;
    self.voiceWindow.backgroundColor = [UIColor clearColor];
    self.voiceWindow.windowLevel = 10000000;

    UIImage *suspendedBallImage = [UIImage ZHImageNamed:@"tab_voice_normal"];
    self.voiceBtn = [[JhtFloatingBall alloc] initWithFrame:CGRectMake(self.voiceWindow.size.width - suspendedBallImage.size.width, self.voiceWindow.size.height - suspendedBallImage.size.height - 75, suspendedBallImage.size.width, suspendedBallImage.size.height)];
    self.voiceBtn.image = suspendedBallImage;
    self.voiceBtn.stayAlpha = 0.6;
    self.voiceBtn.delegate = self;
    self.voiceBtn.stayMode = StayMode_OnlyRight;
    self.voiceBtn.touchesMovedBlock = ^(CGRect frame) {
    };
    self.voiceBtn.stayBlock = ^(CGRect frame) {
    };
    [self.voiceWindow addSubview:self.voiceBtn];

    [self refrshFloatingButton];
}

- (void)tapFloatingBall{
    [self.voiceWindow.rootViewController presentViewController:[GSHVoiceVC voiceVC] animated:YES completion:NULL];
}

-(void)dealloc{
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observerNotifications {
    [self observerNotification:GSHOpenSDKDeviceUpdataNotification];
    [self observerNotification:GSHUserMChangeNotification];
    [self observerNotification:TZMRemoteNotification];
    [self observerNotification:GSHControlSwitchSuccess];
    [self observerNotification:GSHVoiceSettingVCStateChangeNotification];
    [self observerNotification:UIWindowDidBecomeKeyNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHOpenSDKDeviceUpdataNotification]) {
        NSArray *arr = notification.object;
        if ([arr isKindOfClass:NSArray.class] && [arr.firstObject isKindOfClass:NSString.class]) {
            [self.homeVC switchoverRoomWithRoomId:arr.firstObject];
        }
    } else if ([notification.name isEqualToString:GSHUserMChangeNotification]) {
        if (notification.object == nil) {
            [self loginOut:notification];
        }
    } else if ([notification.name isEqualToString:TZMRemoteNotification]) {
        [self handlePushNotification:notification];
    } else if ([notification.name isEqualToString:GSHControlSwitchSuccess]) {
        // 控制切换成功的通知
        self.selectedIndex = 0;
        [self changeTabWithSelectIndex:self.selectedIndex];
        [TZMProgressHUDManager showSuccessWithStatus:@"切换成功" inView:self.view];
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            // 离线模式
            self.voiceWindow.hidden = YES;
        } else {
            if ([GSHUserManager currentUser].voiceStatus.intValue == 2) {
                [self.voiceWindow makeKeyAndVisible];
                self.voiceWindow.hidden = NO;
            }else{
                self.voiceWindow.hidden = YES;
            }
        }
    } else if ([notification.name isEqualToString:GSHVoiceSettingVCStateChangeNotification]) {
        [self refrshFloatingButton];
    } else if ([notification.name isEqualToString:UIWindowDidBecomeKeyNotification]) {
        if ([notification.object isKindOfClass:[UIWindow class]]) {
            UIWindow *window = (UIWindow *)notification.object;
            if (window == self.voiceWindow || [window.rootViewController isKindOfClass:[TZMBlanketVC class]]) {
                [[UIApplication sharedApplication].windows.firstObject makeKeyWindow];
            }
        }
    }
}

// 切换tab 传入索引
- (void)changeTabWithSelectIndex:(NSUInteger)selectIndex {
    self.homeAnimationView.animationProgress = 0;
    self.sceneAnimationView.animationProgress = 0;
    self.playAnimationView.animationProgress = 0;
    self.mineAnimationView.animationProgress = 0;
    if (selectIndex == 0) {
        self.homeAnimationView.animationProgress = 1;
    } else if (selectIndex == 1) {
        self.sceneAnimationView.animationProgress = 1;
    } else if (selectIndex == 2) {
        self.playAnimationView.animationProgress = 1;
    } else if (selectIndex == 0) {
        self.mineAnimationView.animationProgress = 1;
    }
}

-(void)refrshFloatingButton{
    if ([GSHUserManager currentUser].voiceStatus.intValue == 2) {
        [self.voiceWindow makeKeyAndVisible];
        self.voiceWindow.hidden = NO;
    }else{
        self.voiceWindow.hidden = YES;
    }
}

- (void)initAnimationView {
    
    if (!self.homeAnimationView) {
        self.homeAnimationView = [[LOTAnimationView alloc] init];
        [self.homeAnimationView setAnimationNamed:@"tabbar_home.json" inBundle:MYBUNDLE];
//        ;[LOTAnimationView animationNamed:@"tabbar_home" inBundle:bundle];
        
    }
    if (!self.sceneAnimationView) {
        self.sceneAnimationView = [LOTAnimationView animationNamed:@"tabbar_scene" inBundle:MYBUNDLE];
    }
    if (!self.playAnimationView) {
        self.playAnimationView = [LOTAnimationView animationNamed:@"tabbar_play" inBundle:MYBUNDLE];
    }
    if (!self.mineAnimationView) {
        self.mineAnimationView = [LOTAnimationView animationNamed:@"tabbar_mine" inBundle:MYBUNDLE];
    }
}

- (void)addChildViewControllers {
    
    NSArray *viewControllerNames = @[@"GSHHomeVC",@"GSHSceneVC",@"GSHAutomateVC",@"GSHMineVC"];
    NSArray *imageNormalArr = @[@"tab_home_normal",@"tab_scene_normal",@"tab_play_normal",@"tab_personal_normal"];
    NSArray *imageSelectedArr = @[@"tab_home_sel",@"tab_scene_sel",@"tab_play_sel",@"tab_personal_sel"];
    _titles = @[@"首页",@"场景",@"玩转",@"我的"];

    for(NSInteger i = 0 ; i < viewControllerNames.count ; i++) {
        UIViewController *vc;
        if(i == 0){
            self.homeVC = [GSHHomeVC homeVC];
            vc = self.homeVC;
        }else if(i == 2){
            vc = [GSHPlayVC playVC];
        }else if(i == 3){
            vc = [GSHMineVC mineVC];
        } else {
            Class cls = NSClassFromString(viewControllerNames[i]);
            vc = [[cls alloc] init];
        }
        vc.tzm_navigationBarTintColor = [UIColor whiteColor];
        // 添加子控制器
        [self addChildVc:vc title:_titles[i] image:imageNormalArr[i] selectedImage:imageSelectedArr[i]];
    }
    self.selectedIndex = 0;
}

/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
- (void)addChildVc:(UIViewController *)childVc
             title:(NSString *)title
             image:(NSString *)image
     selectedImage:(NSString *)selectedImage
{
    childVc.title = title;
    
    UIImage *normalImage = [[UIImage ZHImageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImg = [[UIImage ZHImageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:normalImage selectedImage:selectedImg];
    
    NSDictionary *normalTextAttrs = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#8E8E93"],NSFontAttributeName:[UIFont boldSystemFontOfSize:10]};
    [tabBarItem setTitleTextAttributes:normalTextAttrs forState:UIControlStateNormal];
    
    NSDictionary *selectTextAttrs = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#3C4366"],NSFontAttributeName:[UIFont boldSystemFontOfSize:10]};
    [tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    
    GSHNavigationViewController *nav = [[GSHNavigationViewController alloc] initWithRootViewController:childVc];
    nav.delegate = self;
    nav.tabBarItem = tabBarItem;
    [self addChildViewController:nav];
}

// 收到退出登录的通知
- (void)loginOut:(NSNotification *)noti {
    // 未登录
    if ([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        if ([nav.viewControllers.firstObject isKindOfClass:[GSHLoginVC class]]) {
            return;
        }
    }
    
    GSHLoginVC *loginVC = [GSHLoginVC loginVC];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    nav.navigationBar.translucent = NO;
    [(GSHAppDelegate*)[UIApplication sharedApplication].delegate changeRootController:nav animate:YES];
}

#pragma mark 收到推送通知
- (void)handlePushNotification:(NSNotification *)notification {
    
    if (![GSHUserManager currentUser].userId) {
        return;
    }
    
    NSDictionary *dic = notification.object;
    NSString *flagValue = [dic objectForKey:@"flag"];
    NSDictionary *userInfo = [dic objectForKey:@"userInfo"];
    NSString *msgType = [userInfo objectForKey:@"msgType"];
    NSString *operateType = [userInfo objectForKey:@"operateType"];
    NSString *bodyStr = [userInfo objectForKey:@"msgBody"];
    NSString *title = [userInfo objectForKey:@"title"];
    NSNumber *familyId = [userInfo objectForKey:@"familyId"];
    NSNumber *adminId = [userInfo objectForKey:@"adminId"]; // 管理员id -- 都表示最新的管理员
    
    // 网关被复位后APP退出登录 99
    if (operateType.integerValue == 99) {
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 1) {
                [GSHUserManager setCurrentUser:nil];
            }
        } textFieldsSetupHandler:NULL andTitle:title andMessage:bodyStr image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        return;
    }
    
    /*
     "201"://转让家庭
     "202"://成员的权限修改
     "302"://管理员删除成员
     "1001"://成员退出家庭
     "1101"://管理员删除家庭
     "301"://管理员添加成员
     */
    
    // 201 转让家庭
    if (operateType.integerValue == 201) {
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (adminId.integerValue == [GSHUserManager currentUser].userId.integerValue) {
                // 原成员变为管理员 -- 刷新首页
                [self postNotification:GSHRefreshHomeDataNotifacation object:nil];
            }
        } textFieldsSetupHandler:NULL andTitle:title andMessage:bodyStr image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了",nil];
        return;
    }
    
    /*
     202 成员的权限修改
     302 管理员删除成员的通知
     1101 管理员删除家庭
     301 管理员添加成员
     */
    if (operateType.integerValue == 202 ||
        operateType.integerValue == 302 ||
        operateType.integerValue == 1101 ||
        operateType.integerValue == 301) {
        
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (adminId.integerValue != [GSHUserManager currentUser].userId.integerValue) {
                // 成员收到的推送 -- 刷新首页
                [self postNotification:GSHRefreshHomeDataNotifacation object:nil];
            }
        } textFieldsSetupHandler:NULL andTitle:title andMessage:bodyStr image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了",nil];
        return;
    }
    
    // 网关升级结果的通知
    if (operateType.integerValue == 601) {
        NSString *resultCode = [userInfo objectForKey:@"resultCode"];
        NSString *buttonTitle;
        if (resultCode.intValue == 0) {
            // 升级成功
            buttonTitle = @"立即查看";
        } else {
            // 升级失败
            buttonTitle = @"重新升级";
        }
        if ([[[self class] visibleTopViewController] isKindOfClass:[GSHGateWayUpdateVC class]]) {
            // 当前页面就是在升级页面 -- 发送通知到网关更新页面刷新页面
            [self postNotification:GSHGateWayUpdateResult object:nil];
        }
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 1) {
                if (![[[self class] visibleTopViewController] isKindOfClass:[GSHGateWayUpdateVC class]]) {
                    // 当前页面不在升级页面 -- 发送通知到网关更新页面刷新页面
                    GSHGateWayUpdateVC *updateVC = [GSHGateWayUpdateVC gateWayUpdateVC];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:updateVC];
                    [[[self class] visibleTopViewController] presentViewController:nav animated:YES completion:nil];
                }
            }
        } textFieldsSetupHandler:NULL andTitle:nil andMessage:bodyStr image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:buttonTitle,nil];
        return;
    }

    //如果是网关升级
    if (operateType.integerValue == 600) {
        GSHVersionCheckUpdateVC *vc = [GSHVersionCheckUpdateVC versionCheckUpdateVCWithTitle:title content:bodyStr type:GSHVersionCheckUpdateVCTypeGW cancelTitle:@"取消" cancelBlock:^{
            
        } updateBlock:NULL];
        [vc show];
        return;
    }
    
    //如果是门铃
    if (operateType.integerValue == 701) {
        NSString *alarmTime = [userInfo stringValueForKey:@"alarmTime" default:@""];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:alarmTime.longValue / 1000];
        if ([date timeIntervalSinceNow] < -60) {
            return;
        }
        if (![TZMVoIPPushManager shared].canPlaySound) {
            return;
        }
        [TZMVoIPPushManager shared].canPlaySound = NO;
        GSHYingshiDoorbellVC *vc = [GSHYingshiDoorbellVC yingshiDoorbellVCWithDeviceSn:[userInfo stringValueForKey:@"deviceSerial" default:@""] cameraNo:[userInfo numverValueForKey:@"channelNo" default:@(1)].integerValue validateCode:[userInfo stringValueForKey:@"validateCode" default:@""] name:[userInfo stringValueForKey:@"title" default:@""] alarmId:[userInfo stringValueForKey:@"alarmId" default:@""]];
        [self presentViewController:vc animated:YES completion:NULL];
        return;
    }
    
    //推送消息如果没有特殊要求都跳转消息页面。
    if (flagValue.intValue == 1) {
        // 应用内收到推送
        if ([familyId.stringValue isEqualToString:[GSHOpenSDKShare share].currentFamily.familyId]) {
            // 当前家庭的消息
            __weak typeof(self)weakSelf = self;
            if (msgType.integerValue > 0 && msgType.integerValue < 5) {
                [GSHAlertManager showAlertWithTitle:@"消息提醒" text:bodyStr block:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                            // 外网控制
                            [weakSelf watchTheMessageInfoWithMsgType:msgType];
                        }
                    } else {
                        [weakSelf postNotification:GSHQueryIsHasUnReadMsgNotification object:nil];
                    }
                }];
            } else {
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                            // 外网控制
                            [weakSelf watchTheMessageInfoWithMsgType:msgType];
                        }
                    } else {
                        [weakSelf postNotification:GSHQueryIsHasUnReadMsgNotification object:nil];
                    }
                } textFieldsSetupHandler:NULL andTitle:title andMessage:bodyStr image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"暂不处理" otherButtonTitles:@"立即查看",nil];
            }
        }else{
            // 非当前家庭的消息
            [GSHPushPopoverController showWithTitle:title content:bodyStr];
        }
    } else {
        // 后台模式或应用关闭时收到推送
        [self watchTheMessageInfoWithMsgType:msgType];
    }
}

- (void)watchTheMessageInfoWithMsgType:(NSString *)msgType {
    
    NSInteger index = 0;
    if (msgType.intValue == 1) {
        // 告警
        index = 0;
    } else if (msgType.intValue == 2) {
        // 系统
        index = 1;
    } else if (msgType.intValue == 4) {
        // 场景
        index = 2;
    } else if (msgType.intValue == 5) {
        // 联动
        index = 3;
    }
    
    if (![[[self class] visibleTopViewController] isKindOfClass:[GSHMessageVC class]]) {
        [self pushToMessageInfoVCWithVCIndex:index];
    } else {
        // 当前在消息页面
        [(GSHMessageVC *)[[self class] visibleTopViewController] changeSelectIndex:index];
    }
}

- (void)pushToMessageInfoVCWithVCIndex:(NSInteger)vcIndex {
    GSHMessageVC *messageVC = [[GSHMessageVC alloc] initWithSelectIndex:vcIndex];
    messageVC.hidesBottomBarWhenPushed = YES;
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dismissButton setImage:[UIImage ZHImageNamed:@"app_icon_blackback_normal"] forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismissClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:dismissButton];
    messageVC.navigationItem.leftBarButtonItem = item;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:messageVC];
    [[[self class] visibleTopViewController] presentViewController:nav animated:YES completion:nil];
    
}

- (void)dismissClick:(UIButton *)button {
    [[[self class] visibleTopViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    LOTAnimationView *aniView;
    if ([item.title isEqualToString:@"首页"]) {
        aniView = self.homeAnimationView;
    } else if ([item.title isEqualToString:@"场景"]) {
        aniView = self.sceneAnimationView;
    } else if ([item.title isEqualToString:@"玩转"]) {
        aniView = self.playAnimationView;
    } else if ([item.title isEqualToString:@"我的"]) {
        aniView = self.mineAnimationView;
    }

    // 连续点击同一个item，不执行动画
    if (aniView.animationProgress > 0) {
        return ;
    }

    self.homeAnimationView.animationProgress = 0;
    self.sceneAnimationView.animationProgress = 0;
    self.playAnimationView.animationProgress = 0;
    self.mineAnimationView.animationProgress = 0;

    if (!aniView.superview) {
        for (UIControl *tabBarButton in self.tabBar.subviews) {
            if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
                for (UIControl *tabBarButtonLabel in tabBarButton.subviews) {
                    if ([tabBarButtonLabel isKindOfClass:NSClassFromString(@"UITabBarButtonLabel")]) {
                        UILabel *label = (UILabel *)tabBarButtonLabel;
                        if ([label.text isEqualToString:item.title]) {
                            for (UIView *imageView in tabBarButton.subviews) {
                                if ([imageView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                                    //添加动画
                                    aniView.frame = CGRectMake(0, 0, imageView.width, imageView.height);
                                    [imageView addSubview:aniView];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    NSLog(@"动画执行结束 1 ");
    if (aniView.animationProgress == 0) {
        NSLog(@"动画执行结束 2");
        [aniView playFromProgress:0.25 toProgress:1 withCompletion:^(BOOL animationFinished) {
            NSLog(@"动画执行结束 3");
        }];
    }
        
}

@end
