//
//  GSHMessageNotiSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/11/29.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHMessageNotiSetVC.h"
#import "GSHAlertManager.h"

@interface GSHMessageNotiSetVC ()

@property (nonatomic,strong) GSHMessageM *messageM;

@property (weak, nonatomic) IBOutlet UISwitch *systemMsgSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *alarmMsgSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *msgNoDisturbSwitch;


@end

@implementation GSHMessageNotiSetVC {
    NSArray *_cellNameArr;
}

+ (instancetype)messageNotiSetVC {
    return [GSHPageManager viewControllerWithSB:@"GSHMessageSB" andID:@"GSHMessageNotiSetVC"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getMsgConfig];
}

#pragma mark - method

- (IBAction)switchClick:(UISwitch *)sender {
    NSInteger tag = sender.tag;
    GSHMsgTypeKey msgTypeKey;
    if (tag == 1) {
        // 系统消息
        msgTypeKey = GSHMsgTypeKeySystemWarn;
        NSString *value = sender.on ? @"0" : @"1";
        [self updateMsgConfigWithGSHMsgTypeKey:msgTypeKey value:value notiSiwtch:sender];
    } else if (tag == 2) {
        // 告警消息
        msgTypeKey = GSHMsgTypeKeyAlarmWarn;
        if (!sender.on) {
            @weakify(self)
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                @strongify(self)
                if (buttonIndex == 1) {
                    [self updateMsgConfigWithGSHMsgTypeKey:msgTypeKey value:@"1" notiSiwtch:sender];
                } else {
                    sender.on = !sender.on;
                }
            } textFieldsSetupHandler:nil andTitle:nil andMessage:@"关闭后，家庭安防设备报警时，将无法收到推送，请谨慎操作" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
        } else {
            [self updateMsgConfigWithGSHMsgTypeKey:msgTypeKey value:@"0" notiSiwtch:sender];
        }
    } else {
        // 消息免打扰
        msgTypeKey = GSHMsgTypeKeyNoDisturb;
        NSString *value = sender.on ? @"1" : @"0";
        [self updateMsgConfigWithGSHMsgTypeKey:msgTypeKey value:value notiSiwtch:sender];
    }
    
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.f;
}

#pragma mark - request
// App用户获取消息提醒设置
- (void)getMsgConfig {
    
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHMessageManager getMsgConfigWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(GSHMessageM *messageM, NSError * _Nonnull error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        } else {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.messageM = messageM;
            self.alarmMsgSwitch.on = messageM.alarmWarn.intValue == 1 ? NO : YES;
            self.systemMsgSwitch.on = messageM.systemWarn.intValue == 1 ? NO : YES;
            self.msgNoDisturbSwitch.on = messageM.noDisturb.intValue == 1 ? YES : NO;
        }
    }];
    
}

// App用户修改消息提醒设置
- (void)updateMsgConfigWithGSHMsgTypeKey:(GSHMsgTypeKey)msgTypeKey value:(NSString *)value notiSiwtch:(UISwitch *)notiSwitch {
    [TZMProgressHUDManager showWithStatus:@"修改中" inView:self.view];
    __weak typeof(notiSwitch) weakNotiSwitch = notiSwitch;
    __weak typeof(self)weakSelf = self;
    [GSHMessageManager updateMsgConfigWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId msgTypeKeyStr:msgTypeKey value:value block:^(NSError * _Nonnull error) {
        __strong typeof(weakNotiSwitch) strongNotiSwitch = weakNotiSwitch;
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            strongNotiSwitch.on = !strongNotiSwitch.on;
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"修改成功" inView:weakSelf.view];
        }
    }];
}


@end

