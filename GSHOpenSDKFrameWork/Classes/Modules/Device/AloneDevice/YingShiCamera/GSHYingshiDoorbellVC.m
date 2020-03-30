//
//  GSHYingshiDoorbellVC.m
//  SmartHome
//
//  Created by gemdale on 2019/5/15.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHYingshiDoorbellVC.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#import <AVFoundation/AVFoundation.h>
#import "GSHAlertManager.h"
#import "TZMVoIPPushManager.h"

@interface GSHYingshiDoorbellVC ()<EZPlayerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIView *viewPlay;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *acticity;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewRealBg;
@property (weak, nonatomic) IBOutlet UIButton *btnStartReal;
- (IBAction)touchStartReal:(UIButton *)sender;
- (IBAction)touchHangup:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAnswer;
- (IBAction)touchAnswer:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnMute;
- (IBAction)touchMute:(UIButton *)sender;

@property(nonatomic,copy)NSString *deviceSn;
@property(nonatomic,copy)NSString *validateCode;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *alarmId;
@property(nonatomic,assign)NSInteger cameraNo;

@property(nonatomic, strong)EZPlayer *realPlayer;
@property(nonatomic, strong)EZPlayer *talkPlayer;
@end

@implementation GSHYingshiDoorbellVC

+(instancetype)yingshiDoorbellVCWithDeviceSn:(NSString*)deviceSn cameraNo:(NSInteger)cameraNo validateCode:(NSString*)validateCode name:(NSString*)name alarmId:(NSString*)alarmId{
    GSHYingshiDoorbellVC *vc =  [GSHPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingshiDoorbellVC"];
    vc.deviceSn = deviceSn;
    vc.cameraNo = cameraNo;
    vc.validateCode = validateCode;
    vc.name = name;
    vc.alarmId = alarmId;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblName.text = self.name;
    [self initRealPlay];
    [self initVoicePlayer];
    [self performSelector:@selector(touchHangup:) afterDelay:30];
    [[TZMVoIPPushManager shared]startPlaySound];
}

-(void)dealloc{
    [TZMVoIPPushManager shared].canPlaySound = YES;
    [[TZMVoIPPushManager shared] stopPlaySound];
    [self.realPlayer destoryPlayer];
    [self.talkPlayer destoryPlayer];
}

#pragma --mark --------------------初始化方法-----------------------------
- (void)initRealPlay{
    self.realPlayer = [EZOpenSDK createPlayerWithDeviceSerial:self.deviceSn cameraNo:self.cameraNo];
    self.realPlayer.delegate = self;
    [self.realPlayer setPlayVerifyCode:self.validateCode];
    [self.realPlayer setPlayerView:self.viewPlay];
    [self startRealPlay];
}

- (void)initVoicePlayer{
    self.talkPlayer = [EZOpenSDK createPlayerWithDeviceSerial:self.deviceSn cameraNo:self.cameraNo];
    self.talkPlayer.delegate = self;
    [self.talkPlayer setPlayVerifyCode:self.validateCode];
}

- (void)startRealPlay{
    if ([self.realPlayer startRealPlay]) {
        [self.acticity startAnimating];
        self.btnStartReal.hidden = YES;
    }
}

- (void)startVoiceTalk{
    __weak typeof(self)weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        dispatch_async_on_main_queue(^{
            if (granted) {
                if ([weakSelf.talkPlayer startVoiceTalk]) {
                    weakSelf.lblName.text = @"开启对讲中";
                }
            }else{
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if([[UIApplication sharedApplication] canOpenURL:url]) {
                            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }
                } textFieldsSetupHandler:NULL andTitle:@"未打开麦克风权限" andMessage:@"请打开权限后重试" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"去打开",@"取消",nil];
            }
        });
    }];
}

#pragma --mark --------------------播放代理-----------------------------
//播放器播放失败错误回调
- (void)player:(EZPlayer *)player didPlayFailed:(NSError *)error{
    __weak typeof(self)weakSelf = self;
    if(error.code == EZ_HTTPS_ACCESS_TOKEN_INVALID ||
       error.code == EZ_HTTPS_ACCESS_TOKEN_EXPIRE){
        //token错误
        [GSHYingShiManager updataAccessTokenWithBlock:^(NSString *token, NSError *error) {
            if(error){
                //获取token错误
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                if (player == weakSelf.realPlayer) {
                    weakSelf.btnStartReal.hidden = NO;
                    [weakSelf.acticity stopAnimating];
                }else if (player == weakSelf.talkPlayer){
                    weakSelf.lblName.text = @"连接失败";
                }
            }else{
                //获取token成功
                if (player == weakSelf.realPlayer) {
                    [weakSelf startRealPlay];
                }else if (player == weakSelf.talkPlayer){
                    [weakSelf startVoiceTalk];
                }
            }
        }];
    }else{
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        if (player == weakSelf.realPlayer) {
            self.btnStartReal.hidden = NO;
            [self.acticity stopAnimating];
        }else if (player == self.talkPlayer){
            self.lblName.text = @"连接失败";
        }
    }
}

//播放器消息回调
- (void)player:(EZPlayer *)player didReceivedMessage:(NSInteger)messageCode{
    if (player == self.realPlayer){
        [self.acticity stopAnimating];
        if (messageCode == PLAYER_REALPLAY_START) {
        }
    }
    if (player == self.talkPlayer){
        self.btnAnswer.hidden = YES;
        self.btnMute.hidden = NO;
        if (messageCode == PLAYER_VOICE_TALK_START) {
            self.btnMute.selected = NO;
            self.lblName.text = @"对讲中";
        }
        if (messageCode == PLAYER_VOICE_TALK_END) {
            self.lblName.text = @"对讲结束";
            self.btnMute.selected = YES;
        }
    }
}

- (IBAction)touchStartReal:(UIButton *)sender {
    [self startRealPlay];
}

- (IBAction)touchHangup:(UIButton *)sender {
    [[TZMVoIPPushManager shared] stopPlaySound];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)touchAnswer:(UIButton *)sender {
    [[TZMVoIPPushManager shared] stopPlaySound];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self startVoiceTalk];
    if (self.alarmId) {
        [GSHYingShiManager postPickUpCallingWithAlarmId:self.alarmId block:^(NSError *error) {
        }];
    }
}

- (IBAction)touchMute:(UIButton *)sender {
    if (sender.selected) {
        if ([self.talkPlayer startVoiceTalk]) {
            self.lblName.text = @"开启对讲中";
        }
    }else{
        if ([self.talkPlayer stopVoiceTalk]) {
            self.lblName.text = @"停止对讲中";
        }
    }
}
@end
