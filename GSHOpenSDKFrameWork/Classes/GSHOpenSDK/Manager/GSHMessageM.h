//
//  GSHMessageM.h
//  SmartHome
//
//  Created by zhanghong on 2018/11/16.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    GSHMsgTypeKeySystemWarn = 0,                        // 系统消息提醒
    GSHMsgTypeKeyBatteryWarn,                           // 低电量消息提醒
    GSHMsgTypeKeyScenarioWarn,                          // 场景消息提醒
    GSHMsgTypeKeyAutomationWarn,                        // 联动消息提醒
    GSHMsgTypeKeyAlarmWarn,                             // 告警消息提醒
    GSHMsgTypeKeyNoDisturb,                             // 消息免打扰
} GSHMsgTypeKey;

@interface GSHMessageM : NSObject

@property (nonatomic , copy) NSString *createTime;
@property (nonatomic , copy) NSString *msgBody;
@property (nonatomic , copy) NSString *msgId;
@property (nonatomic , copy) NSString *msgTitle;
@property (nonatomic , copy) NSString *msgType;
@property (nonatomic , copy) NSString *readFlag;
@property (nonatomic , copy) NSString *deviceId;
@property (nonatomic , copy) NSString *deviceName;
@property (nonatomic , copy) NSString *deviceSn;
@property (nonatomic , copy) NSString *deviceType;
@property (nonatomic , copy) NSString *familyId;
@property (nonatomic , copy) NSString *deviceModel;
@property (nonatomic , copy) NSString *floorId;
@property (nonatomic , copy) NSString *floorName;
@property (nonatomic , copy) NSString *roomId;
@property (nonatomic , copy) NSString *roomName;

@property (nonatomic , copy) NSString *alarmWarn;
@property (nonatomic , copy) NSString *automationWarn;
@property (nonatomic , copy) NSString *batteryWarn;
@property (nonatomic , copy) NSString *scenarioWarn;
@property (nonatomic , copy) NSString *systemWarn;
@property (nonatomic , copy) NSString *noDisturb;

@end

@interface GSHMessageManager : NSObject

// 获取消息列表
+ (NSURLSessionDataTask *)getAllMessageListWithFamilyId:(NSString *)familyId
                                                msgType:(NSInteger)msgType
                                               currPage:(NSInteger)currPage
                                                  block:(void(^)(NSArray<GSHMessageM*>*list,NSError *error))block;

// 查询是否有未读消息
+ (NSURLSessionDataTask *)queryIsHasUnReadMsgWithFamilyId:(NSString *)familyId
                                                    block:(void(^)(NSArray<NSNumber*>*list,NSError *error))block;

// App用户获取消息提醒设置
+ (NSURLSessionDataTask *)getMsgConfigWithFamilyId:(NSString *)familyId
                                             block:(void(^)(GSHMessageM *messageM,NSError *error))block;


/*
 App用户修改消息提醒设置
 */

+ (NSURLSessionDataTask *)updateMsgConfigWithFamilyId:(NSString *)familyId
                                        msgTypeKeyStr:(GSHMsgTypeKey)msgTypeKeyStr
                                                value:(NSString *)value
                                                block:(void(^)(NSError *error))block;

// 清空消息 /msg/clearMsg
+ (NSURLSessionDataTask *)deleteMsgWithFamilyId:(NSString *)familyId
                                        msgType:(NSInteger)msgType
                                          block:(void(^)(NSError *error))block;


// POST /msg/msgToRead App用户将某种type的消息标记为已读
+ (NSURLSessionDataTask *)setMsgToBeReadWithFamilyId:(NSString *)familyId
                                             msgType:(NSInteger)msgType
                                               block:(void(^)(NSError *error))block;


// 获取家庭防御消息
+ (NSURLSessionDataTask *)getFamilyDefenseMsgWithFamilyId:(NSString *)familyId
                                               deviceType:(NSString *)deviceType
                                                 currPage:(NSInteger)currPage
                                                    block:(void(^)(NSArray<GSHMessageM*>*list,NSError *error))block;

@end

NS_ASSUME_NONNULL_END
