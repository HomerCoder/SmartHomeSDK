//
//  GSHMessageM.m
//  SmartHome
//
//  Created by zhanghong on 2018/11/16.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHMessageM.h"
#import "GSHOpenSDKInternal.h"
#import "NSObject+YYModel.h"
#import "GSHFamilyM.h"
#import "YYModel.h"


@implementation GSHMessageM

@end

@implementation GSHMessageManager

// 获取消息列表
+ (NSURLSessionDataTask *)getAllMessageListWithFamilyId:(NSString *)familyId
                                                msgType:(NSInteger)msgType
                                               currPage:(NSInteger)currPage
                                                  block:(void(^)(NSArray<GSHMessageM*>*list,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:@(msgType) forKey:@"msgType"];
    [dic setValue:@(currPage) forKey:@"currPage"];
    [dic setValue:@"10" forKey:@"size"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"msg/getAllMsg" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            NSArray<GSHMessageM*>*list = [NSArray yy_modelArrayWithClass:GSHMessageM.class json:responseObject];
            block(list,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
    
}

// 查询是否有未读消息
+ (NSURLSessionDataTask *)queryIsHasUnReadMsgWithFamilyId:(NSString *)familyId block:(void(^)(NSArray<NSNumber*>*list,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"msg/updateMsg" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            NSArray<NSNumber*>*list = [(NSDictionary *)responseObject objectForKey:@"msgTypeList"]; 
            block(list,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// App用户获取消息提醒设置
+ (NSURLSessionDataTask *)getMsgConfigWithFamilyId:(NSString *)familyId block:(void(^)(GSHMessageM *messageM,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"msg/getMsgConfig" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHMessageM *messageM = [GSHMessageM yy_modelWithJSON:responseObject];
        if (block) {
            block(messageM,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// App用户修改消息提醒设置
+ (NSURLSessionDataTask *)updateMsgConfigWithFamilyId:(NSString *)familyId
                                        msgTypeKeyStr:(GSHMsgTypeKey)msgTypeKeyStr
                                                value:(NSString *)value
                                                block:(void(^)(NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    
    if (msgTypeKeyStr == GSHMsgTypeKeyAlarmWarn) {
        [dic setValue:value forKey:@"alarmWarn"];
    } else if (msgTypeKeyStr == GSHMsgTypeKeySystemWarn) {
        [dic setValue:value forKey:@"systemWarn"];
    } else if (msgTypeKeyStr == GSHMsgTypeKeyBatteryWarn) {
        [dic setValue:value forKey:@"batteryWarn"];
    } else if (msgTypeKeyStr == GSHMsgTypeKeyScenarioWarn) {
        [dic setValue:value forKey:@"scenarioWarn"];
    } else if (msgTypeKeyStr == GSHMsgTypeKeyAutomationWarn) {
        [dic setValue:value forKey:@"automationWarn"];
    } else if (msgTypeKeyStr == GSHMsgTypeKeyNoDisturb) {
        [dic setValue:value forKey:@"noDisturb"];
    }
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"msg/updateMsgConfig" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// 清空消息 /msg/clearMsg
+ (NSURLSessionDataTask *)deleteMsgWithFamilyId:(NSString *)familyId
                                        msgType:(NSInteger)msgType
                                          block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:@(msgType) forKey:@"msgType"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"msg/clearMsg" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// POST /msg/msgToRead App用户将某种type的消息标记为已读
+ (NSURLSessionDataTask *)setMsgToBeReadWithFamilyId:(NSString *)familyId
                                             msgType:(NSInteger)msgType
                                               block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:@(msgType) forKey:@"msgType"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"msg/msgToRead" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// 获取家庭防御消息
+ (NSURLSessionDataTask *)getFamilyDefenseMsgWithFamilyId:(NSString *)familyId
                                               deviceType:(NSString *)deviceType
                                                 currPage:(NSInteger)currPage
                                                    block:(void(^)(NSArray<GSHMessageM*>*list,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceType forKey:@"deviceType"];
    [dic setValue:@(currPage) forKey:@"currPage"];
    [dic setValue:@"10" forKey:@"size"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"msg/getFamilyDefenceMsg" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            NSArray<GSHMessageM*>*list = [NSArray yy_modelArrayWithClass:GSHMessageM.class json:responseObject];
            block(list,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

@end
