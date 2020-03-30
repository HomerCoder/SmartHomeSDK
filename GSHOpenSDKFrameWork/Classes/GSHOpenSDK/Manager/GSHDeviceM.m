//
//  GSHDeviceM.m
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDeviceM.h"
#import "GSHDeviceDao.h"
#import "GSHOpenSDKInternal.h"
#import <TZMOpenLib/NSObject+TZM.h>
#import "GSHSceneDao.h"

@implementation GSHMeteBindedInfoListM
@end

@implementation GSHSwitchMeteBindInfoModelM
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"meteBindedInfoList":[GSHMeteBindedInfoListM class]};
}
-(instancetype)init{
    self = [super init];
    if (self) {
        self.meteBindedInfoList = [NSMutableArray array];
    }
    return self;
}
@end

@implementation GSHSwitchBindM
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"switchMeteBindInfoModels":[GSHSwitchMeteBindInfoModelM class]};
}
-(instancetype)init{
    self = [super init];
    if (self) {
        self.switchMeteBindInfoModels = [NSMutableArray array];
    }
    return self;
}
@end

@implementation GSHDeviceAttributeM
@end

@implementation GSHDeviceExtM{
    NSString *_rightValue;
}
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"conditionOperator":@"operator"};
}
-(NSString *)rightValue{
    if (_rightValue.length > 0) {
        return _rightValue;
    }else{
        return _param;
    }
}

-(void)setRightValue:(NSString *)rightValue{
    _rightValue = [rightValue copy];
    _param = _rightValue;
}

@end

@implementation GSHDeviceCategoryM
@end

@implementation GSHDeviceModelM
@end

@implementation GSHDeviceTypeM

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.devices = [NSMutableArray array];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"deviceModelList":[GSHDeviceModelM class],
             @"devices":[GSHDeviceM class],
             @"exts":[GSHDeviceExtM class]
    };
}
@end

@implementation GSHDeviceKindM
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"deviceTypeList":[GSHDeviceTypeM class]};
}
@end

@implementation GSHDeviceM {
    GSHDeviceCategoryM *_categoryM;
    BOOL _isSelected;
}
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"attribute":[GSHDeviceAttributeM class],
             @"exts":[GSHDeviceExtM class]
             };
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.exts = [NSMutableArray array];
        self.attribute = [NSMutableArray array];
    }
    return self;
}

- (GSHDeviceCategoryM *)category {
    if (!_categoryM) {
        _categoryM = [GSHDeviceCategoryM new];
        _categoryM.deviceModel = self.deviceModel;
        _categoryM.deviceModelStr = self.deviceModelStr;
        _categoryM.deviceType = self.deviceType;
        _categoryM.deviceTypeStr = self.deviceTypeStr;
    }
    return _categoryM;
}

- (BOOL)isSelected {
    return _isSelected;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
}

- (NSDictionary*)realTimeDic{
    NSDictionary *dic;
    if([self.deviceType isEqualToNumber:@(254)] && self.deviceModel.integerValue < 0){
        dic = [[GSHOpenSDKInternal share].webSocketClient.realTimeDic objectForKey:self.validateCode];
    }else{
        dic = [[GSHOpenSDKInternal share].webSocketClient.realTimeDic objectForKey:self.deviceSn];
    }
    if ([dic isKindOfClass:NSDictionary.class]) {
        return dic;
    }
    return nil;
}

- (NSString *)getBaseMeteIdFromDeviceSn:(NSString *)deviceSn {
    if ([deviceSn containsString:@"_"]) {
        return [deviceSn componentsSeparatedByString:@"_"].lastObject;
    }
    return @"";
}
@end

@implementation GSHDeviceManager
//控制设备
+ (void)deviceControlWithDeviceId:(NSString *)deviceId deviceSN:(NSString *)deviceSN familyId:(NSString *)familyId basMeteId:(NSString *)basMeteId value:(NSString *)value block:(void(^)(NSError *error))block{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        [[GSHOpenSDKInternal share].webSocketClient deviceControlWithGatewayId:deviceId deviceSN:deviceSN basMeteId:basMeteId value:value block:^(NSError *error) {
            if (block) {
                block(error);
            }
        }];
    }else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:familyId forKey:@"familyId"];
        [dic setValue:deviceId forKey:@"deviceId"];
        [dic setValue:deviceSN forKey:@"deviceSn"];
        [dic setValue:basMeteId forKey:@"basMeteId"];
        [dic setValue:value forKey:@"value"];
        [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/deviceControl" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
            if (block) {
                block(nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(error);
            }
        }];
    }
}

+(NSURLSessionDataTask*)getDevicesListWithFamilyId:(NSString*)familyId block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getDeviceList" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:[responseObject valueForKey:@"list"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// v2.4 设备管理 - 获取所有设备
+(NSURLSessionDataTask*)getFamilyDevicesListWithFamilyId:(NSString*)familyId block:(void(^)(GSHGatewayM *gatewayM,GSHFamilyM *familyM,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getFamilyDeviceList" parameters:dic success:^(id operationOrTask, id responseObject) {
        GSHGatewayM *tmpGatewayM = [GSHGatewayM yy_modelWithJSON:[responseObject valueForKey:@"gatewayInfo"]];
        GSHFamilyM *tmpFamilyM = [GSHFamilyM yy_modelWithJSON:responseObject];
        if (block) {
            block(tmpGatewayM,tmpFamilyM,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,nil,error);
        }
    } useCache:NO];
}

//首页单独获取设备
+(NSURLSessionDataTask*)getHomeVCDevicesListWithFamilyId:(NSString*)familyId roomId:(NSNumber*)roomId pageIndex:(NSNumber*)pageIndex block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网
        NSArray *devices = [[GSHDeviceDao shareDeviceDao] selectDeviceTableWithRoomId:[NSString stringWithFormat:@"%@",roomId]];
        if (block) {
            block(devices,nil);
        }
        return nil;
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:familyId forKey:@"familyId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:pageIndex forKey:@"currPage"];
        [dic setValue:@(20) forKey:@"pageSize"];
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"homePage/getRoomDevice" parameters:dic success:^(id operationOrTask, id responseObject) {
            NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:[responseObject valueForKey:@"list"]];
            if (block) {
                block(list,nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(nil,error);
            }
        } useCache:NO];
    }
}

//首页设备排序
+(NSURLSessionDataTask*)postHomeVCSortDeviceRoomId:(NSNumber*)roomId globalIdList:(NSArray<NSString*>*)globalIdList block:(void(^)(NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:globalIdList forKey:@"list"];
    [dic setValue:roomId forKey:@"roomId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"homePage/sortDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

//获取房间设备与场景
+(NSURLSessionDataTask*)getFamilyDeviceAndScenariosWithFamilyId:(NSString*)familyId roomId:(NSNumber*)roomId floorId:(NSNumber*)floorId block:(void(^)(NSArray<GSHDeviceM*> *devices,NSArray<GSHSceneM*> *scenarios,NSError *error))block;{
    
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网
        if (roomId && roomId.integerValue != -1) {
            NSArray *devices = [[GSHDeviceDao shareDeviceDao] selectDeviceTableWithRoomId:[NSString stringWithFormat:@"%@",roomId]];
            NSArray *sceneList = [[GSHSceneDao shareSceneDao] selectSceneTableWithRoomId:roomId.stringValue];
            if (block) {
                block(devices,sceneList,nil);
            }
        }else{
            NSArray *devices = [[GSHDeviceDao shareDeviceDao] selectDeviceTableWithFloorId:[NSString stringWithFormat:@"%@",floorId]];
            if (block) {
                block(devices,nil,nil);
            }
        }
        return nil;
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:familyId forKey:@"familyId"];
        [dic setValue:floorId forKey:@"floorId"];
        [dic setValue:roomId forKey:@"roomId"];
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"homePage/getRoomDeviceNScenario" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSArray<GSHDeviceM*> *devices = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:[(NSDictionary *)responseObject objectForKey:@"devices"]];
            NSArray<GSHSceneM*> *scenarios = [NSArray yy_modelArrayWithClass:GSHSceneM.class json:[(NSDictionary *)responseObject objectForKey:@"scenarios"]];
            if (block) {
                block(devices,scenarios,nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (block) {
                block(nil,nil,error);
            }
        }];
    }
}

+(NSURLSessionDataTask*)postHomeVCMoveDeviceWithRoomId:(NSNumber*)roomId deviceId:(NSString*)deviceId targetDeviceId:(NSString*)targetDeviceId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:roomId forKey:@"roomId"];
    [dic setValue:deviceId forKey:@"deviceId"];
    [dic setValue:targetDeviceId forKey:@"targetDeviceId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"homePage/updateDeviceList" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

// 获取设备品类
+ (NSURLSessionDataTask *)getDeviceTypesWithBlock:(void(^)(NSArray<GSHDeviceCategoryM*> *list,NSError *error))block {
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"general/getDeviceModels" parameters:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceCategoryM.class json:[responseObject valueForKey:@"deviceModelList"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// 通过二维码获取设备信息
+ (NSURLSessionDataTask *)postDeviceModelListWithQRCode:(NSString*)qrCode block:(void(^)(NSArray<GSHDeviceModelM*> *list,NSString *sn, NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:qrCode forKey:@"str"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"general/scanQrcode" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceModelM.class json:[(NSDictionary *)responseObject objectForKey:@"deviceModels"]];
        NSString *sn = [(NSDictionary *)responseObject objectForKey:@"deviceSn"];
        if(block) block(list,sn,nil);
    } failure:^(id operationOrTask, NSError *error) {
        if(block) block(nil,nil,error);
    }];
}

// v2.4.0 获取设备品类
+ (NSURLSessionDataTask *)getSystemDeviceTemplateWithBlock:(void(^)(NSArray<GSHDeviceKindM*> *list,NSError *error))block {
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"general/getSystemDeviceTemplate" parameters:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceKindM.class json:[responseObject valueForKey:@"deviceKindList"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// 设备发现 /setting/deviceDiscovery
+ (NSURLSessionDataTask *)searchDevicesWithFamilyId:(NSString *)familyId
                                         scanStatus:(NSString *)scanStatus
                                           deviceSn:(NSString *)deviceSn
                                              block:(void(^)(NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:scanStatus forKey:@"scanStatus"];
    [dic setValue:deviceSn.length>0?deviceSn:@"" forKey:@"deviceSn"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"setting/deviceDiscovery" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
    
}

//添加设备
+ (NSURLSessionDataTask *)postAddDeviceWithFamilyId:(NSString *)familyId
                                           deviceId:(NSString *)deviceId
                                         deviceType:(NSString *)deviceType
                                             roomId:(NSString*)roomId
                                         deviceName:(NSString *)deviceName
                                          attribute:(NSArray *)attribute
                                              block:(void(^)(GSHDeviceM *device, NSError *error))block {
    // 实际调用的修改设备接口 -- 后期根据实际要求修改
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceId forKey:@"deviceId"];
    [dic setValue:deviceType forKey:@"deviceType"];
    [dic setValue:roomId forKey:@"roomId"];
    [dic setValue:deviceName forKey:@"deviceName"];
    [dic setValue:attribute forKey:@"attribute"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"/setting/updateDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKDeviceUpdataNotification object:roomId == nil ? nil : @[roomId]]];
        if (block) {
            block(nil,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//修改设备
+ (NSURLSessionDataTask *)postUpdateDeviceWithFamilyId:(NSString *)familyId deviceId:(NSString *)deviceId deviceSn:(NSString *)deviceSn deviceType:(NSString *)deviceType roomId:(NSString*)roomId newRoomId:(NSString*)newRoomId deviceName:(NSString *)deviceName attribute:(NSArray *)attribute block:(void(^)(GSHDeviceM *device,NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceId forKey:@"deviceId"];
    [dic setValue:deviceSn forKey:@"deviceSn"];
    [dic setValue:deviceType forKey:@"deviceType"];
    if (newRoomId.length > 0) {
        [dic setValue:newRoomId forKey:@"roomId"];
    }else{
        [dic setValue:roomId forKey:@"roomId"];
    }
    [dic setValue:deviceName forKey:@"deviceName"];
    [dic setValue:attribute forKey:@"attribute"];
    
    NSMutableArray *roomIdList = [NSMutableArray array];
    if (newRoomId.length > 0) {
        [roomIdList addObject: newRoomId];
    }
    if (roomId.length > 0) {
        [roomIdList addObject: roomId];
    }
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"/setting/updateDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKDeviceUpdataNotification object:roomIdList]];
        if (block) {
            block(nil,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// 删除设备
+ (NSURLSessionDataTask *)deleteDeviceWithFamilyId:(NSString *)familyId roomId:(NSString*)roomId deviceId:(NSString *)deviceId deviceSn:(NSString *)deviceSn deviceModel:(NSString *)deviceModel deviceType:(NSString *)deviceType block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceId forKey:@"deviceId"];
    [dic setValue:deviceSn forKey:@"deviceSn"];
    [dic setValue:deviceType forKey:@"deviceType"];
    [dic setValue:deviceModel forKey:@"deviceModel"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"/setting/deleteDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
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


// 获取发现的设备 /setting/getDiscoveryDevices
+ (NSURLSessionDataTask *)getDiscoveryDevicesWithFamilyId:(NSString *)familyId block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getDiscoveryDevices" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:[(NSDictionary *)responseObject objectForKey:@"deviceMsgList"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil , error);
        }
    } useCache:NO];
    
}

// 获取设备及其监控量详细信息 /setting/getDeviceInfo
+ (NSURLSessionDataTask *)getDeviceInfoWithFamilyId:(NSString *)familyId deviceId:(NSString *)deviceId deviceSign:(NSString*)deviceSign block:(void(^)(GSHDeviceM *device, NSError *error))block {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        GSHDeviceM *deviceM = [[GSHDeviceDao shareDeviceDao] selectDeviceInfoWithDeviceId:deviceId];
        if (block) {
            block(deviceM,nil);
        }
        return nil;
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:familyId forKey:@"familyId"];
        [dic setValue:deviceId forKey:@"deviceId"];
        [dic setValue:deviceSign forKey:@"deviceSign"];
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getDeviceInfo" parameters:dic success:^(id operationOrTask, id responseObject) {
            GSHDeviceM *deviceM = [GSHDeviceM yy_modelWithJSON:responseObject];
            if (block) {
                block(deviceM,nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(nil , error);
            }
        } useCache:NO];
    }
}

// 获取房间下所有开关设备
+(NSURLSessionDataTask *)getSwitchDevicesListWithroomId:(NSString *)roomId
                                                  block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:roomId forKey:@"roomId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getRoomSwitch" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceM.class json:responseObject];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
    
}

// 绑定多控开关关联关系
+(NSURLSessionDataTask *)bindMultiControlWithDeviceId:(NSString *)deviceId
                                             deviceSn:(NSString *)deviceSn
                                            basMeteId:(NSString *)basMeteId
                                          relDeviceId:(NSString *)relDeviceId
                                          relDeviceSn:(NSString *)relDeviceSn
                                         relBasMeteId:(NSString *)relBasMeteId
                                                block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:deviceId forKey:@"deviceId"];
    [dic setObject:deviceSn forKey:@"deviceSN"];
    [dic setObject:basMeteId forKey:@"basMeteId"];
    [dic setObject:relDeviceId forKey:@"relDeviceId"];
    [dic setObject:relBasMeteId forKey:@"relBasMeteId"];
    [dic setObject:relDeviceSn forKey:@"relDeviceSN"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"setting/bindMultControl" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

// 场景面板 -- 解绑 /operation/unbindScenarioBoard
+ (NSURLSessionDataTask *)unbindScenarioBoardWithFamilyId:(NSString *)familyId basMeteId:(NSString *)basMeteId deviceId:(NSString *)deviceId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:deviceId forKey:@"deviceId"];
    [dic setObject:basMeteId forKey:@"basMeteId"];
    [dic setObject:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"operation/unbindScenarioBoard" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

// APP查询设备绑定详情
+ (NSURLSessionDataTask *)getDeviceBIndInfoWithDeviceId:(NSString *)deviceId block:(void(^)(GSHSwitchBindM *switchBindM,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceId forKey:@"deviceId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getDeviceBindInfo" parameters:dic success:^(id operationOrTask, id responseObject) {
        GSHSwitchBindM *switchBindM = [GSHSwitchBindM yy_modelWithJSON:responseObject];
        if (block) {
            block(switchBindM,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// 解绑多控开关关联关系
+ (NSURLSessionDataTask *)unBindMultiControlWithDeviceId:(NSString *)deviceId deviceSn:(NSString *)deviceSn basMeteId:(NSString *)basMeteId relDeviceId:(NSString *)relDeviceId relDeviceSn:(NSString *)relDeviceSn relBasMeteId:(NSString *)relBasMeteId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceId forKey:@"deviceId"];
    [dic setValue:deviceSn forKey:@"deviceSN"];
    [dic setValue:basMeteId forKey:@"basMeteId"];
    [dic setValue:relDeviceId forKey:@"relDeviceId"];
    [dic setValue:relBasMeteId forKey:@"relBasMeteId"];
    [dic setValue:relDeviceSn forKey:@"relDeviceSN"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"setting/unbindMultControl" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

#pragma mark--声必可
+ (NSURLSessionDataTask *)addIpcDeviceWithFamilyId:(NSString *)familyId ipcName:(NSString *)ipcName ipcModel:(NSString *)ipcModel modelName:(NSString *)modelName areaId:(NSString *)areaId deviceSerial:(NSString *)deviceSerial firmwareVersion:(NSString *)firmwareVersion block:(void(^)(NSError *error))block{
    // 实际调用的修改设备接口 -- 后期根据实际要求修改
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:ipcName forKey:@"ipcName"];
    [dic setValue:ipcModel forKey:@"ipcModel"];
    [dic setValue:modelName forKey:@"modelName"];
    [dic setValue:areaId forKey:@"areaId"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:firmwareVersion forKey:@"firmwareVersion"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"setting/addIpcDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKDeviceUpdataNotification object:areaId == nil ? nil : @[areaId]]];
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

+ (NSURLSessionDataTask *)updateIpcDeviceWithIpcId:(NSString *)ipcId familyId:(NSString *)familyId ipcName:(NSString *)ipcName areaId:(NSString *)areaId newAreaId:(NSString *)newAreaId firmwareVersion:(NSString *)firmwareVersion block:(void(^)(NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:ipcId forKey:@"ipcId"];
    [dic setValue:ipcName forKey:@"ipcName"];
    [dic setValue:newAreaId forKey:@"areaId"];
    [dic setValue:firmwareVersion forKey:@"firmwareVersion"];
    [dic setValue:familyId forKey:@"familyId"];
    
    NSMutableArray *roomIdList = [NSMutableArray array];
    if (newAreaId.length > 0) {
        [roomIdList addObject:newAreaId];
    }
    if (areaId.length > 0) {
        [roomIdList addObject: areaId];
    }
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"setting/updateIpcDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
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

+ (NSURLSessionDataTask *)deleteIpcDeviceWithFamilyId:(NSString *)familyId ipcId:(NSString *)ipcId areaId:(NSString *)areaId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:ipcId forKey:@"ipcId"];
    [dic setValue:areaId forKey:@"areaId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/deleteIpcDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKDeviceUpdataNotification object:areaId == nil ? nil : @[areaId]]];
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
