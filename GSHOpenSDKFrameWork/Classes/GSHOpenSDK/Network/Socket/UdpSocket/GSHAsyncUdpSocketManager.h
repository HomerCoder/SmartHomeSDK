//
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

extern NSString *const GSHAsyncUdpSocketErrorDomain;

typedef NS_ENUM(NSInteger, GSHAsyncUdpSocketError) {
    GSHAsyncSocketNoError = 0,
    GSHAsyncUdpSocketErrorSendTimeout,
    GSHAsyncUdpSocketErrorReceiveTimeout,
    GSHAsyncUdpSocketErrorCancelled, //任务被取消
};

typedef NS_ENUM(NSInteger, GSHAsyncUdpSocketTaskState) {
    GSHAsyncUdpSocketTaskStateSending   = 0,
    GSHAsyncUdpSocketTaskStateReceiving = 1,
    GSHAsyncUdpSocketTaskStateCanceled = 2,
    GSHAsyncUdpSocketTaskStateCompleted = 3,
};

@interface GSHAsyncUdpSocketTask : NSObject
@property (readonly, assign) long taskIdentifier;
@property (readonly, assign) GSHAsyncUdpSocketTaskState state;
- (void)cancel;
@end

@interface GSHAsyncUdpSocketManager : NSObject

-(instancetype)initBroadcastSocket;
-(GSHAsyncUdpSocketTask*)sendGWSearchMsgWithsendHandler:(void (^)(NSError *error))sendHandler receiveHandler:(BOOL(^)(NSDictionary *gwDic,NSError *error))receiveHandler;
@end
