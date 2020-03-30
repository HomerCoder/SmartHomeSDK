//
//  GSHInfraredControllerM.m
//  SmartHome
//
//  Created by gemdale on 2019/2/21.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHInfraredControllerManager.h"
#import "GSHOpenSDKInternal.h"
#import <YYCategories.h>
#import "GSHFamilyM.h"

@implementation GSHKuKongDeviceTypeM
@end

@implementation GSHKuKongBrandM
-(BOOL)isSP{
    return self.spId == nil ? NO : YES;
}
@end

@implementation GSHKuKongBrandListM
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"dataList":[GSHKuKongBrandM class]};
}
@end

@interface GSHKuKongRemoteM()
@end
@implementation GSHKuKongRemoteM{
    KKZipACManager *_airConditionerManager;
}
-(void)setAirConditionerManager:(KKZipACManager *)manager{
    _airConditionerManager = manager;
}

-(KKZipACManager *)airConditionerManager{
    return _airConditionerManager;
}

+ (NSURLSessionDataTask *)getKuKongDeviceIrDataWithDeviceSn:(NSString*)deviceSn fileUrl:(NSString*)fileUrl fid:(NSString*)fid remoteId:(NSNumber*)remoteId block:(void(^)(KKZipACManager *manager, NSError *error))block{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",fileUrl,fid];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([response isKindOfClass:NSHTTPURLResponse.class]) {
            if (((NSHTTPURLResponse*)response).statusCode != 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block(nil,error);
                    }
                });
            }else{
                NSDictionary *dic = [NSMutableDictionary dictionaryWithXML:data];
                NSMutableDictionary * mutDict1=[[NSMutableDictionary alloc] init];
                NSMutableDictionary * mutDict2=[[NSMutableDictionary alloc] init];
                id exts = [[[dic valueForKey:@"remote_controller"] valueForKey:@"exts"] valueForKey:@"ext"];
                if ([exts isKindOfClass:NSArray.class]) {
                    for (NSDictionary *dic in exts) {
                        if ([dic isKindOfClass:NSDictionary.class]) {
                            NSString *tag = [dic valueForKey:@"tag"];
                            NSString *value = [dic valueForKey:@"value"];
                            if (tag.length > 0 && value.length > 0) {
                                [mutDict1 setValue:value forKey:tag];
                            }
                        }
                    }
                }
                [mutDict2 setValue:mutDict1 forKey:@"exts"];
                
                id frequency = [[dic valueForKey:@"remote_controller"] valueForKey:@"frequency"];
                if ([frequency isKindOfClass:NSString.class]) {
                    [mutDict2 setValue:frequency forKey:@"fre"];
                }
                id rid = [[dic valueForKey:@"remote_controller"] valueForKey:@"id"];
                if ([frequency isKindOfClass:NSString.class]) {
                    [mutDict2 setValue:rid forKey:@"rid"];
                }
                id type = [[dic valueForKey:@"remote_controller"] valueForKey:@"type"];
                if ([type isKindOfClass:NSString.class]) {
                    [mutDict2 setValue:type forKey:@"type"];
                }
                [mutDict2 setValue:[[NSArray alloc] init] forKey:@"keys"];
                
                KKZipACManager *manager;
                if (deviceSn.length > 0) {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSArray *arr = [userDefaults objectForKey:deviceSn];
                    manager = [[KKZipACManager alloc]initWithRemoteId:remoteId.stringValue irData:mutDict2 modeStateValue:arr];
                }else{
                    manager = [[KKZipACManager alloc]initWithRemoteId:remoteId.stringValue irData:mutDict2 modeStateValue:nil];
                    [manager changePowerStateWithPowerstate:AC_POWER_OFF];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block(manager, nil);
                    }
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(nil, error);
                }
            });
        }
    }];
    [task resume];
    return task;
}

@end

@implementation GSHKuKongInfraredDeviceM
@end

@implementation GSHKuKongInfraredTryKeyM : GSHBaseModel
@end

@implementation GSHInfraredControllerManager

+ (void)initKuKongSDKWithUserAuthority:(NSString*)userAuthority{
    [[KookongSDK shareKooKongSDK] setKKSDKScheme:YES];
    [[KookongSDK shareKooKongSDK] checkUserAuthority:userAuthority deviceId:@""];
}

// 获取红外设备下的虚拟遥控列表
+ (NSURLSessionDataTask *)getKuKongDeviceListWithParentDeviceId:(NSNumber*)parentDeviceId familyId:(NSString*)familyId kkDeviceType:(NSNumber*)kkDeviceType deviceSn:(NSString*)deviceSn block:(void(^)(NSArray<GSHKuKongInfraredDeviceM*> *list, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:parentDeviceId forKey:@"parentDeviceId"];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:kkDeviceType forKey:@"kkDeviceType"];
    [dic setValue:deviceSn forKey:@"deviceSn"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"kk/getInfraredDevicesByPId" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHKuKongInfraredDeviceM.class json:[(NSDictionary *)responseObject objectForKey:@"list"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// 获取类型列表
+ (NSURLSessionDataTask *)getKuKongDeviceTypeListWithBlock:(void(^)(NSArray<GSHKuKongDeviceTypeM*> *list,NSNumber *version, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"kk/getDeviceTypeList" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list;
        NSNumber *version;
        if ([responseObject isKindOfClass:NSDictionary.class]) {
            NSDictionary *dic = responseObject;
            version = [dic numverValueForKey:@"version" default:nil];
            NSArray *array = [dic objectForKey:@"deviceTypeList"];
            if ([array isKindOfClass:NSArray.class]) {
                list = [NSArray yy_modelArrayWithClass:GSHKuKongDeviceTypeM.class json:array];
            }
            
        }
        if (block) {
            block(list,version,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,nil,error);
        }
    }];
}

// 获取品牌列表（机顶盒包括运营商）
+ (NSURLSessionDataTask *)getKuKongBrandListWithDeviceType:(NSNumber*)devicetypeId block:(void(^)(NSMutableArray<GSHKuKongBrandListM*> *list, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (devicetypeId.integerValue == 1) {
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"kk/getSpList" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
            NSMutableArray *list = [NSMutableArray array];
            if ([responseObject isKindOfClass:NSDictionary.class]) {
                NSDictionary *dic = responseObject;
                
                NSArray *ipList = [dic objectForKey:@"iptvBrandDataList"];
                if ([ipList isKindOfClass:NSArray.class]) {
                    NSArray *arr = [NSArray yy_modelArrayWithClass:GSHKuKongBrandM.class json:ipList];
                    GSHKuKongBrandListM *brandList = [GSHKuKongBrandListM new];
                    brandList.dataList = arr;
                    brandList.pyCh = @"IPTV";
                    [list addObject:brandList];
                }
                
                NSArray *spList = [dic objectForKey:@"spDataList"];
                if ([spList isKindOfClass:NSArray.class]) {
                    NSArray *arr = [NSArray yy_modelArrayWithClass:GSHKuKongBrandListM.class json:spList];
                    [list addObjectsFromArray:arr];
                }
            }
            if (block) {
                block(list,nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(nil,error);
            }
        }];
    }else{
        [dic setValue:devicetypeId forKey:@"deviceType"];
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"kk/getBrandListByDeviceType" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
            NSMutableArray *list;
            if ([responseObject isKindOfClass:NSArray.class]) {
                list = [[NSArray yy_modelArrayWithClass:GSHKuKongBrandListM.class json:responseObject] mutableCopy];
            }
            if (block) {
                block(list,nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(nil,error);
            }
        }];
    }
}

// 获取遥控列表（机顶盒包括运营商）
+ (NSURLSessionDataTask *)getKuKongRemoteListWithDeviceType:(NSNumber*)devicetypeId brand:(GSHKuKongBrandM*)brand block:(void(^)(NSMutableArray<GSHKuKongRemoteM*> *list, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (brand.isSP) {
        [dic setValue:brand.spId forKey:@"spId"];
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"kk/getRemoteListBySp" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
            NSMutableArray *list;
            if ([responseObject isKindOfClass:NSDictionary.class]) {
                NSArray *array = [(NSDictionary*)responseObject objectForKey:@"list"];
                if ([array isKindOfClass:NSArray.class]) {
                    list = [[NSArray yy_modelArrayWithClass:GSHKuKongRemoteM.class json:array] mutableCopy];
                }
            }
            if (block) {
                block(list,nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(nil,error);
            }
        }];
    } else {
        [dic setValue:devicetypeId forKey:@"devicetypeId"];
        [dic setValue:brand.brandId forKey:@"brandId"];
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"kk/getRemoteListByDeviceTypeNBrand" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
            NSMutableArray *list;
            if ([responseObject isKindOfClass:NSDictionary.class]) {
                NSArray *array = [(NSDictionary*)responseObject objectForKey:@"list"];
                if ([array isKindOfClass:NSArray.class]) {
                    list = [[NSArray yy_modelArrayWithClass:GSHKuKongRemoteM.class json:array] mutableCopy];
                }
            }
            if (block) {
                block(list,nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(nil,error);
            }
        }];
    }
}

// 用户获取酷控对码按键
+ (NSURLSessionDataTask *)getKuKongModuleTryKeysWithDeviceType:(NSNumber*)devicetypeId block:(void(^)(NSArray<GSHKuKongInfraredTryKeyM*> *keyList, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:devicetypeId forKey:@"devicetypeId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"kk/getModuleTryKeys" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSMutableArray *list;
        if ([responseObject isKindOfClass:NSArray.class]) {
            list = [[NSArray yy_modelArrayWithClass:GSHKuKongInfraredTryKeyM.class json:responseObject] mutableCopy];
        }
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// 用户对码
+ (NSURLSessionDataTask *)postKuKongModuleVerifyWithRemoteId:(NSNumber*)remoteId deviceSN:(NSString*)deviceSN familyId:(NSString*)familyId operType:(NSInteger)operType deviceTypeId:(NSNumber*)deviceTypeId remoteParam:(NSString*)remoteParam keyParam:(NSString*)keyParam keyId:(NSNumber*)keyId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:remoteId forKey:@"remoteId"];
    [dic setValue:deviceSN forKey:@"deviceSn"];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:@(operType) forKey:@"operType"];
    [dic setValue:deviceTypeId forKey:@"deviceTypeId"];
    [dic setValue:remoteParam forKey:@"remoteParam"];
    [dic setValue:keyParam forKey:@"keyParam"];
    [dic setValue:keyId forKey:@"keyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"kk/remoteControl" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

// 用户获取酷控遥控器按键模板
+ (NSURLSessionDataTask *)getKuKongModulePanelKeysWithDeviceType:(NSNumber*)devicetypeId block:(void(^)(NSString *keyString, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:devicetypeId forKey:@"devicetypeId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"kk/getModulePanelKeys" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(responseObject,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// 保存红外设备
+ (NSURLSessionDataTask *)postSaveInfraredDeviceWithFamilyId:(NSString*)familyId deviceSn:(NSString*)deviceSn deviceId:(NSNumber*)parentDeviceId deviceBrand:(NSNumber*)deviceBrand deviceType:(NSNumber*)deviceType remoteId:(NSNumber*)remoteId deviceName:(NSString*)deviceName roomId:(NSNumber*)roomId remoteParam:(NSString*)remoteParam block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:parentDeviceId forKey:@"parentDeviceId"];
    [dic setValue:deviceBrand forKey:@"deviceBrand"];
    [dic setValue:deviceType forKey:@"deviceType"];
    [dic setValue:remoteId forKey:@"remoteId"];
    [dic setValue:deviceName forKey:@"deviceName"];
    [dic setValue:roomId forKey:@"roomId"];
    [dic setValue:deviceSn forKey:@"parentDeviceSn"];
    [dic setValue:remoteParam forKey:@"remoteParam"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"kk/saveInfraredDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKDeviceUpdataNotification object:roomId == nil ? nil : @[roomId.stringValue]]];
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

// 更新红外设备
+ (NSURLSessionDataTask *)postUpdateInfraredDeviceWithFamilyId:(NSString*)familyId deviceSn:(NSString*)deviceSn bindRemoteId:(NSNumber*)bindRemoteId deviceName:(NSString*)deviceName roomId:(NSNumber*)roomId newRoomId:(NSNumber*)newRoomId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceName forKey:@"deviceName"];
    [dic setValue:deviceSn forKey:@"deviceSn"];
    [dic setValue:bindRemoteId forKey:@"bindRemoteId"];
    
    if (newRoomId.stringValue.length > 0) {
        [dic setValue:newRoomId forKey:@"roomId"];
    }else{
        [dic setValue:roomId forKey:@"roomId"];
    }
    NSMutableArray *roomIdList = [NSMutableArray array];
    if (newRoomId.stringValue.length > 0) {
        [roomIdList addObject:newRoomId.stringValue];
    }
    if (roomId.stringValue.length > 0) {
        [roomIdList addObject:roomId.stringValue];
    }
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"kk/updateInfraredDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKDeviceUpdataNotification object:roomIdList]];
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

// 解绑红外设备
+ (NSURLSessionDataTask *)postUpdateInfraredDeviceWithFamilyId:(NSString*)familyId deviceSn:(NSString*)deviceSn deviceName:(NSString*)deviceName roomId:(NSNumber*)roomId newRoomId:(NSNumber*)newRoomId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceName forKey:@"deviceName"];
    [dic setValue:deviceSn forKey:@"deviceSn"];
    [dic setValue:@(1) forKey:@"isUnbind"];
    if (newRoomId.stringValue.length > 0) {
        [dic setValue:newRoomId forKey:@"roomId"];
    }else{
        [dic setValue:roomId forKey:@"roomId"];
    }
    NSMutableArray *roomIdList = [NSMutableArray array];
    if (newRoomId.stringValue.length > 0) {
        [roomIdList addObject:newRoomId.stringValue];
    }
    if (roomId.stringValue.length > 0) {
        [roomIdList addObject:roomId.stringValue];
    }
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"kk/updateInfraredDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKDeviceUpdataNotification object:roomIdList]];
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

// 删除红外设备
+ (NSURLSessionDataTask *)postDeleteInfraredDeviceWithDeviceSn:(NSString*)deviceSn roomId:(NSString*)roomId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSn forKey:@"deviceSn"];
    [dic setValue:[GSHOpenSDKShare share].currentFamily.familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"kk/delInfraredDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKDeviceUpdataNotification object:roomId == nil ? nil : @[roomId]]];
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

@end
