//
//  AppDelegate.h
//  DemoFrameworkProject
//
//  Created by zhanghong on 2020/3/22.
//  Copyright © 2020 zhanghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)changeRootController:(UIViewController *)controller animate:(BOOL)animate;

@end

