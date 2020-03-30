//
//  GSHGateWayUpdateVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/1/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHGateWayUpdateVC.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "UIView+TZMPageStatusViewEx.h"
#import <SDWebImage/UIImage+GIF.h>
#import "NSString+TZM.h"
#import "NSObject+TZM.h"

NSString *const GSHGateWayUpdateResult = @"GSHGateWayUpdateResult";

@interface GSHGateWayUpdateVC ()

@property (weak, nonatomic) IBOutlet UITableView *updateTableView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIImageView *loadImageView;

@property (nonatomic ,strong) GSHGatewayVersionM *gateWayVersionM;
@property (strong, nonatomic) CABasicAnimation *animation;

@end

@implementation GSHGateWayUpdateVC

+ (instancetype)gateWayUpdateVC {
    GSHGateWayUpdateVC *vc = [GSHPageManager viewControllerWithSB:@"GSHGateWaySettingSB" andID:@"GSHGateWayUpdateVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *leftImage = [[UIImage ZHImageNamed:@"app_icon_blackback_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:leftImage style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    [self getGatewayUpdateMsg];
    
    [self observerNotifications];
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:GSHGateWayUpdateResult];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHGateWayUpdateResult]) {
        [self getGatewayUpdateMsg];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 1) {
        return 52;
    } else {
        return 70 + [self.gateWayVersionM.descInfo tzm_getStrHeightWithFontSize:15.0 labelWidth:SCREEN_WIDTH - 30];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 || indexPath.row == 1) {
        GSHGateWayUpdateFirstCell *firstCell = [tableView dequeueReusableCellWithIdentifier:@"GSHGateWayUpdateFirstCell" forIndexPath:indexPath];
        firstCell.cellTypeNameLabel.text = indexPath.row == 0 ? @"新版本号" : @"版本大小";
        firstCell.cellValueLabel.text = indexPath.row == 0 ? [NSString stringWithFormat:@"v%@",self.gateWayVersionM.versionTarget] : [NSString stringWithFormat:@"%@M",self.gateWayVersionM.size];
        return firstCell;
    } else {
        GSHGateWayUpdateSecondCell *secondCell = [tableView dequeueReusableCellWithIdentifier:@"GSHGateWayUpdateSecondCell" forIndexPath:indexPath];
        secondCell.updateInfoLabel.text = self.gateWayVersionM.descInfo?self.gateWayVersionM.descInfo:@"";
        return secondCell;
    }
    
}

#pragma mark - method

- (IBAction)updateButtonClick:(id)sender {
    
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"操作中" inView:self.view];
    [GSHGatewayManager updateGatewayWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId gatewayId:[GSHOpenSDKShare share].currentFamily.gatewayId versionId:self.gateWayVersionM.versionId block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"操作成功" inView:self.view];
            [self showUpdatingButton];
        }
    }];
    
}

- (void)back {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - request
// 获取网关升级信息
- (void)getGatewayUpdateMsg {
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"网关升级信息获取中" inView:self.view];
    [GSHGatewayManager getGatewayUpdateMsgWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId gatewayId:[GSHOpenSDKShare share].currentFamily.gatewayId block:^(GSHGatewayVersionM *gateWayVersionM, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager dismissInView:self.view];
            @weakify(self)
            TZMPageStatusView *statusView = [self.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"gatewaySetting_blank_pic_gateway"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                @strongify(self)
                [self getGatewayUpdateMsg];
            }];
            statusView.backgroundColor = [UIColor whiteColor];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            self.gateWayVersionM = gateWayVersionM;
            if (self.gateWayVersionM.updateFlag.intValue == 1) {
                [self showBlankView];
                self.updateButton.hidden = YES;
            } else {
                if (self.gateWayVersionM.updateFlag.intValue == 2) {
                    [self showUpdatingButton];
                } else if (self.gateWayVersionM.updateFlag.intValue == 0 ||
                           self.gateWayVersionM.updateFlag.intValue == 3) {
                    [self showHasNewVersionButton];
                }
                [self.updateTableView reloadData];
            }
        }
    }];
}

- (void)showBlankView {
    
    TZMPageStatusView *statusView = [self showPageStatus:TZMPageStatusNormal
                   image:[UIImage ZHImageNamed:@"gatewaySetting_blank_pic_gateway"]
                   title:nil
                    desc:@"当前已是最新版本"
              buttonText:nil
  didClickButtonCallback:nil];
    statusView.backgroundColor = [UIColor whiteColor];
}

// 显示按钮正在升级的状态
- (void)showUpdatingButton {
    [self.updateButton setTitle:@"正在升级" forState:UIControlStateNormal];
    self.loadImageView.hidden = NO;
    [self.loadImageView.layer addAnimation:self.animation forKey:nil];
    self.updateButton.enabled = NO;
    self.updateButton.alpha = 0.3;
}

// 显示有升级版本时按钮状态
- (void)showHasNewVersionButton {
    [self.updateButton setTitle:@"版本升级" forState:UIControlStateNormal];
    self.loadImageView.hidden = YES;
    self.updateButton.enabled = YES;
    self.updateButton.alpha = 1;
}

- (CABasicAnimation *)animation {
    if (!_animation) {
        _animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
        _animation.fromValue = [NSNumber numberWithFloat:0.f];
        _animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
        _animation.duration  = 1;
        _animation.autoreverses = NO;
        _animation.removedOnCompletion = NO;
        _animation.fillMode =kCAFillModeForwards;
        _animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    }
    return _animation;
}


@end

@implementation GSHGateWayUpdateFirstCell

@end

@implementation GSHGateWayUpdateSecondCell

@end


