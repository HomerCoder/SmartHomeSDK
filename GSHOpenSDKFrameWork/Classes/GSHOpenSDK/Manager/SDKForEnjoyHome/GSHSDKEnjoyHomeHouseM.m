//
//  GSHSDKEnjoyHomeHouseM.m
//  GSHOpenSDK
//
//  Created by zhanghong on 2020/3/13.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHSDKEnjoyHomeHouseM.h"
#import "GSHOpenSDKInternal.h"

@implementation GSHSDKEnjoyHomeHouseBindInfoM



@end

@implementation GSHSDKEnjoyHomeHouseM



@end


@implementation GSHSDKEnjoyHomeHouseManager


// 获取享家房屋列表
+ (NSURLSessionDataTask *)getEnjoyHomeHouseListWithAccessToken:(NSString *)accessToken
                                                         block:(void(^)(NSArray<GSHSDKEnjoyHomeHouseM*>*list,NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:accessToken forKey:@"accessToken"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"link/houseList" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSArray *list = [NSArray yy_modelArrayWithClass:GSHSDKEnjoyHomeHouseM.class json:responseObject];
               if (block) {
                   block(list,nil);
               }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// 获取房屋家居家庭与享家房屋的绑定详情
+ (NSURLSessionDataTask *)getBindDetailInfoWithFamilyId:(NSString *)familyId
                                                  block:(void(^)(GSHSDKEnjoyHomeHouseBindInfoM*bindInfoM,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"link/family" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHSDKEnjoyHomeHouseBindInfoM *infoM = [GSHSDKEnjoyHomeHouseBindInfoM yy_modelWithJSON:responseObject];
        if (block) {
            block(infoM,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// 绑定享家房屋
+ (NSURLSessionDataTask *)bindEnjoyHomeHouseWithFamilyId:(NSString *)familyId
                                                mHouseId:(NSString *)mHouseId
                                              mHouseName:(NSString *)mHouseName
                                                   block:(void(^)(NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:mHouseId forKey:@"mhomeId"];
    [dic setValue:mHouseName forKey:@"mhomeName"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"link/bindFamily" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
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

// 解绑享家房屋
+ (NSURLSessionDataTask *)unBindEnjoyHomeHouseWithMHouseId:(NSString *)mHouseId
                                                     block:(void(^)(NSError *error))block {
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:mHouseId forKey:@"mhomeId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"link/cancelBinding" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
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

// 改变通知物业告警消息的开关状态
+ (NSURLSessionDataTask *)changeAlarmSwitchStatusWithFamilyId:(NSString *)familyId
                                               propertySwitch:(NSString *)propertySwitch
                                                        block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:propertySwitch forKey:@"propertySwitch"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"link/changePropertySwitch" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
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

@end
