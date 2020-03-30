//
//  GSHVoiceM.m
//  SmartHome
//
//  Created by zhanghong on 2018/11/30.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHVoiceM.h"
#import "GSHOpenSDKInternal.h"
#import <iflyMSC/iflyMSC.h> // 科大讯飞

@implementation GSHVoiceM

@end

@implementation GSHVoiceManager

static NSString *IFlyAppId;
// 初始化讯飞SDK
+ (void)initIFlyAppId:(NSString*)appId {
    @try {
        // 讯飞
        IFlyAppId = appId;
        [IFlySetting setLogFile:LVL_NONE];  //不打印日志
        //打开输出在console的log开关
        [IFlySetting showLogcat:NO];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        [IFlySetting setLogFilePath:cachePath];
        //所有服务启动前，需要确保执行createUtility
        [IFlySpeechUtility createUtility:[NSString stringWithFormat:@"appid=%@",appId]];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

// POST 语音控制
+ (NSURLSessionDataTask *)voiceControlWithFamilyId:(NSString *)familyId
                                              text:(NSString *)text
                                             block:(void(^)(NSString *msg,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:text forKey:@"text"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/voiceControl" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

@end
