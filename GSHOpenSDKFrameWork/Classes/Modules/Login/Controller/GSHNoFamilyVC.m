//
//  GSHNoFamilyVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/8/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHNoFamilyVC.h"
#import "UINavigationController+TZM.h"
#import "GSHMainTabBarViewController.h"
#import "GSHCreateFamilyVC.h"
#import "GSHAppDelegate.h"

@interface GSHNoFamilyVC ()

@property (weak, nonatomic) IBOutlet UIButton *jumpButton;
@property (weak, nonatomic) IBOutlet UIButton *addFamilyButton;

@end

@implementation GSHNoFamilyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tzm_interactivePopDisabled = YES;   // 禁止手势
    self.tzm_prefersNavigationBarHidden = YES;
    [self initUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI {
    self.jumpButton.layer.borderWidth = 0.5f;
    self.jumpButton.layer.borderColor = [UIColor colorWithHexString:@"#585858"].CGColor;
    self.jumpButton.layer.cornerRadius = self.jumpButton.frame.size.height / 2.0;
    
    self.addFamilyButton.layer.cornerRadius = self.addFamilyButton.frame.size.height / 2.0;
}

// 跳过按钮点击
- (IBAction)jumpButtonClick:(id)sender {
    GSHMainTabBarViewController *mainTabBarVC = [[GSHMainTabBarViewController alloc] init];
    [(GSHAppDelegate*)[UIApplication sharedApplication].delegate changeRootController:mainTabBarVC animate:YES];
}

// 添加家庭按钮点击
- (IBAction)addFamilyButtonClick:(id)sender {
    GSHCreateFamilyVC *vc = [GSHCreateFamilyVC createFamilyVCWithFamilyListVC:nil completeBlock:^{
        GSHMainTabBarViewController *mainTabBarVC = [[GSHMainTabBarViewController alloc] init];
        [(GSHAppDelegate*)[UIApplication sharedApplication].delegate changeRootController:mainTabBarVC animate:YES];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
