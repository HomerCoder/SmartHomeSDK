//
//  GSHSceneM.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSceneM.h"
#import "NSDictionary+TZM.h"
#import "GSHOSSManagerClient.h"
#import "GSHFileManager.h"
#import "GSHSceneDao.h"
#import "GSHOpenSDKInternal.h"
#import "GSHFloorM.h"

@implementation GSHSceneBackgroundImageM


@end

@implementation GSHSceneBannerM


@end

@implementation GSHSceneTemplateM

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"sceneTemplateId":@"id",@"descriptionStr":@"description"};
}

@end

@implementation GSHSceneTemplateDetailInfoM

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"deviceTypes":[GSHDeviceTypeM class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"sceneTemplateId":@"id",@"descriptionStr":@"description"};
}

@end

@implementation GSHOssSceneM {
    BOOL _isSelected;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"scenarioId":@"id"};
}

- (BOOL)isSelected {
    return _isSelected;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
}

@end

@implementation GSHSceneListM

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scenarios = [NSMutableArray array];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"banners":[GSHSceneBannerM class],
             @"scenarioTpls":[GSHSceneTemplateM class],
             @"scenarios":[GSHOssSceneM class]};
}

@end

@implementation GSHSceneM {
    BOOL _isSelected;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.devices = [NSMutableArray array];
    }
    return self;
}

- (BOOL)isSelected {
    return _isSelected;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"scenarioId":@[@"id",@"scenarioId"],
             @"scenarioName":@[@"scenarioName",@"name"],
             @"picUrl":@[@"picUrl",@"backgroundUrl"]
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"devices":[GSHDeviceM class]};
}

+ (UIImage*)getSceneBackgroundImageWithId:(int)backgroundId {
    return [UIImage ZHImageNamed:[NSString stringWithFormat:@"sence_pic_bg_%d_little",backgroundId]];
}

// 首页 -- 场景背景图片
+ (UIImage*)getHomeSceneBackgroundImageWithId:(int)backgroundId {
    return [UIImage ZHImageNamed:[NSString stringWithFormat:@"homesence_pic_bg_%d_little",backgroundId]];
}

+(UIImage*)getSceneListBackgroundImageWithId:(int)backgroundId {
    return [UIImage ZHImageNamed:[NSString stringWithFormat:@"sence_pic_bg_%d",backgroundId]];
}

@end

@implementation GSHNameIdM

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"nameStr":@"name",
             @"idStr":@"id" };
}

@end

@implementation GSHSceneManager
#pragma mark - 场景相关基本功能
// 添加场景
+ (NSURLSessionDataTask *)addSceneWithSceneM:(GSHSceneM *)sceneM
                                   ossSceneM:(GSHOssSceneM *)ossSceneM
                                       block:(void(^)(NSString *scenarionId , NSError *error))block {
    
    return [[GSHOpenSDKInternal share].ossManagerClient getFileIdFromSeaweedfsWithBlock:^(NSString *fid,NSString *url,NSError *error) {
        if (error) {
            if (block) {
                block(nil,error);
            }
        } else {
            NSString *jsonStr = [sceneM yy_modelToJSONString];
            NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *urlStr = [NSString stringWithFormat:@"http://%@/%@",url,fid];
            [[GSHOpenSDKInternal share].ossManagerClient uploadFileToSeaweedfsWithUrl:urlStr fileData:jsonData fileName:fid mimeType:@"text/plain" block:^(NSError * _Nonnull error) {
                if (error) {
                    if (block) {
                        block(nil,error);
                    }
                } else {
                    ossSceneM.fid = fid;
                    // 添加场景到后台
                    NSMutableDictionary *parameterDic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[ossSceneM yy_modelToJSONObject]];
                    [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/setScenario" parameters:parameterDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        [[GSHFileManager shared] writeDataToFileWithFileType:LocalStoreFileTypeScene fileName:fid fileContent:jsonStr];
                        if (block) {
                            block(responseObject,nil);
                        }
                        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKSceneUpdataNotification object:ossSceneM.roomId == nil ? nil : @[ossSceneM.roomId]]];
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (block) {
                            block(nil,error);
                        }
                    }];
                }
            }];
        }
    }];
}

// 删除场景
+ (NSURLSessionDataTask *)deleteSceneWithOssSceneM:(GSHOssSceneM *)ossSceneM
                                          familyId:(NSString *)familyId
                                             block:(void(^)(NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:ossSceneM.scenarioId.stringValue forKey:@"scenarioId"];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/deleteScenario" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (block) {
            block(nil);
        }
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKSceneUpdataNotification object:ossSceneM.roomId == nil ? nil : @[ossSceneM.roomId]]];
        // 删除本地文件
        [[GSHFileManager shared] deleteFileWithFileType:LocalStoreFileTypeScene fileName:ossSceneM.fid];
        // 删除文件服务器文件
        NSString *volumeId = [ossSceneM.fid componentsSeparatedByString:@","].firstObject;
        [[GSHOpenSDKInternal share].ossManagerClient getLocalUrlFromSeaweedfsWithVolumeId:volumeId block:^(NSArray * _Nonnull urlArray, NSError * _Nonnull error) {
            if (!error) {
                if (urlArray.count > 0) {
                    NSDictionary *dic = urlArray[0];
                    NSString *publicUrl = [dic objectForKey:@"publicUrl"];
                    NSString *url = [NSString stringWithFormat:@"http://%@/%@",publicUrl,ossSceneM.fid];
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

// 修改场景
+ (NSURLSessionDataTask *)alertSceneWithVolumeId:(NSString *)volumeId
                                       oldRoomId:(NSString *)oldRoomId
                                          sceneM:(GSHSceneM *)sceneM
                                       ossSceneM:(GSHOssSceneM *)ossSceneM
                                           block:(void(^)(NSError *error))block {
    NSMutableArray *roomIdList = [NSMutableArray array];
    if (oldRoomId.length > 0) {
        [roomIdList addObject: oldRoomId];
    }
    if (ossSceneM.roomId != nil) {
        [roomIdList addObject:ossSceneM.roomId.stringValue];
    }
    
    return [[GSHOpenSDKInternal share].ossManagerClient getLocalUrlFromSeaweedfsWithVolumeId:volumeId block:^(NSArray * _Nonnull urlArray, NSError * _Nonnull error) {
        if (error) {
            if (block) {
                block(error);
            }
        } else {
            if (urlArray.count > 0) {
                NSDictionary *dic = urlArray[0];
                NSString *publicUrl = [dic objectForKey:@"publicUrl"];
                NSString *url = [NSString stringWithFormat:@"http://%@/%@",publicUrl,ossSceneM.fid];
                NSString *jsonStr = [sceneM yy_modelToJSONString];
                NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                [[GSHOpenSDKInternal share].ossManagerClient uploadFileToSeaweedfsWithUrl:url fileData:jsonData fileName:ossSceneM.fid mimeType:@"text/plain" block:^(NSError * _Nonnull error) {
                    if (error) {
                        if (block) {
                            block(error);
                        }
                    } else {
                        NSMutableDictionary *parameterDic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[ossSceneM yy_modelToJSONObject]];
                        [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/updateScenario" parameters:parameterDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            // 更新本地文件
                            [[GSHFileManager shared] writeDataToFileWithFileType:LocalStoreFileTypeScene fileName:ossSceneM.fid fileContent:jsonStr];
                            if (block) {
                                block(nil);
                            }
                            [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKSceneUpdataNotification object:roomIdList]];
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

// 获取场景列表
+ (NSURLSessionDataTask *)getSceneListWithFamilyId:(NSString *)familyId
                                          currPage:(NSString *)currPage
                                             block:(void(^)(GSHSceneListM *sceneListM,NSError *error))block {
    
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网控制
        NSArray *sceneList = [[GSHSceneDao shareSceneDao] selectSceneTableWithFamilyId:familyId];
        GSHSceneListM *listM = [[GSHSceneListM alloc] init];
        [listM.scenarios addObjectsFromArray:sceneList];
        if (block) {
            block(listM,nil);
        }
        return nil;
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:familyId forKey:@"familyId"];
        if (currPage) {
            [dic setValue:currPage forKey:@"currPage"];
            [dic setValue:@"12" forKey:@"pageSize"];
        }
        return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/getScenario" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
            if (block) {
                GSHSceneListM *listM = [GSHSceneListM yy_modelWithJSON:responseObject];
                block(listM,nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(nil,error);
            }
        }];
    }
}

// 场景列表排序
+ (NSURLSessionDataTask *)sortSceneWithFamilyId:(NSString *)familyId rankArray:(NSArray *)rankArray block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:rankArray forKey:@"scenarios"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/setRank" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// 执行场景
+ (NSURLSessionDataTask *)executeSceneWithFamilyId:(NSString *)familyId
                       gateWayId:(NSString *)gateWayId
                      scenarioId:(NSString *)scenarioId
                           block:(void(^)(NSError *error))block {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        [[GSHWebSocketClient shared] executeSceneWithGatewayId:gateWayId scenarioId:scenarioId block:^(NSError *error) {
            if (block) {
                block(error);
            }
        }];
        return nil;
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:familyId forKey:@"familyId"];
        [dic setValue:scenarioId forKey:@"scenarioId"];
        return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/executeScenario" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

// 校验语音关键词
+ (NSURLSessionDataTask *)verifyVoiceKeyWordWithFamilyId:(NSString *)familyId voiceKeyWord:(NSString *)voiceKeyWord block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:voiceKeyWord forKey:@"voiceKeyword"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/checkVoiceKeyword" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// 场景选择设备 -- 查询楼层房间信息
+ (NSURLSessionDataTask *)getAllFloorAndRoomWithFamilyId:(NSString *)familyId block:(void(^)(NSArray<GSHFloorM*>*list,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/getFloors" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray<GSHFloorM*>*list = [NSArray yy_modelArrayWithClass:[GSHFloorM class] json:[responseObject valueForKey:@"floors"]];
        block(list,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//单独获取首页某房间情景
+ (NSURLSessionDataTask *)getHomeVCSceneWithFamilyId:(NSString *)familyId roomId:(NSNumber*)roomId block:(void(^)(NSArray<GSHSceneM*>*list,NSError *error))block{
    
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网
        NSArray *sceneList = [[GSHSceneDao shareSceneDao] selectSceneTableWithRoomId:roomId.stringValue];
        if (block) {
            block(sceneList,nil);
        }
        return nil;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:roomId forKey:@"roomId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"homePage/getRoomScenario" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray<GSHSceneM*>*list = [NSArray yy_modelArrayWithClass:GSHSceneM.class json:[responseObject valueForKey:@"list"]];
        if (block) block(list,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// 校验设备信息是否有更改，设备是否被删除
+ (NSURLSessionDataTask *)checkDevicesFromServerWithDeviceIdArray:(NSArray *)deviceIdArray
                                                       sceneArray:(NSArray *)sceneArray
                                                        autoArray:(NSArray *)autoArray
                                                         familyId:(NSString *)familyId
                                                            block:(void(^)(NSArray <GSHNameIdM*> *deviceArr,NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceIdArray.count>0?deviceIdArray:@[] forKey:@"deviceIdList"];
    [dic setValue:sceneArray.count>0?sceneArray:@[] forKey:@"scenarioIdList"];
    [dic setValue:autoArray.count>0?autoArray:@[] forKey:@"automationIdList"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/checkDevicesOrOperations" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *deviceArray = [NSArray yy_modelArrayWithClass:GSHNameIdM.class json:[(NSDictionary *)responseObject objectForKey:@"deviceMsgs"]];
        if (block) {
            block(deviceArray,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
    
}

// 场景模块 -- 获取执行动作设备
+(NSURLSessionDataTask *)getSceneDevicesListWithFamilyId:(NSString *)familyId
                                                  roomId:(NSString *)roomId
                                                   block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    if (roomId.length > 0) {
        [dic setValue:roomId forKey:@"roomId"];
    }
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/getScenarioDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:[(NSDictionary *)responseObject objectForKey:@"devices"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// 从oss服务端获取场景数据
+ (void)getSceneFileFromOssWithFid:(NSString *)fid
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
                        [[GSHFileManager shared] writeDataToFileWithFileType:LocalStoreFileTypeScene fileName:fid fileContent:json];
                        if (block) {
                            block(json,nil);
                        }
                    }
                }];
            }
        }
    }];
}

// v3.0新增 -- 获取所有情景模板
+ (NSURLSessionDataTask *)getSceneTemplateListWithFamilyId:(NSString *)familyId
                         isOnlyRecommend:(NSString *)isOnlyRecommend
                                   block:(void(^)(NSArray<GSHSceneTemplateM*>*list,NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:isOnlyRecommend forKey:@"isOnlyRecommend"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"scenariotpl/getScenarioTplList" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray<GSHSceneTemplateM*>*list = [NSArray yy_modelArrayWithClass:GSHSceneTemplateM.class json:responseObject];
        if (block) block(list,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
    
}

// v3.0新增 -- 获取情景模板详情
+ (NSURLSessionDataTask *)getSceneTemplateDetailWithFamilyId:(NSString *)familyId
                                             sceneTemplateId:(NSNumber *)sceneTemplateId
                                                       block:(void(^)(GSHSceneTemplateDetailInfoM *sceneTemplateDetailInfoM,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:sceneTemplateId.stringValue forKey:@"scenarioTplId"];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"scenariotpl/getScenarioTplDetail" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHSceneTemplateDetailInfoM *sceneTemplateDetailInfoM = [GSHSceneTemplateDetailInfoM yy_modelWithJSON:responseObject];
        if (block) block(sceneTemplateDetailInfoM,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// v3.0新增 -- 获取场景背景图片
+ (NSURLSessionDataTask *)getScenarioBackgroundImageListblock:(void(^)(NSArray<GSHSceneBackgroundImageM *>*list,NSError *error))block {
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"general/getScenarioBackgroupImgList" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray<GSHSceneBackgroundImageM*>*list = [NSArray yy_modelArrayWithClass:GSHSceneBackgroundImageM.class json:[(NSDictionary *)responseObject objectForKey:@"list"]];
        if (block) block(list,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

@end




