//
//  GSHAddGWApIntroVC.m
//  SmartHome
//
//  Created by gemdale on 2019/12/18.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAddGWApIntroVC.h"
#import "GSHConfigWifiInfoVC.h"

@interface GSHAddGWApIntroVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblModelName;
@property (weak, nonatomic) IBOutlet UILabel *lblMac;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
- (IBAction)touchNext:(UIButton *)sender;

@property (assign, nonatomic)BOOL bind;
@property (copy, nonatomic)NSString *sn;
@property (strong, nonatomic)GSHDeviceModelM *model;
@end

@implementation GSHAddGWApIntroVC

+(instancetype)addGWApIntroVCWithSn:(NSString*)sn deviceModel:(GSHDeviceModelM*)model bind:(BOOL)bind{
    GSHAddGWApIntroVC *vc = [GSHPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHAddGWApIntroVC"];
    vc.model = model;
    vc.sn = sn;
    vc.bind = bind;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblModelName.text = @"网关基础版";
    self.lblMac.text = [NSString stringWithFormat:@"MAC:%@",self.sn];
    if (self.bind) {
        self.imageView.image = [UIImage ZHImageNamed:@"addGW_ap_image_icon_2"];
        self.btnNext.hidden = YES;
        self.lblError.hidden = NO;
    }else{
        self.imageView.image = [UIImage ZHImageNamed:@"addGW_ap_image_icon_1"];
        self.btnNext.hidden = NO;
        self.lblError.hidden = YES;
    }
}

- (IBAction)touchNext:(UIButton *)sender {
    GSHConfigWifiInfoVC *vc = [GSHConfigWifiInfoVC configWifiInfoVCWithGW:self.sn];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
