//
//  GSHDefenseDeviceTypeM.h
//  SmartHome
//
//  Created by zhanghong on 2019/5/31.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHDefenseDeviceTypeM : NSObject
@property (copy , nonatomic) NSString *defenceState;
@property (copy , nonatomic) NSString *deviceType;
@property (copy , nonatomic) NSString *enableFlag;
@property (copy , nonatomic) NSString *picPath;
@property (copy , nonatomic) NSString *sessionId;
@property (copy , nonatomic) NSString *typeName;
@end

@interface GSHDefenseDeviceTypeManager : NSObject

// 获取防御设备品类
+ (NSURLSessionDataTask *)getDefenseDeviceTypeWithFamilyId:(NSString *)familyId block:(void(^)(NSArray<GSHDefenseDeviceTypeM*> *list,NSArray<GSHDefenseDeviceTypeM*> *lackDeviceList,NSError *error))block;

// 查询全局防御状态
+ (NSURLSessionDataTask *)getGlobalDefenceStateWithFamilyId:(NSString *)familyId
                                                      block:(void(^)(NSNumber *defenceState,NSError *error))block;

// 设置家庭全局防御状态
+ (NSURLSessionDataTask *)setGlobalDefenceStateWithFamilyId:(NSString *)familyId
                                               defenceState:(NSString *)defenceState
                                                      block:(void(^)(NSError *error))block;

// 校验密码
+ (NSURLSessionDataTask *)verifyPasswordWithPsd:(NSString *)password
                                          block:(void(^)(NSError *error))block;

// 设置防御状态
+ (NSURLSessionDataTask *)setDefenceStateWithFamilyId:(NSString *)familyId
                                           deviceType:(NSString *)deviceType
                                         defenceState:(NSString *)defenceState
                                                block:(void(^)(NSError *error))block;

@end

@interface GSHDefenseDeviceMeteM : NSObject

@property (copy , nonatomic) NSString *basMeteId;
@property (copy , nonatomic) NSString *meteName;
@property (copy , nonatomic) NSString *status;
@property (copy , nonatomic) NSString *meteKind;

@end

@interface GSHDefenseInfoM : NSObject

@property (copy , nonatomic) NSString *deviceType;
@property (copy , nonatomic) NSString *reportName;
@property (copy , nonatomic) NSString *reportLevel;
@property (copy , nonatomic) NSString *templateId;
@property (copy , nonatomic) NSString *templateName;
@property (copy , nonatomic) NSString *monTime;
@property (copy , nonatomic) NSString *tueTime;
@property (copy , nonatomic) NSString *wedTime;
@property (copy , nonatomic) NSString *thuTime;
@property (copy , nonatomic) NSString *friTime;
@property (copy , nonatomic) NSString *sauTime;
@property (copy , nonatomic) NSString *sunTime;

@property (strong , nonatomic) NSMutableArray <GSHDefenseDeviceMeteM *> *deviceMeteList;

@end

@interface GSHDefenseInfoManager : NSObject

// 获取防御规则
+ (NSURLSessionDataTask *)getDefenseWithFamilyId:(NSString *)familyId
                                      deviceType:(NSString *)deviceType
                                           block:(void(^)(GSHDefenseInfoM *infoM,NSError *error))block;

// 配置防御规则
+ (NSURLSessionDataTask *)setDefenseWithFamilyId:(NSString *)familyId
                                  deviceMeteList:(NSArray *)deviceMeteList
                                    defenseInfoM:(GSHDefenseInfoM *)defenseInfoM
                                           block:(void(^)(NSError *error))block;

@end

@interface GSHDefensePlanM : NSObject

@property (copy , nonatomic) NSString *templateId;
@property (copy , nonatomic) NSString *templateName;
@property (copy , nonatomic) NSString *templateType;
@property (copy , nonatomic) NSString *monTime;
@property (copy , nonatomic) NSString *tueTime;
@property (copy , nonatomic) NSString *wedTime;
@property (copy , nonatomic) NSString *thuTime;
@property (copy , nonatomic) NSString *friTime;
@property (copy , nonatomic) NSString *sauTime;
@property (copy , nonatomic) NSString *sunTime;

@end

@interface GSHDefensePlanManager : NSObject

// 获取防御时间计划模版列表
+ (NSURLSessionDataTask *)getDefensePlanListWithFamilyId:(NSString *)familyId
                                                   block:(void(^)(NSArray<GSHDefensePlanM*> *list,NSError *error))block;

// 新增防御时间计划
+ (NSURLSessionDataTask *)addDefensePlanWithPlanSetM:(GSHDefensePlanM *)defensePlanSetM
                                            familyId:(NSString *)familyId
                                               block:(void(^)(NSError *error))block;

// 删除防御时间计划
+ (NSURLSessionDataTask *)deleteDefensePlanWithPlanTemplateId:(NSString *)templateId
                                                        block:(void(^)(NSError *error))block;
@end

NS_ASSUME_NONNULL_END
