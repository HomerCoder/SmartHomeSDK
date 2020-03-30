//
//  AppDelegate.h
//  SmartHome
//
//  Created by gemdale on 2018/4/3.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)changeRootController:(UIViewController *)controller animate:(BOOL)animate;
@end

