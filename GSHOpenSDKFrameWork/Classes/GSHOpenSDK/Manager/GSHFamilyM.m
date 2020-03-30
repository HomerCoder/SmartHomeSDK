//
//  GSHFamilyM.m
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFamilyM.h"
#import "GSHOpenSDKInternal.h"
#import "GSHAutoM.h"
#import "GSHFloorM.h"
#import "GSHFamilyMemberM.h"
#import "GSHFamilyDao.h"
#import "GSHFloorDao.h"
#import "GSHRoomDao.h"
#import "GSHDeviceDao.h"
#import "GSHSceneDao.h"
#import "GSHAutoDao.h"
#import "GSHSensorDao.h"

@implementation GSHPrecinctM
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"childPrecincts":[GSHPrecinctM class]};
}
@end

@interface GSHFamilyM()
@end
@implementation GSHFamilyM{
}
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"members":[GSHFamilyMemberM class],
             @"floor":[GSHFloorM class]
             };
}
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"floor":@[@"floors",@"floor"]};
}
-(instancetype)init{
    self = [super init];
    if (self) {
        self.members = [NSMutableArray array];
        self.floor = [NSMutableArray array];
        self.onlineStatus = -1;
    }
    return self;
}
-(NSArray<GSHFloorM *> *)filterFloor{
    NSMutableArray *array = [NSMutableArray array];
    for (GSHFloorM *floor in self.floor) {
        if (floor.rooms.count > 0) {
            [array addObject:floor];
        }
    }
    return array;
}
-(void)copyCommonData:(GSHFamilyM*)family {
    self.familyName = family.familyName;
    self.picPath = family.picPath;
    self.address = family.address;
    self.projectName = family.projectName;
    self.project = family.project;
}
//获取家庭下某个楼层
-(GSHFloorM*)getFloorWithFloorId:(NSNumber*)floorId{
    if (floorId) {
        for (GSHFloorM *f in self.floor) {
            if ([f.floorId isEqualToNumber:floorId]) {
                return f;
            }
        }
    }
    return nil;
}
//获取家庭下某个房间
-(GSHRoomM*)getRoomWithRoomId:(NSNumber*)roomId{
    if (roomId) {
        for (GSHFloorM *f in self.floor) {
            for (GSHRoomM *r in f.rooms) {
                if ([r.roomId isEqualToNumber:roomId]) {
                    return r;
                }
            }
        }
    }
    return nil;
}
@end

@implementation GSHFamilyManager

//获取用户家庭指数
+(NSURLSessionDataTask*)getFamilyIndexWithFamilyId:(NSString*)familyId block:(void(^)(NSDictionary *familyIndex,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"homePage/getFamilyIndex" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block && [responseObject isKindOfClass:NSDictionary.class]) {
            block(responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask*)getFamilyListWithblock:(void(^)(NSArray<GSHFamilyM*> *familyList,NSError *error))block {
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"familyInfo/getFamilyList" parameters:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHFamilyM.class json:[(NSDictionary *)responseObject objectForKey:@"list"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

+(NSURLSessionDataTask*)getHomeVCFamilyListWithblock:(void(^)(NSArray<GSHFamilyM*> *familyList,NSError *error))block{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网
        NSArray *families = [[GSHFamilyDao shareFamilyDao] selectFamilyTableAllRecord];
        if (block) {
            block(families,nil);
        }
        return nil;
    } else {
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"homePage/getFamilyList" parameters:nil success:^(id operationOrTask, id responseObject) {
            NSArray *list = [NSArray yy_modelArrayWithClass:GSHFamilyM.class json:[(NSDictionary *)responseObject objectForKey:@"list"]];
            if (list) {
                [GSHOpenSDKShare share].familyList = [NSMutableArray arrayWithArray:list];
            }else{
                [GSHOpenSDKShare share].familyList = nil;
            }
            if (block) {
                block([GSHOpenSDKShare share].familyList,nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(nil,error);
            }
        } useCache:YES];
    }
}

+(NSURLSessionDataTask*)postHomeVCChangeFamilyWithFamilyId:(NSString*)familyId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"homePage/updateCurrentFamilyId" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil);
        }
    }];
}

+(NSURLSessionDataTask*)postSetFamilyWithFamilyName:(NSString*)familyName familyPic:(NSString*)familyPic project:(NSString*)project address:(NSString*)address block:(void(^)(GSHFamilyM *family,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyName forKey:@"familyName"];
    [dic setValue:familyPic forKey:@"picPath"];
    [dic setValue:project forKey:@"project"];
    [dic setValue:address forKey:@"address"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/setFamilyInfo" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHFamilyM *family = [GSHFamilyM yy_modelWithJSON:responseObject];
        if (family) {
            [[GSHOpenSDKShare share].familyList addObject:family];
        }
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyListUpdataNotification object:family]];
        if (block) {
            block(family,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+(NSURLSessionDataTask*)postUpdateFamilyWithFamilyId:(NSString*)familyId familyName:(NSString*)familyName familyPic:(NSString*)familyPic project:(NSString*)project projectName:(NSString*)projectName address:(NSString*)address block:(void(^)(GSHFamilyM *family,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:familyName forKey:@"familyName"];
    [dic setValue:familyPic forKey:@"picPath"];
    [dic setValue:project forKey:@"project"];
    [dic setValue:address forKey:@"address"];
    [dic setValue:projectName forKey:@"projectName"];
    GSHFamilyM *family = [GSHFamilyM yy_modelWithJSON:dic];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/updateFamilyInfo" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (family.familyId) {
            if ([[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:family.familyId]) {
                [[GSHOpenSDKShare share].currentFamily copyCommonData:family];
                [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyUpdataNotification object:family]];
            }
            for (GSHFamilyM *f in [GSHOpenSDKShare share].familyList) {
                if (f.familyId) {
                    if ([family.familyId isEqualToString:f.familyId]) {
                        [f copyCommonData:family];
                        break;
                    }
                }
            }
        }
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyListUpdataNotification object:family]];
        if (block) {
            block(family,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+(NSURLSessionDataTask*)postDeleteFamilyWithFamilyId:(NSString*)familyId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/deleteFamilyList" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (familyId) {
            for (int i = (int)[GSHOpenSDKShare share].familyList.count - 1; i >= 0; i--) {
                GSHFamilyM *f = [GSHOpenSDKShare share].familyList[i];
                if ([f.familyId isEqualToString:familyId]) {
                    [[GSHOpenSDKShare share].familyList removeObjectAtIndex:i];
                    break;
                }
            }
        }
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyListUpdataNotification object:nil]];
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

+(NSURLSessionDataTask*)postTransferFamilyWithFamilyId:(NSString*)familyId childUserId:(NSString*)childUserId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:childUserId forKey:@"childUserId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/transferFamily" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

//获取家庭下所有信息：楼层，房间，设备（切换离线模式的时候需要拉取信息）
+(NSURLSessionDataTask *)getAllInfoFromFamilyWithFamilyId:(NSString *)familyId
                                                    block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getAllDeviceInfoV2" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray *automationList = [NSArray yy_modelArrayWithClass:GSHOssAutoM.class json:[(NSDictionary *)[(NSDictionary *)responseObject objectForKey:@"automations"] objectForKey:@"automationList"]];
        GSHFamilyM *familyM = [GSHFamilyM yy_modelWithJSON:[(NSDictionary *)responseObject objectForKey:@"offlineFamilyRoomsBo"]];
        NSArray *scenarios = [NSArray yy_modelArrayWithClass:GSHOssSceneM.class json:[(NSDictionary *)[(NSDictionary *)responseObject objectForKey:@"scenarioRank"] objectForKey:@"scenarios"]];
        NSArray *sensorList = [NSArray yy_modelArrayWithClass:GSHSensorM.class json:[(NSDictionary *)responseObject objectForKey:@"sensorList"]];
        
        [[GSHFamilyDao shareFamilyDao] deleteAllFamilyInfo];
        [[GSHFloorDao shareFloorDao] deleteAllFloorInfo];
        [[GSHRoomDao shareRoomDao] deleteAllRoomInfo];
        [[GSHDeviceDao shareDeviceDao] deleteAllDeviceInfo];

        [[GSHFamilyDao shareFamilyDao] insertFamilyTableRecordWithModel:familyM];
        for (GSHFloorM *floorM in familyM.floor) {
            [[GSHFloorDao shareFloorDao] insertFloorTableRecordWithModel:floorM familyId:familyM.familyId];
            for (GSHRoomM *roomM in floorM.rooms) {
                [[GSHRoomDao shareRoomDao] insertRoomTableRecordWithModel:roomM floorId:[NSString stringWithFormat:@"%@",floorM.floorId]];
                for (GSHDeviceM *deviceM in roomM.devices) {
                    deviceM.floorId = floorM.floorId;
                    [[GSHDeviceDao shareDeviceDao] insertDeviceTableRecordWithModel:deviceM];
                }
            }
        }

        // 场景
        [[GSHSceneDao shareSceneDao] deleteAllSceneInfo];
        for (GSHOssSceneM *ossSceneM in scenarios) {
            [[GSHSceneDao shareSceneDao] insertSceneTableRecordWithModel:ossSceneM];
        }

        // 联动
        [[GSHAutoDao shareAutoDao] deleteAllAutoInfo];
        for (GSHOssAutoM *ossAutoM in automationList) {
            [[GSHAutoDao shareAutoDao] insertAutoTableRecordWithModel:ossAutoM familyId:familyId];
        }

        // 传感器
        [[GSHSensorDao shareSensorDao] deleteAllSensorInfo];
        for (GSHSensorM *sensorM in sensorList) {
            [[GSHSensorDao shareSensorDao] insertSensorTableRecordWithModel:sensorM];
        }
        
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    } useCache:YES];
}

+(NSURLSessionDataTask*)getAllDevicesWithFamilyId:(NSString*)familyId block:(void(^)(NSArray<GSHFloorM*> *list,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getAllDevices" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHFloorM.class json:[responseObject valueForKey:@"floors"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

+(NSURLSessionDataTask*)getPrecinctListWithblock:(void(^)(NSArray<GSHPrecinctM*> *precinctList,NSError *error))block{
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"familyInfo/getPrecinctList" parameters:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHPrecinctM.class json:[(NSDictionary *)responseObject objectForKey:@"list"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:YES];
}

//绑定别名
+(NSURLSessionDataTask*)postBindFamilyWithFamilyId:(NSString*)familyId aliasName:(NSString*)aliasName mhomeName:(NSString*)mhomeName block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:aliasName forKey:@"mhomeId"];
    [dic setValue:mhomeName forKey:@"mhomeName"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"link/bindFamily" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

//解绑别名
+(NSURLSessionDataTask*)postUnBindFamilyWithFamilyId:(NSString*)familyId aliasName:(NSString*)aliasName block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:aliasName forKey:@"mhomeId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"link/cancelBinding" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

//通过别名获取family
+(NSURLSessionDataTask*)postFamilyWithAliasName:(NSString*)aliasName block:(void(^)(NSError *error,GSHFamilyM *family))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:aliasName forKey:@"mhomeId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"link/family" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHFamilyM *family = [GSHFamilyM yy_modelWithJSON:responseObject];
        if (block) {
            block(nil,family);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error,nil);
        }
    }];
}

//第三方获取familylist
+(NSURLSessionDataTask*)postThirdpPartyFamilyListWithBlock:(void(^)(NSError *error,NSArray<GSHFamilyM*> *list))block{
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"link/familyList" parameters:nil progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHFamilyM.class json:responseObject];
        if (block) {
            block(nil,list);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error,nil);
        }
    }];
}

@end
