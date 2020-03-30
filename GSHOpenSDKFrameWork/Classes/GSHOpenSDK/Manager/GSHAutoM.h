//
//  GSHAutoM.h
//  SmartHome
//
//  Created by zhanghong on 2018/7/10.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"
#import "GSHDeviceM.h"
#import "GSHSceneM.h"

// 主要用于接收联动列表数据
@interface GSHOssAutoM : GSHBaseModel

@property (nonatomic , copy) NSString *fid;
@property (nonatomic , copy) NSString *md5;
@property (nonatomic , copy) NSString *name;
@property (nonatomic , strong) NSNumber *familyId;
@property (nonatomic , strong) NSNumber *relationType;
@property (nonatomic , strong) NSNumber *type;
@property (nonatomic , strong) NSNumber *status;
@property (nonatomic , strong) NSNumber *ruleId;
@property (nonatomic , strong) NSNumber *autoTplId; // 联动模版id

@end

@interface GSHAutoActionListM : GSHBaseModel

@property (nonatomic , copy) NSString *ruleName;        // 执行动作 -- 联动名称
@property (nonatomic , copy) NSString *scenarioName;    // 执行动作 -- 情景名称
@property (nonatomic , strong) NSNumber *actionId;      // 执行动作id
@property (nonatomic , strong) NSNumber *ruleId;        // 执行动作 -- 联动id
@property (nonatomic , strong) NSNumber *scenarioId;    // 执行动作 -- 情景id
@property (nonatomic , strong) NSNumber *businessId;    // 场景业务id
@property (nonatomic , strong) GSHDeviceM *device;
@property (nonatomic , strong) NSMutableArray<GSHDeviceTypeM *> *deviceTypes; // 设备类型 (v3.0 用于联动模版列表 )

- (NSString *)getActionName;

@end

@interface GSHAutoTriggerConditionListM : GSHBaseModel   // 触发条件

@property (nonatomic , copy) NSString *conditionId;
@property (nonatomic , copy) NSString *gatewayId;
@property (nonatomic , strong) NSNumber *datetimer;   //定时规则触动的时间点
@property (nonatomic , assign) NSInteger week;
@property (nonatomic , strong) GSHDeviceM *device;

@property (nonatomic , strong) GSHDeviceTypeM *deviceTypeModel; // 设备类型 (v3.0 用于联动模版列表 )

- (NSString *)getWeekStrWithIndexSet:(NSMutableIndexSet *)tmpSet;
- (NSString *)getDateTimer;

@end

@interface GSHAutoTriggerM : GSHBaseModel   // 触发条件

@property (nonatomic , copy) NSString *triggerId;   //触发条件id
@property (nonatomic , copy) NSString *name;   //触发条件名称
@property (nonatomic , strong) NSMutableArray<GSHAutoTriggerConditionListM *> *conditionList;     // 必选条件
@property (nonatomic , strong) NSMutableArray<GSHAutoTriggerConditionListM *> *optionalConditionList;   // 可选条件
@property (nonatomic , strong) NSNumber *relationType;   //条件关系,0:满足所有条件 1:满足任一条件

- (BOOL)isSetRequiredTime;  // 必选条件是否设置了时间
- (BOOL)isSetOptionalTime;  // 可选条件是否设置了时间

@end

@interface GSHAutoM : GSHBaseModel

@property (nonatomic , copy) NSString *automationName;   //联动名称
@property (nonatomic , copy) NSString *conditionTime;   //联动 -- 条件时限
@property (nonatomic , strong) NSNumber *familyId;
@property (nonatomic , strong) NSNumber *ruleId;   //联动id
@property (nonatomic , strong) NSNumber *type;   // 0:条件场景 1：定时场景 ,
@property (nonatomic , strong) NSNumber *status;   // 规则状态，0：未启用 1.启用
@property (nonatomic , strong) NSNumber *endTime;  // 生效时间段 -- 结束时间
@property (nonatomic , strong) NSNumber *startTime;   // 生效时间段 -- 开始时间
@property (nonatomic , assign) NSInteger week;   // 生效时间段 -- 重复次数
@property (nonatomic , strong) NSMutableArray<GSHAutoActionListM *> *actionList;     // 执行动作
@property (nonatomic , strong) GSHAutoTriggerM *trigger;     // 执行条件

 // v3.0 联动模版信息
@property (nonatomic , strong) NSNumber *tplId; // 联动模版id
@property (nonatomic , copy) NSString *tplName;   //联动模版名称
@property (nonatomic , copy) NSString *tplDesc;   //联动模版简介
@property (nonatomic , copy) NSString *picPath;   //联动模版图片

- (NSString *)getEndTime;
- (NSString *)getStartTime;

@end

@interface GSHAutoManager : NSObject

#pragma mark 联动相关基本功能

// 添加联动
+ (NSURLSessionDataTask *)addAutoWithOssAutoM:(GSHOssAutoM *)ossAutoM
                                        autoM:(GSHAutoM *)autoM
                                        block:(void(^)(NSString *ruleId ,NSError *error))block;

// 删除联动
+ (NSURLSessionDataTask *)deleteAutoWithOssAutoM:(GSHOssAutoM *)ossAutoM
                                        familyId:(NSString *)familyId
                                           block:(void(^)(NSError *error))block;

// 修改联动
+ (NSURLSessionDataTask *)updateAutoWithVolumeId:(NSString *)volumeId
                                        ossAutoM:(GSHOssAutoM *)ossAutoM
                                           autoM:(GSHAutoM *)autoM
                                           block:(void(^)(NSError *error))block;

// 获取联动列表
+ (NSURLSessionDataTask *)getAutoListWithFamilyId:(NSString *)familyId
                                         currPage:(NSString *)currPage
                                            block:(void(^)(NSArray<GSHOssAutoM*>*list,NSError *error))block;

// v3.0 获取联动列表 -- 分页修改为传 联动id
+ (NSURLSessionDataTask *)getAutoListNewWithFamilyId:(NSString *)familyId
                                          lastAutoId:(NSNumber *)lastAutoId
                                               block:(void(^)(NSArray<GSHOssAutoM*>*list,NSError *error))block;

// 修改联动 -- 开/关
+ (NSURLSessionDataTask *)updateAutoSwitchWithRuleId:(NSString *)ruleId
                                              status:(NSString *)status
                                           gateWayId:(NSString *)gateWayId
                                            familyId:(NSString *)familyId
                                               block:(void(^)(NSError *error))block;

// 场景面板绑定 -- 添加联动 并 保存绑定信息
+ (NSURLSessionDataTask *)bindSceneWithOssAutoM:(GSHOssAutoM *)ossAutoM
                                          autoM:(GSHAutoM *)autoM
                                       deviceId:(NSString *)deviceId
                                      basMeteId:(NSString *)basMeteId
                                     scenarioId:(NSString *)scenarioId
                                          block:(void(^)(NSString *ruleId ,NSError *error))block;

// 校验设备信息是否有更改，设备是否被删除
+ (NSURLSessionDataTask *)checkDevicesFromServerWithDeviceIdArray:(NSArray *)deviceIdArray
                                                       sceneArray:(NSArray *)sceneArray
                                                        autoArray:(NSArray *)autoArray
                                                         familyId:(NSString *)familyId
                                                            block:(void(^)(NSArray <GSHNameIdM*> *deviceArr,NSArray <GSHNameIdM*> *sceneArr,NSArray <GSHNameIdM*> *autoArr,NSError *error))block;

// 联动 -- 触发条件 -- 获取设备
+ (NSURLSessionDataTask *)getAutoTriggerDevicesListWithFamilyId:(NSString *)familyId
                                                        roomId:(NSString *)roomId
                                                         block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block;

// 联动 -- 执行动作 -- 获取设备
+ (NSURLSessionDataTask *)getAutoActionDevicesListWithFamilyId:(NSString *)familyId
                                                       roomId:(NSString *)roomId
                                                        block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block;

// 从oss服务端获取联动数据
+ (void)getAutoFileFromOssWithFid:(NSString *)fid
                            block:(void(^)(NSString *json,NSError *error))block;

// v3.0 -- 获取联动模板列表
+ (NSURLSessionDataTask *)getAutoTemplateListWithFamilyId:(NSString *)familyId
                                          isOnlyRecommend:(NSString *)isOnlyRecommend
                                                    block:(void(^)(NSArray<GSHAutoM *> *autoTemplateList,NSError *error))block;

// v3.0 -- 获取推荐自动化模板条件设备及动作设备列表
+ (NSURLSessionDataTask *)getAutoTemplateDeviceListWithFamilyId:(NSString *)familyId
                                                     templateId:(NSNumber *)templateId
                                                          block:(void(^)(NSArray<GSHDeviceM *> *actionDeviceList,NSArray<GSHDeviceM *> *optTriggerDeviceList,NSArray<GSHDeviceM *> *reqTriggerDeviceList,NSError *error))block;

@end



