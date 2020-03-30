//
//  GSHVoiceVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/29.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHVoiceVC.h"
#import "GSHVoiceExampleVC.h"

#import "UIView+TZM.h"
#import "UINavigationController+TZM.h"

#import "YSCNewVoiceWaveView.h"

#import "IATConfig.h"
#import "ISRDataHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "PcmPlayer.h"
#import "TTSConfig.h"

#import <SDWebImage/UIImage+GIF.h>
#import "NSString+TZM.h"

typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,    //Normal TTS
    UriType             = 6,    //URI TTS
};

//state of TTS
typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2,
    Paused              = 4,
};


@interface GSHVoiceVC ()
<UITableViewDelegate,
UITableViewDataSource,
IFlySpeechRecognizerDelegate,
IFlySpeechSynthesizerDelegate,
UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *voiceTableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;

@property (weak, nonatomic) IBOutlet YSCNewVoiceWaveView *waveView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *recognitionImageView;
@property (strong, nonatomic) CABasicAnimation *animation;

// 语音听写
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, strong) NSMutableString *result;
@property (nonatomic, assign) BOOL isRecognizerCanceled;

// 语音合成
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property (nonatomic, strong) PcmPlayer *audioPlayer;
@property (nonatomic, strong) NSString *uriPath;
@property (nonatomic, assign) BOOL isSynthesizerCanceled;
@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, assign) Status state;
@property (nonatomic, assign) SynthesizeType synType;

@property (weak, nonatomic) IBOutlet UIView *exampleView;
@property (weak, nonatomic) IBOutlet UIScrollView *exampleScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *beginVoiceImageView;

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) BOOL isBeginAutoScroll;

@end

@implementation GSHVoiceVC

+ (instancetype)voiceVC {
    GSHVoiceVC *vc = [GSHPageManager viewControllerWithSB:@"GSHVoiceSB" andID:@"GSHVoiceVC"];
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.waveView changeVolume:0.1];
    [self.waveView start];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.waveView stop];
    
    [self.iFlySpeechRecognizer cancel];
    [self.iFlySpeechRecognizer setDelegate:nil];
    [self.iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    [_iFlySpeechSynthesizer stopSpeaking];
    [_audioPlayer stop];
    [_iFlySpeechSynthesizer setDelegate:nil];
    
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    self.voiceTableView.dataSource = self;
    self.voiceTableView.delegate = self;
    self.voiceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.voiceTableView.backgroundColor = [UIColor clearColor];
    
    [self.recognitionImageView.layer addAnimation:self.animation forKey:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClick:)];
    [self.waveView addGestureRecognizer:tapGesture];
    self.waveView.hidden = YES;
    
    NSString *prePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //Set the audio file name for URI TTS
    _uriPath = [NSString stringWithFormat:@"%@/%@",prePath,@"uri.pcm"];
    //Instantiate player for URI TTS
    _audioPlayer = [[PcmPlayer alloc] init];

    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"yuyin@2x" ofType:@"gif"];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage sd_animatedGIFWithData:imageData];
    [self.beginVoiceImageView setImage:image];
    
    UITapGestureRecognizer *beginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginVoiceButtonClick)];
    [self.beginVoiceImageView addGestureRecognizer:beginTap];
    
    [self initExampleScrollView];
    
    [self.timer setFireDate:[NSDate distantPast]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (_timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    NSLog(@"dealloc");
}

- (void)initExampleScrollView {
    
    self.exampleScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*2, self.exampleScrollView.height);
    self.exampleScrollView.scrollEnabled = YES;
    self.exampleScrollView.showsHorizontalScrollIndicator = NO;
    NSArray *exampleArray = @[@"打开新风",@"离家模式",@"空调温度调到最低",
                              @"",@"窗帘拉开一半",@"地暖设为40度",@"新风设为中风",
                              @"回家模式",@"打开卧室的灯",@"空调温度设为26度",@"",
                              @"关闭窗帘",@"关闭空调",@"关闭客厅的射灯"];
    CGFloat labelHeight = self.exampleScrollView.height/7.0;
    for (int i = 0; i < exampleArray.count; i ++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((i / 7) * SCREEN_WIDTH, (i % 7) * labelHeight, SCREEN_WIDTH, labelHeight)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:18.0];
        label.text = exampleArray[i];
        [self.exampleScrollView addSubview:label];
    }
}

#pragma mark -  语音识别
- (IFlySpeechRecognizer *)iFlySpeechRecognizer {
    if (!_iFlySpeechRecognizer) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        _iFlySpeechRecognizer.delegate = self;
        
        //扩展参数
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        //设置为听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下。
        [_iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        //设置最长录音时间
        [_iFlySpeechRecognizer setParameter:@"30000" forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        //设置采样率，推荐16K
        [_iFlySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
        //设置语言
        [_iFlySpeechRecognizer setParameter:@"zh_cn" forKey:[IFlySpeechConstant LANGUAGE]];
        [_iFlySpeechRecognizer setParameter:@"en_us" forKey:[IFlySpeechConstant LANGUAGE_ENGLISH]];
        //设置方言
        [_iFlySpeechRecognizer setParameter:@"mandarin" forKey:[IFlySpeechConstant ACCENT]];
        //设置是否返回标点符号 -- 不带标点
        [_iFlySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant ASR_PTT]];
        //设置数据返回格式
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下（为了测试音频流识别用的）
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    }
    return _iFlySpeechRecognizer;
}

// 启动语音识别
- (void)startListening {
    
    [self.iFlySpeechRecognizer cancel];
    //设置音频来源为麦克风
    [self.iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    BOOL ret = [self.iFlySpeechRecognizer startListening];
    if (ret) {
        NSLog(@"启动成功");
        self.result = nil;
        [self showListeningView];
    } else {
        NSLog(@"启动失败");
        [TZMProgressHUDManager showErrorWithStatus:@"启动失败" inView:self.view];
    }
}

- (void)stopListening {
    [self.iFlySpeechRecognizer stopListening];
    [self.iFlySpeechRecognizer cancel];
    [self.iFlySpeechRecognizer setDelegate:nil];
    _iFlySpeechRecognizer = nil;
    [self.iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
}

/*!
 *  识别结果回调
 *
 *  在识别过程中可能会多次回调此函数，你最好不要在此回调函数中进行界面的更改等操作，只需要将回调的结果保存起来。<br>
 *  使用results的示例如下：
 *  <pre><code>
 *  - (void) onResults:(NSArray *) results{
 *     NSMutableString *result = [[NSMutableString alloc] init];
 *     NSDictionary *dic = [results objectAtIndex:0];
 *     for (NSString *key in dic){
 *        [result appendFormat:@"%@",key];//合并结果
 *     }
 *   }
 *  </code></pre>
 *
 *  @param results  -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，sc为识别结果的置信度。
 *  @param isLast   -[out] 是否最后一个结果
 */
- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
    NSLog(@"================== enter in speech result callback");
    if (results.count > 0) {
        NSMutableString *resultString = [[NSMutableString alloc] init];
        NSDictionary *dic = results[0];
        for (NSString *key in dic.allKeys) {
            [resultString appendFormat:@"%@",key];
        }
        NSString *resultFromJson =  nil;
        if([IATConfig sharedInstance].isTranslate) {
            // The result type must be utf8, otherwise an unknown error will happen.
            NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:
                                        [resultString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            if(resultDic != nil){
                NSDictionary *trans_result = [resultDic objectForKey:@"trans_result"];
                if([[IATConfig sharedInstance].language isEqualToString:@"en_us"]){
                    NSString *dst = [trans_result objectForKey:@"dst"];
                    NSLog(@"dst=%@",dst);
                    resultFromJson = [NSString stringWithFormat:@"%@\ndst:%@",resultString,dst];
                } else {
                    NSString *src = [trans_result objectForKey:@"src"];
                    NSLog(@"src=%@",src);
                    resultFromJson = [NSString stringWithFormat:@"%@\nsrc:%@",resultString,src];
                }
            }
        } else {
            resultFromJson = [ISRDataHelper stringFromJson:resultString];
        }
        [self.result appendString:resultFromJson];
        if (isLast) {
            NSLog(@"speech result is last");
            [self stopListening];
            NSCharacterSet *set = [NSCharacterSet punctuationCharacterSet];
            [self.result stringByTrimmingCharactersInSet:set];
            self.result = [[self.result stringByReplacingOccurrencesOfString:@"。" withString:@""] mutableCopy];
            if (self.result.length > 0) {
                NSString *str = [NSString stringWithFormat:@"“%@”",self.result];
                NSDictionary *dic = @{@"right":str};
                [self.sourceArray addObject:dic];
                if (self.sourceArray.count > 0) {
                    self.exampleView.hidden = YES;
                    [self.voiceTableView reloadData];
                    [self.voiceTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.sourceArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
                [self voiceControlWithText:self.result];
                [self isCanBeginTalk];
            } else {
                [self showNotListenView];   // 未识别成功
            }
            self.result = nil;
        }
    }
}

/**
 * 音量值回调
 * volume callback,range from 0 to 30.
 **/
- (void)onVolumeChanged:(int)volume {
    [self.waveView changeVolume:volume/30.0];
}

/*!
 *  识别结果回调
 *
 *  在进行语音识别过程中的任何时刻都有可能回调此函数，你可以根据errorCode进行相应的处理，当errorCode没有错误时，表示此次会话正常结束；否则，表示此次会话有错误发生。特别的当调用`cancel`函数时，引擎不会自动结束，需要等到回调此函数，才表示此次会话结束。在没有回调此函数之前如果重新调用了`startListenging`函数则会报错误。
 *
 *  @param errorCode 错误描述
 */
//- (void)onCompleted:(IFlySpeechError *)errorCode {
//    NSString *text ;
//    if (self.isRecognizerCanceled) {
//        text = @"识别取消";
//    } else if (errorCode.errorCode == 0) {
//        if (_result.length == 0) {
//            text = @"无识别结果";
//        } else {
//            text = @"识别成功";
//        }
//    } else {
//        text = [NSString stringWithFormat:@"发生错误：%d %@",errorCode.errorCode,errorCode.errorDesc];
//    }
//    NSLog(@"%@",text);
//
//    if (errorCode) {
//        if (errorCode.errorCode == 20001) {
//            // 网络问题
//        } else {
//            // 失败
//        }
//    }
//}

/*!
 *  开始录音回调<br>
 *  当调用了`startListening`函数之后，如果没有发生错误则会回调此函数。<br>
 *  如果发生错误则回调onCompleted:函数
 */
- (void)onBeginOfSpeech {
//    [self showListeningView]; // 显示聆听中视图
}

/*!
 *  停止录音回调<br>
 *  当调用了`stopListening`函数或者引擎内部自动检测到断点，如果没有发生错误则回调此函数。<br>
 *  如果发生错误则回调onCompleted:函数
 */
- (void)onEndOfSpeech {
    if ([self.iFlySpeechRecognizer isListening]) {
        NSLog(@"显示识别");
        [self isBeingRecognition];
    }
}

/*!
 *  取消识别回调<br>
 *  当调用了`cancel`函数之后，会回调此函数，在调用了cancel函数和回调onCompleted之前会有一个<br>
 *  短暂时间，您可以在此函数中实现对这段时间的界面显示。
 */
- (void)onCancel {
    [self isCanBeginTalk];
}

- (void)onError:(IFlySpeechError *)error {
    
    [self isBeingRecognition];
    if (error.errorCode == 0) {
        NSLog(@"识别成功，结束识别");
    } else {
        NSLog(@"发生错误：%@-%@", @(error.errorCode), error.errorDesc);
    }
}

#pragma mark -  语音合成
- (IFlySpeechSynthesizer *)iFlySpeechSynthesizer {
    if (!_iFlySpeechSynthesizer) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
        _iFlySpeechSynthesizer.delegate = self;
        
        TTSConfig *instance = [TTSConfig sharedInstance];
        
        //set the resource path, only for offline TTS
        NSString *resPath = [[NSBundle mainBundle] resourcePath];
        NSString *newResPath = [[NSString alloc] initWithFormat:@"%@/aisound/common.jet;%@/aisound/xiaoyan.jet",resPath,resPath];
        [[IFlySpeechUtility getUtility] setParameter:@"tts" forKey:[IFlyResourceUtil ENGINE_START]];
        [_iFlySpeechSynthesizer setParameter:newResPath forKey:@"tts_res_path"];
        
        //设置语速1-100
        [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
        //设置音量1-100
        [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
        //设置音调1-100
        [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
        //设置采样率
        [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        //设置发音人
        [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
        //set text encoding mode
        [_iFlySpeechSynthesizer setParameter:@"unicode" forKey:[IFlySpeechConstant TEXT_ENCODING]];
        //set engine type
        [_iFlySpeechSynthesizer setParameter:instance.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
    }
    return _iFlySpeechSynthesizer;
}

// 开始合成
- (void)startSynthesizerWithStr:(NSString *)str {
    
    if (!str) {
        return;
    }
    if (_audioPlayer != nil && _audioPlayer.isPlaying == YES) {
        [_audioPlayer stop];
    }
    _synType = NomalType;
    self.hasError = NO;
    [NSThread sleepForTimeInterval:0.05];
    
    str = [str stringByReplacingOccurrencesOfString:@"。" withString:@""];
    
    self.isSynthesizerCanceled = NO;
    
    [self.iFlySpeechSynthesizer startSpeaking:str];
    if (self.iFlySpeechSynthesizer.isSpeaking) {
        _state = Playing;
    }
    
    NSDictionary *dic = @{@"left":str};
    [self.sourceArray addObject:dic];
    [self.voiceTableView reloadData];
    [self.voiceTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.sourceArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark IFlySpeechSynthesizerDelegate

/**
 callback of starting playing
 Notice：
 Only apply to normal TTS
 **/
- (void)onSpeakBegin {
    self.isSynthesizerCanceled = NO;
    if (_state  != Playing) {
        NSLog(@"开始播放");
    }
    _state = Playing;
}

/**
 callback of buffer progress
 Notice：
 Only apply to normal TTS
 **/
- (void)onBufferProgress:(int)progress message:(NSString *)msg {
    NSLog(@"buffer progress %2d%%. msg: %@.", progress, msg);
}

/**
 callback of playback progress
 Notice：
 Only apply to normal TTS
 **/
- (void)onSpeakProgress:(int)progress beginPos:(int)beginPos endPos:(int)endPos {
//    NSLog(@"speak progress %2d%%, beginPos=%d, endPos=%d", progress,beginPos,endPos);
    if (progress == 100) {
        [self.iFlySpeechSynthesizer stopSpeaking];
    }
}

/**
 callback of pausing player
 Notice：
 Only apply to normal TTS
 **/
- (void)onSpeakPaused
{
//    [_inidicateView hide];
//    [_popUpView showText: NSLocalizedString(@"T_TTS_Pause", nil)];
    NSLog(@"播放暂停");
    _state = Paused;
}

/**
 callback of TTS completion
 **/
- (void)onCompleted:(IFlySpeechError *)error {
    
    NSLog(@"%s,errorCode=%d",__func__,error.errorCode);

    if(error.errorCode==20001){
        // 网络问题
        [self showNetErrorView];
    }
    NSString *text;
    if (self.isSynthesizerCanceled) {
        text = @"合成已取消"; // NSLocalizedString(@"T_TTS_Cancel", nil);
    } else if (error.errorCode == 0) {
        text = @"合成结束"; //NSLocalizedString(@"T_TTS_End", nil);
    } else {
        text = [NSString stringWithFormat:@"Error：%d %@",error.errorCode,error.errorDesc];
        self.hasError = YES;
    }
    [self isCanBeginTalk];
    NSLog(@"%@",text);
    _state = NotStart;
//    if (_synType == UriType) {//URI TTS
//        NSFileManager *fm = [NSFileManager defaultManager];
//        if ([fm fileExistsAtPath:_uriPath]) {
//            [self playUriAudio];//play the audio file generated by URI TTS
//        }
//    }
//    [self.iFlySpeechSynthesizer stopSpeaking];  // 结束合成
    
}

- (void)playUriAudio {
    TTSConfig *instance = [TTSConfig sharedInstance];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"audio error : %@",error);
    }
    _audioPlayer = [[PcmPlayer alloc] initWithFilePath:_uriPath sampleRate:[instance.sampleRate integerValue]];
    [_audioPlayer play];
}

#pragma mark - Lazy
- (CABasicAnimation *)animation {
    if (!_animation) {
        _animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
        _animation.fromValue = [NSNumber numberWithFloat:0.f];
        _animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
        _animation.duration  = 1;
        _animation.autoreverses = NO;
        _animation.fillMode =kCAFillModeForwards;
        _animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    }
    return _animation;
}

- (NSMutableArray *)sourceArray {
    if (!_sourceArray) {
        _sourceArray = [NSMutableArray array];
    }
    return _sourceArray;
}

- (NSMutableString *)result {
    if (!_result) {
        _result = [NSMutableString string];
    }
    return _result;
}

- (NSTimer *)timer {
    if (!_timer) {
        @weakify(self)
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            [self autoScrollExampleView];
        } repeats:YES];
    }
    return _timer;
}

#pragma mark - method
- (void)autoScrollExampleView {
    if (self.isBeginAutoScroll) {
        CGFloat width = self.exampleScrollView.contentOffset.x == 0 ? SCREEN_WIDTH : 0;
        [self.exampleScrollView setContentOffset:CGPointMake(width, 0) animated:YES];
    } else {
        self.isBeginAutoScroll = YES;
    }
}

// 关闭按钮点击
- (IBAction)closeButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// 开始语音按钮点击
- (void)beginVoiceButtonClick {
    
    // 检查是否有麦克风权限
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(videoAuthStatus == AVAuthorizationStatusRestricted ||
       videoAuthStatus == AVAuthorizationStatusDenied) {
        // 麦克风权限未授权
        [self showSetAlertView];
        return;
    }
    
    if (self.sourceArray.count == 0) {
        self.exampleView.hidden = NO;
    }
    self.voiceTableView.hidden = NO;
    [self startListening];
    
}

// 波浪视图手势点击 -- 页面恢复成可点击说话的状态
- (void)tapGestureClick:(UITapGestureRecognizer *)tap {
    [self stopListening];
//    [_iFlySpeechRecognizer cancel];
    [self isCanBeginTalk];
}

// 正在聆听中
- (void)showListeningView {
    self.waveView.hidden = NO;
    self.beginVoiceImageView.hidden = YES;
    self.recognitionImageView.hidden = YES;
    self.stateLabel.text = @"聆听中，请说话...";
}

// 可点击说话
- (void)isCanBeginTalk {
    self.waveView.hidden = YES;
    self.beginVoiceImageView.hidden = NO;
    self.recognitionImageView.hidden = YES;
    self.stateLabel.text = @"点击说话";
}

// 正在识别中
- (void)isBeingRecognition {
    self.waveView.hidden = YES;
    self.beginVoiceImageView.hidden = YES;
    self.recognitionImageView.hidden = NO;
    [self.recognitionImageView.layer addAnimation:self.animation forKey:nil];
    self.stateLabel.text = @"识别中...";
}

// 显示网络出错
- (void)showNetErrorView {
    
    if (!self.exampleView.hidden) {
        self.exampleView.hidden = YES;
    }
    if (self.voiceTableView.hidden) {
        self.voiceTableView.hidden = NO;
    }
    
    NSDictionary *dic = @{@"left":@"网络不给力，请检查网络设置或稍后再试"};
    [self.sourceArray addObject:dic];
    [self.voiceTableView reloadData];
    [self.voiceTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.sourceArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self isCanBeginTalk];
}

// 显示听不清视图
- (void)showNotListenView {
    
    if (!self.exampleView.hidden) {
        self.exampleView.hidden = YES;
    }
    if (self.voiceTableView.hidden) {
        self.voiceTableView.hidden = NO;
    }
    
    NSDictionary *dic = @{@"left":@"抱歉，我没听清噢，您能再说一遍吗？"};
    [self.sourceArray addObject:dic];
    [self.voiceTableView reloadData];
    [self.voiceTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.sourceArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self isCanBeginTalk];
    
}

//提示用户进行麦克风使用授权
- (void)showSetAlertView {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"麦克风权限未开启" message:@"麦克风权限未开启，请进入系统【设置】>【隐私】>【麦克风】中打开开关,开启麦克风功能" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳入当前App设置界面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:setAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
//滑动的时候停止定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.timer setFireDate:[NSDate distantFuture]];
}

//停止滑动之后开启定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.timer setFireDate:[NSDate distantPast]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHVoiceCell *voiceCell = [tableView dequeueReusableCellWithIdentifier:@"voiceCell" forIndexPath:indexPath];
    NSDictionary *dic = self.sourceArray[indexPath.row];
    if ([dic.allKeys[0] isEqualToString:@"left"]) {
        voiceCell.leftLabel.text = dic.allValues[0];
        voiceCell.rightLabel.text = @"";
    } else {
        voiceCell.rightLabel.text = dic.allValues[0];
        voiceCell.leftLabel.text = @"";
    }
//    if ((indexPath.row+1) % 2 == 1) {
//        voiceCell.rightLabel.text = self.sourceArray[indexPath.row];
//        voiceCell.leftLabel.text = @"";
//    } else {
//        voiceCell.leftLabel.text = self.sourceArray[indexPath.row];
//        voiceCell.rightLabel.text = @"";
//    }
    return voiceCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.sourceArray[indexPath.row];
    NSString *str = dic.allValues[0];
    if ([dic.allKeys[0] isEqualToString:@"right"]) {
        CGFloat singleLineHeight = [@"haha" tzm_getStrHeightWithFontSize:18.0 labelWidth:SCREEN_WIDTH - 80];
        CGFloat labelHeight = [str tzm_getStrHeightWithFontSize:18.0 labelWidth:SCREEN_WIDTH - 80];
        return 50 - singleLineHeight + labelHeight;
    } else {
        CGFloat singleLineHeight = [@"haha" tzm_getStrHeightWithFontSize:24.0 labelWidth:SCREEN_WIDTH - 80];
        CGFloat labelHeight = [str tzm_getStrHeightWithFontSize:24.0 labelWidth:SCREEN_WIDTH - 80];
        return 50 - singleLineHeight + labelHeight;
    }
}

#pragma mark - request
- (void)voiceControlWithText:(NSString *)text {
    
    @weakify(self)
    [GSHVoiceManager voiceControlWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId text:text block:^(NSString *msg,NSError * _Nonnull error) {
        @strongify(self)
        if (error && error.localizedDescription) {
            [self startSynthesizerWithStr:error.localizedDescription];
        } else {
            if (msg) {
                [self startSynthesizerWithStr:msg];
            }
        }
    }];
}

@end

@implementation GSHVoiceCell

@end
