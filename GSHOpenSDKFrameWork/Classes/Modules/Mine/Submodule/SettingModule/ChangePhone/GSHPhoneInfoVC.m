//
//  GSHPhoneInfoVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/15.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHPhoneInfoVC.h"
#import "GSHOldPhoneVerifyVC.h"

@interface GSHPhoneInfoVC ()
@property(nonatomic,strong)GSHUserInfoM *userInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
- (IBAction)touchChange:(UIButton *)sender;
@end

@implementation GSHPhoneInfoVC

+(instancetype)phoneInfoVCWithUserInfo:(GSHUserInfoM*)userInfo{
    GSHPhoneInfoVC *vc =[GSHPageManager viewControllerWithSB:@"GSHChangePhoneSB" andID:@"GSHPhoneInfoVC"];
    vc.userInfo = userInfo;
    return vc;
}

-(void)setUserInfo:(GSHUserInfoM *)userInfo{
    _userInfo = userInfo;
    self.lblPhone.text = [NSString stringWithFormat:@"你的手机号：%@ **** %@",[userInfo.phone substringToIndex:3],[userInfo.phone substringFromIndex:7]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userInfo = self.userInfo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchChange:(UIButton *)sender {
    GSHOldPhoneVerifyVC *vc = [GSHOldPhoneVerifyVC oldPhoneVerifyVCWithUserInfo:self.userInfo];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
