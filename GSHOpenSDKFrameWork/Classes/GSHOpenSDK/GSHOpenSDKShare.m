//
//  GSHOpenSDK.m
//  SmartHome
//
//  Created by gemdale on 2019/7/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHOpenSDKShare.h"
#import "GSHJSONRequestSerializer.h"
#import "GSHFamilyM.h"
#import <YYCategories/YYCategories.h>
#import "GSHUserM.h"
#import "GSHOSSManagerClient.h"
#import "GSHWebSocketClient.h"
#import "GSHHTTPAPIClient.h"

#import "GSHAlertManager.h"
#import "GSHYingShiManager.h"
#import "GSHInfraredControllerManager.h"
#import "GSHVoiceM.h"
#import "GSHAppConfig.h"
#import <OpenShareHeader.h> //OpenShare
#import "WXApi.h"
#import "UIViewController+TZM.h"
#import "TZMPushManager.h"

NSString * const GSHOpenSDKFamilyChangeNotification = @"GSHOpenSDKFamilyChangeNotification";                    //当前房间被切换
NSString * const GSHOpenSDKFamilyListUpdataNotification = @"GSHOpenSDKFamilyListUpdataNotification";            //家庭列表更新
NSString * const GSHOpenSDKFamilyUpdataNotification = @"GSHOpenSDKFamilyUpdataNotification";                    //当前家庭改变
NSString * const GSHOpenSDKFamilyGatewayChangeNotification = @"GSHOpenSDKFamilyGatewayChangeNotification";      //网关替换中
NSString * const GSHOpenSDKDeviceUpdataNotification = @"GSHOpenSDKDeviceUpdataNotification";                    //
NSString * const GSHOpenSDKSceneUpdataNotification = @"GSHOpenSDKSceneUpdataNotification";                      //场景更新（会带上一个数组，改动相关房间的roomId）GSHOpenSDKSceneUpdataNotification

NSString * const GSHSDKNotificationAuth = @"GSHSDKNotificationAuth";
NSString * const GSHSDKNotificationAccessToken = @"GSHSDKNotificationAccessToken";    

@interface GSHOpenSDKShare()
@property(nonatomic,copy,readwrite)NSString *userId;
@property(nonatomic,copy,readwrite)NSString *appid;
@property(nonatomic,strong,readwrite)GSHHTTPAPIClient *httpAPIClient;
@property(nonatomic,strong,readwrite)GSHWebSocketClient *webSocketClient;
@property(nonatomic,strong,readwrite)GSHOSSManagerClient *ossManagerClient;
@end

@implementation GSHOpenSDKShare
+(instancetype)share{
    static dispatch_once_t onceToken ;
    static GSHOpenSDKShare *_share = nil;
    dispatch_once(&onceToken, ^{
        _share = [[self alloc] init];
    });
    return _share;
}

// sdk 初始化方法,集成方在appDelegate -- didFinishLaunchingWithOptions 中调用
-(void)initSDK {
    [self initConfig];
    [self initUIStyle];
}

// 通知处理方法
-(void)handleNotificationWithApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *flagValue = @"";
    if (application.applicationState == UIApplicationStateActive) {
        // 在应用页面收到通知
        flagValue = @"1";
    } else {
        // 应用在后台模式或关闭时 收到通知
        flagValue = @"2";
    }
    [dic setObject:flagValue forKey:@"flag"];
    [dic setObject:userInfo forKey:@"userInfo"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TZMRemoteNotification object:dic];
}

static BOOL showLoginOut = NO;
- (void)initConfig {
  
    [[GSHOpenSDKShare share] setResponseBlock:^(NSError *error) {
        if (error.code == 117) {
            if (!(showLoginOut || [GSHUserManager currentUser].userId.length == 0)) {
                showLoginOut = YES;
                NSString *message = error.localizedDescription;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                        [GSHUserManager setCurrentUser:nil];
                        showLoginOut = NO;
                    } textFieldsSetupHandler:NULL andTitle:@"警告" andMessage:message image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"确认",nil];
                });
            }
        }
    }];
    [GSHYingShiManager initEZOpenSDK:kYingShiAppID];
    [GSHInfraredControllerManager initKuKongSDKWithUserAuthority:@"88ED3C305D0DE7EADCD7F70BD3F493D1"];
    [GSHVoiceManager initIFlyAppId:XunFei_AppId];
    
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:100 * 1024 * 1024 diskPath:@"NSURLCache"];
    [NSURLCache setSharedURLCache:cache];
    
    [WXApi registerApp:WX_App_ID];   // 设置微信appId
    [OpenShare connectWeixinWithAppId:WX_App_ID];   // 设置微信appId
    [OpenShare connectQQWithAppId:QQ_App_ID];   // qq
    
}

//初始化UI配置
- (void)initUIStyle {
    [[UITableView appearance] setSeparatorColor:[UIColor colorWithHexString:@"#eaeaea"]];
    UINavigationBar *navBar = [UINavigationBar appearance];
    //样式
    navBar.barStyle = UIBarStyleDefault;
    //是否半透明
    navBar.translucent = NO;
    //背景颜色(背景图片优先颜色)
    navBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //阴影图片
    navBar.shadowImage = [UIImage imageWithColor:[UIColor clearColor]];
    // title
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#222222"],NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18]};
    //返回按钮
    UIImage *backImage = [UIImage ZHImageNamed:@"app_icon_blackback_normal"];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navBar.backIndicatorImage = backImage;
    navBar.backIndicatorTransitionMaskImage = backImage;
    dispatch_async_on_main_queue(^{
        [UIViewController tzm_appearance].tzmBackBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
    
    UITabBar *tabbar = [UITabBar appearance];
    tabbar.translucent = YES;
    tabbar.shadowImage = [UIImage imageWithColor:[UIColor colorWithRGB:0xe8e8e8] size:CGSizeMake(10, 0.5)];
    tabbar.backgroundImage = [UIImage imageWithColor:[UIColor colorWithRGB:0xffffff alpha:0.9] size:CGSizeMake(10, 10)];
    
    [UIViewController tzm_exchangeImplementationsViewWillAppearBlock:^BOOL(UIViewController *vc) {
        NSLog(@"-------------%@",vc.className);
        if ([vc.className rangeOfString:@"GSH"].location != NSNotFound) {
            return YES;
        }
        return NO;
    }];

}


-(NSString *)userId{
    return [GSHUserManager currentUser].userId;
}

-(void)authWithAppId:(NSString*)appid phone:(NSString*)phone userId:(NSString*)userId black:(void(^)(NSError *error))block{
    self.appid = appid;
    [self.httpAPIClient.requestSerializer setValue:self.appid forHTTPHeaderField:@"appId"];
    NSDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:appid forKey:@"appId"];
    [dic setValue:phone forKey:@"phone"];
    [dic setValue:userId forKey:@"muserId"];
    [GSHUserManager setCurrentUser:nil];
    [self.httpAPIClient POST:@"link/auth" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHUserM *user = [GSHUserM yy_modelWithJSON:responseObject];
        [GSHUserManager setCurrentUser:user];
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

//设置http请求返回总回调block
-(void)setResponseBlock:(void(^)(NSError *error))responseBlock{
    self.httpAPIClient.responseBlock = responseBlock;
}

-(void)setCurrentFamily:(GSHFamilyM *)currentFamily{
    _currentFamily = currentFamily;
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN && currentFamily) {
        [GSHFamilyManager postHomeVCChangeFamilyWithFamilyId:currentFamily.familyId block:^(NSError *error) {
        }];
    }
    [self updateGWId];
    [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyChangeNotification object:currentFamily]];
}

-(void)updateGWId{
    if (self.webSocketClient == nil) {
        self.webSocketClient = [GSHWebSocketClient shared];
    }
    [self.webSocketClient getWebSocketIpAndPortToConnectWithGWId:self.currentFamily.gatewayId];
}

-(GSHHTTPAPIClient *)httpAPIClient{
    if (_httpAPIClient == nil) {
        NSURLComponents *urlComponents = [NSURLComponents new];
        urlComponents.scheme = @"https";
        urlComponents.host = @"app.gemdalehome.com";
        urlComponents.path = @"";
        self.httpAPIClient = [[GSHHTTPAPIClient alloc] initWithBaseURL:[urlComponents URL]];
        [GSHJSONRequestSerializer userNewAccessKey:NO];
    }
    return _httpAPIClient;
}

-(void)updateHttpDomain:(NSString*)httpDomain port:(NSNumber*)port{
    NSURLComponents *urlComponents = [NSURLComponents new];
    urlComponents.scheme = @"http";
    urlComponents.host = httpDomain;
    urlComponents.port = port;
    urlComponents.path = @"";
    self.httpAPIClient = [[GSHHTTPAPIClient alloc] initWithBaseURL:[urlComponents URL]];
    [GSHJSONRequestSerializer userNewAccessKey:NO];
}

-(GSHOSSManagerClient *)ossManagerClient{
    if (_ossManagerClient == nil) {
        NSURLComponents *urlComponents = [NSURLComponents new];
        urlComponents.scheme = @"http";
        urlComponents.host = @"dfs.gemdalehome.com";
        urlComponents.path = @"";
        _ossManagerClient = [[GSHOSSManagerClient alloc] initWithBaseURL:[urlComponents URL]];
    }
    return _ossManagerClient;
}

-(void)updateOssDomain:(NSString*)ossDomain {
    NSURLComponents *urlComponents = [NSURLComponents new];
    urlComponents.scheme = @"http";
    if ([ossDomain containsString:@":"]) {
        NSArray *arr = [ossDomain componentsSeparatedByString:@":"];
        urlComponents.host = arr[0];
        urlComponents.port = ((NSString *)arr[1]).numberValue;
    } else {
        urlComponents.host = ossDomain;
    }
    urlComponents.path = @"";
    self.ossManagerClient = [[GSHOSSManagerClient alloc] initWithBaseURL:[urlComponents URL]];
}

@end
