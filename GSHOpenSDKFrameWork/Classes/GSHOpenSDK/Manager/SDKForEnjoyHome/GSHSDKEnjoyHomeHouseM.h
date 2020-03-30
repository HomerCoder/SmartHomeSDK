//
//  GSHSDKEnjoyHomeHouseM.h
//  GSHOpenSDK
//
//  Created by zhanghong on 2020/3/13.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"

@interface GSHSDKEnjoyHomeHouseBindInfoM : GSHBaseModel

@property (strong , nonatomic) NSNumber *familyId;
@property (strong , nonatomic) NSString *familyName;
@property (strong , nonatomic) NSNumber *mhomeId;
@property (strong , nonatomic) NSString *mhomeName;
@property (strong , nonatomic) NSNumber *permissions;
@property (strong , nonatomic) NSNumber *propertySwitch;


@end

@interface GSHSDKEnjoyHomeHouseM : GSHBaseModel

@property (strong , nonatomic) NSNumber *userHouseId;
@property (strong , nonatomic) NSString *houseName;
@property (strong , nonatomic) NSString *relationType;   // 业主01 住户02 业主亲属03 其他99

@end

@interface GSHSDKEnjoyHomeHouseManager : NSObject

// 获取享家房屋列表
+ (NSURLSessionDataTask *)getEnjoyHomeHouseListWithAccessToken:(NSString *)accessToken
                                                         block:(void(^)(NSArray<GSHSDKEnjoyHomeHouseM*>*list,NSError *error))block;


// 获取房屋家居家庭与享家房屋的绑定详情
+ (NSURLSessionDataTask *)getBindDetailInfoWithFamilyId:(NSString *)familyId
                                                  block:(void(^)(GSHSDKEnjoyHomeHouseBindInfoM*bindInfoM,NSError *error))block;
    

// 绑定享家房屋
+ (NSURLSessionDataTask *)bindEnjoyHomeHouseWithFamilyId:(NSString *)familyId
                                                mHouseId:(NSString *)mHouseId
                                              mHouseName:(NSString *)mHouseName
                                                   block:(void(^)(NSError *error))block;

// 解绑享家房屋
+ (NSURLSessionDataTask *)unBindEnjoyHomeHouseWithMHouseId:(NSString *)mHouseId
                                                     block:(void(^)(NSError *error))block;


// 改变通知物业告警消息的开关状态
+ (NSURLSessionDataTask *)changeAlarmSwitchStatusWithFamilyId:(NSString *)familyId
                                               propertySwitch:(NSString *)propertySwitch
                                                        block:(void(^)(NSError *error))block;

@end



