//
//

#import "GSHAsyncUdpSocketManager.h"
#import "GSHGWSearchMsg.h"


NSString * const GSHAsyncUdpSocketErrorDomain = @"GSHAsyncUdpSocketErrorDomain";
NSTimeInterval const GSHAsyncUdpSocketTaskSendTimeOut  = 5.0;
NSTimeInterval const GSHAsyncUdpSocketTaskReceiveTimeOut  = 60.0;

@interface GSHAsyncUdpSocketTask ()
@property(nonatomic, assign) long taskIdentifier;
@property(nonatomic, copy) NSData *requestData;
@property(nonatomic, assign) GSHAsyncUdpSocketTaskState state;
@property(nonatomic, copy) void (^sendHandler)(NSError *error);
@property(nonatomic, copy) BOOL (^receiveHandler)(NSData *responseData,NSData *address,NSError *error);
@property(nonatomic, strong)NSTimer * timer;
@property(nonatomic, weak)GSHAsyncUdpSocketManager *manager;
@end


#pragma mark - GSHAsyncUdpSocketManager

@interface GSHAsyncUdpSocketManager ()<GCDAsyncUdpSocketDelegate>
@property(strong, nonatomic) GCDAsyncUdpSocket *socket;
@property(strong) NSMutableDictionary<NSNumber*,GSHAsyncUdpSocketTask *> *taskDic;
@property(nonatomic, strong) dispatch_queue_t taskDicQueue;
@end

@implementation GSHAsyncUdpSocketManager {
}

-(instancetype)initBroadcastSocket{
    self = [super init];
    if (self) {
        self.socket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        NSError *error = nil;
//        //不绑定端口, 那么就会随机产生一个随机的电脑唯一的端口
//        [self.socket bindToPort:6666 error:&error];
        //启用广播
        [self.socket enableBroadcast:YES error:&error];
        //开启监听
        [self.socket beginReceiving:&error];
        if (error){
            return nil;
        }
        
        self.taskDic = [NSMutableDictionary dictionary];
        self.taskDicQueue = dispatch_queue_create("com.ienjoys.eSmartHome.GSHAsyncUdpSocketManager.taskDicQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(GSHAsyncUdpSocketTask*)sendGWSearchMsgWithsendHandler:(void (^)(NSError *error))sendHandler receiveHandler:(BOOL(^)(NSDictionary *gwDic,NSError *error))receiveHandler{
    GSHGWSearchMsg *msg = [GSHGWSearchMsg new];
    NSData *data = msg.msgData;
    return [self sendRequestData:data port:8088 sendHandler:^(NSError *error) {
        if(sendHandler) sendHandler(error);
    } receiveHandler:^BOOL(NSData *responseData, NSData *address, NSError *error) {
        if (responseData) {
            GSHBaseMsg *baseM = [GSHBaseMsg msgBaseMWithData:responseData];
            NSMutableDictionary *gwDic = [NSMutableDictionary dictionary];
            [gwDic setValue:baseM.message.gwId forKey:@"gwId"];
            NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
            [gwDic setValue:ip forKey:@"address"];
            for (ProtocolNodeMap *nodeMap in baseM.message.nodeArray) {
                for (ProtocolNode *node in nodeMap.nodeArray) {
                    for (ProtocolNodeAttribute *attr in node.attrArray) {
                        if ([attr.name isEqualToString:@"bindflag"]) {
                            NSString *code = attr.value;
                            if (code) {
                                [gwDic setValue:@(code.integerValue) forKey:@"isBinded"];
                            }
                        }
                        if ([attr.name isEqualToString:@"deviceModel"]) {
                            NSString *code = attr.value;
                            if (code) {
                                [gwDic setValue:code forKey:@"deviceModel"];
                            }
                        }
                    }
                }
            }
            if (receiveHandler) return receiveHandler(gwDic,error);
        }else{
            if (receiveHandler) return receiveHandler(nil,error);
        }
        return NO;
    }];
}

-(GSHAsyncUdpSocketTask*)sendRequestData:(NSData*)requestData port:(uint16_t)post sendHandler:(void (^)(NSError *error))sendHandler receiveHandler:(BOOL(^)(NSData *responseData,NSData *address,NSError *error))receiveHandler{
    NSError *error = nil;
    [self.socket enableBroadcast:YES error:&error];
    [self.socket beginReceiving:&error];
    
    GSHAsyncUdpSocketTask *task = [GSHAsyncUdpSocketTask new];
    task.requestData = requestData;
    task.sendHandler = sendHandler;
    task.receiveHandler = receiveHandler;
    task.manager = self;

    if (self.taskDicQueue) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(weakSelf.taskDicQueue, ^{
            [weakSelf.taskDic setObject:task forKey:@(task.taskIdentifier)];
            [weakSelf.socket sendData:requestData toHost:@"255.255.255.255" port:post withTimeout:GSHAsyncUdpSocketTaskSendTimeOut tag:task.taskIdentifier];
            task.state = GSHAsyncUdpSocketTaskStateSending;
        });
    }else{
        task.state = GSHAsyncUdpSocketTaskStateCompleted;
    }
    return task;
}

#pragma mark - GCDAsyncUdpSocketDelegate
//如果去连接特定主机，连接成功回调
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"连接成功");
}

//如果去连接特定主机，连接失败回调
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    NSLog(@"连接失败");
}

//发送消息成功
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"发送消息成功 tag = %ld",tag);
    if (self.taskDicQueue) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(weakSelf.taskDicQueue, ^{
            GSHAsyncUdpSocketTask *task = [weakSelf.taskDic objectForKey:@(tag)];
            //发送成功回调
            if (task.sendHandler) task.sendHandler(nil);
            //是否需要接受回复
            if (task.receiveHandler) {
                //需要就收回复则会设置接收超时
                task.state = GSHAsyncUdpSocketTaskStateReceiving;
            }else{
                //不需要回复则任务结束
                task.state = GSHAsyncUdpSocketTaskStateCompleted;
            }
        });
    }
}

//发送消息失败
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"发送消息失败");
    if (self.taskDicQueue) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(weakSelf.taskDicQueue, ^{
            GSHAsyncUdpSocketTask *task = [weakSelf.taskDic objectForKey:@(tag)];
            if (task.sendHandler) task.sendHandler(error);
            task.state = GSHAsyncUdpSocketTaskStateCompleted;
        });
    }
}

//接受到数据
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(nullable id)filterContext{
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    NSLog(@"接收到消息 ip = %@,port = %d",ip,port);
    if (self.taskDicQueue) {
        dispatch_async(self.taskDicQueue, ^{
            for (NSUInteger i = self.taskDic.allKeys.count; i > 0; i--) {
                NSNumber *key = self.taskDic.allKeys[i - 1];
                GSHAsyncUdpSocketTask *task = [self.taskDic objectForKey:key];
                //只有等待接收的任务才处理
                if (task.state == GSHAsyncUdpSocketTaskStateReceiving) {
                    if (task.receiveHandler) {
                        BOOL received = task.receiveHandler(data,address,nil);
                        if (received) {
                            //回调返回接收完成
                            task.state = GSHAsyncUdpSocketTaskStateCompleted;
                        }
                    }else{
                        //如果在任务在接收中但又没有接收回调怎直接完成
                        task.state = GSHAsyncUdpSocketTaskStateCompleted;
                    }
                }
            }
        });
    }
}

//socket关闭时回调
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"socket关闭");
    __weak typeof(self)weakSelf = self;
    dispatch_async(self.taskDicQueue, ^{
        for (NSNumber *tag in weakSelf.taskDic.allKeys) {
            GSHAsyncUdpSocketTask *task = [self.taskDic objectForKey:tag];
            if (task.sendHandler) task.sendHandler(error);
            task.state = GSHAsyncUdpSocketTaskStateCompleted;
        }
    });
}


@end

#pragma mark - GSHAsyncUdpSocketTask

@implementation GSHAsyncUdpSocketTask

- (instancetype)init {
//    NSLog(@"新建任务");
    self = [super init];
    if (self) {
        static long taskIdentifier = 0;
        _taskIdentifier = ++taskIdentifier;
    }
    return self;
}

- (void)dealloc {
//    NSLog(@"任务释放");
    self.requestData = nil;
    self.sendHandler = nil;
    self.receiveHandler = nil;
    self.timer = nil;
}

-(void)setState:(GSHAsyncUdpSocketTaskState)state{
//    NSLog(@"修改状态 state = %ld",state);
    _state = state;
    if (state == GSHAsyncUdpSocketTaskStateCanceled || state == GSHAsyncUdpSocketTaskStateCompleted) {
        self.sendHandler = nil;
        self.receiveHandler = nil;
        [self.timer invalidate];
        self.timer = nil;
        if (self.manager.taskDicQueue) {
            __weak typeof(self)weakSelf = self;
            dispatch_async(weakSelf.manager.taskDicQueue, ^{
                [weakSelf.manager.taskDic removeObjectForKey:@(self.taskIdentifier)];
            });
        }
    }else if(state == GSHAsyncUdpSocketTaskStateReceiving){
        self.sendHandler = nil;
        self.timer = [NSTimer timerWithTimeInterval:GSHAsyncUdpSocketTaskReceiveTimeOut target:self selector:@selector(receiveTimeout) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    }else{
        
    }
}

-(void)receiveTimeout{
    NSLog(@"接收超时");
    if (self.receiveHandler) self.receiveHandler(nil, nil, [NSError errorWithDomain:GSHAsyncUdpSocketErrorDomain code:GSHAsyncUdpSocketErrorReceiveTimeout userInfo:nil]);
    self.state = GSHAsyncUdpSocketTaskStateCompleted;
}

#pragma mark - Action
- (void)cancel {
    NSError *error = [NSError errorWithDomain:GSHAsyncUdpSocketErrorDomain code:GSHAsyncUdpSocketErrorCancelled userInfo:nil];
    if(self.receiveHandler){
        self.receiveHandler(nil,nil, error);
    }
    if (self.sendHandler) {
        self.sendHandler(error);
    }
    self.state = GSHAsyncUdpSocketTaskStateCanceled;
}

@end
