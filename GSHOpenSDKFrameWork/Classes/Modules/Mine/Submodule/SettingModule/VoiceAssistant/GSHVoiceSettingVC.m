//
//  GSHVoiceSettingVC.m
//  SmartHome
//
//  Created by gemdale on 2019/11/20.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHVoiceSettingVC.h"
#import "GSHThirdPartyVoiceVC.h"

NSString *const GSHVoiceSettingVCStateChangeNotification = @"GSHVoiceSettingVCStateChangeNotification";

@interface GSHVoiceSettingVC ()
- (IBAction)touchSettingVoice:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switchOpen;
@end

@implementation GSHVoiceSettingVC

+(instancetype)voiceSettingVC{
    GSHVoiceSettingVC *vc = [GSHPageManager viewControllerWithSB:@"VoiceAssistantSB" andID:@"GSHVoiceSettingVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([GSHUserManager currentUser].voiceStatus.intValue == 1) {
        self.switchOpen.on = NO;
    }else{
        self.switchOpen.on = YES;
    }
}

-(void)dealloc{
    [GSHUserManager postUpdateUserInfoWithParameter:@{@"voiceStatus":self.switchOpen.on ? @(2) : @(1)} block:^(GSHUserInfoM *userInfo, NSError *error) {
    }];
}

#pragma mark - Table view data source

- (IBAction)touchSettingVoice:(UISwitch *)sender {
    if (self.switchOpen.on) {
        [GSHUserManager currentUser].voiceStatus = @(2);
    }else{
        [GSHUserManager currentUser].voiceStatus = @(1);
    }
    [self postNotification:GSHVoiceSettingVCStateChangeNotification object:[GSHUserManager currentUser].voiceStatus];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        [self.navigationController pushViewController:[GSHThirdPartyVoiceVC thirdPartyVoiceVC] animated:YES];
    }
    return NO;
}
@end
