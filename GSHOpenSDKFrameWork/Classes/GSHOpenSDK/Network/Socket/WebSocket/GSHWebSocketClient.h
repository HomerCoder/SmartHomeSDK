//
//  GSHChangeNetworkManager.h
//  SmartHome
//
//  Created by gemdale on 2019/1/29.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHAsyncUdpSocketClient.h"

extern NSString * const GSHChangeNetworkManagerWebSocketOpenNotification;               //ws链接成功
extern NSString * const GSHChangeNetworkManagerWebSocketCloseNotification;              //ws链接失败
extern NSString * const GSHChangeNetworkManagerWebSocketRealDataUpdateNotification;     //ws实时数据更新

@class GSHBaseMsg;
@interface GSHWebSocketTask : NSObject
- (void)cancel;
@end

typedef enum : NSUInteger {
    GSHNetworkTypeWAN,
    GSHNetworkTypeLAN,
} GSHNetworkType;
//此类不支持直接用performSelector发送延时消息，应为内部有取消所有延时发送消息的代码
@interface GSHWebSocketClient : NSObject
@property(nonatomic,assign,readonly)GSHNetworkType networkType;
+(instancetype)shared;
//切换网络(只是切换网络模式，不代表socket网络已经链接成功。如果是从外切到内，那么检测是否能找到当前家庭网关，能找到则切换成功。如果是内切到外，则直接成功)。在此之前按产品需求应该先同步云端信息
-(GSHAsyncUdpSocketTask *)changType:(GSHNetworkType)type gatewayId:(NSString *)gatewayId block:(void(^)(NSError *error))block;
//链接
-(void)getWebSocketIpAndPortToConnectWithGWId:(NSString*)gwId;
//关闭ws
-(void)clearWebSocket;
//是否在链接中
-(BOOL)isConnect;

//发送获取实时数据请求
-(BOOL)sendGetRealTimeMsg;
//实时数据字典
-(NSDictionary*)realTimeDic;

//控制设备
-(GSHWebSocketTask*)deviceControlWithGatewayId:(NSString *)gatewayId deviceSN:(NSString *)deviceSN basMeteId:(NSString *)basMeteId value:(NSString *)value block:(void(^)(NSError *error))block;
//发送执行场景消息
-(GSHWebSocketTask*)executeSceneWithGatewayId:(NSString *)gatewayId scenarioId:(NSString *)scenarioId block:(void(^)(NSError *error))block;
//启动关闭联动
-(GSHWebSocketTask*)updateAutoStatushWithGatewayId:(NSString *)gatewayId ruleId:(NSString *)ruleId status:(NSString *)status block:(void(^)(NSError *error))block;
@end
