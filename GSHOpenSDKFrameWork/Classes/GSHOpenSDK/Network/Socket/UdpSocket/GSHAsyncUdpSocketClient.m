//
//  GSHAsyncUdpSocketClient.m
//  SmartHome
//
//  Created by gemdale on 2018/8/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAsyncUdpSocketClient.h"

@implementation GSHAsyncUdpSocketClient
+ (instancetype)shared {
    static GSHAsyncUdpSocketClient *socket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socket = [[GSHAsyncUdpSocketClient alloc] initBroadcastSocket];
    });
    return socket;
}
@end
