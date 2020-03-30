//
//  GSHYingShiPlayerVC.m
//  SmartHome
//
//  Created by gemdale on 2019/5/13.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHYingShiPlayerVC.h"
#import "TZMPhotoLibraryManager.h"
#import "GSHYingShiLiXianVC.h"
#import "GSHSpreadAnimationView.h"
#import "GSHAlertManager.h"
#import <AFNetworking.h>
#import "NSObject+TZM.h"
#import "UIImageView+WebCache.h"

@interface GSHYingShiPlayerVC ()<EZPlayerDelegate>
@property(nonatomic, strong)EZPlayer *realPlayer;
@property(nonatomic, strong)EZPlayer *talkPlayer;
@property(nonatomic, strong)NSTimer *timer;

@property(atomic, assign)int saveElectricitySecond;
@property(atomic, assign)BOOL saveElectricityTimer;
@property(atomic, assign)int jieShiPingSecond;
@property(atomic, assign)BOOL jieShiPingTimer;
@property(nonatomic, copy)NSString *shiPingPath;

@property(nonatomic, strong)GSHDeviceM *device;
@property(nonatomic, assign)NSInteger isSupportTalk;
@property(nonatomic, assign)EZVideoLevelType videoLevelType;
@property(nonatomic, assign)NSInteger cameraNo;

//播放视图
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIView *playView;
//暂停保留视图
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCapturePicture;

//清晰度逻辑
@property (weak, nonatomic) IBOutlet UIButton *btnQingXiDu;
@property (weak, nonatomic) IBOutlet UIView *viewQingXiDu;
@property (weak, nonatomic) IBOutlet UIButton *btnChaoQing;
@property (weak, nonatomic) IBOutlet UIButton *btnGaoQing;
@property (weak, nonatomic) IBOutlet UIButton *btnBiaoQing;
@property (weak, nonatomic) IBOutlet UIButton *btnLiuChang;
- (IBAction)touchQingXiDu:(id)sender;
- (IBAction)changeQingXiDu:(UIButton *)sender;

//播放逻辑
@property (weak, nonatomic) IBOutlet UIButton *btnStartV;
@property (weak, nonatomic) IBOutlet UIButton *btnStartH;
@property (weak, nonatomic) IBOutlet UIButton *btnPaly;
- (IBAction)touchPlay:(UIButton *)sender;

//静音逻辑
@property (weak, nonatomic) IBOutlet UIButton *butJingYinV;
@property (weak, nonatomic) IBOutlet UIButton *butJingYinH;
- (IBAction)touchJingYin:(id)sender;

//对讲逻辑
- (IBAction)startShuoHua:(UIButton *)sender;
- (IBAction)endShuoHua:(UIButton *)sender;
- (IBAction)cancelDuiJiang:(UIButton *)sender;
- (IBAction)touchDuiJiang:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblDuiJiangTishiH;
@property (weak, nonatomic) IBOutlet UILabel *lblDuiJiangTiShiV;
@property (weak, nonatomic) IBOutlet UIView *viewDuiJiangH;
@property (weak, nonatomic) IBOutlet UIView *viewDuiJiangV;
@property (weak, nonatomic) IBOutlet UIButton *btnDuiJiangH;
@property (weak, nonatomic) IBOutlet UIButton *btnDuiJiangV;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelDuiJiangV;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelDuijiangH;
@property (weak, nonatomic) IBOutlet UIButton *btnStartDuiJiangV;
@property (weak, nonatomic) IBOutlet UIButton *btnStartDuiJiangH;
@property (weak, nonatomic) IBOutlet UIView *viewDuiJiang;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcDuiJiangTop;
@property (weak, nonatomic) IBOutlet GSHSpreadAnimationView *svpreadAnimationView;

//截视屏
@property (weak, nonatomic) IBOutlet UIButton *btnJieShiPingV;
@property (weak, nonatomic) IBOutlet UIButton *btnJieShiPingH;
@property (weak, nonatomic) IBOutlet UIView *viewJieShiPingTime;
@property (weak, nonatomic) IBOutlet UILabel *lblJieShiPingTime;
@property (weak, nonatomic) IBOutlet UIView *viewJieShiPingRedDot;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcJieShiPingTop;
- (IBAction)touchJieShiPing:(UIButton *)sender;

//截图
- (IBAction)touchJieTu:(UIButton *)sender;
- (IBAction)touchToPhoneLib:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnCapture;
@property (weak, nonatomic) IBOutlet UILabel *lblCature;
@property (weak, nonatomic) IBOutlet UIView *viewCature;

//进入横屏和退出横屏
- (IBAction)touchFangda:(UIButton *)sender;
- (IBAction)touchFanHui:(UIButton *)sender;

//省电
@property (weak, nonatomic) IBOutlet UIView *viewSaveElectricity;
@property (weak, nonatomic) IBOutlet UILabel *lblSaveElectricity;
- (IBAction)touchSaveElectricityStop:(UIButton *)sender;
- (IBAction)touchSaveElectricityStart:(UIButton *)sender;
@end

@implementation GSHYingShiPlayerVC

+(instancetype)yingShiPlayerVCWithDevice:(GSHDeviceM*)device{
    GSHYingShiPlayerVC *vc =  [GSHPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingShiPlayerVC"];;
    vc.device = device;
    return vc;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    UIImage *image = [self.realPlayer capturePicture:100];
    if (!image) {
        image = self.imageViewCapturePicture.image;
    }
    [[SDImageCache sharedImageCache] storeImage:image forKey:self.device.deviceSn toDisk:YES completion:nil];
    if (!self.btnStartV.selected) {
        [self stopRealPlay];
    }
    if (self.btnDuiJiangH.selected) {
        [self.talkPlayer stopVoiceTalk];
    }
}

-(void)setIsShield:(BOOL)isShield{
    _isShield = isShield;
    [self stopRealPlay];
}

-(void)setVideoLevelType:(EZVideoLevelType)videoLevelType{
    _videoLevelType = videoLevelType;
    
    self.viewQingXiDu.hidden = YES;
    self.btnGaoQing.selected = NO;
    self.btnChaoQing.selected = NO;
    self.btnBiaoQing.selected = NO;
    self.btnLiuChang.selected = NO;
    switch (_videoLevelType) {
        case EZVideoLevelHigh:
            self.btnGaoQing.selected = YES;
            [self.btnQingXiDu setTitle:@"高清" forState:UIControlStateNormal];
            break;
        case EZVideoLevelSuperHigh:
            self.btnChaoQing.selected = YES;
            [self.btnQingXiDu setTitle:@"超清" forState:UIControlStateNormal];
            break;
        case EZVideoLevelMiddle:
            self.btnBiaoQing.selected = YES;
            [self.btnQingXiDu setTitle:@"均衡" forState:UIControlStateNormal];
            break;
        default:
            self.btnLiuChang.selected = YES;
            [self.btnQingXiDu setTitle:@"流畅" forState:UIControlStateNormal];
            break;
    }
}

-(void)updateDeviceInfo:(EZDeviceInfo *)deviceInfo{
    EZCameraInfo *camera = deviceInfo.cameraInfo.firstObject;
    if ([camera isKindOfClass:EZCameraInfo.class]) {
        self.cameraNo = camera.cameraNo;
        self.btnChaoQing.hidden = YES;
        self.btnGaoQing.hidden = YES;
        self.btnBiaoQing.hidden = YES;
        self.btnLiuChang.hidden = YES;
        EZVideoLevelType type = EZVideoLevelMiddle;
        if ([camera.videoQualityInfos.firstObject isKindOfClass:EZVideoQualityInfo.class]) {
            type = ((EZVideoQualityInfo*)camera.videoQualityInfos.firstObject).videoLevel;
        }
        for (EZVideoQualityInfo *qualityInfo in camera.videoQualityInfos) {
            if ([qualityInfo isKindOfClass:EZVideoQualityInfo.class]) {
                if (qualityInfo.videoLevel == camera.videoLevel) {
                    type = qualityInfo.videoLevel;
                }
                switch (qualityInfo.videoLevel) {
                    case EZVideoLevelHigh:
                        self.btnGaoQing.hidden = NO;
                        break;
                    case EZVideoLevelSuperHigh:
                        self.btnChaoQing.hidden = NO;
                        break;
                    case EZVideoLevelMiddle:
                        self.btnBiaoQing.hidden = NO;
                        break;
                    default:
                        self.btnLiuChang.hidden = NO;
                        break;
                }
            }
        }
        self.videoLevelType = type;
    }
    
    self.isSupportTalk = deviceInfo.isSupportTalk;
    switch (deviceInfo.isSupportTalk) {
        case 0:
            //不支持对讲
            break;
        case 1:
            //支持全双工
            self.lblDuiJiangTishiH.text = @"挂断";
            self.lblDuiJiangTiShiV.text = @"挂断";
            self.btnCancelDuijiangH.hidden = YES;
            self.btnCancelDuiJiangV.hidden = YES;
            [self.btnStartDuiJiangH setImage:[UIImage ZHImageNamed:@"yingShiCameraVC_duijiang_end_touch_icon"] forState:UIControlStateNormal];
            [self.btnStartDuiJiangV setImage:[UIImage ZHImageNamed:@"yingShiCameraVC_duijiang_end_touch_icon"] forState:UIControlStateNormal];
            break;
        default:
            //半双工
            self.lblDuiJiangTishiH.text = @"按住说话，松开收听";
            self.lblDuiJiangTiShiV.text = @"按住说话，松开收听";
            self.btnCancelDuijiangH.hidden = NO;
            self.btnCancelDuiJiangV.hidden = NO;
            [self.btnStartDuiJiangH setImage:[UIImage ZHImageNamed:@"yingShiCameraVC_duijiang_touch_icon"] forState:UIControlStateNormal];
            [self.btnStartDuiJiangV setImage:[UIImage ZHImageNamed:@"yingShiCameraVC_duijiang_touch_icon"] forState:UIControlStateNormal];
            break;
    }
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (size.width > size.height) {
        // 横屏
        self.btnCancelDuijiangH.hidden = NO;
    } else {
        // 竖屏布局
        self.btnCancelDuijiangH.hidden = YES;
    }
}

-(void)dealloc{
    [self.timer invalidate];
    [self.realPlayer destoryPlayer];
    [self.talkPlayer destoryPlayer];
    [self removeNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageViewCapturePicture.image = [[SDImageCache sharedImageCache] imageFromCacheForKey:self.device.deviceSn];
    if (!self.imageViewCapturePicture.image) {
        if (self.device.deviceType.intValue == 15) {
            self.imageViewCapturePicture.image = [UIImage ZHImageNamed:@"yingShiCameraVC_maoYan_default_bg"];
        }else{
            self.imageViewCapturePicture.image = [UIImage ZHImageNamed:@"yingShiCameraVC_sheXiangJi_default_bg"];
        }
    }
    
    __weak typeof(self)weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
        [weakSelf timing];
    } repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    self.timer.fireDate = [NSDate distantFuture];
    
    self.cameraNo = 1;
    [self initRealPlay];
    [self initVoicePlayer];
    
    [self observerNotifications];
}

-(void)observerNotifications{
    [self observerNotification:UIApplicationWillResignActiveNotification];
    [self observerNotification:AFNetworkingReachabilityDidChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
        if (!self.btnStartV.selected) {
            [self stopRealPlay];
        }
        if (self.btnDuiJiangH.selected) {
            [self.talkPlayer stopVoiceTalk];
        }
    }
    if ([notification.name isEqualToString:AFNetworkingReachabilityDidChangeNotification]) {
        NSNumber *status = [notification.userInfo numverValueForKey:AFNetworkingReachabilityNotificationStatusItem default:nil];
        if (status.intValue == AFNetworkReachabilityStatusNotReachable) {
            [TZMProgressHUDManager showErrorWithStatus:@"网络不给力，请检查网络设置" inView:self.view];
            if (!self.btnStartV.selected) {
                [self stopRealPlay];
            }
            if (self.btnDuiJiangH.selected) {
                [self.talkPlayer stopVoiceTalk];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma --mark --------------------初始化方法-----------------------------
- (void)initRealPlay{
    self.realPlayer = [EZOpenSDK createPlayerWithDeviceSerial:self.device.deviceSn cameraNo:self.cameraNo];
    self.realPlayer.delegate = self;
    [self.realPlayer setPlayVerifyCode:self.device.validateCode];
    [self.realPlayer setPlayerView:self.playView];
}

- (void)initVoicePlayer{
    self.talkPlayer = [EZOpenSDK createPlayerWithDeviceSerial:self.device.deviceSn cameraNo:self.cameraNo];
    self.talkPlayer.delegate = self;
    [self.talkPlayer setPlayVerifyCode:self.device.validateCode];
}

#pragma --mark --------------------操作方法-----------------------------
- (void)timing{
    if (self.jieShiPingTimer) {
        self.viewJieShiPingRedDot.hidden = self.jieShiPingSecond % 2 == 0;
        self.lblJieShiPingTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",self.jieShiPingSecond / 3600,self.jieShiPingSecond % 3600 / 60,self.jieShiPingSecond % 60];
        self.jieShiPingSecond++;
    }
    
    if (self.saveElectricityTimer) {
        if (self.saveElectricitySecond > 10) {
            self.viewSaveElectricity.hidden = YES;
        }else if (self.saveElectricitySecond > 0){
            self.viewSaveElectricity.hidden = NO;
            self.lblSaveElectricity.text = [NSString stringWithFormat:@"为了节省电量，设备将在%d秒后进入休眠并停止播放",self.saveElectricitySecond];
        }else{
            self.viewSaveElectricity.hidden = YES;
            self.saveElectricityTimer = NO;
            if (!self.btnStartH.selected) {
                [self stopRealPlay];
            }
//            if (self.btnDuiJiangH.selected) {
//                [self stopVoiceTalk];
//            }
        }
        self.saveElectricitySecond--;
    }
    
    if ((!self.jieShiPingTimer) && (!self.saveElectricityTimer)) {
        self.timer.fireDate = [NSDate distantFuture];
    }
}

- (void)startRealPlay{
    if ([self.realPlayer startRealPlay]) {
        [TZMProgressHUDManager showWithStatus:@"加载直播中" inView:self.view];
    }else{
        [TZMProgressHUDManager showErrorWithStatus:@"播放失败" inView:self.view];
    }
}

- (void)stopRealPlay{
    UIImage *image = [self.realPlayer capturePicture:100];
    if (image) {
        self.imageViewCapturePicture.image = image;
    }
    if (self.btnJieShiPingH.selected) [self jieShiPing];
    [self.realPlayer stopRealPlay];
    self.btnStartH.selected = YES;
    self.btnPaly.hidden = self.isShield;
    self.btnStartV.selected = YES;
    
    if (self.device.deviceType.intValue == 15){
//        if (!self.btnDuiJiangH.selected) {
            self.viewSaveElectricity.hidden = YES;
            self.saveElectricityTimer = NO;
//        }
    }
}

- (void)startVoiceTalk{
    __weak typeof(self)weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (granted) {
            if ([weakSelf.talkPlayer startVoiceTalk]) {
                [TZMProgressHUDManager showWithStatus:@"启动对讲中" inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager showErrorWithStatus:@"启动失败" inView:weakSelf.view];
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
    }];
}

- (void)stopVoiceTalk{
    [TZMProgressHUDManager showWithStatus:@"结束对讲中" inView:self.view];
    [self.talkPlayer stopVoiceTalk];
}

-(void)hideCature{
    self.viewCature.hidden = YES;
}

-(void)changeVideoLevel:(EZVideoLevelType)type{
    if (self.videoLevelType == type) {
        self.viewQingXiDu.hidden = YES;
        return;
    }
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"切换中，请稍候" inView:self.view];
    [EZOpenSDK setVideoLevel:self.device.deviceSn cameraNo:self.cameraNo videoLevel:type completion:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [weakSelf stopRealPlay];
            [weakSelf startRealPlay];
            weakSelf.videoLevelType = type;
        }
    }];
}

-(void)jieTu{
    UIImage *image = [self.realPlayer capturePicture:100];
    if (image) {
        __weak typeof(self)weakSelf = self;
        [TZMProgressHUDManager showWithStatus:@"保存截图中" inView:self.view];
        [TZMPhotoLibraryManager saveImageIntoAlbumWithImage:image block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager showSuccessWithStatus:@"截图已经保存到相册" inView:weakSelf.view];
                [weakSelf.btnCapture setBackgroundImage:image forState:UIControlStateNormal];
                [weakSelf.btnCapture setBackgroundImage:image forState:UIControlStateHighlighted];
                weakSelf.lblCature.text = @"点击查看截图";
                weakSelf.viewCature.hidden = NO;
                [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(hideCature) object:nil];
                [weakSelf performSelector:@selector(hideCature) withObject:nil afterDelay:5];
            }
        }];
    }else{
        if (self.btnStartH.selected) {
            [TZMProgressHUDManager showErrorWithStatus:@"请打开直播后再截图" inView:self.view];
        }else{
            [TZMProgressHUDManager showErrorWithStatus:@"截图失败" inView:self.view];
        }
    }
}

-(void)jieShiPing{
    if (self.btnJieShiPingH.selected) {
        BOOL end = [self.realPlayer stopLocalRecord];
        UIImage *image = [self.realPlayer capturePicture:100];
        self.btnJieShiPingH.selected = NO;
        self.btnJieShiPingV.selected = NO;
        self.viewJieShiPingTime.hidden = YES;
        if (!self.viewDuiJiang.hidden) self.lcDuiJiangTop.constant = 20;
        self.jieShiPingTimer = NO;
        if (end) {
            __weak typeof(self)weakSelf = self;
            [TZMProgressHUDManager showWithStatus:@"视频保存中" inView:self.view];
            [TZMPhotoLibraryManager saveVideoIntoAlbumWitVideoPath:[NSURL URLWithString:self.shiPingPath] block:^(NSError *error) {
                if (error) {
                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                }else{
                    [TZMProgressHUDManager showSuccessWithStatus:@"视频已经保存到相册" inView:weakSelf.view];
                    [weakSelf.btnCapture setBackgroundImage:image forState:UIControlStateNormal];
                    [weakSelf.btnCapture setBackgroundImage:image forState:UIControlStateHighlighted];
                    weakSelf.lblCature.text = @"点击查看视频";
                    weakSelf.viewCature.hidden = NO;
                    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(hideCature) object:nil];
                    [weakSelf performSelector:@selector(hideCature) withObject:nil afterDelay:5];
                }
            }];
        }else{
            [TZMProgressHUDManager showErrorWithStatus:@"录像失败，请重试" inView:self.view];
        }
    }else{
        if (self.btnStartH.selected) {
            [TZMProgressHUDManager showErrorWithStatus:@"请打开直播后再录像" inView:self.view];
        }else{
            NSString *path = @"/SmartHome/LocalRecord/Video";
            NSArray *docdirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docdir = [docdirs objectAtIndex:0];
            NSString *configFilePath = [docdir stringByAppendingPathComponent:path];
            if(![[NSFileManager defaultManager] fileExistsAtPath:configFilePath]){
                NSError *error = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:configFilePath
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:&error];
            }
            self.shiPingPath = [NSString stringWithFormat:@"%@/%@.mov",configFilePath,[[NSDate date]stringWithFormat:@"yyyyMMddHHmmss"]];
            BOOL start = [self.realPlayer startLocalRecordWithPath:self.shiPingPath];
            if (start) {
                self.viewJieShiPingTime.hidden = NO;
                self.lcJieShiPingTop.constant = self.viewDuiJiang.hidden ? 20 : 20 + 28 + 8;
                self.btnJieShiPingH.selected = YES;
                self.btnJieShiPingV.selected = YES;
                self.lblJieShiPingTime.text = @"00:00:00";
                self.jieShiPingSecond = 0;
                self.jieShiPingTimer = YES;
                NSLog(@"------------------%f",[self.timer.fireDate timeIntervalSinceNow]);
                if ([self.timer.fireDate timeIntervalSinceNow] > 10000) {
                    self.timer.fireDate = [NSDate distantPast];
                }
            }else{
                [TZMProgressHUDManager showErrorWithStatus:@"开始录像失败" inView:self.view];
            }
        }
    }
}

-(void)openPhoneLib{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
        [self presentViewController:imagePicker animated:YES completion:^{
        }];
        
        UIImage *image = [self.realPlayer capturePicture:100];
        if (!image) {
            image = self.imageViewCapturePicture.image;
        }
        [[SDImageCache sharedImageCache] storeImage:image forKey:self.device.deviceSn toDisk:YES completion:nil];
        if (!self.btnStartV.selected) {
            [self stopRealPlay];
        }
        if (self.btnDuiJiangH.selected) {
            [self.talkPlayer stopVoiceTalk];
        }
    }
}

#pragma --mark --------------------播放代理-----------------------------
//播放器播放失败错误回调
- (void)player:(EZPlayer *)player didPlayFailed:(NSError *)error{
    __weak typeof(self)weakSelf = self;
    if(error.code == EZ_HTTPS_ACCESS_TOKEN_INVALID ||
       error.code == EZ_HTTPS_ACCESS_TOKEN_EXPIRE){
        //token错误
        [TZMProgressHUDManager showWithStatus:@"更新token中" inView:self.view];
        [GSHYingShiManager updataAccessTokenWithBlock:^(NSString *token, NSError *error) {
            if(error){
                //获取token错误
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                //获取token成功
                if (player == weakSelf.realPlayer) {
                    [weakSelf startRealPlay];
                }else if (player == self.talkPlayer){
                    [weakSelf startVoiceTalk];
                }else{
                    [TZMProgressHUDManager dismissInView:weakSelf.view];
                }
            }
        }];
    }else{
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
    }
}

//播放器消息回调
- (void)player:(EZPlayer *)player didReceivedMessage:(NSInteger)messageCode{
    /*
     PLAYER_VIDEOLEVEL_CHANGE = 2,     //直播流清晰度切换中
     PLAYER_NET_CHANGED = 21,          //播放器检测到wifi变换过
     PLAYER_NO_NETWORK = 22,           //播放器检测到无网络
     */
    [TZMProgressHUDManager dismissInView:self.view];
    if (player == self.realPlayer) {
        if (messageCode == PLAYER_REALPLAY_START) {
            self.btnStartH.selected = NO;
            self.btnPaly.hidden = YES;
            self.btnStartV.selected = NO;
            //重新开始自动静音
            self.butJingYinH.selected = ![self.realPlayer openSound];
            self.butJingYinV.selected = self.butJingYinH.selected;
            
            if (self.device.deviceType.intValue == 15){
                self.saveElectricitySecond = 50;
                self.saveElectricityTimer = YES;
                if ([self.timer.fireDate timeIntervalSinceNow] > 10000) {
                    self.timer.fireDate = [NSDate distantPast];
                }
            }
        }
    }else if (player == self.talkPlayer){
        if (messageCode == PLAYER_VOICE_TALK_START) {
            //对讲开始
            self.viewDuiJiangH.hidden = NO;
            self.viewDuiJiangV.hidden = NO;
            self.btnDuiJiangH.selected = YES;
            self.btnDuiJiangV.selected = YES;
            self.viewDuiJiang.hidden = NO;
            self.lcDuiJiangTop.constant = self.viewJieShiPingTime.hidden ? 20 : 20 + 28 + 8;
//
//            if (self.device.deviceType.intValue == 15){
//                self.saveElectricitySecond = 50;
//                self.saveElectricityTimer = YES;
//                if ([self.timer.fireDate timeIntervalSinceNow] > 10000) {
//                    self.timer.fireDate = [NSDate distantPast];
//                }
//            }
        }
        if (messageCode == PLAYER_VOICE_TALK_END) {
            //对讲结束
            self.viewDuiJiangH.hidden = YES;
            self.viewDuiJiangV.hidden = YES;
            self.btnDuiJiangH.selected = NO;
            self.btnDuiJiangV.selected = NO;
            self.viewDuiJiang.hidden = YES;
            if (self.viewJieShiPingTime.hidden) self.lcJieShiPingTop.constant = 20;
//
//            if (self.device.deviceType.intValue == 15){
//                if (self.btnStartV.selected) {
//                    self.viewSaveElectricity.hidden = YES;
//                    self.saveElectricityTimer = NO;
//                }
//            }
        }
    }
}

#pragma --mark --------------------点击事件-----------------------------
- (IBAction)touchPlay:(UIButton *)sender {
    if (self.isShield) {
        [TZMProgressHUDManager showErrorWithStatus:@"请开启镜头后再使用此功能" inView:self.view];
        return;
    }
    if (self.btnStartV.selected) {
        [self startRealPlay];
    }else{
        [self stopRealPlay];
    }
}

- (IBAction)touchJingYin:(id)sender {
    if (self.butJingYinH.selected) {
        self.butJingYinH.selected = ![self.realPlayer openSound];
        self.butJingYinV.selected = self.butJingYinH.selected;
    }else{
        self.butJingYinH.selected = [self.realPlayer closeSound];
        self.butJingYinV.selected = self.butJingYinH.selected;
    }
}

- (IBAction)touchFanHui:(UIButton *)sender {
    [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
}

- (IBAction)touchFangda:(UIButton *)sender {
    [self setInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
}

- (IBAction)touchQingXiDu:(id)sender {
    if (self.isShield) {
        [TZMProgressHUDManager showErrorWithStatus:@"请开启镜头后再使用此功能" inView:self.view];
        return;
    }
    self.viewQingXiDu.hidden = !self.viewQingXiDu.hidden;
}

- (IBAction)changeQingXiDu:(UIButton *)sender {
    if (self.isShield) {
        [TZMProgressHUDManager showErrorWithStatus:@"请开启镜头后再使用此功能" inView:self.view];
        return;
    }
    if (sender == self.btnChaoQing) {
        [self changeVideoLevel:EZVideoLevelSuperHigh];
    }else if (sender == self.btnGaoQing) {
        [self changeVideoLevel:EZVideoLevelHigh];
    }else if (sender == self.btnBiaoQing) {
        [self changeVideoLevel:EZVideoLevelMiddle];
    }else{
        [self changeVideoLevel:EZVideoLevelLow];
    }
}

- (IBAction)touchJieTu:(UIButton *)sender {
    if (self.isShield) {
        [TZMProgressHUDManager showErrorWithStatus:@"请开启镜头后再使用此功能" inView:self.view];
        return;
    }
    [self jieTu];
}

- (IBAction)touchToPhoneLib:(UIButton *)sender {
    [self openPhoneLib];
}

- (IBAction)touchDuiJiang:(UIButton *)sender {
    if (self.isSupportTalk == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"本设备不支持对讲" inView:self.view];
        return;
    }
    if (self.btnDuiJiangH.selected) {
        [self stopVoiceTalk];
    }else{
        [self startVoiceTalk];
    }
}

- (IBAction)cancelDuiJiang:(UIButton *)sender {
    [self stopVoiceTalk];
}

- (IBAction)startShuoHua:(UIButton *)sender {
    if (self.isSupportTalk == 1) {
    }else if (self.isSupportTalk == 3) {
        [self.talkPlayer audioTalkPressed:YES];
        self.svpreadAnimationView.hidden = NO;
        [self.svpreadAnimationView start];
    }else{
        
    }
}

- (IBAction)endShuoHua:(UIButton *)sender {
    if (self.isSupportTalk == 1) {
        [self stopVoiceTalk];
    }else if (self.isSupportTalk == 3) {
        [self.talkPlayer audioTalkPressed:NO];
        [self.svpreadAnimationView stop];
        self.svpreadAnimationView.hidden = YES;
    }else{
        
    }
}

- (IBAction)touchJieShiPing:(UIButton *)sender {
    if (self.isShield) {
        [TZMProgressHUDManager showErrorWithStatus:@"请开启镜头后再使用此功能" inView:self.view];
        return;
    }
    [self jieShiPing];
}

- (IBAction)touchSaveElectricityStop:(UIButton *)sender {
    self.saveElectricitySecond = 0;
    self.viewSaveElectricity.hidden = YES;
    self.saveElectricityTimer = NO;
    if (!self.btnStartH.selected) {
        [self stopRealPlay];
    }
//    if (self.btnDuiJiangH.selected) {
//        [self stopVoiceTalk];
//    }
}

- (IBAction)touchSaveElectricityStart:(UIButton *)sender{
    self.saveElectricitySecond = 50;
    self.viewSaveElectricity.hidden = YES;
}
@end
