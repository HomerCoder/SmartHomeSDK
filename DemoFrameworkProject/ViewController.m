//
//  ViewController.m
//  DemoFrameworkProject
//
//  Created by zhanghong on 2020/3/22.
//  Copyright © 2020 zhanghong. All rights reserved.
//

#import "ViewController.h"
//#import <GSHOpenSDKFrameWork/GSHSDKTransitionViewController.h>
//#import <GSHOpenSDKFrameWork/GSHOpenSDKShare.h>
#import <GSHOpenSDKFrameWork/GSHOpenSDKFrameWork.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[GSHOpenSDKShare share] updateHttpDomain:@"10.34.4.17" port:@(8777)];
    [[GSHOpenSDKShare share] initSDK];
}

- (IBAction)btnClick:(id)sender {
    GSHSDKTransitionViewController *vc = [[GSHSDKTransitionViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.jumpSuccessBlock = ^{
        GSHMainTabBarViewController *vc = [[GSHMainTabBarViewController alloc] init];
        [self changeRootController:vc animate:YES];
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)changeRootController:(UIViewController *)controller animate:(BOOL)animate {
    CATransition *transition = [CATransition animation];
    transition.duration = animate ? 0.5 : 0;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    if ([UIApplication sharedApplication].delegate.window.rootViewController) {
        [UIApplication sharedApplication].delegate.window.rootViewController = nil;
    }
    [[UIApplication sharedApplication].delegate.window setRootViewController:controller];
    [[UIApplication sharedApplication].delegate.window.layer addAnimation:transition forKey:@"animation"];
}

@end
