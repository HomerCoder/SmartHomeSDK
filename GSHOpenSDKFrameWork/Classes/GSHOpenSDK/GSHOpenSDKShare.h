//
//  GSHOpenSDK.h
//  SmartHome
//
//  Created by gemdale on 2019/7/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define GSHSDKAppId @"10122234"

//! Project version number for GSHOpenSDK.
FOUNDATION_EXPORT double GSHOpenSDKVersionNumber;
//! Project version string for GSHOpenSDK.
FOUNDATION_EXPORT const unsigned char GSHOpenSDKVersionString[];

extern NSString * const GSHOpenSDKFamilyChangeNotification;                                 //当前家庭被切换
extern NSString * const GSHOpenSDKFamilyListUpdataNotification;                             //家庭列表更新
extern NSString * const GSHOpenSDKFamilyUpdataNotification;                                 //当前家庭改变
extern NSString * const GSHOpenSDKFamilyGatewayChangeNotification;                          //网关替换中
extern NSString * const GSHOpenSDKDeviceUpdataNotification;                                 //设备更新（会带上一个数组，改动相关房间的roomId）
extern NSString * const GSHOpenSDKSceneUpdataNotification;                                  //场景更新（会带上一个数组，改动相关房间的roomId）

extern NSString * const GSHSDKNotificationAuth;                                             // 调用授权页面的通知
extern NSString * const GSHSDKNotificationAccessToken;                                      // 获取享家授权结果及accessToken的通知


@class GSHFamilyM;

@interface GSHOpenSDKShare : NSObject
@property(nonatomic,copy,readonly)NSString *userId;
@property(nonatomic,strong)NSMutableArray<GSHFamilyM*> *familyList;
@property(nonatomic,strong)GSHFamilyM *currentFamily;
@property(nonatomic,strong)NSString *appId;

+(instancetype)share;

#pragma mark  - Appdelegate
// sdk 初始化方法,集成方在appDelegate -- didFinishLaunchingWithOptions 中调用
-(void)initSDK;

// 通知处理方法
-(void)handleNotificationWithApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

-(void)setAppId:(NSString *)appId;

-(void)authWithAppId:(NSString*)appid phone:(NSString*)phone userId:(NSString*)userId black:(void(^)(NSError *error))block;

//设置http请求返回总回调block
-(void)setResponseBlock:(void(^)(NSError *error))responseBlock;
//更新HttpApi服务域名与端口（不设置默认线上服务）
-(void)updateHttpDomain:(NSString*)httpDomain port:(NSNumber*)port;
//更新OSS服务域名(不设置默认线上服务)
-(void)updateOssDomain:(NSString*)ossDomain;



@end
