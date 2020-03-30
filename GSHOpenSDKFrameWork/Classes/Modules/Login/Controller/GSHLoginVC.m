//
//  GSHLoginVC.m
//  SmartHome
//
//  Created by gemdale on 2018/4/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHLoginVC.h"
#import "GSHThirdLoginBindMobileVC.h"
#import "GSHNoFamilyVC.h"
#import "GSHWebViewController.h"

#import "GSHMainTabBarViewController.h"
#import "UINavigationController+TZM.h"
#import "GSHLoginResetPasswordVC.h"

#import "NSString+TZM.h"
#import "UITextField+TZM.h"

#import "TZMCountDownButton.h"
#import "GSHAppDelegate.h"

#import <OpenShareHeader.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <EnjoyHomeOpenSDK.h>

#import <AFNetworking.h>

#import "NSDictionary+TZM.h"
#import "GSHAppConfig.h"

#import "GSHLoginInputPhoneNumberVC.h"
#import <AVFoundation/AVFoundation.h>
#import "GSHPrivacyNotiVCViewController.h"



static const NSTimeInterval KCountDownDuration = 60.0;
#define GSHLoginSuccessMobileNo @"GSHLoginSuccessMobileNo"
#define GSHLoginIndexVideoInfoVersion @"GSHLoginIndexVideoInfoVersion"

@interface GSHLoginVC () <UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewFirst;
@property (weak, nonatomic) IBOutlet UIButton *btnFirstWeChatLogin;
- (IBAction)touchPhoneLogin:(UIButton *)sender;
- (IBAction)touchWeChatLogin:(UIButton *)sender;


- (IBAction)touchNavBack:(UIButton *)sender;
- (IBAction)touchLoginType:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;

@property (weak, nonatomic) IBOutlet UIView *viewCode;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet TZMCountDownButton *btnGetCode;
- (IBAction)touchGetCode:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *viewPassword;
@property (weak, nonatomic) IBOutlet UITextField *passWordField;
- (IBAction)touchHidePassword:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnFindPassword;
- (IBAction)touchFindPassword:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
- (IBAction)touchLogin:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *enjoyHomeButton;
@property (weak, nonatomic) IBOutlet UIButton *qqLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *wechatLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *lblOtherLogin;
- (IBAction)touchXieYi:(UIButton *)sender;
- (IBAction)touchZhengce:(UIButton *)sender;

@property(nonatomic, assign)BOOL isPassWord;
@property(nonatomic, assign)BOOL passWordLoginError;
@property(nonatomic, strong)AVPlayer *player;
@end

@implementation GSHLoginVC

+(instancetype)loginVC{
    GSHLoginVC *vc = [GSHPageManager viewControllerWithSB:@"loginSB" andID:@"GSHLoginVC"];
    return vc;
}

- (BOOL)prefersStatusBarHidden {
    return !self.viewFirst.hidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tzm_prefersNavigationBarHidden = YES;
    // 暂时隐藏享家和支付宝登录按钮
    self.mobileTextField.tzm_isPhoneNumber = YES;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:GSHLoginSuccessMobileNo]) {
        self.mobileTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:GSHLoginSuccessMobileNo];
    }
    
    if (![OpenShare isQQInstalled]) {
        self.qqLoginButton.hidden = YES;
    }
    if (![OpenShare isWeixinInstalled]) {
        self.wechatLoginButton.hidden = YES;
        self.btnFirstWeChatLogin.hidden = YES;
    }
    if (![EnjoyHomeOpenSDK isAppInstalled]) {
        self.enjoyHomeButton.hidden = YES;
    }
    if (self.enjoyHomeButton.hidden && self.qqLoginButton.hidden && self.wechatLoginButton.hidden) {
        self.lblOtherLogin.hidden = YES;
    }
    self.btnLogin.enabled = NO;
    
    [self setupForAVplayerView];
    [_player play];
    [self getAVFile];
    [self observerNotifications];
    
    // 显示隐私政策提示弹框
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"isShowPrivacyAlert"]) {
        GSHPrivacyNotiVCViewController *privacyNotiVC = [[GSHPrivacyNotiVCViewController alloc] init];
        [self addChildViewController:privacyNotiVC];
        privacyNotiVC.view.frame = self.view.frame;
        [self.view addSubview:privacyNotiVC.view];
    }
    
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:UIApplicationDidBecomeActiveNotification];
    [self observerNotification:UIApplicationDidEnterBackgroundNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [_player pause];
    }
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [_player play];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshLoginBut{
    if (self.isPassWord) {
        if (self.mobileTextField.text.length == 0 || self.passWordField.text.length == 0) {
            self.btnLogin.enabled = NO;
            return;
        }
    }else{
        if (self.mobileTextField.text.length == 0 || self.codeTextField.text.length == 0) {
            self.btnLogin.enabled = NO;
            return;
        }
    }
    self.btnLogin.enabled = YES;
}

- (void)getAVFile{
    __weak typeof(self)weakSelf = self;
    [GSHRequestManager getWithPath:@"general/getIndexVideoInfo" parameters:@{@"type":@(1)} block:^(id responseObjec, NSError *error) {
        if ([responseObjec isKindOfClass:NSDictionary.class]) {
            NSString *videoUrl = [(NSDictionary*)responseObjec stringValueForKey:@"videoUrl" default:nil];
            NSString *version = [(NSDictionary*)responseObjec stringValueForKey:@"version" default:nil];
            if (videoUrl) {
                [weakSelf requestAVUrl:videoUrl version:version];
            }
        }
    }];
}

-(void)requestAVUrl:(NSString *)avUrl version:(NSString*)version{
    NSString *localityVersion = [[NSUserDefaults standardUserDefaults] stringForKey:GSHLoginIndexVideoInfoVersion];
    if (version && [localityVersion isEqualToString:version]) {
        return;
    }
    NSURL *url = [NSURL URLWithString:avUrl];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (location) {
            NSURL *filePath = [NSURL fileURLWithPath:[GSHLoginVC getAVFilePath]];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtURL:filePath error:nil];
            [fileManager moveItemAtURL:location toURL:filePath error:nil];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (version) {
                [userDefaults setObject:version forKey:GSHLoginIndexVideoInfoVersion];
                [userDefaults synchronize];
            }
        }
    }];
    [task resume];
}

+ (NSString *)getAVFilePath{
     NSString * cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
     NSString * downloadImagesPath = [cachesPath stringByAppendingPathComponent:@"DownloadImages"];
     NSFileManager * fileManager = [NSFileManager defaultManager];
     if (![fileManager fileExistsAtPath:downloadImagesPath]){
         [fileManager createDirectoryAtPath:downloadImagesPath withIntermediateDirectories:YES attributes:nil error:nil];
     }
     NSString * fileName = @"loginAV.mp4";
     NSString * filePath = [downloadImagesPath stringByAppendingPathComponent:fileName];
     return filePath;
}

- (void)setupForAVplayerView{
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    playerLayer.frame = self.view.bounds;
    [self.viewFirst.layer insertSublayer:playerLayer atIndex:0];
}

- (AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem = [self getPlayItem];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return _player;
}

- (AVPlayerItem *)getPlayItem{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString *filePath = [GSHLoginVC getAVFilePath];
    if (![fileManager fileExistsAtPath:filePath]){
        filePath = [[NSBundle mainBundle]pathForResource:@"loginAV" ofType:@"mp4"];
    }
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    return playerItem;
}

- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)sender{
//    [_player seekToTime:kCMTimeZero]; // 设置从头继续播放
}

#pragma mark -点击事件
- (IBAction)touchPhoneLogin:(UIButton *)sender{
    self.viewFirst.hidden = YES;
    [_player pause];
    [self setNeedsStatusBarAppearanceUpdate];
}
- (IBAction)touchWeChatLogin:(UIButton *)sender{
    if (![OpenShare isWeixinInstalled]) {
        [TZMProgressHUDManager showErrorWithStatus:@"请先安装微信客户端" inView:self.view];
        return;
    }
    [self weChatLogin];
}

- (IBAction)qqThirdLogin:(id)sender {
    if ([OpenShare isQQInstalled]) {
        @weakify(self)
        [OpenShare QQAuth:kOPEN_PERMISSION_GET_INFO Success:^(NSDictionary *message) {
            @strongify(self)
            NSLog(@"message : %@",message);
            [self getUnionIdWithDictionary:message];
        } Fail:^(NSDictionary *message, NSError *error) {
            
        }];
    } else {
        [TZMProgressHUDManager showErrorWithStatus:@"请先安装QQ客户端" inView:self.view];
    }
}
- (IBAction)enjoyHomeLogin:(UIButton *)sender {
    if ([EnjoyHomeOpenSDK isAppInstalled]) {
    __weak typeof(self)weakSelf = self;
        [EnjoyHomeOpenSDK sendAuthLoginReqWithAppId:@"enjoyHome" authFetchInfoMode:EHAuthFetchInfoModeBasic Success:^(NSString *authCode) {
            NSLog(@"authCode : %@",authCode);
            if (authCode) {
                [weakSelf getEnjoyUserInfoWithAuthCode:authCode];
            }
        } Fail:^(NSError *error) {
        }];
    } else {
        [TZMProgressHUDManager showErrorWithStatus:@"请先安装享家客户端" inView:self.view];
    }
}

- (IBAction)touchNavBack:(UIButton *)sender{
    self.viewFirst.hidden = NO;
    [_player play];
    [self setNeedsStatusBarAppearanceUpdate];
}
- (IBAction)touchLoginType:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.isPassWord = sender.selected;
    if (self.isPassWord) {
        self.viewCode.hidden = YES;
        self.viewPassword.hidden = NO;
        self.btnLogin.selected = YES;
        self.btnFindPassword.hidden = !self.passWordLoginError;
    }else{
        self.viewCode.hidden = NO;
        self.viewPassword.hidden = YES;
        self.btnLogin.selected = NO;
        self.btnFindPassword.hidden = YES;
    }
    [self refreshLoginBut];
}
- (IBAction)touchGetCode:(UIButton *)sender{
    [self.view endEditing:YES];
    NSString *mobile = [self.mobileTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![mobile tzm_checkMobileNumber]) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入正确手机号" inView:self.view];
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"验证码获取中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHUserManager postVerifyCodeWithPhoneNumber:mobile type:GSHGetVerifyCodeTypeLogin block:^(NSError *error) {
        if (error) {
            // 请求失败
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        } else {
            // 请求成功
            [TZMProgressHUDManager showSuccessWithStatus:@"获取验证码成功" inView:weakSelf.view];
            [weakSelf.btnGetCode startTimeWithDuration:KCountDownDuration]; // 按钮开始倒计时
        }
    }];
}
- (IBAction)touchHidePassword:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self.passWordField setSecureTextEntry:!sender.selected];
}
- (IBAction)touchFindPassword:(UIButton *)sender{
    GSHLoginInputPhoneNumberVC *findPasswordVC = [GSHLoginInputPhoneNumberVC loginInputPhoneNumberVC];
    [self.navigationController pushViewController:findPasswordVC animated:YES];
}
- (IBAction)touchLogin:(UIButton *)sender{
    [self.view endEditing:YES];
    __weak typeof(self)weakSelf = self;
    NSString *mobile = [self.mobileTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![mobile tzm_checkMobileNumber]) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入正确手机号" inView:weakSelf.view];
        return;
    }
    if (self.isPassWord) {
        if ([self.passWordField.text tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"密码不能为空" inView:weakSelf.view];
            return;
        }
        [TZMProgressHUDManager showWithStatus:@"登录中" inView:self.view];
        __weak typeof(self)weakSelf = self;
        [GSHUserManager postLoginWithPhoneNumber:mobile passWord:self.passWordField.text block:^(GSHUserM *user, NSError *error) {
            if (error) {
                weakSelf.passWordLoginError = YES;
                if (weakSelf.isPassWord) {
                    weakSelf.btnFindPassword.hidden = !weakSelf.passWordLoginError;
                }
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            } else {
                [weakSelf loginSuccessToHandleByUserM:user];
            }
        }];
    }else{
        if ([self.codeTextField.text tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"验证码不能为空" inView:weakSelf.view];
            return;
        }
        [TZMProgressHUDManager showWithStatus:@"登录中" inView:self.view];
        [GSHUserManager postLoginWithPhoneNumber:mobile verifyCode:self.codeTextField.text block:^(GSHUserM *user, NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            } else {
                [weakSelf loginSuccessToHandleByUserM:user];
            }
        }];
    }
}
- (IBAction)touchXieYi:(UIButton *)sender{
    NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypeAgreement parameter:nil];
    [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
}

- (IBAction)touchZhengce:(UIButton *)sender {
    NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypePrivacy parameter:nil];
    [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
}

static NSInteger _touchChangeEnvironmentCount;
- (IBAction)changeButtonClick:(id)sender {
    if (_touchChangeEnvironmentCount > 6) {
        [GSHAppConfig showChangeAlertViewWithVC:self];
    }else{
        _touchChangeEnvironmentCount++;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf refreshLoginBut];
    });
    return YES;
}

#pragma mark -
// 登录成功的处理
- (void)loginSuccessToHandleByUserM:(GSHUserM *)userM {
    [[NSUserDefaults standardUserDefaults] setObject:userM.phone forKey:GSHLoginSuccessMobileNo];
    if (userM.currentFamilyId.length > 0) {
        // 有家庭
        [TZMProgressHUDManager showSuccessWithStatus:@"登录成功" inView:self.view];
        // 登录成功 进入首页
        GSHMainTabBarViewController *mainTabBarVC = [[GSHMainTabBarViewController alloc] init];
        [(GSHAppDelegate*)[UIApplication sharedApplication].delegate changeRootController:mainTabBarVC animate:YES];
    } else {
        [TZMProgressHUDManager dismissInView:self.view];
        GSHNoFamilyVC *noFamilyVC = [[GSHNoFamilyVC alloc] init];
        [self.navigationController pushViewController:noFamilyVC animated:YES];
    }
}

- (NSURLSessionDataTask *)getWithAllUrl:(NSString *)allUrl
                             parameters:(id)parameters
                                success:(void (^)(id operationOrTask, id responseObject))success
                                failure:(void (^)(id operationOrTask, NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/plain",@"text/javascript",@"application/x-gzip" ,nil];
    return [manager GET:allUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *json = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Response GET: %@ , %@ \njson : %@", task.currentRequest.URL,parameters?parameters:@"",json);
        if (success) {
            success(task,json);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task,error);
        }
    }];
}

- (void)postThirdPartyLoginWithOpenId:(NSString *)openId
                             userName:(NSString *)userName
                           headImgUrl:(NSString *)headImgUrl
                                 type:(GSHUserMLoginType)type
                   userThirdLoginType:(GSHUserMThirdPartyLoginType)userThirdLoginType {
    @weakify(self)
    [GSHUserManager postThirdPartyLoginWithOpenId:openId userName:userName headImgUrl:headImgUrl type:type userThirdLoginType:userThirdLoginType block:^(GSHUserM *user, NSError *error) {
        @strongify(self)
        if (error) {
            // 请求失败
            if (error.code == 101) {
                // 未绑定手机号
                [TZMProgressHUDManager dismissInView:self.view];
                GSHThirdLoginBindMobileVC *bindVC = [[GSHThirdLoginBindMobileVC alloc] init];
                bindVC.openId = openId;
                bindVC.userName = userName;
                bindVC.headImgUrl = headImgUrl;
                bindVC.type = type;
                bindVC.userThirdLoginType = userThirdLoginType;
                [self.navigationController pushViewController:bindVC animated:YES];
            } else {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            }
        } else {
            [GSHUserManager currentUserInfo].picPath = headImgUrl;
            [self loginSuccessToHandleByUserM:user];
        }
    }];
}
#pragma mark -微信登录
- (void)weChatLogin {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_ACCESS_TOKEN];
    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
    // 如果已经请求过微信授权登录，那么考虑用已经得到的access_token
    if (accessToken && openID) {
        NSString *refreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_REFRESH_TOKEN];
        NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token"];
        NSDictionary *dict = @{@"appid":WX_App_ID,@"refresh_token":refreshToken,@"grant_type":@"refresh_token"};
        @weakify(self)
        [TZMProgressHUDManager showWithStatus:@"登录中" inView:self.view];
        [self getWithAllUrl:urlString parameters:dict success:^(id operationOrTask, id responseObject) {
            @strongify(self)
            NSDictionary *dict = [NSDictionary tzm_dictionaryWithJsonString:responseObject];
            NSString *reAccessToken = [dict objectForKey:WX_ACCESS_TOKEN];
            // 如果reAccessToken为空,说明reAccessToken也过期了,反之则没有过期
            if (reAccessToken) {
                //存储AccessToken OpenId RefreshToken以便下次直接登陆,  AccessToken有效期两小时，RefreshToken有效期三十天
                [[NSUserDefaults standardUserDefaults] setObject:reAccessToken forKey:WX_ACCESS_TOKEN];
                [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:WX_OPEN_ID] forKey:WX_OPEN_ID];
                [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:WX_REFRESH_TOKEN] forKey:WX_REFRESH_TOKEN];
                [[NSUserDefaults standardUserDefaults] synchronize]; // 命令直接同步到文件里，来避免数据的丢失
                [self wechatLoginByRequestForUserInfo]; // 获取微信用户信息
            } else {
                [self getWeChatAuthCode];
            }
        } failure:^(id operationOrTask, NSError *error) {
            NSLog(@"error : %@",error);
            @strongify(self)
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        }];
    } else {
        [self getWeChatAuthCode];
    }
}
// 获取code
- (void)getWeChatAuthCode {
    @weakify(self)
    [OpenShare WeixinAuth:@"snsapi_userinfo" Success:^(NSDictionary *message) {
        @strongify(self)
        NSLog(@"微信登录成功:\n%@",message);
        [self getAccessTokenWithCode:[message objectForKey:@"code"]];
    } Fail:^(NSDictionary *message, NSError *error) {
        NSLog(@"微信登录失败:\n%@\n%@",message,error);
    }];
}
// 使用code获取access token
- (void)getAccessTokenWithCode:(NSString *)code {
    [TZMProgressHUDManager showWithStatus:@"登录中" inView:self.view];
    NSString *urlString = @"https://api.weixin.qq.com/sns/oauth2/access_token";
    NSDictionary *dict = @{@"appid":WX_App_ID,@"secret":WX_AppSecret,@"code":code,@"grant_type":@"authorization_code"};
    @weakify(self)
    [self getWithAllUrl:urlString parameters:dict success:^(id operationOrTask, id responseObject) {
       @strongify(self)
        NSDictionary *dict = [NSDictionary tzm_dictionaryWithJsonString:responseObject];
        if ([dict objectForKey:@"errcode"]) {
            //获取token错误
            [TZMProgressHUDManager showErrorWithStatus:[dict objectForKey:@"errcode"] inView:self.view];
        } else {
            //存储AccessToken OpenId RefreshToken以便下次直接登陆,  AccessToken有效期两小时，RefreshToken有效期三十天
            NSString *accessToken = [dict objectForKey:WX_ACCESS_TOKEN];
            NSString *openID = [dict objectForKey:WX_OPEN_ID];
            NSString *refreshToken = [dict objectForKey:WX_REFRESH_TOKEN];
            if (accessToken && ![accessToken isEqualToString:@""] && openID && ![openID isEqualToString:@""]) {
                [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:WX_ACCESS_TOKEN];
                [[NSUserDefaults standardUserDefaults] setObject:openID forKey:WX_OPEN_ID];
                [[NSUserDefaults standardUserDefaults] setObject:refreshToken forKey:WX_REFRESH_TOKEN];
                [[NSUserDefaults standardUserDefaults] synchronize]; // 命令直接同步到文件里，来避免数据的丢失
            }
            [self wechatLoginByRequestForUserInfo]; // 获取微信用户信息
        }
    } failure:^(id operationOrTask, NSError *error) {
        NSLog(@"error : %@",error);
        @strongify(self)
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
    }];
}

// 获取用户个人信息（UnionID机制）
- (void)wechatLoginByRequestForUserInfo {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_ACCESS_TOKEN];
    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
    NSString *userUrlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo"];
    NSDictionary *dict = @{@"access_token":accessToken,@"openid":openID};
    @weakify(self)
    [self getWithAllUrl:userUrlStr parameters:dict success:^(id operationOrTask, id responseObject) {
        @strongify(self)
        NSLog(@"请求用户信息的response = %@", responseObject);
        NSDictionary *userDict = [NSDictionary tzm_dictionaryWithJsonString:responseObject];
        NSString *nickName = [userDict objectForKey:@"nickname"];
        NSString *openId = [userDict objectForKey:@"openid"];
        NSString *headImgUrl = [userDict objectForKey:@"headimgurl"];
        [self postThirdPartyLoginWithOpenId:openId userName:nickName headImgUrl:headImgUrl type:GSHUserMLoginTypeWechat userThirdLoginType:GSHUserMThirdPartyLoginTypeWechat];
    } failure:^(id operationOrTask, NSError *error) {
        NSLog(@"获取用户信息时出错 = %@", error);
        @strongify(self)
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
    }];
}
#pragma mark -QQ登录
- (void)getUnionIdWithDictionary:(NSDictionary *)message {
    NSString *access_token = [message objectForKey:@"access_token"];
    NSString *urlString = @"https://graph.qq.com/oauth2.0/me";
    NSDictionary *dict = @{@"access_token":access_token,@"unionid":@"1"};
    @weakify(self)
    [self getWithAllUrl:urlString parameters:dict success:^(id operationOrTask, id responseObject) {
        @strongify(self)
        [TZMProgressHUDManager dismissInView:self.view];
        NSString *result = [responseObject substringFromIndex:10];
        result = [result substringToIndex:result.length-3];
        NSDictionary *dict = [NSDictionary tzm_dictionaryWithJsonString:result];
        [self getUserInfoWithDictionary:message unionid:[dict objectForKey:@"unionid"]];
    } failure:^(id operationOrTask, NSError *error) {
        @strongify(self)
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
    }];
}

- (void)getUserInfoWithDictionary:(NSDictionary *)message unionid:(NSString *)unionid {
    NSString *urlString = @"https://graph.qq.com/user/get_user_info";
    NSString *openId = [message objectForKey:@"openid"];
    NSString *access_token = [message objectForKey:@"access_token"];
    NSString *oauth_consumer_key = QQ_App_ID;
    NSDictionary *dict = @{@"access_token":access_token,@"oauth_consumer_key":oauth_consumer_key,@"openid":openId};
    [TZMProgressHUDManager showWithStatus:@"登录中" inView:self.view];
    @weakify(self)
    [self getWithAllUrl:urlString parameters:dict success:^(id operationOrTask, id responseObject) {
        @strongify(self)
        [TZMProgressHUDManager dismissInView:self.view];
        NSDictionary *dict = [NSDictionary tzm_dictionaryWithJsonString:responseObject];
        NSString *userName = [dict valueForKey:@"nickname"];
        NSString *headImgUrl1 = [dict objectForKey:@"figureurl_qq_1"];
        NSString *headImgUrl2 = [dict objectForKey:@"figureurl_qq_2"];
        [self postThirdPartyLoginWithOpenId:unionid
                                   userName:userName
                                 headImgUrl:headImgUrl2.length>0?headImgUrl2:headImgUrl1
                                       type:GSHUserMLoginTypeQQ
                         userThirdLoginType:GSHUserMThirdPartyLoginTypeQQ];
    } failure:^(id operationOrTask, NSError *error) {
        @strongify(self)
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
    }];
}

#pragma mark -享家登录
- (void)getEnjoyUserInfoWithAuthCode:(NSString *)authCode {
    [TZMProgressHUDManager showWithStatus:@"" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHRequestManager postWithPath:@"user/getEnjoyUserInfo" parameters:@{@"accessToken":authCode} block:^(id responseObjec, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if ([responseObjec isKindOfClass:NSDictionary.class]){
                NSString *headImgUrl = [((NSDictionary*)responseObjec) stringValueForKey:@"headImgUrl" default:nil];
                NSString *openId = [((NSDictionary*)responseObjec) stringValueForKey:@"openId" default:nil];
                NSString *userName = [((NSDictionary*)responseObjec) stringValueForKey:@"nickName" default:nil];
                [weakSelf postThirdPartyLoginWithOpenId:openId
                                           userName:userName
                                         headImgUrl:headImgUrl
                                               type:GSHUserMLoginTypeEnjoy
                                 userThirdLoginType:GSHUserMThirdPartyLoginTypeEnjoy];
            }
        }
    }];
}

@end
