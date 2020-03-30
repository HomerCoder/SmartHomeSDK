//
//  GSHChangeNetworkManager.m
//  SmartHome
//
//  Created by gemdale on 2019/1/29.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHWebSocketClient.h"
#import "GSHOpenSDKInternal.h"

#import "GSHGWSearchMsg.h"
#import "GSHHeartMsg.h"
#import "GSHDeviceRealTimeMsg.h"
#import "GSHDeviceControlMsg.h"
#import "GSHExecuteSceneMsg.h"
#import "GSHUpdateAutoStatusMsg.h"
#import "GSHBaseMsg.h"

#import "AFNetworking.h"
#import "SRWebSocket.h"

#import <TZMOpenLib/NSObject+TZM.h>
#import "YYCategories.h"

NSString *const GSHWebSocketClientType = @"GSHWebSocketClientType";
NSString *const GSHWebSocketClientLANIp = @"GSHWebSocketClientLANIp";
NSString *const GSHChangeNetworkManagerWebSocketOpenNotification = @"GSHChangeNetworkManagerWebSocketOpenNotification";                         //ws链接成功
NSString *const GSHChangeNetworkManagerWebSocketCloseNotification = @"GSHChangeNetworkManagerWebSocketCloseNotification";                       //ws链接失败
NSString *const GSHChangeNetworkManagerWebSocketRealDataUpdateNotification = @"GSHChangeNetworkManagerWebSocketRealDataUpdateNotification";     //ws实时数据更新

@interface GSHWebSocketTask ()
@property(nonatomic, assign) long taskIdentifier;
@property(nonatomic, assign) BOOL isEnd;   //这个字段如果是web内网任务则回调后就为yes。如果是外网任务在发出http请求的时候就yes啦，如果要了解任务进度请查看httpTask的状态；
@property(nonatomic, strong) id requestData;
@property(nonatomic, copy) void(^receiveHandler)(GSHBaseMsg *responseData,NSError *error);//内网的时候没有http请求，这个保存回调
@property(nonatomic, strong) NSURLSessionDataTask *httpTask;//在外网需要发起http请求
@end

@interface GSHWebSocketClient()<SRWebSocketDelegate>
@property(nonatomic,copy)NSString *gwId;    //网关id
@property(nonatomic,copy)NSString *gwIp;    //内网WS服务IP
@property(nonatomic,copy)NSString *server;  //远程WS服务地址
@property(nonatomic,copy)NSString *port;    //WS服务端口
@property(nonatomic,strong)NSMutableDictionary *realTimeDataDic;

@property(nonatomic,strong,readwrite)SRWebSocket *webSocket;
@property(nonatomic,assign,readwrite)GSHNetworkType networkType;
@property(nonatomic,strong)GSHAsyncUdpSocketTask *task;
@property(nonatomic,strong)NSTimer *pingTimer;
@property(nonatomic,assign)NSInteger reconnectCount;

@property(nonatomic,strong)NSMutableDictionary<NSString*,GSHWebSocketTask*> *gatewayNetworkTaskDic;
@property(nonatomic,strong)dispatch_queue_t taskDicQueue;
@end

@implementation GSHWebSocketClient
+(instancetype)shared{
    static GSHWebSocketClient *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [GSHWebSocketClient new];
    });
    return _shared;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.gatewayNetworkTaskDic = [NSMutableDictionary dictionary];
        self.taskDicQueue = dispatch_queue_create("com.ienjoys.eSmartHome.GSHWebSocketClient.taskDicQueue", DISPATCH_QUEUE_SERIAL);
        NSNumber *type = [[NSUserDefaults standardUserDefaults] objectForKey:GSHWebSocketClientType];
        if (type) {
            _networkType = type.integerValue;
            if (type.integerValue == GSHNetworkTypeLAN) {
                NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:GSHWebSocketClientLANIp];
                _gwIp = ip;
            }
        }else{
            _networkType = GSHNetworkTypeWAN;
        }
        //心跳
        __weak typeof(self) weakSelf = self;
        _pingTimer = [NSTimer scheduledTimerWithTimeInterval:20 block:^(NSTimer * _Nonnull timer) {
            if (weakSelf.webSocket.readyState == SR_OPEN) {
                //webSocket自带心跳
                [weakSelf.webSocket sendPing:nil];
                //业务心跳，在外网环境网关会切换链接服务器，这个心跳会判断
                if (weakSelf.networkType == GSHNetworkTypeWAN) {
                    [weakSelf.webSocket send:[[GSHHeartMsg alloc] init].msgData];
                }
            }
        } repeats:YES];
        [_pingTimer setFireDate:[NSDate distantFuture]];
        
        [self observerNotifications];
    }
    return self;
}

-(void)dealloc {
    if (_pingTimer) {
        [self.pingTimer invalidate];
        self.pingTimer = nil;
    }
    [self clearWebSocket];
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:AFNetworkingReachabilityDidChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification {
    if ([notification.name isEqualToString:AFNetworkingReachabilityDidChangeNotification]) {
        // 网络切换的通知
        if (self.webSocket.readyState != SR_OPEN) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            self.reconnectCount = 0;
            [self getWebSocketIpAndPortToConnectWithGWId:self.gwId];
        }
    }
}

-(void)setNetworkType:(GSHNetworkType)networkType {
    _networkType = networkType;
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(networkType) forKey:GSHWebSocketClientType];
    [userDefaults synchronize];
}

-(void)setGwIp:(NSString *)gwIp{
    _gwIp = gwIp;
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (gwIp) {
        [userDefaults setObject:gwIp forKey:GSHWebSocketClientLANIp];
    }else{
        [userDefaults removeObjectForKey:GSHWebSocketClientLANIp];
    }
    [userDefaults synchronize];
}

#pragma mark --------------WebSocket链接与维护方法
-(GSHAsyncUdpSocketTask *)changType:(GSHNetworkType)type gatewayId:(NSString *)gatewayId block:(void(^)(NSError *error))block{
    if (type == self.networkType) {
        if (block) block(nil);
        return nil;
    }else{
        if (type == GSHNetworkTypeWAN) {
            self.networkType = GSHNetworkTypeWAN;
            self.gwIp = nil;
            [self clearWebSocket];
            [self postNotification:GSHChangeNetworkManagerWebSocketCloseNotification object:nil];
            if (block) block(nil);
            return nil;
        }else{
            __weak typeof(self)weakSelf = self;
            self.task = [[GSHAsyncUdpSocketClient shared]sendGWSearchMsgWithsendHandler:^(NSError *error) {
                if (error) {
                    if (block) block(error);
                }
            } receiveHandler:^BOOL(NSDictionary *gwDic, NSError *error) {
                if (gwDic) {
                    NSLog(@"=============udp获取到的网关数据: %@",gwDic);
                    NSString *gwId = [gwDic stringValueForKey:@"gwId" default:nil];
                    if (gwId.length > 0 && [gatewayId isEqualToString:gwId]) {
                        weakSelf.networkType = GSHNetworkTypeLAN;
                        weakSelf.gwIp = [gwDic stringValueForKey:@"address" default:nil];
                        NSLog(@"=============udp获取到的网关ip : %@",weakSelf.gwIp);
                        [weakSelf clearWebSocket];
                        [weakSelf postNotification:GSHChangeNetworkManagerWebSocketCloseNotification object:nil];
                        if (block) block(nil);
                        return YES;
                    }
                }
                if (error) {
                    if (block) block(error);
                    return YES;
                }
                return NO;
            }];
            return self.task;
        }
    }
}
-(BOOL)isConnect{
    return self.webSocket.readyState == SR_OPEN;
}
-(void)clearWebSocket{
    self.webSocket.delegate = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.webSocket close];
    self.webSocket = nil;
    [self.pingTimer setFireDate:[NSDate distantFuture]];
}
//链接WebSocket  会重新生成WebSocket对象
-(void)getWebSocketIpAndPortToConnectWithGWId:(NSString*)gwId{
    __weak typeof(self)weakSelf = self;
    if (gwId == nil) {
        return;
    }else{
        if (![self.gwId isEqualToString:gwId]) {
            self.gwId = gwId;
            self.realTimeDataDic = [NSMutableDictionary dictionary];
        }
    }
    if (self.networkType == GSHNetworkTypeWAN) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:gwId forKey:@"gatewayId"];
        [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getServerConfig" parameters:dic success:^(id operationOrTask, id responseObject) {
            if ([responseObject isKindOfClass:NSDictionary.class]) {
                NSString *externalIp = [((NSDictionary*)responseObject) stringValueForKey:@"externalIp" default:nil];
                NSString *externalPort = [((NSDictionary*)responseObject) stringValueForKey:@"externalPort" default:nil];
                weakSelf.server = externalIp;
                weakSelf.port = externalPort;
                [weakSelf connectWebSocket];
            }
        } failure:^(id operationOrTask, NSError *error) {
            [weakSelf performSelector:@selector(getWebSocketIpAndPortToConnectWithGWId:) withObject:weakSelf.gwId afterDelay:weakSelf.reconnectCount * 5 + 1];
            if (weakSelf.reconnectCount > 2) [weakSelf postNotification:GSHChangeNetworkManagerWebSocketCloseNotification object:nil];
            weakSelf.reconnectCount++;
        } useCache:NO];
    }else{
        if (self.reconnectCount > 2) {
            [[AFNetworkReachabilityManager sharedManager] startMonitoring];
            if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
                [[GSHAsyncUdpSocketClient shared] sendGWSearchMsgWithsendHandler:^(NSError *error) {
                    if (error) {
                        if (weakSelf.reconnectCount > 2) [weakSelf postNotification:GSHChangeNetworkManagerWebSocketCloseNotification object:nil];
                        weakSelf.reconnectCount++;
                        [weakSelf performSelector:@selector(getWebSocketIpAndPortToConnectWithGWId:) withObject:weakSelf.gwId afterDelay:weakSelf.reconnectCount * 5 + 1];
                    }
                } receiveHandler:^BOOL(NSDictionary *gwDic, NSError *error) {
                    if (gwDic) {
                        NSLog(@"=============udp获取到的网关数据: %@",gwDic);
                        NSString *gwId = [gwDic stringValueForKey:@"gwId" default:nil];
                        if (gwId.length > 0 && [weakSelf.gwId isEqualToString:gwId]) {
                            weakSelf.gwIp = [gwDic stringValueForKey:@"address" default:nil];
                            weakSelf.port = @"9090";
                            [weakSelf connectWebSocket];
                            return YES;
                        }
                    }
                    if (error) {
                        if (weakSelf.reconnectCount > 2) [weakSelf postNotification:GSHChangeNetworkManagerWebSocketCloseNotification object:nil];
                        weakSelf.reconnectCount++;
                        [weakSelf performSelector:@selector(getWebSocketIpAndPortToConnectWithGWId:) withObject:weakSelf.gwId afterDelay:1];
                        return YES;
                    }
                    return NO;
                }];
                [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
            } else {
                if (weakSelf.reconnectCount > 2) [weakSelf postNotification:GSHChangeNetworkManagerWebSocketCloseNotification object:nil];
                self.reconnectCount++;
                [self performSelector:@selector(getWebSocketIpAndPortToConnectWithGWId:) withObject:weakSelf.gwId afterDelay:weakSelf.reconnectCount * 5 + 1];
            }
        }else{
            self.server = self.gwIp.length > 0 ? self.gwIp : @"255.255.255.255";
            self.port = @"9090";
            [self connectWebSocket];
        }
    }
}
//根据端口ip生成WebSocket对象
- (void)connectWebSocket{
    [self clearWebSocket];
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%@",self.server,self.port]] protocols:@[@"gem-ws-protocol"]];
    self.webSocket.delegate = self;
    [self.webSocket open];
}
#pragma mark --------------WebSocket收发消息处理方法
//实时数据字典
-(NSDictionary *)realTimeDic{
    return self.realTimeDataDic;
}
//发送请求实时数据
- (BOOL)sendGetRealTimeMsg{
    if (self.webSocket.readyState == SR_OPEN) {
        GSHDeviceRealTimeMsg *realTimeMsg = [[GSHDeviceRealTimeMsg alloc] initWithGwId:self.gwId];
        [self.realTimeDataDic removeAllObjects];
        [self.webSocket send:realTimeMsg.msgData];
        return YES;
    }else{
        return NO;
    }
}
//收到实时数据
-(void)receiveRealTimeData:(GSHBaseMsg*)data{
    for (ProtocolNodeMap *messageNodeMap in data.message.nodeArray) {
        for (ProtocolNode *realTimeNode in messageNodeMap.nodeArray) {
            for (ProtocolNodeMap *deviceNodeMap in realTimeNode.nodeArray) {
                for (ProtocolNode *deviceNode in deviceNodeMap.nodeArray) {
                    
                    if (deviceNode.attrArray.count > 0) {
                        ProtocolNodeAttribute *deviceNodeAttr = deviceNode.attrArray[0];
                        NSString *deviceSN = deviceNodeAttr.value;
                        if ([deviceSN isKindOfClass:NSString.class]) {
                            NSMutableDictionary *meteInfoDic ;
                            if ([self.realTimeDataDic objectForKey:deviceSN]) {
                                meteInfoDic = [self.realTimeDataDic objectForKey:deviceSN];
                            } else {
                                meteInfoDic = [NSMutableDictionary dictionary];
                                [self.realTimeDataDic setObject:meteInfoDic forKey:deviceSN];
                            }
                            for (ProtocolNodeMap *meteNodeMap in deviceNode.nodeArray) {
                                for (ProtocolNode *meteNode in meteNodeMap.nodeArray) {
                                    if (meteNode.attrArray.count >= 2) {
                                        ProtocolNodeAttribute *meteNodeAttr1 = meteNode.attrArray[0];
                                        ProtocolNodeAttribute *meteNodeAttr2 = meteNode.attrArray[1];
                                        [meteInfoDic setObject:meteNodeAttr2.value forKey:meteNodeAttr1.value];
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    [self postNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification object:self.realTimeDataDic];
}
//发送心跳
-(BOOL)sendHeart{
    if (self.webSocket.readyState == SR_OPEN) {
        //webSocket自带心跳
        [self.webSocket sendPing:nil];
        //业务心跳，在外网环境网关会切换链接服务器，这个心跳会判断
        if (self.networkType == GSHNetworkTypeWAN) {
            [self.webSocket send:[[GSHHeartMsg alloc] init].msgData];
        }
        return YES;
    }else{
        return NO;
    }
}
//收到心跳回复
-(void)receiveHeartData:(GSHBaseMsg*)data{
    for (ProtocolNodeMap *heartBeatNodeMap in data.message.nodeArray) {
        for (ProtocolNode *heartBeatNode in heartBeatNodeMap.nodeArray) {
            if (heartBeatNode.attrArray.count > 0) {
                ProtocolNodeAttribute *heartBeatNodeAttr = heartBeatNode.attrArray[0];
                NSString *code = heartBeatNodeAttr.value;
                NSLog(@"websocket 316 code : %@",code);
                if (code.integerValue == 9) {
                    // ip地址更换
                    [self clearWebSocket];
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                    [self getWebSocketIpAndPortToConnectWithGWId:self.gwId];
                }
            }
        }
    }
}
//控制设备
-(GSHWebSocketTask*)deviceControlWithGatewayId:(NSString *)gatewayId deviceSN:(NSString *)deviceSN basMeteId:(NSString *)basMeteId value:(NSString *)value block:(void(^)(NSError *error))block{
    GSHWebSocketTask *task = [GSHWebSocketTask new];
    if ([GSHWebSocketClient shared].isConnect) {
        GSHDeviceControlMsg *msg = [[GSHDeviceControlMsg alloc]initWithGwId:gatewayId sn:(int32_t)task.taskIdentifier deviceSN:deviceSN basMeteId:basMeteId value:value];
        task.requestData = msg;
        task.receiveHandler = ^(GSHBaseMsg *responseData, NSError *error) {
            if (block) {
                block(error);
            }
        };
        [[GSHWebSocketClient shared].webSocket send:msg.msgData];
        dispatch_sync([GSHWebSocketClient shared].taskDicQueue, ^{
            [[GSHWebSocketClient shared].gatewayNetworkTaskDic setValue:task forKey:[NSString stringWithFormat:@"%ld",task.taskIdentifier]];
        });
    }else{
        if (block) {
            block([NSError errorWithDomain:@"GSHWebSocketClientDomain" code:1 userInfo:@{NSLocalizedDescriptionKey:@"与网关链接断开"}]);
        }
        task.isEnd = YES;
    }
    return task;
}
//收到控制消息回复
-(void)receiveDeviceControlData:(GSHBaseMsg*)data{
    __block GSHWebSocketTask *task;
    dispatch_sync([GSHWebSocketClient shared].taskDicQueue, ^{
        task = [[GSHWebSocketClient shared].gatewayNetworkTaskDic objectForKey:[NSString stringWithFormat:@"%d",data.sn]];
    });
    if (task) {
        if (!task.isEnd) {
            for (ProtocolNodeMap *nodeMap in data.message.nodeArray) {
                for (ProtocolNode *node in nodeMap.nodeArray) {
                    if (node.attrArray.count > 0) {
                        ProtocolNodeAttribute *nodeAttr = node.attrArray[0];
                        NSString *code = nodeAttr.value;
                        if (code.integerValue == 0) {
                            task.receiveHandler(data, nil);
                        }else if (code.integerValue == 1){
                            task.receiveHandler(data, [NSError errorWithDomain:@"GSHWebSocketClientDomain" code:2 userInfo:@{NSLocalizedDescriptionKey:@"设备不存在"}]);
                        }else if (code.integerValue == 2){
                            task.receiveHandler(data, [NSError errorWithDomain:@"GSHWebSocketClientDomain" code:2 userInfo:@{NSLocalizedDescriptionKey:@"监控量不存在"}]);
                        }else{
                            task.receiveHandler(data, [NSError errorWithDomain:@"GSHWebSocketClientDomain" code:2 userInfo:@{NSLocalizedDescriptionKey:@"未知错误"}]);
                        }
                    }
                }
            }
            task.isEnd = YES;
        }
        dispatch_sync([GSHWebSocketClient shared].taskDicQueue, ^{
            [[GSHWebSocketClient shared].gatewayNetworkTaskDic removeObjectForKey:[NSString stringWithFormat:@"%d",data.sn]];
        });
    }
}
//发送执行场景消息
-(GSHWebSocketTask*)executeSceneWithGatewayId:(NSString *)gatewayId scenarioId:(NSString *)scenarioId block:(void(^)(NSError *error))block{
    GSHWebSocketTask *task = [GSHWebSocketTask new];
    if ([GSHWebSocketClient shared].webSocket.readyState == SR_OPEN) {
        GSHExecuteSceneMsg *msg = [[GSHExecuteSceneMsg alloc] initWithGwId:gatewayId sn:(int32_t)task.taskIdentifier sceneId:scenarioId];
        task.requestData = msg;
        task.receiveHandler = ^(GSHBaseMsg *responseData, NSError *error) {
            if (block) {
                block(error);
            }
        };
        [[GSHWebSocketClient shared].webSocket send:msg.msgData];
        dispatch_sync([GSHWebSocketClient shared].taskDicQueue, ^{
            [[GSHWebSocketClient shared].gatewayNetworkTaskDic setValue:task forKey:[NSString stringWithFormat:@"%ld",task.taskIdentifier]];
        });
    }else{
        if (block) {
            block([NSError errorWithDomain:@"GSHWebSocketClientDomain" code:1 userInfo:@{NSLocalizedDescriptionKey:@"与网关链接断开"}]);
        }
        task.isEnd = YES;
    }
    return task;
}
//收到场景回复消息
-(void)receiveExecuteSceneData:(GSHBaseMsg*)data{
    __block GSHWebSocketTask *task;
    dispatch_sync([GSHWebSocketClient shared].taskDicQueue, ^{
        task = [[GSHWebSocketClient shared].gatewayNetworkTaskDic objectForKey:[NSString stringWithFormat:@"%d",data.sn]];
    });
    if (task) {
        if (!task.isEnd) {
            for (ProtocolNodeMap *nodeMap in data.message.nodeArray) {
                for (ProtocolNode *node in nodeMap.nodeArray) {
                    if (node.attrArray.count > 0) {
                        ProtocolNodeAttribute *nodeAttr = node.attrArray[0];
                        NSString *code = nodeAttr.value;
                        if (code.integerValue == 0) {
                            task.receiveHandler(data, nil);
                        }else if (code.integerValue == 1){
                            task.receiveHandler(data, [NSError errorWithDomain:@"GSHWebSocketClientDomain" code:2 userInfo:@{NSLocalizedDescriptionKey:@"执行失败"}]);
                        }
                    }
                }
            }
            task.isEnd = YES;
        }
        dispatch_sync([GSHWebSocketClient shared].taskDicQueue, ^{
            [[GSHWebSocketClient shared].gatewayNetworkTaskDic removeObjectForKey:[NSString stringWithFormat:@"%d",data.sn]];
        });
    }
}
//启动关闭联动
-(GSHWebSocketTask*)updateAutoStatushWithGatewayId:(NSString *)gatewayId ruleId:(NSString *)ruleId status:(NSString *)status block:(void(^)(NSError *error))block{
    GSHWebSocketTask *task = [GSHWebSocketTask new];
    if ([GSHWebSocketClient shared].webSocket.readyState == SR_OPEN) {
        GSHUpdateAutoStatusMsg *msg = [[GSHUpdateAutoStatusMsg alloc] initWithGwId:gatewayId sn:(int32_t)task.taskIdentifier ruleId:ruleId status:status];
        task.requestData = msg;
        task.receiveHandler = ^(GSHBaseMsg *responseData, NSError *error) {
            if (block) {
                block(error);
            }
        };
        [[GSHWebSocketClient shared].webSocket send:msg.msgData];
        dispatch_sync([GSHWebSocketClient shared].taskDicQueue, ^{
            [[GSHWebSocketClient shared].gatewayNetworkTaskDic setValue:task forKey:[NSString stringWithFormat:@"%ld",task.taskIdentifier]];
        });
    }else{
        if (block) {
            block([NSError errorWithDomain:@"GSHWebSocketClientDomain" code:1 userInfo:@{NSLocalizedDescriptionKey:@"与网关链接断开"}]);
        }
        task.isEnd = YES;
    }
    return task;
}

#pragma mark----------------webSockek代理----------------------------------------
// 收到消息
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:NSData.class]) {
        GSHBaseMsg *msg = [GSHBaseMsg msgBaseMWithData:message];
        NSLog(@"收到消息 id:%d sn:%d",msg.message.id_p,msg.sn);
        if (msg.message.id_p == 302) {
            // 实时数据
            [self receiveRealTimeData:msg];
        } else if (msg.message.id_p == 316) {
            //心跳回复 -- 判断websocket的ip和端口号是否有更改
            [self receiveHeartData:msg];
        } else if (msg.message.id_p == 402) {
            //设备控制回复
            [self receiveDeviceControlData:msg];
        } else if (msg.message.id_p == 404){
            // 执行场景响应
            [self receiveExecuteSceneData:msg];
        }
    }
}
//链接打开
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"连接成功");
    [self.pingTimer setFireDate:[NSDate distantPast]];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.reconnectCount = 0;
    
    //每次链接成功必须重新发送获取实时消息
    [self sendGetRealTimeMsg];
    
    [self postNotification:GSHChangeNetworkManagerWebSocketOpenNotification object:nil];
}
//
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"连接失败");
    [self.pingTimer setFireDate:[NSDate distantFuture]];
    [self performSelector:@selector(getWebSocketIpAndPortToConnectWithGWId:) withObject:self.gwId afterDelay:self.reconnectCount * 5 + 1];
    if (self.reconnectCount > 2) [self postNotification:GSHChangeNetworkManagerWebSocketCloseNotification object:nil];
    self.reconnectCount++;
}
//
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"连接自己断开或被服务器断开");
    [self.pingTimer setFireDate:[NSDate distantFuture]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self getWebSocketIpAndPortToConnectWithGWId:self.gwId];
    if (self.reconnectCount > 2) [self postNotification:GSHChangeNetworkManagerWebSocketCloseNotification object:nil];
}
//
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"收到系统心跳回调");
}
@end

#pragma mark - GSHAsyncUdpSocketTask
@implementation GSHWebSocketTask
- (instancetype)init {
    self = [super init];
    if (self) {
        static long taskIdentifier = 0;
        _taskIdentifier = ++taskIdentifier;
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf timeOut];
        });
    }
    return self;
}

- (void)dealloc {
    self.requestData = nil;
    self.receiveHandler = nil;
    self.httpTask = nil;
}

- (void)timeOut{
    self.isEnd = YES;
    if(self.receiveHandler){
        NSError *error = [NSError errorWithDomain:@"GSHWebSocketClientDomain" code:3 userInfo:@{NSLocalizedDescriptionKey:@"请求超时"}];
        self.receiveHandler(nil, error);
        self.receiveHandler = nil;
    }
    __weak typeof(self)weakSelf = self;
    dispatch_sync([GSHWebSocketClient shared].taskDicQueue, ^{
        [[GSHWebSocketClient shared].gatewayNetworkTaskDic removeObjectForKey:[NSString stringWithFormat:@"%ld",weakSelf.taskIdentifier]];
    });
}

- (void)cancel {
    self.isEnd = YES;
    if(self.receiveHandler){
        NSError *error = [NSError errorWithDomain:@"GSHWebSocketClientDomain" code:-999 userInfo:@{NSLocalizedDescriptionKey:@"已取消"}];
        self.receiveHandler(nil, error);
        self.receiveHandler = nil;
    }
    if (self.httpTask) {
        [self.httpTask cancel];
        self.httpTask = nil;
    }
    __weak typeof(self)weakSelf = self;
    dispatch_sync([GSHWebSocketClient shared].taskDicQueue, ^{
        [[GSHWebSocketClient shared].gatewayNetworkTaskDic removeObjectForKey:[NSString stringWithFormat:@"%ld",weakSelf.taskIdentifier]];
    });
}
@end
