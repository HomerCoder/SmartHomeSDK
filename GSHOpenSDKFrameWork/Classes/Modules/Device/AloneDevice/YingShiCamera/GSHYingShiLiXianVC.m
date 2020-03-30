//
//  GSHYingShiLiXianVC.m
//  SmartHome
//
//  Created by gemdale on 2018/8/29.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiLiXianVC.h"
#import "GSHYingShiDeviceCategoryVC.h"
#import "GSHConfigWifiInfoVC.h"

@interface GSHYingShiLiXianVC ()
- (IBAction)touchPeiZhi:(UIButton *)sender;
@property (strong, nonatomic)GSHDeviceM *device;
@property (weak, nonatomic) IBOutlet UIView *viewSheXiangJi;
@property (weak, nonatomic) IBOutlet UIView *viewMaoYan;
@end

@implementation GSHYingShiLiXianVC

+(instancetype)yingShiLiXianVCWithDevice:(GSHDeviceM*)device{
    GSHYingShiLiXianVC *vc =  [GSHPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingShiLiXianVC"];
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.device.deviceType.integerValue == 15) {
        self.title = @"设备离线帮助";
        self.viewMaoYan.hidden = NO;
        self.viewSheXiangJi.hidden = YES;
    }else{
        self.title = @"设备离线";
        self.viewMaoYan.hidden = YES;
        self.viewSheXiangJi.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchPeiZhi:(UIButton *)sender {
    GSHConfigWifiInfoVC *vc = [GSHConfigWifiInfoVC configWifiInfoVCWithDeviceM:self.device];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
