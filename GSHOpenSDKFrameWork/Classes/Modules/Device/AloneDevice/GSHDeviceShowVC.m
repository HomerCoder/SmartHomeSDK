//
//  GSHDeviceShowVC.m
//  SmartHome
//
//  Created by gemdale on 2019/11/21.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDeviceShowVC.h"

@interface GSHDeviceShowVC ()
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
- (IBAction)touchClose:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcBotton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcBotton1;
@end

@implementation GSHDeviceShowVC

+(instancetype)deviceShowVCWithVC:(GSHDeviceVC*)vc{
    GSHDeviceShowVC *deviceShowVC = [GSHPageManager viewControllerWithClass:GSHDeviceShowVC.class nibName:@"GSHDeviceShowVC"];
    [deviceShowVC addChildViewController:vc];
    return deviceShowVC;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIViewController *childVC = self.childViewControllers.firstObject;
    [self.viewContent addSubview:childVC.view];
    __weak typeof(self) weakSelf = self;
    [childVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.viewContent);
    }];
    
    [self observerNotifications];
}

-(void)observerNotifications{
    [self observerNotification:GSHUserMChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHUserMChangeNotification]) {
        [self close];
    }
}

-(void)dealloc{
    [self removeNotifications];
}

- (IBAction)touchClose:(UIButton *)sender {
    [self close];
}

-(void)show{
    [super show];
    __weak typeof(self)weakSelf = self;
    self.lcBotton.constant = -24;
    self.lcBotton1.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [weakSelf.view layoutIfNeeded];
    }];
}

-(void)hideTopView:(BOOL)hide{
    self.viewTop.hidden = hide;
}
@end
