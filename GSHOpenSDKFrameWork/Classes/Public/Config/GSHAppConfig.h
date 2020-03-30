//
//  GSHAppConfig.h
//  SmartHome
//
//  Created by gemdale on 2018/4/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+TZM.h"
#import "TZMPushManager.h"

#ifdef DEBUG
#else
#endif

#pragma mark - 宏--第三方信息
// wechat
#define WX_App_ID @"wx50d1e4fbc3ee47a8"
#define WX_AppSecret @"9522a0144a7934ce7954e23a34970d36"
#define WX_ACCESS_TOKEN @"access_token"
#define WX_REFRESH_TOKEN @"refresh_token"
#define WX_OPEN_ID @"openid"
// QQ
#define QQ_App_ID @"1107017080"
#define QQ_AppKey @"HsClO3cZ580E0M6N"
// Bugly
#define Bugly_App_ID @"38e5c4af9a"
#define Bugly_AppKey @"e7fb1401-7e13-4551-8f9f-117e52e02bac"
// AliPush
#define AliPush_AppKey @"25025426"
#define AliPush_AppSecret @"9613b6d58f7c986fd74ff10723632523"
// 科大讯飞
#define XunFei_AppId @"5c0f6d36"

static NSString * const kTencentQQAppID = @"";

static NSString * const kYingShiAppID = @"6c03c351df624de9bfdb241a2d6a74a1";

static NSString * const kWXAppID = @""; //应用ID：这里是一个最新申请的微信APPID 用于除了支付以外的功能

#pragma mark -

typedef enum : NSInteger {
    GSHAppConfigTypeProduction = 0, // 生产环境
    GSHAppConfigTypePrepare    = 1, // 预发布环境
    GSHAppConfigTypeIP    = 2, // 直连ip
    GSHAppConfigTypeTest    = 3, // 测试
} GSHAppConfigType;

@interface GSHAppConfig : NSObject
@property (nonatomic, readonly, assign) GSHAppConfigType type;
@property (nonatomic, readonly, copy) NSString *typeString;
@property (nonatomic, readonly, copy) NSString *desc;

@property (nonatomic, copy) NSString *httpHostString;
@property (nonatomic, copy) NSString *httpIpString;
@property (nonatomic, copy) NSString *httpDomainString;
@property (nonatomic, strong) NSNumber *httpPort;
@property (nonatomic, copy) NSString *h5IpString;
@property (nonatomic, copy) NSString *ossHostString;
@property (nonatomic, copy) NSString *ossDomainString;
@property (nonatomic, copy) NSString *ossIpString;


@property (nonatomic, readonly, copy) NSString *tcpDomainString;
@property (nonatomic, readonly, assign) uint16_t tcpHostPort;

@property (nonatomic, readonly, copy) NSString *udpDomainString;
@property (nonatomic, readonly, assign) uint16_t udpHostPort;

+ (GSHAppConfig *)config;

// 切换配置
+ (void)showChangeAlertViewWithVC:(UIViewController*)VC;

@end
