//
//  GSHOpenSDKInternal.h
//  GSHOpenSDK
//
//  Created by gemdale on 2019/8/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHOpenSDKShare.h"
#import "GSHOSSManagerClient.h"
#import "GSHHTTPAPIClient.h"
#import "GSHWebSocketClient.h"

@interface GSHOpenSDKInternal : GSHOpenSDKShare
@property(nonatomic,strong,readonly)GSHWebSocketClient *webSocketClient;
@property(nonatomic,strong,readonly)GSHOSSManagerClient *ossManagerClient;
@property(nonatomic,strong,readonly)GSHHTTPAPIClient *httpAPIClient;
@property(nonatomic,copy,readonly)NSString *appid;
@end
