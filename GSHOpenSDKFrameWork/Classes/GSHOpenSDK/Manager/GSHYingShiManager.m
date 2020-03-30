//
//  GSHYingShiCameraM.m
//  SmartHome
//
//  Created by gemdale on 2018/7/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiManager.h"
#import <YYCategories.h>
#import "GSHOpenSDKInternal.h"
#import "GSHFamilyM.h"

NSString *const GSHYingShiManagerAccessToken = @"GSHYingShiManagerAccessToken";

@implementation GSHYingShiGaoJingM
-(NSDate *)alarmTimeDate{
    if (!_alarmTimeDate) {
        _alarmTimeDate = [NSDate dateWithTimeIntervalSince1970:self.alarmTime * 1.0 / 1000];
    }
    return _alarmTimeDate;
}

-(NSString *)dateDay{
    if (_dateDay.length == 0) {
        if ([self.alarmTimeDate isToday]) {
            _dateDay = [self.alarmTimeDate stringWithFormat:@"今天 EEEE" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }else if ([[self.alarmTimeDate dateByAddingDays:1] isToday]){
            _dateDay = [self.alarmTimeDate stringWithFormat:@"昨天 EEEE" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }else if ([[self.alarmTimeDate dateByAddingDays:2] isToday]){
            _dateDay = [self.alarmTimeDate stringWithFormat:@"前天 EEEE" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }else{
            _dateDay = [self.alarmTimeDate stringWithFormat:@"yyyy年M月d日 EEEE" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        }
    }
    return _dateDay;
}

-(NSString *)startTime{
    if (_startTime.length == 0) {
        _startTime = [self.alarmTimeDate stringWithFormat:@"HH:mm:ss"];
    }
    return _startTime;
}
@end

@implementation GSHYingShiCameraDefenceM
@end

@implementation GSHYingShiGaoJingGroupM
@end

@implementation GSHYingShiManager
static NSString *EZOpenSDKAppKey;
static NSString *EZOpenSDKAccessToken;
+(void)initEZOpenSDK:(NSString*)appkey{
    @try {
        EZOpenSDKAppKey = appkey;
        [EZOpenSDK initLibWithAppKey:appkey];
        [EZOpenSDK enableP2P:YES];
        NSString *yingShiToken = [[NSUserDefaults standardUserDefaults] objectForKey:GSHYingShiManagerAccessToken];
        if ([yingShiToken isKindOfClass:NSString.class] && yingShiToken.length > 0) {
            [EZOpenSDK setAccessToken:yingShiToken];
            EZOpenSDKAccessToken = yingShiToken;
        }
        [GSHYingShiManager updataAccessTokenWithBlock:NULL];
    } @catch (NSException *exception) {
    } @finally {
    }
}

+(NSURLSessionDataTask *)updataAccessTokenWithBlock:(void(^)(NSString *token,NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAppKey forKey:@"appKey"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"app/getAccessToken" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSString *accessToken = [responseObject valueForKey:@"accessToken"];
        if ([accessToken isKindOfClass:NSString.class]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:accessToken forKey:GSHYingShiManagerAccessToken];
            [userDefaults synchronize];
            [EZOpenSDK setAccessToken:accessToken];
            EZOpenSDKAccessToken = accessToken;
            if (block) {
                block(accessToken,nil);
            }
        }else{
            if (block) {
                block(nil,nil);
            }
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+(NSURLSessionDataTask *)postAddDeviceWithIpcName:(NSString *)ipcName familyId:(NSString *)familyId ipcModel:(NSString *)ipcModel areaId:(NSString *)areaId validateCode:(NSString*)validateCode deviceSerial:(NSString *)deviceSerial modelName:(NSString*)modelName block:(void(^)(GSHDeviceM *device, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:ipcName forKey:@"ipcName"];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:ipcModel forKey:@"ipcModel"];
    [dic setValue:areaId forKey:@"areaId"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:validateCode forKey:@"validateCode"];
    [dic setValue:modelName forKey:@"modelName"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/addDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if ([[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
            [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKDeviceUpdataNotification object:areaId == nil ? nil : @[areaId]]];
        }
        if (block) {
            block(nil,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (error.code == 10002) {
            [GSHYingShiManager updataAccessTokenWithBlock:NULL];
        }
        if (block) {
            block(nil,error);
        }
    }];
}

+(NSURLSessionDataTask *)postDeleteDeviceWithDeviceSerial:(NSString *)deviceSerial deviceId:(NSString*)deviceId areaId:(NSString*)areaId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:deviceId forKey:@"ipcId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/deleteDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
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

+(NSURLSessionDataTask *)postUpdateDeviceWithIpcName:(NSString *)ipcName deviceSerial:(NSString *)deviceSerial areaId:(NSString *)areaId newAreaId:(NSString *)newAreaId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:ipcName forKey:@"ipcName"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    if (newAreaId.length > 0) {
        [dic setValue:newAreaId forKey:@"areaId"];
    }else{
        [dic setValue:areaId forKey:@"areaId"];
    }
    
    NSMutableArray *roomIdList = [NSMutableArray array];
    if (newAreaId.length > 0) {
        [roomIdList addObject:newAreaId];
    }
    if (areaId.length > 0) {
        [roomIdList addObject:areaId];
    }
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/updateDevice" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
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

+(NSURLSessionDataTask *)getDefencePlanWithDeviceSerial:(NSString *)deviceSerial channelNo:(NSInteger)channelNo block:(void(^)(GSHYingShiCameraDefenceM *model,NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:@(channelNo) forKey:@"channelNo"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"app/getDefencePlan" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        GSHYingShiCameraDefenceM *model = [GSHYingShiCameraDefenceM yy_modelWithJSON:responseObject];
        if (block) {
            block(model,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+(NSURLSessionDataTask *)postDefencePlanWithDeviceSerial:(NSString *)deviceSerial startTime:(NSString*)startTime stopTime:(NSString*)stopTime period:(NSString*)period channelNo:(NSInteger)channelNo defenceEnable:(BOOL)defenceEnable block:(void(^)(NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:startTime forKey:@"startTime"];
    [dic setValue:stopTime forKey:@"stopTime"];
    [dic setValue:period forKey:@"period"];
    [dic setValue:@(channelNo) forKey:@"channelNo"];
    if (defenceEnable) {
        [dic setValue:@(1) forKey:@"defenceEnable"];
    }else{
        [dic setValue:@(0) forKey:@"defenceEnable"];
    }
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/setDefencePlan" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

+(NSURLSessionDataTask *)getIsDeviceAddableWithDeviceSerial:(NSString *)deviceSerial modelName:(NSString *)modelName familyId:(NSString*)familyId block:(void(^)(NSDictionary *data, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:modelName forKey:@"modelName"];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"app/isDeviceAddable" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSDictionary *data = nil;
        if ([responseObject isKindOfClass:NSDictionary.class]) {
            data = responseObject;
        }
        if (block) {
            block(data,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+(NSURLSessionDataTask *)getIPCStatusWithDeviceSerial:(NSString *)deviceSerial block:(void(^)(NSDictionary *data, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"app/getIPCStatus" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSDictionary *data = nil;
        if ([responseObject isKindOfClass:NSDictionary.class]) {
            data = responseObject;
        }
        if (block) {
            block(data,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+(NSURLSessionDataTask *)getDeviceOnlineStatusByRoom:(NSNumber *)roomId block:(void(^)(NSArray<NSDictionary*> *data, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:roomId forKey:@"areaId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"app/getDeviceOnlineStatusByRoom" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *data = nil;
        if ([responseObject isKindOfClass:NSArray.class]) {
            if ([((NSArray*)responseObject).firstObject isKindOfClass:NSDictionary.class]) {
                data = responseObject;
            }
        }
        if (block) {
            block(data,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//布撤防
+(NSURLSessionDataTask *)postDefenceWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:on ? @(1) : @(0) forKey:@"isDefence"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/setDefence" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}
//设置设备移动跟踪开关
+(NSURLSessionDataTask *)postDeviceMobileStatusWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:on ? @(1) : @(0) forKey:@"mobileStatus"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/setDeviceMobileStatus" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}
//设置消息免打扰
+(NSURLSessionDataTask *)postDisturbStateWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:on ? @(1) : @(0) forKey:@"disturbState"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/setDisturbState" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}
//设置镜头遮蔽开关
+(NSURLSessionDataTask *)postSceneSwitchStatusWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:on ? @(1) : @(0) forKey:@"sceneSwitchStatus"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/setSceneSwitchStatus" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}
//设置全天录像开关
+(NSURLSessionDataTask *)postFulldaySwitchStatusWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:on ? @(1) : @(0) forKey:@"fulldaySwitchStatus"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/setFulldaySwitchStatus" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}
//设置告警声音模式
+(NSURLSessionDataTask *)postAlarmSoundModeWithDeviceSerial:(NSString *)deviceSerial mode:(GSHYingShiCameraMAlarmSoundMode)mode block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:@(mode) forKey:@"alarmSoundMode"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/setAlarmSoundMode" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

//设置告警声音模式
+(NSURLSessionDataTask *)postPickUpCallingWithAlarmId:(NSString *)alarmId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:alarmId forKey:@"alarmId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/pickUpCalling" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}
// 获取摄像头信息
+(NSURLSessionDataTask *)getIPCInfoWithDeviceSerial:(NSString *)deviceSerial block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"app/getIPCInfo" parameters:dic success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    } useCache:NO];
}


+(NSURLSessionDataTask *)getAlarmListWithDeviceSerial:(NSString *)deviceSeriale alarmType:(GSHYingShiGaoJingMAlarmType)type alarmTime:(NSNumber*)alarmTime startTime:(NSNumber*)startTime endTime:(NSNumber*)endTime block:(void(^)(NSArray<GSHYingShiGaoJingM*> *list, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSeriale forKey:@"deviceSerial"];
    [dic setValue:@(20) forKey:@"pageSize"];
    [dic setValue:alarmTime forKey:@"alarmTime"];
    [dic setValue:startTime forKey:@"startTime"];
    [dic setValue:endTime forKey:@"endTime"];
    switch (type) {
        case GSHYingShiGaoJingMAlarmTypeYiDong:
            [dic setValue:@"motiondetect" forKey:@"alarmType"];
            break;
        case GSHYingShiGaoJingMAlarmTypeRenTiGanYing:
            [dic setValue:@"pir" forKey:@"alarmType"];
            break;
        case GSHYingShiGaoJingMAlarmTypeDoorbell:
            [dic setValue:@"calling" forKey:@"alarmType"];
            break;
        default:
            break;
    }
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"app/getAlarmList" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHYingShiGaoJingM.class json:responseObject];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+(NSURLSessionDataTask *)getCollectAlarmListWithDeviceSerial:(NSString *)deviceSerial alarmType:(GSHYingShiGaoJingMAlarmType)type alarmTime:(NSNumber*)alarmTime block:(void(^)(NSArray<GSHYingShiGaoJingM*> *list, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:@(20) forKey:@"pageSize"];
    [dic setValue:alarmTime forKey:@"alarmTime"];
    switch (type) {
        case GSHYingShiGaoJingMAlarmTypeYiDong:
            [dic setValue:@"motiondetect" forKey:@"alarmType"];
            break;
        case GSHYingShiGaoJingMAlarmTypeRenTiGanYing:
            [dic setValue:@"pir" forKey:@"alarmType"];
            break;
        case GSHYingShiGaoJingMAlarmTypeDoorbell:
            [dic setValue:@"calling" forKey:@"alarmType"];
            break;
        default:
            break;
    }
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"app/getCollectAlarmList" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHYingShiGaoJingM.class json:responseObject];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+(NSURLSessionDataTask *)postAlarmReadWithAlarmIdList:(NSArray<NSString *>*)alarmIdList block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:alarmIdList forKey:@"alarmIdList"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/checkedAlarm" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

+(NSURLSessionDataTask *)postCollectAlarmWithAlarmIdList:(NSArray<NSString *>*)alarmIdList block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:alarmIdList.firstObject forKey:@"alarmId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/collectAlarm" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

+(NSURLSessionDataTask *)postDeleteAlarmWithAlarmIdList:(NSArray<NSString *>*)alarmIdList deleteFlag:(NSNumber*)deleteFlag block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:alarmIdList forKey:@"alarmIdList"];
    [dic setValue:deleteFlag forKey:@"deleteFlag"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/deleteAlarm" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

+(NSURLSessionDataTask *)postUncollectAlarmWithAlarmIdList:(NSArray<NSString *>*)alarmIdList block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:alarmIdList.firstObject forKey:@"alarmId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/uncollectAlarm" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

// 设置告警消息免打扰
+(NSURLSessionDataTask *)postAlarmPushConfigWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on familyId:(NSString*)familyId block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:on ? @(1) : @(0) forKey:@"alarmPush"];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/setAlarmPushConfig" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

// 设置猫眼门铃免打扰
+(NSURLSessionDataTask *)postCallingPushConfigWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on familyId:(NSString*)familyId block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:on ? @(1) : @(0) forKey:@"callingPush"];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/setCallingPushConfig" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

// 检查摄像头是否支持AP配网
+(NSURLSessionDataTask *)getCheckAPAvailableWithModelName:(NSString *)modelName block:(void(^)(id responseObject, NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:modelName forKey:@"modelName"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"app/checkAPAvailable" parameters:dic success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// 设置全天录像开关
+(NSURLSessionDataTask *)postSetFulldaySwitchStatusWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:EZOpenSDKAccessToken forKey:@"accessToken"];
    [dic setValue:deviceSerial forKey:@"deviceSerial"];
    [dic setValue:on ? @(1) : @(0) forKey:@"fulldaySwitchStatus"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"app/setFulldaySwitchStatus" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
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
