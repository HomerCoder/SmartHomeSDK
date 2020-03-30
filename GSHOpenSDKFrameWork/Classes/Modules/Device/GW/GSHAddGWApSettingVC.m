//
//  GSHAddGWApSettingVC.m
//  SmartHome
//
//  Created by gemdale on 2019/12/18.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAddGWApSettingVC.h"
#import "GSHAPConfigWifiInfoVC.h"

@interface GSHAddGWApSettingVC ()
@property (strong, nonatomic)NSString *sn;
@property (strong, nonatomic)NSString *wifiName;
@property (strong, nonatomic)NSString *wifiPassWord;
- (IBAction)touchNext:(UIButton *)sender;
@end

@implementation GSHAddGWApSettingVC

+(instancetype)addGWApSettingVCWithSn:(NSString*)sn wifiName:(NSString*)wifiName wifiPassWord:(NSString*)wifiPassWord{
    GSHAddGWApSettingVC *vc = [GSHPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHAddGWApSettingVC"];
    vc.sn = sn;
    vc.wifiName = wifiName;
    vc.wifiPassWord = wifiPassWord;
    return vc;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)touchNext:(UIButton *)sender {
    GSHAPConfigWifiInfoVC *vc = [GSHAPConfigWifiInfoVC apConfigWifiInfoVCWithGW:self.sn wifiName:self.wifiName wifiPassWord:self.wifiPassWord];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
