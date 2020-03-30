//
//  GSHYingShiVideoVC.m
//  SmartHome
//
//  Created by gemdale on 2018/8/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiVideoVC.h"
#import "TZMPhotoLibraryManager.h"
#import "UINavigationController+TZM.h"
#import "GSHPickerView.h"
#import "NSObject+TZM.h"
#import "GSHYingShiCameraVC.h"

@interface GSHYingShiVideoVC ()<EZPlayerDelegate>
@property(nonatomic, strong)EZDeviceRecordFile *recordFile;
@property(nonatomic, strong)NSArray<EZDeviceRecordFile*> *recordFileList;
@property(nonatomic, assign)NSInteger seleIndex;
@property(nonatomic, copy)NSString *verifyCode;
@property(nonatomic, copy)NSString *deviceSerial;
@property(nonatomic, assign)NSInteger cameraNo;

@property(nonatomic, strong)EZPlayer *recordPlayer;
@property(nonatomic, assign)BOOL startPlaybackSucceed;
@property(nonatomic, strong)NSTimer *timerJieShiPing;
@property(nonatomic, strong)NSTimer *timerJingDu;
@property(nonatomic, assign)int jieShiPingSecond;
@property(nonatomic, copy)NSString *shiPingPath;
@property(nonatomic, assign)EZPlaybackRate rate;


@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UISlider *sliderTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;
- (IBAction)changeSliderTime:(UISlider *)sender;

//播放视图
@property (weak, nonatomic) IBOutlet UIView *playView;
//暂停保留视图
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCapturePicture;

//播放逻辑
@property (weak, nonatomic) IBOutlet UIButton *btnStartV;
@property (weak, nonatomic) IBOutlet UIButton *btnStartH;
- (IBAction)touchPlay:(UIButton *)sender;

//静音逻辑
@property (weak, nonatomic) IBOutlet UIButton *butJingYinV;
@property (weak, nonatomic) IBOutlet UIButton *butJingYinH;
- (IBAction)touchJingYin:(id)sender;

//截视屏
@property (weak, nonatomic) IBOutlet UIButton *btnJieShiPingV;
@property (weak, nonatomic) IBOutlet UIButton *btnJieShiPingH;
@property (weak, nonatomic) IBOutlet UIView *viewJieShiPingTime;
@property (weak, nonatomic) IBOutlet UILabel *lblJieShiPingTime;
@property (weak, nonatomic) IBOutlet UIView *viewJieShiPingRedDot;
- (IBAction)touchJieShiPing:(UIButton *)sender;

//截图
- (IBAction)touchJieTu:(UIButton *)sender;
- (IBAction)touchToPhoneLib:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnCapture;
@property (weak, nonatomic) IBOutlet UILabel *lblCature;
@property (weak, nonatomic) IBOutlet UIView *viewCature;

- (IBAction)touchFangda:(UIButton *)sender;
- (IBAction)touchFanHui:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UIButton *btnPrevious;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
- (IBAction)touchNext:(UIButton *)sender;
- (IBAction)touchPrevious:(UIButton *)sender;

- (IBAction)return10:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnBeiSuH;
@property (weak, nonatomic) IBOutlet UIButton *btnBeiSuV;
@property (weak, nonatomic) IBOutlet UIButton *btnBeiSu1;
@property (weak, nonatomic) IBOutlet UIButton *btnBeiSu2;
@property (weak, nonatomic) IBOutlet UIButton *btnBeiSu4;
@property (weak, nonatomic) IBOutlet UIButton *btnBeiSu8;
@property (weak, nonatomic) IBOutlet UIButton *btnBeiSu1_2;
@property (weak, nonatomic) IBOutlet UIButton *btnBeiSu1_4;
@property (weak, nonatomic) IBOutlet UIButton *btnBeiSu1_8;
@property (weak, nonatomic) IBOutlet UIView *viewBeiSu;
- (IBAction)touchBeiSu:(UIButton *)sender;
- (IBAction)touchBeiSuX:(UIButton *)sender;

@end

@implementation GSHYingShiVideoVC

+(instancetype)yingShiCameraVCWithDeviceSerial:(NSString *)deviceSerial cameraNo:(NSInteger)cameraNo recordFile:(EZDeviceRecordFile*)recordFile verifyCode:(NSString *)verifyCode{
    if (recordFile) {
        GSHYingShiVideoVC *vc = [self yingShiCameraVCWithDeviceSerial:deviceSerial cameraNo:cameraNo recordFileList:@[recordFile] seleIndex:0 verifyCode:verifyCode];
        return vc;
    }else{
        GSHYingShiVideoVC *vc = [self yingShiCameraVCWithDeviceSerial:deviceSerial cameraNo:cameraNo recordFileList:nil seleIndex:0 verifyCode:verifyCode];
        return vc;
    }
}

+(instancetype)yingShiCameraVCWithDeviceSerial:(NSString *)deviceSerial cameraNo:(NSInteger)cameraNo recordFileList:(NSArray<EZDeviceRecordFile*> *)recordFileList seleIndex:(NSInteger)seleIndex verifyCode:(NSString *)verifyCode{
    GSHYingShiVideoVC *vc = [GSHPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingShiVideoVC"];
    vc.deviceSerial = deviceSerial;
    vc.cameraNo = cameraNo;
    vc.recordFileList = recordFileList;
    vc.seleIndex = seleIndex;
    vc.verifyCode = verifyCode;
    return vc;
}

- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [NSObject postNotification:GSHYingShiNeedOpenLandscapeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [NSObject postNotification:GSHYingShiNeedCloseLandscapeNotification object:nil];
    [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    self.btnStartH.selected = YES;
    self.btnStartV.selected = YES;
    if (self.btnJieShiPingH.selected == YES) {
        [self touchJieShiPing:self.btnJieShiPingH];
    }
    [self.recordPlayer pausePlayback];
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
        self.tzm_interactivePopDisabled = YES;
        self.navigationController.navigationBarHidden = YES;
    } else {
        // 竖屏布局
        self.tzm_interactivePopDisabled = NO;
        self.navigationController.navigationBarHidden = NO;
    }
}

-(void)dealloc{
    [self.timerJieShiPing invalidate];
    [self.timerJingDu invalidate];
    [self.recordPlayer destoryPlayer];
    [self removeNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initRecordPlayer];
    [self initUI];
    
    __weak typeof(self)weakSelf = self;
    self.timerJieShiPing = [NSTimer timerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
        [weakSelf timingJieShiPing];
    } repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.timerJieShiPing forMode:NSRunLoopCommonModes];
    self.timerJieShiPing.fireDate = [NSDate distantFuture];
    
    self.timerJingDu = [NSTimer timerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
        [weakSelf timingJingDu];
    } repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.timerJingDu forMode:NSRunLoopCommonModes];
    self.timerJingDu.fireDate = [NSDate distantPast];
    
    [self observerNotifications];
}

-(void)observerNotifications{
    [self observerNotification:UIApplicationWillResignActiveNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
        
    }
}
#pragma --mark --------------------初始化方法-----------------------------

- (void)initUI{
    [self.sliderTime setThumbImage:[UIImage ZHImageNamed:@"yingShiVideoVC_thumb_icon"] forState:UIControlStateNormal];
    [self refrshRecordFileIndex:self.seleIndex];
}

-(void)refrshRecordFileIndex:(NSInteger)index{
    self.btnPrevious.hidden = index <= 0;
    self.btnNext.hidden = index >= self.recordFileList.count - 1;
    self.seleIndex = index;
    if (index >= 0 && index < self.recordFileList.count) {
        [self refrshRecordFile:self.recordFileList[index]];
    }
}

- (void)refrshRecordFile:(EZDeviceRecordFile*)recordFile{
    self.recordFile = recordFile;
    if (self.recordFile) {
        self.lblEndTime.text = [self.recordFile.stopTime stringWithFormat:@"HH:mm:ss"];
        self.lblStartTime.text = [self.recordFile.startTime stringWithFormat:@"HH:mm:ss"];
        self.lblDate.text = [self.recordFile.startTime stringWithFormat:@"yyyy年M月d日HH:mm:ss"];
        
        self.btnStartH.selected = YES;
        self.btnStartV.selected = YES;
        self.startPlaybackSucceed = NO;
        self.sliderTime.value = 0;
        if (self.btnJieShiPingH.selected == YES) {
            [self touchJieShiPing:self.btnJieShiPingH];
        }
        [self.recordPlayer stopPlayback];
    }
}

- (void)initRecordPlayer{
    self.recordPlayer = [EZOpenSDK createPlayerWithDeviceSerial:self.deviceSerial cameraNo:self.cameraNo];
    self.recordPlayer.delegate = self;
    [self.recordPlayer setPlayVerifyCode:self.verifyCode];
    [self.recordPlayer setPlayerView:self.playView];
    self.rate = EZ_PLAYBACK_RATE_1;
}

#pragma --mark --------------------操作方法-----------------------------
- (void)timingJingDu{
    if (self.sliderTime.state == UIControlStateNormal && !self.btnStartV.selected) {
        if (self.recordFile) {
            NSDate *nowData = [self.recordPlayer getOSDTime];
            if (nowData) {
                NSTimeInterval playTime = [nowData timeIntervalSinceDate:self.recordFile.startTime];
                NSTimeInterval allTime = [self.recordFile.stopTime timeIntervalSinceDate:self.recordFile.startTime];
                if (playTime > allTime - 1) {
                    self.btnStartH.selected = YES;
                    self.btnStartV.selected = YES;
                    self.startPlaybackSucceed = NO;
                    self.sliderTime.value = 0;
                    if (self.btnJieShiPingH.selected == YES) {
                        [self touchJieShiPing:self.btnJieShiPingH];
                    }
                    [self.recordPlayer stopPlayback];
                }
                self.sliderTime.value = playTime / allTime;
            }
        }
    }
}

-(void)showPickerView{
    __weak typeof(self)weakSelf = self;
    [GSHPickerView showPickerViewContainResetButtonWithDataArray:@[@"8倍速率播放",@"4倍速率播放",@"2倍速率播放",@"1倍速率播放",@"1/2倍速率播放",@"1/4倍速率播放",@"1/8倍速率播放"]
     cancelBenTitle:@"取消"
     cancelBenTitleColor:[UIColor colorWithRGB:0x999999]
     sureBtnTitle:@"确定"
     cancelBlock:^{
     } completion:^(NSString *selectContent , NSArray *selectRowArray) {
         NSNumber *sele = selectRowArray.firstObject;
         if (sele) {
             switch (sele.intValue) {
                 case 0:
                     [weakSelf touchBeiSuX:weakSelf.btnBeiSu8];
                     break;
                 case 1:
                     [weakSelf touchBeiSuX:weakSelf.btnBeiSu4];
                     break;
                 case 2:
                     [weakSelf touchBeiSuX:weakSelf.btnBeiSu2];
                     break;
                 case 4:
                     [weakSelf touchBeiSuX:weakSelf.btnBeiSu1_2];
                     break;
                 case 5:
                     [weakSelf touchBeiSuX:weakSelf.btnBeiSu1_4];
                     break;
                 case 6:
                     [weakSelf touchBeiSuX:weakSelf.btnBeiSu1_8];
                     break;
                 default:
                     [weakSelf touchBeiSuX:weakSelf.btnBeiSu1];
                     break;
             }
         }
     }];
}

#pragma --mark --------------------截视屏截图操作方法-----------------------------
- (void)timingJieShiPing{
    self.viewJieShiPingRedDot.hidden = self.jieShiPingSecond % 2 == 0;
    self.lblJieShiPingTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",self.jieShiPingSecond / 3600,self.jieShiPingSecond % 3600 / 60,self.jieShiPingSecond % 60];
    self.jieShiPingSecond++;
}

-(void)hideCature{
    self.viewCature.hidden = YES;
}

-(void)jieTu{
    UIImage *image = [self.recordPlayer capturePicture:100];
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
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCature) object:nil];
                [weakSelf performSelector:@selector(hideCature) withObject:nil afterDelay:5];
            }
        }];
    }else{
        if (self.btnStartH.selected) {
            [TZMProgressHUDManager showErrorWithStatus:@"请打开播放后再截图" inView:self.view];
        }else{
            [TZMProgressHUDManager showErrorWithStatus:@"截图失败" inView:self.view];
        }
    }
}

-(void)jieShiPing{
    if (self.btnJieShiPingH.selected) {
        UIImage *image = [self.recordPlayer capturePicture:100];
        __weak typeof(self)weakSelf = self;
        [TZMProgressHUDManager showWithStatus:@"视频保存中" inView:self.view];
        [TZMPhotoLibraryManager saveVideoIntoAlbumWitVideoPath:[NSURL URLWithString:self.shiPingPath] block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                weakSelf.btnJieShiPingH.selected = NO;
                weakSelf.btnJieShiPingV.selected = NO;
                weakSelf.viewJieShiPingTime.hidden = YES;
                weakSelf.timerJieShiPing.fireDate = [NSDate distantFuture];
                
                [TZMProgressHUDManager showSuccessWithStatus:@"视频已经保存到相册" inView:weakSelf.view];
                [weakSelf.btnCapture setBackgroundImage:image forState:UIControlStateNormal];
                [weakSelf.btnCapture setBackgroundImage:image forState:UIControlStateHighlighted];
                weakSelf.lblCature.text = @"点击查看视频";
                weakSelf.viewCature.hidden = NO;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCature) object:nil];
                [weakSelf performSelector:@selector(hideCature) withObject:nil afterDelay:5];
            }
        }];
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
        BOOL start = [self.recordPlayer startLocalRecordWithPath:self.shiPingPath];
        if (start) {
            self.viewJieShiPingTime.hidden = NO;
            self.btnJieShiPingH.selected = YES;
            self.btnJieShiPingV.selected = YES;
            self.jieShiPingSecond = 0;
            self.timerJieShiPing.fireDate = [NSDate distantPast];
        }else{
            if (self.btnStartH.selected) {
                [TZMProgressHUDManager showErrorWithStatus:@"请打开直播后再录像" inView:self.view];
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
        [self presentViewController:imagePicker animated:YES completion:^{
        }];
        self.btnStartH.selected = YES;
        self.btnStartV.selected = YES;
        if (self.btnJieShiPingH.selected == YES) {
            [self touchJieShiPing:self.btnJieShiPingH];
        }
        [self.recordPlayer pausePlayback];
    }
}

#pragma --mark --------------------播放代理-----------------------------
//播放器播放失败错误回调
- (void)player:(EZPlayer *)player didPlayFailed:(NSError *)error{
    __weak typeof(self)weakSelf = self;
    NSLog(@"代理报错 err = %@",error);
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
                if (player == weakSelf.recordPlayer) {
                }else{
                    [TZMProgressHUDManager dismissInView:weakSelf.view];
                }
            }
        }];
    }else if(error.code == 320356 || error.code == 320355){
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
    }else{
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
    }
}

//播放器消息回调
- (void)player:(EZPlayer *)player didReceivedMessage:(NSInteger)messageCode{
    NSLog(@"回调 messageCode = %d",(int)messageCode);
    [TZMProgressHUDManager dismissInView:self.view];
    if (player == self.recordPlayer) {
        if (messageCode == PLAYER_PLAYBACK_START) {
            //录像回放开始播放
            self.btnStartH.selected = NO;
            self.btnStartV.selected = NO;
            self.startPlaybackSucceed = YES;
            self.imageViewCapturePicture.image = [self.recordPlayer capturePicture:100];
            self.imageViewCapturePicture.hidden = YES;
            if (self.butJingYinH.selected) {
                [self.recordPlayer closeSound];
            }else{
                [self.recordPlayer openSound];
            }
            [self.recordPlayer setPlaybackRate:self.rate];
        }
        if (messageCode == PLAYER_PLAYBACK_STOP || messageCode == PLAYER_PLAYBACK_FINISHED  || messageCode == PLAYER_NO_NETWORK) {
            //录像回放结束播放或录像回放被用户强制中断或者没网
            self.imageViewCapturePicture.hidden = NO;
            self.btnStartH.selected = YES;
            self.btnStartV.selected = YES;
            if (self.btnJieShiPingH.selected == YES) {
                [self touchJieShiPing:self.btnJieShiPingH];
            }
            self.startPlaybackSucceed = NO;
            self.sliderTime.value = 0;
            [self.recordPlayer stopPlayback];
        }
    }
}

#pragma --mark --------------------点击事件-----------------------------
- (IBAction)touchPlay:(UIButton *)sender {
    if (self.btnStartV.selected) {
        if (self.startPlaybackSucceed) {
            [TZMProgressHUDManager showWithStatus:@"开始播放" inView:self.view];
            [self.recordPlayer resumePlayback];
        }else{
            if (self.recordFile) {
                [TZMProgressHUDManager showWithStatus:@"开始播放" inView:self.view];
                [self.recordPlayer startPlaybackFromDevice:self.recordFile];
            }
        }
    }else{
        self.imageViewCapturePicture.image = [self.recordPlayer capturePicture:100];
        self.imageViewCapturePicture.hidden = NO;
        if (self.btnJieShiPingH.selected == YES) {
            [self touchJieShiPing:self.btnJieShiPingH];
        }
        [self.recordPlayer pausePlayback];
        self.btnStartH.selected = YES;
        self.btnStartV.selected = YES;
    }
}

- (IBAction)touchJingYin:(id)sender {
    if (self.butJingYinH.selected) {
        self.butJingYinH.selected = ![self.recordPlayer openSound];
        self.butJingYinV.selected = self.butJingYinH.selected;
    }else{
        self.butJingYinH.selected = [self.recordPlayer closeSound];
        self.butJingYinV.selected = self.butJingYinH.selected;
    }
}

- (IBAction)changeSliderTime:(UISlider *)sender {
    CGFloat v = sender.value;
    if (self.recordFile) {
        NSTimeInterval startTime = [self.recordFile.startTime timeIntervalSince1970];
        NSTimeInterval endTime = [self.recordFile.stopTime timeIntervalSince1970];
        NSTimeInterval playTime = (endTime - startTime) * v + startTime;
        self.imageViewCapturePicture.hidden = NO;
        if (endTime - playTime < 1) {
            self.btnStartH.selected = YES;
            self.btnStartV.selected = YES;
            self.startPlaybackSucceed = NO;
            self.sliderTime.value = 0;
            if (self.btnJieShiPingH.selected == YES) {
                [self touchJieShiPing:self.btnJieShiPingH];
            }
            [self.recordPlayer stopPlayback];
            return;
        }
        [TZMProgressHUDManager showWithStatus:@"开始播放" inView:self.view];
        [self.recordPlayer seekPlayback:[NSDate dateWithTimeIntervalSince1970:playTime]];
    }
}

- (IBAction)touchFanHui:(UIButton *)sender {
    [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
}

- (IBAction)touchNext:(UIButton *)sender {
    [self refrshRecordFileIndex:self.seleIndex + 1];
}

- (IBAction)touchPrevious:(id)sender {
    [self refrshRecordFileIndex:self.seleIndex - 1];
}

- (IBAction)return10:(UIButton *)sender {
    NSDate *nowData = [self.recordPlayer getOSDTime];
    NSTimeInterval nowTime = [nowData timeIntervalSince1970];
    self.imageViewCapturePicture.hidden = NO;
    [self.recordPlayer seekPlayback:[NSDate dateWithTimeIntervalSince1970:nowTime - 10]];
}

- (IBAction)touchFangda:(UIButton *)sender {
    [self setInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
}

- (IBAction)touchJieTu:(UIButton *)sender {
    [self jieTu];
}

- (IBAction)touchToPhoneLib:(UIButton *)sender {
    [self openPhoneLib];
}

- (IBAction)touchJieShiPing:(UIButton *)sender {
    [self jieShiPing];
}

- (IBAction)touchBeiSu:(UIButton *)sender {
    if (sender == self.btnBeiSuV) {
        [self showPickerView];
    }else{
        self.viewBeiSu.hidden = !self.viewBeiSu.hidden;
    }
}

- (IBAction)touchBeiSuX:(UIButton *)sender {
    self.viewBeiSu.hidden = YES;
    EZPlaybackRate rate;
    self.btnBeiSu1.selected = NO;
    self.btnBeiSu2.selected = NO;
    self.btnBeiSu4.selected = NO;
    self.btnBeiSu8.selected = NO;
    self.btnBeiSu1_2.selected = NO;
    self.btnBeiSu1_4.selected = NO;
    self.btnBeiSu1_8.selected = NO;
    sender.selected = YES;
    if (sender == self.btnBeiSu1) {
        rate = EZ_PLAYBACK_RATE_1;
        [self.btnBeiSuV setTitle:@"1X" forState:UIControlStateNormal];
        [self.btnBeiSuH setTitle:@"1X" forState:UIControlStateNormal];
    } else if (sender == self.btnBeiSu2) {
        rate = EZ_PLAYBACK_RATE_2;
        [self.btnBeiSuV setTitle:@"2X" forState:UIControlStateNormal];
        [self.btnBeiSuH setTitle:@"2X" forState:UIControlStateNormal];
    } else if (sender == self.btnBeiSu4) {
        rate = EZ_PLAYBACK_RATE_4;
        [self.btnBeiSuV setTitle:@"4X" forState:UIControlStateNormal];
        [self.btnBeiSuH setTitle:@"4X" forState:UIControlStateNormal];
    } else if (sender == self.btnBeiSu8) {
        rate = EZ_PLAYBACK_RATE_8;
        [self.btnBeiSuV setTitle:@"8X" forState:UIControlStateNormal];
        [self.btnBeiSuH setTitle:@"8X" forState:UIControlStateNormal];
    } else if (sender == self.btnBeiSu1_2) {
        rate = EZ_PLAYBACK_RATE_2_1;
        [self.btnBeiSuV setTitle:@"1/2X" forState:UIControlStateNormal];
        [self.btnBeiSuH setTitle:@"1/2X" forState:UIControlStateNormal];
    } else if (sender == self.btnBeiSu1_4) {
        rate = EZ_PLAYBACK_RATE_4_1;
        [self.btnBeiSuV setTitle:@"1/4X" forState:UIControlStateNormal];
        [self.btnBeiSuH setTitle:@"1/4X" forState:UIControlStateNormal];
    } else {
        rate = EZ_PLAYBACK_RATE_8_1;
        [self.btnBeiSuV setTitle:@"1/8X" forState:UIControlStateNormal];
        [self.btnBeiSuH setTitle:@"1/8X" forState:UIControlStateNormal];
    }
    if (self.rate == rate) {
        return;
    }
    [self.recordPlayer setPlaybackRate:rate];
    self.rate = rate;
}

@end
