//
//  GSHDefenseDeviceTypeM.m
//  SmartHome
//
//  Created by zhanghong on 2019/5/31.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDefenseM.h"
#import "GSHOpenSDKInternal.h"
#import "YYModel.h"
#import "YYCategories.h"

@implementation GSHDefenseDeviceTypeM
@end

@implementation GSHDefenseDeviceTypeManager

+ (NSURLSessionDataTask *)getDefenseDeviceTypeWithFamilyId:(NSString *)familyId block:(void(^)(NSArray<GSHDefenseDeviceTypeM*> *list,NSArray<GSHDefenseDeviceTypeM*> *lackDeviceList,NSError *error))block{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"defence/getFamilyDeviceTypeList" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray *temp = [NSArray yy_modelArrayWithClass:GSHDefenseDeviceTypeM.class json:responseObject];
        NSMutableArray *list = [NSMutableArray array];
        NSMutableArray *lackDeviceList = [NSMutableArray array];
        for (GSHDefenseDeviceTypeM *model in temp) {
            if (model.enableFlag.intValue == 0) {
                [lackDeviceList addObject:model];
            }else{
                [list addObject:model];
            }
        }
        if (block) {
            block(list,lackDeviceList,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,nil,error);
        }
    } useCache:NO];
}

+ (NSURLSessionDataTask *)getGlobalDefenceStateWithFamilyId:(NSString *)familyId
                                                      block:(void(^)(NSNumber *defenceState,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"defence/getGlobalDefenceState" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSNumber *defenceState = [(NSDictionary *)responseObject objectForKey:@"defenceState"];
        if (block) {
            block(defenceState,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

+ (NSURLSessionDataTask *)setGlobalDefenceStateWithFamilyId:(NSString *)familyId
                                               defenceState:(NSString *)defenceState
                                                      block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:defenceState forKey:@"defenceState"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"defence/setGlobalDefenceState" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// 校验密码
+ (NSURLSessionDataTask *)verifyPasswordWithPsd:(NSString *)password block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSData *pwd = [password dataUsingEncoding:NSUTF8StringEncoding];
    pwd = [pwd md5Data];
    password = [pwd base64EncodedStringWithOptions:0];
    [dic setValue:password forKey:@"pwd"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"userInfo/confirmPwd" parameters:dic success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    } useCache:NO];
}

// 设置防御状态
+ (NSURLSessionDataTask *)setDefenceStateWithFamilyId:(NSString *)familyId
                                           deviceType:(NSString *)deviceType
                                         defenceState:(NSString *)defenceState
                                                block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceType forKey:@"deviceType"];
    [dic setValue:defenceState forKey:@"defenceState"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"defence/setDefenceState" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

@implementation GSHDefenseDeviceMeteM

@end

@implementation GSHDefenseInfoM

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.deviceMeteList = [NSMutableArray array];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"deviceMeteList":[GSHDefenseDeviceMeteM class]};
}

@end

@implementation GSHDefenseInfoManager

+ (NSURLSessionDataTask *)getDefenseWithFamilyId:(NSString *)familyId
                                      deviceType:(NSString *)deviceType
                                           block:(void(^)(GSHDefenseInfoM *infoM,NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceType forKey:@"deviceType"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"defence/getDefenceConfig" parameters:dic success:^(id operationOrTask, id responseObject) {
        GSHDefenseInfoM *infoM = [GSHDefenseInfoM yy_modelWithJSON:responseObject];
        if (block) {
            block(infoM,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// 配置防御规则
+ (NSURLSessionDataTask *)setDefenseWithFamilyId:(NSString *)familyId
                                  deviceMeteList:(NSArray *)deviceMeteList
                                    defenseInfoM:(GSHDefenseInfoM *)defenseInfoM
                                           block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:defenseInfoM.deviceType forKey:@"deviceType"];
    [dic setValue:defenseInfoM.reportLevel forKey:@"reportLevel"];
    [dic setValue:defenseInfoM.templateId forKey:@"templateId"];
    [dic setValue:deviceMeteList forKey:@"basMeteIdList"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"defence/setDefenceConfig" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

@implementation GSHDefensePlanM

@end

@implementation GSHDefensePlanManager

+ (NSURLSessionDataTask *)getDefensePlanListWithFamilyId:(NSString *)familyId block:(void(^)(NSArray<GSHDefensePlanM*> *list,NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"defence/getDefenceTimetplList" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDefensePlanM.class json:responseObject ];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil , error);
        }
    } useCache:NO];
}

+ (NSURLSessionDataTask *)addDefensePlanWithPlanSetM:(GSHDefensePlanM *)defensePlanSetM
                                            familyId:(NSString *)familyId
                                               block:(void(^)(NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    if (defensePlanSetM.templateId.length > 0) {
        [dic setValue:defensePlanSetM.templateId?defensePlanSetM.templateId:@"" forKey:@"templateId"];
    }
    [dic setValue:defensePlanSetM.templateName forKey:@"templateName"];
    [dic setValue:defensePlanSetM.monTime forKey:@"monTime"];
    [dic setValue:defensePlanSetM.tueTime forKey:@"tueTime"];
    [dic setValue:defensePlanSetM.wedTime forKey:@"wedTime"];
    [dic setValue:defensePlanSetM.thuTime forKey:@"thuTime"];
    [dic setValue:defensePlanSetM.friTime forKey:@"friTime"];
    [dic setValue:defensePlanSetM.sauTime forKey:@"sauTime"];
    [dic setValue:defensePlanSetM.sunTime forKey:@"sunTime"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"defence/addOrUpdateDefenceTimetpl" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// 删除计划
+ (NSURLSessionDataTask *)deleteDefensePlanWithPlanTemplateId:(NSString *)templateId
                                                        block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:templateId forKey:@"templateId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"defence/deleteDefenceTimetpl" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
