//
//  GSHAutoM.m
//  SmartHome
//
//  Created by zhanghong on 2018/7/10.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutoM.h"
#import "GSHAutoDao.h"
#import "GSHOSSManagerClient.h"
#import "GSHFileManager.h"
#import "GSHOpenSDKInternal.h"

@implementation GSHOssAutoM {
    BOOL _isSelected;
}

@end

@implementation GSHAutoActionListM

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"exts":[GSHDeviceExtM class],@"deviceTypes":[GSHDeviceTypeM class]};
}

- (NSString *)getActionName {
    NSString *actionName = @"";
    if (self.scenarioId) {
        actionName = self.scenarioName;
    } else if (self.ruleId) {
        actionName = self.ruleName;
    } else {
        actionName = self.device.deviceName;
    }
    return actionName;
}
@end

@implementation GSHAutoTriggerConditionListM

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"exts":[GSHDeviceExtM class]};
}

- (NSString *)getWeekStrWithIndexSet:(NSMutableIndexSet *)tmpSet {
    __block NSMutableString *showStr = [NSMutableString stringWithFormat:@""];
    if (tmpSet.count == 7) {
        [showStr appendString:@"每天执行"];
    } else if (tmpSet.count == 2 && [tmpSet containsIndex:5] && [tmpSet containsIndex:6]){
        [showStr appendString:@"周末执行"];
    } else if (tmpSet.count == 5 && ![tmpSet containsIndex:5] && ![tmpSet containsIndex:6]) {
        [showStr appendString:@"工作日执行"];
    } else if (tmpSet.count == 0) {
        [showStr appendString:@"仅一次"];
    } else {
        [tmpSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                [showStr appendString:@"周一、"];
            } else if (idx == 1) {
                [showStr appendString:@"周二、"];
            } else if (idx == 2) {
                [showStr appendString:@"周三、"];
            } else if (idx == 3) {
                [showStr appendString:@"周四、"];
            } else if (idx == 4) {
                [showStr appendString:@"周五、"];
            } else if (idx == 5) {
                [showStr appendString:@"周六、"];
            } else if (idx == 6) {
                [showStr appendString:@"周日、"];
            }
        }];
        showStr = [[showStr substringToIndex:(showStr.length - 1)] mutableCopy];
    }
    return showStr;
}


- (NSString *)getDateTimer {
    if (!self.datetimer) {
        return nil;
    }
    return [self changeTimerToStrWithTimer:[self.datetimer intValue]];
}

- (NSString *)changeTimerToStrWithTimer:(int)timeInterval {
    int hour = timeInterval / 3600;
    int minute = (timeInterval % 3600) / 60;
    NSString *hourStr ;
    NSString *minuteStr;
    if (hour < 10) {
        hourStr = [NSString stringWithFormat:@"0%d",hour];
    } else {
        hourStr = [NSString stringWithFormat:@"%d",hour];
    }
    if (minute < 10) {
        minuteStr = [NSString stringWithFormat:@"0%d",minute];
    } else {
        minuteStr = [NSString stringWithFormat:@"%d",minute];
    }
    NSString *dateStr = [NSString stringWithFormat:@"%@:%@",hourStr,minuteStr];
    return dateStr;
}

@end

@implementation GSHAutoTriggerM  // 触发条件

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.conditionList = [NSMutableArray array];
        self.optionalConditionList = [NSMutableArray array];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"conditionList":[GSHAutoTriggerConditionListM class],
             @"optionalConditionList":[GSHAutoTriggerConditionListM class]};
}

- (BOOL)isSetRequiredTime {
    BOOL isSet = NO;
    if (self.conditionList.count > 0) {
        GSHAutoTriggerConditionListM *triggerConditionListM = self.conditionList[0];
        if (triggerConditionListM.getDateTimer) {
            isSet = YES;
        }
    }
    return isSet;
}

- (BOOL)isSetOptionalTime {
    BOOL isSet = NO;
    if (self.optionalConditionList.count > 0) {
        GSHAutoTriggerConditionListM *triggerConditionListM = self.optionalConditionList[0];
        if (triggerConditionListM.getDateTimer) {
            isSet = YES;
        }
    }
    return isSet;
}

@end

@implementation GSHAutoM {
    BOOL _isSelected;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.actionList = [NSMutableArray array];
    }
    return self;
}

- (NSString *)getEndTime {
    if (!self.endTime) {
        return nil;
    }
    return [self changeTimerToStrWithTimer:[self.endTime intValue]];
}

- (NSString *)getStartTime {
    if (!self.startTime) {
        return nil;
    }
    return [self changeTimerToStrWithTimer:[self.startTime intValue]];
}

- (NSString *)changeTimerToStrWithTimer:(int)timeInterval {
    int hour = timeInterval / 3600;
    int minute = (timeInterval % 3600) / 60;
    NSString *hourStr ;
    NSString *minuteStr;
    if (hour < 10) {
        hourStr = [NSString stringWithFormat:@"0%d",hour];
    } else {
        hourStr = [NSString stringWithFormat:@"%d",hour];
    }
    if (minute < 10) {
        minuteStr = [NSString stringWithFormat:@"0%d",minute];
    } else {
        minuteStr = [NSString stringWithFormat:@"%d",minute];
    }
    NSString *dateStr = [NSString stringWithFormat:@"%@:%@",hourStr,minuteStr];
    return dateStr;
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"actionList":[GSHAutoActionListM class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"automationName":@"name"};
}

@end

@implementation GSHAutoManager

#pragma mark 联动相关基本功能
// 添加联动
+ (NSURLSessionDataTask *)addAutoWithOssAutoM:(GSHOssAutoM *)ossAutoM
                                        autoM:(GSHAutoM *)autoM
                                        block:(void(^)(NSString *ruleId ,NSError *error))block {
    
    return [[GSHOpenSDKInternal share].ossManagerClient getFileIdFromSeaweedfsWithBlock:^(NSString *fid,NSString *url,NSError *error) {
        if (error) {
            if (block) {
                block(nil,error);
            }
        } else {
            NSString *jsonStr = [autoM yy_modelToJSONString];
            NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *urlStr = [NSString stringWithFormat:@"http://%@/%@",url,fid];
            [[GSHOpenSDKInternal share].ossManagerClient uploadFileToSeaweedfsWithUrl:urlStr fileData:jsonData fileName:fid mimeType:@"text/plain" block:^(NSError * _Nonnull error) {
                if (error) {
                    if (block) {
                        block(nil,error);
                    }
                } else {
                    ossAutoM.fid = fid;
                    // 添加联动到后台
                    NSMutableDictionary *parameterDic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[ossAutoM yy_modelToJSONObject]];
                    [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/addAutomation" parameters:parameterDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        [[GSHFileManager shared] writeDataToFileWithFileType:LocalStoreFileTypeAuto fileName:fid fileContent:jsonStr];
                        if (block) {
                            block(responseObject , nil);
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (block) {
                            block(nil , error);
                        }
                    }];
                }
            }];
        }
    }];
}

// 删除联动
+ (NSURLSessionDataTask *)deleteAutoWithOssAutoM:(GSHOssAutoM *)ossAutoM
                                        familyId:(NSString *)familyId
                                           block:(void(^)(NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:ossAutoM.ruleId.stringValue forKey:@"ruleId"];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/deleteAutomation" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
        // 删除本地文件
        [[GSHFileManager shared] deleteFileWithFileType:LocalStoreFileTypeAuto fileName:ossAutoM.fid];
        // 删除oss服务端文件
        NSString *volumeId = [ossAutoM.fid componentsSeparatedByString:@","].firstObject;
        [[GSHOpenSDKInternal share].ossManagerClient getLocalUrlFromSeaweedfsWithVolumeId:volumeId block:^(NSArray * _Nonnull urlArray, NSError * _Nonnull error) {
            if (!error) {
                if (urlArray.count > 0) {
                    NSDictionary *dic = urlArray[0];
                    NSString *publicUrl = [dic objectForKey:@"publicUrl"];
                    NSString *url = [NSString stringWithFormat:@"http://%@/%@",publicUrl,ossAutoM.fid];
                    
                    [[GSHOpenSDKInternal share].ossManagerClient deleteFileFromSeaweedfsWithUrlStr:url block:^(NSError * _Nonnull error) {
                        
                    }];
                }
            }
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}


// 修改联动
+ (NSURLSessionDataTask *)updateAutoWithVolumeId:(NSString *)volumeId
                                        ossAutoM:(GSHOssAutoM *)ossAutoM
                                           autoM:(GSHAutoM *)autoM
                                           block:(void(^)(NSError *error))block {
    
    return [[GSHOpenSDKInternal share].ossManagerClient getLocalUrlFromSeaweedfsWithVolumeId:volumeId block:^(NSArray * _Nonnull urlArray, NSError * _Nonnull error) {
        if (error) {
            if (block) {
                block(error);
            }
        } else {
            if (urlArray.count > 0) {
                NSDictionary *dic = urlArray[0];
                NSString *publicUrl = [dic objectForKey:@"publicUrl"];
                NSString *url = [NSString stringWithFormat:@"http://%@/%@",publicUrl,ossAutoM.fid];
                NSString *jsonStr = [autoM yy_modelToJSONString];
                NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                [[GSHOpenSDKInternal share].ossManagerClient uploadFileToSeaweedfsWithUrl:url fileData:jsonData fileName:ossAutoM.fid mimeType:@"text/plain" block:^(NSError * _Nonnull error) {
                    if (error) {
                        if (block) {
                            block(error);
                        }
                    } else {
                        NSMutableDictionary *parameterDic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[ossAutoM yy_modelToJSONObject]];
                        [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/updateAutomation" parameters:parameterDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            // 更新本地文件
                            [[GSHFileManager shared] writeDataToFileWithFileType:LocalStoreFileTypeAuto fileName:ossAutoM.fid fileContent:jsonStr];
                            if (block) {
                                block(nil);
                            }
                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            if (block) {
                                block(error);
                            }
                        }];
                    }
                }];
            }
        }
    }];
}

// 获取联动列表
+ (NSURLSessionDataTask *)getAutoListWithFamilyId:(NSString *)familyId
                                         currPage:(NSString *)currPage
                                            block:(void(^)(NSArray<GSHOssAutoM*>*list,NSError *error))block {
    
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网
        NSArray *autoList = [[GSHAutoDao shareAutoDao] selectAutoTableWithFamilyId:familyId];
        if (block) {
            block(autoList,nil);
        }
        return nil;
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:familyId forKey:@"familyId"];
        if (currPage) {
            [dic setValue:currPage forKey:@"currPage"];
            [dic setValue:@"12" forKey:@"pageSize"];
        }
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"operation/getAutomationList" parameters:dic success:^(id operationOrTask, id responseObject) {
            if (block) {
                NSArray<GSHOssAutoM*>*list = [NSArray yy_modelArrayWithClass:GSHOssAutoM.class json:[(NSDictionary *)responseObject objectForKey:@"automationList"]];
                block(list,nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(nil,error);
            }
        } useCache:NO];
    }
}

// v3.0 获取联动列表 -- 分页修改为传 联动id
+ (NSURLSessionDataTask *)getAutoListNewWithFamilyId:(NSString *)familyId
                                          lastAutoId:(NSNumber *)lastAutoId
                                               block:(void(^)(NSArray<GSHOssAutoM*>*list,NSError *error))block {
    
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网
        NSArray *autoList = [[GSHAutoDao shareAutoDao] selectAutoTableWithFamilyId:familyId];
        if (block) {
            block(autoList,nil);
        }
        return nil;
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:familyId forKey:@"familyId"];
        if (lastAutoId) {
            [dic setValue:lastAutoId.stringValue forKey:@"sepAutoId"];
            [dic setValue:@"12" forKey:@"pageSize"];
        }
        return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/getAutomationListV3" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (block) {
                NSArray<GSHOssAutoM*>*list = [NSArray yy_modelArrayWithClass:GSHOssAutoM.class json:[(NSDictionary *)responseObject objectForKey:@"automationList"]];
                block(list,nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (block) {
                block(nil,error);
            }
        }];
    }
}

// 修改联动 -- 开/关
+ (NSURLSessionDataTask *)updateAutoSwitchWithRuleId:(NSString *)ruleId
                                              status:(NSString *)status
                                           gateWayId:(NSString *)gateWayId
                                            familyId:(NSString *)familyId
                                               block:(void(^)(NSError *error))block {
    
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网
        [[GSHWebSocketClient shared] updateAutoStatushWithGatewayId:gateWayId ruleId:ruleId status:status block:^(NSError *error) {
            if (block) {
                block(error);
            }
        }];
        return nil;
    } else {
        NSMutableDictionary *autoM_dic = [NSMutableDictionary dictionary];
        [autoM_dic setObject:status forKey:@"status"];
        [autoM_dic setObject:ruleId forKey:@"ruleId"];
        [autoM_dic setObject:familyId forKey:@"familyId"];
        
        return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/updateAutomationInfo" parameters:autoM_dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (block) {
                block(nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (block) {
                block(error);
            }
        }];
    }
    
}

// 场景面板绑定 -- 添加联动 并 保存绑定信息
+ (NSURLSessionDataTask *)bindSceneWithOssAutoM:(GSHOssAutoM *)ossAutoM
                                          autoM:(GSHAutoM *)autoM
                                       deviceId:(NSString *)deviceId
                                      basMeteId:(NSString *)basMeteId
                                     scenarioId:(NSString *)scenarioId
                                          block:(void(^)(NSString *ruleId ,NSError *error))block {
    
    return [[GSHOpenSDKInternal share].ossManagerClient getFileIdFromSeaweedfsWithBlock:^(NSString *fid,NSString *url,NSError *error) {
        if (error) {
            if (block) {
                block(nil,error);
            }
        } else {
            NSString *jsonStr = [autoM yy_modelToJSONString];
            NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *urlStr = [NSString stringWithFormat:@"http://%@/%@",url,fid];
            ossAutoM.fid = fid;
            
            [[GSHOpenSDKInternal share].ossManagerClient uploadFileToSeaweedfsWithUrl:urlStr fileData:jsonData fileName:fid mimeType:@"text/plain" block:^(NSError * _Nonnull error) {
                if (error) {
                    if (block) {
                        block(nil,error);
                    }
                } else {
                    NSMutableDictionary *parameterDic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[ossAutoM yy_modelToJSONObject]];
                    [parameterDic setValue:deviceId forKey:@"deviceId"];
                    [parameterDic setValue:scenarioId forKey:@"scenarioId"];
                    [parameterDic setValue:basMeteId forKey:@"basMeteId"];
                    
                    [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/bindScenarioBoard" parameters:parameterDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        if (block) {
                            block(responseObject,nil);
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (error) {
                            if (block) {
                                block(nil,error);
                            }
                        }
                    }];
                }
            }];
        }
    }];
}

// 校验设备信息是否有更改，设备是否被删除
+ (NSURLSessionDataTask *)checkDevicesFromServerWithDeviceIdArray:(NSArray *)deviceIdArray
                                                       sceneArray:(NSArray *)sceneArray
                                                        autoArray:(NSArray *)autoArray
                                                         familyId:(NSString *)familyId
                                                            block:(void(^)(NSArray <GSHNameIdM*> *deviceArr,NSArray <GSHNameIdM*> *sceneArr,NSArray <GSHNameIdM*> *autoArr,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceIdArray.count>0?deviceIdArray:@[] forKey:@"deviceIdList"];
    [dic setValue:sceneArray.count>0?sceneArray:@[] forKey:@"scenarioIdList"];
    [dic setValue:autoArray.count>0?autoArray:@[] forKey:@"automationIdList"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/checkDevicesOrOperations" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *deviceArray = [NSArray yy_modelArrayWithClass:GSHNameIdM.class json:[(NSDictionary *)responseObject objectForKey:@"deviceMsgs"]];
        NSArray *sceneArray = [NSArray yy_modelArrayWithClass:GSHNameIdM.class json:[(NSDictionary *)responseObject objectForKey:@"scenarios"]];
        NSArray *autoArray = [NSArray yy_modelArrayWithClass:GSHNameIdM.class json:[(NSDictionary *)responseObject objectForKey:@"automations"]];
        if (block) {
            block(deviceArray,sceneArray,autoArray,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,nil,nil,error);
        }
    }];
}

// 联动 -- 触发条件 -- 获取设备
+ (NSURLSessionDataTask *)getAutoTriggerDevicesListWithFamilyId:(NSString *)familyId
                                                         roomId:(NSString *)roomId
                                                          block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    if (roomId.length > 0) {
        [dic setValue:roomId forKey:@"roomId"];
    }
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"operation/getConditionDevices" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:[(NSDictionary *)responseObject objectForKey:@"list"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// 联动 -- 执行动作 -- 获取设备
+ (NSURLSessionDataTask *)getAutoActionDevicesListWithFamilyId:(NSString *)familyId
                                                        roomId:(NSString *)roomId
                                                         block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    if (roomId.length > 0) {
        [dic setValue:roomId forKey:@"roomId"];
    }
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"operation/getOperatorDevice" parameters:dic success:^(id operationOrTask, id responseObject) {
        id json = [(NSDictionary *)responseObject objectForKey:@"list"];
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:json];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// 从oss服务端获取联动数据
+ (void)getAutoFileFromOssWithFid:(NSString *)fid
                            block:(void(^)(NSString *json,NSError *error))block {
    
    NSString *volumeId = [fid componentsSeparatedByString:@","].firstObject;
    [[GSHOpenSDKInternal share].ossManagerClient getLocalUrlFromSeaweedfsWithVolumeId:volumeId block:^(NSArray * _Nonnull urlArray, NSError * _Nonnull error) {
        if (error) {
            if (block) {
                block(nil,error);
            }
        } else {
            if (urlArray.count > 0) {
                NSDictionary *dic = urlArray[0];
                NSString *publicUrl = [dic objectForKey:@"publicUrl"];
                NSString *url = [NSString stringWithFormat:@"http://%@/%@",publicUrl,fid];
                [[GSHOpenSDKInternal share].ossManagerClient getFileDataFromSeaweedfsWithUrl:url block:^(NSString * _Nonnull json, NSError * _Nonnull error) {
                    if (error) {
                        if (block) {
                            block(nil,error);
                        }
                    } else {
                        // 写入文件
                        [[GSHFileManager shared] writeDataToFileWithFileType:LocalStoreFileTypeAuto fileName:fid fileContent:json];
                        if (block) {
                            block(json,nil);
                        }
                    }
                }];
            }
        }
    }];
    
}

// v3.0 -- 获取联动模板列表
+ (NSURLSessionDataTask *)getAutoTemplateListWithFamilyId:(NSString *)familyId
                                          isOnlyRecommend:(NSString *)isOnlyRecommend
                                                    block:(void(^)(NSArray<GSHAutoM *> *autoTemplateList,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:isOnlyRecommend forKey:@"isOnlyRecommend"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"operation/getRecommendAutoTplList" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray *autoTemplateList = [NSArray yy_modelArrayWithClass:GSHAutoM.class json:responseObject];
        if (block) {
            block(autoTemplateList,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// v3.0 -- 获取推荐自动化模板条件设备及动作设备列表
+ (NSURLSessionDataTask *)getAutoTemplateDeviceListWithFamilyId:(NSString *)familyId
                                                     templateId:(NSNumber *)templateId
                                                          block:(void(^)(NSArray<GSHDeviceM *> *actionDeviceList,NSArray<GSHDeviceM *> *optTriggerDeviceList,NSArray<GSHDeviceM *> *reqTriggerDeviceList,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:templateId.stringValue forKey:@"tplId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"operation/getAutoTplDeviceList" parameters:dic success:^(id operationOrTask, id responseObject) {
        
        NSArray *actionDeviceArray = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:[(NSDictionary *)responseObject objectForKey:@"actionDeviceList"]];
        NSArray *optTriggerDeviceArray = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:[(NSDictionary *)responseObject objectForKey:@"optTriggerDeviceList"]];
        NSArray *reqTriggerDeviceArray = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:[(NSDictionary *)responseObject objectForKey:@"reqTriggerDeviceList"]];
        if (block) {
            block(actionDeviceArray,optTriggerDeviceArray,reqTriggerDeviceArray,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,nil,nil,error);
        }
    } useCache:NO];
}

@end



