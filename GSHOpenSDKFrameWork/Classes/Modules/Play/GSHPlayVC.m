//
//  GSHPlayVC.m
//  SmartHome
//
//  Created by gemdale on 2019/12/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHPlayVC.h"
#import <TZMOpenLib/UINavigationController+TZM.h>

@interface GSHPlayVC ()
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UILabel *label;
@property(nonatomic,strong)UIButton *but;
@end

@implementation GSHPlayVC

+(instancetype)playVC{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@([GSHOpenSDKShare share].currentFamily.permissions) forKey:@"permissions"];
    [dic setValue:[GSHOpenSDKShare share].currentFamily.familyId forKey:@"familyId"];
    NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypePaly parameter:dic];
    GSHPlayVC *vc = [[GSHPlayVC alloc] initWithURL:url];
    return vc;
}

- (void)viewDidLoad {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@([GSHOpenSDKShare share].currentFamily.permissions) forKey:@"permissions"];
    [dic setValue:[GSHOpenSDKShare share].currentFamily.familyId forKey:@"familyId"];
    NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypePaly parameter:dic];
    self.URL = url;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tzm_prefersNavigationBarHidden = YES;
    
    self.topView = [[UIView alloc] initWithFrame:CGRectZero];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topView];

    self.label = [[UILabel alloc] initWithFrame:CGRectZero];
    self.label.textColor = [UIColor colorWithHexString:@"#222222"];
    self.label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.text = @"玩转";
    [self.topView addSubview:self.label];
    
    self.but = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.but setImage:[UIImage ZHImageNamed:@"playVC_search"] forState:UIControlStateNormal];
    [self.but addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.but];
    
    [self observerNotifications];
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:GSHOpenSDKFamilyChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHOpenSDKFamilyChangeNotification]) {
        [self updateFamily];
    }
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    UIView *contentView = self.view.subviews.firstObject;
    contentView.frame = CGRectMake(0, self.topView.size.height, self.topView.size.width, self.view.size.height - self.topView.size.height);
    self.label.frame = CGRectMake(16, KStatusBar_Height, 100, 50);
    self.topView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50 + KStatusBar_Height);
    self.but.frame = CGRectMake(self.topView.frame.size.width - 56, KStatusBar_Height, 56, 50);
    
    if (self.progressView.superview != self.view) {
        [self.progressView removeFromSuperview];
        [self.view addSubview:self.progressView];
    }
    self.progressView.frame = CGRectMake(0, self.topView.size.height, self.topView.size.width, 2);
}

-(void)search{
    [self.webView callHandler:@"clickNavRightBut" arguments:nil];
}

-(void)updateFamily{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[GSHOpenSDKShare share].currentFamily.familyId forKey:@"familyId"];
    [dic setValue:@([GSHOpenSDKShare share].currentFamily.permissions) forKey:@"permissions"];
    [self.webView callHandler:@"updateFamily" arguments:@[dic.yy_modelToJSONString]];
}

@end
