//
//  GSHWebViewController.h
//  SmartHome
//
//  Created by gemdale on 2018/9/25.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "LYWKWebViewController.h"
#import <dsbridge.h>

typedef enum : NSInteger {
    GSHAppConfigH5TypeAgreement = 0,    // 使用协议
    GSHAppConfigH5TypeFeedback  = 1,    // 意见反馈
    GSHAppConfigH5TypeNorouter  = 2,    // 找不到要连接的路由
    GSHAppConfigH5TypeHelp  = 3,        // 使用帮助
    GSHAppConfigH5TypeSensor  = 4,      // 传感器
    GSHAppConfigH5TypePrivacy = 5,      // 隐私
    GSHAppConfigH5TypeVoiceDetail = 6,  // 第三方语音详情
    GSHAppConfigH5TypePaly = 7,    // 玩转
} GSHAppConfigH5Type;

@class GSHWebViewController;
@interface GSHEventHandler : NSObject
@property(nonatomic,weak)GSHWebViewController *webViewController;
@end

@interface GSHWebViewController : LYWebViewController
@property(nonatomic, readonly) DWKWebView *webView;
// 生成h5 url
+ (NSURL*)webUrlWithType:(GSHAppConfigH5Type)type parameter:(NSDictionary*)parameter;
- (void)newNavbarRightButWithTitle:(NSString*)title image:(NSString*)image block:(void(^)(id response))callBack;
- (void)enterEditDevice:(NSDictionary*)dic;
@end
