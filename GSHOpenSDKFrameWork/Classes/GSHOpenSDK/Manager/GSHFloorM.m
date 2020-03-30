//
//  GSHFloorM.m
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFloorM.h"
#import "GSHOpenSDKInternal.h"
#import "GSHFloorDao.h"
#import "GSHRoomDao.h"
#import "GSHDeviceDao.h"
#import "GSHFamilyM.h"

@interface GSHFloorM()
@end
@implementation GSHFloorM{
    GSHFloorMAuthorityType _authorityType;
}

-(GSHFloorMAuthorityType)authorityType{
    return _authorityType;
}

- (void)setAuthorityType:(GSHFloorMAuthorityType)authorityType{
    _authorityType = authorityType;
    if (authorityType == GSHFloorMAuthorityTypeAll) {
        for (GSHRoomM *room in self.rooms) {
            room.authorityType = GSHRoomMAuthorityTypeAll;
            for (GSHDeviceM *device in room.devices) {
                device.permissionState = @(1);
            }
        }
    }else if (authorityType == GSHFloorMAuthorityTypeSome){
        
    }else{
        for (GSHRoomM *room in self.rooms) {
            room.authorityType = GSHRoomMAuthorityTypeNothing;
            for (GSHDeviceM *device in room.devices) {
                device.permissionState = @(0);
            }
        }
    }
}

-(void)refreshAuthority{
    NSUInteger roomHaveNoRight = 0;
    NSUInteger roomHaveRight = 0;
    BOOL isSome = NO;
    for (GSHRoomM *room in self.rooms) {
        if (room.authorityType == GSHRoomMAuthorityTypeSome) {
            isSome = YES;
            break;
        }else if (room.authorityType == GSHRoomMAuthorityTypeAll) {
            roomHaveRight++;
        }else{
            roomHaveNoRight++;
        }
    }
    //根据房间权限个数设置楼层权限
    if (isSome) {
        self.authorityType = GSHFloorMAuthorityTypeSome;
    }else if (roomHaveRight > 0) {
        self.authorityType = roomHaveNoRight > 0 ? GSHFloorMAuthorityTypeSome : GSHFloorMAuthorityTypeAll;
    }else{
        self.authorityType = GSHFloorMAuthorityTypeNothing;
    }
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.rooms = [NSMutableArray array];
        self.floorName = @"";
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"rooms":[GSHRoomM class],
             @"sensorMsgList":[GSHSensorM class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"rooms":@[@"rooms",@"room"]};
}
@end

@implementation GSHFloorManager
+(NSURLSessionDataTask*)getHomeVCFloorListWithFamilyId:(NSString*)familyId flag:(NSNumber*)flag block:(void(^)(NSArray<GSHFloorM*> *floorList,NSError *error,NSString *gatewayId,NSString *onlineStatus,NSInteger familyDeviceCount))block{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网
        NSArray *floors = [[GSHFloorDao shareFloorDao] selectFloorTableWithFamilyId:familyId];
        for (GSHFloorM *floorM in floors) {
            NSArray *rooms = [[GSHRoomDao shareRoomDao] selectRoomTableWithFloorId:[NSString stringWithFormat:@"%@",floorM.floorId]];
            if (rooms.count > 0) {
                floorM.rooms = [NSMutableArray arrayWithArray:rooms];
            }
        }
        if (familyId) {
            if ([[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
                [GSHOpenSDKShare share].currentFamily.floor = [NSMutableArray arrayWithArray:floors];
            }
        }
        if (block) {
            // 返回websocket在线状态 -- 标示网关在线状态
            NSString *onlineStatus = [GSHWebSocketClient shared].isConnect ? @"1" : @"0";
            block(floors,nil,[GSHOpenSDKShare share].currentFamily.gatewayId,onlineStatus,-1);
        }
        return nil;
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:familyId forKey:@"familyId"];
        [dic setValue:flag forKey:@"flag"];
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"homePage/getRoomManagement" parameters:dic success:^(id operationOrTask, id responseObject) {
            NSArray *list = [NSArray yy_modelArrayWithClass:GSHFloorM.class json:[responseObject valueForKey:@"floors"]];
            NSString *gatewayId = [responseObject valueForKey:@"gatewayId"] ? [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"gatewayId"]] : nil;
            NSString *onlineStatus = [responseObject valueForKey:@"onlineStatus"] ? [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"onlineStatus"]] : nil;
            NSString *familyDeviceCount = [responseObject valueForKey:@"familyDeviceCount"] ? [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"familyDeviceCount"]] : nil;
            if (familyId) {
                if ([[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
                    [GSHOpenSDKShare share].currentFamily.floor = [NSMutableArray arrayWithArray:list];
                    if (onlineStatus) [GSHOpenSDKShare share].currentFamily.onlineStatus = onlineStatus.integerValue;
                    if (gatewayId) [GSHOpenSDKShare share].currentFamily.gatewayId = gatewayId;
                }
            }
            if (block) {
                block(list,nil,gatewayId,onlineStatus,familyDeviceCount.integerValue);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(nil,error,nil,nil,-1);
            }
        } useCache:YES];
    }
}

//获取楼层列表
+(NSURLSessionDataTask*)getFloorListWithFamilyId:(NSString*)familyId block:(void(^)(NSArray<GSHFloorM*> *floorList,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"familyInfo/getRoomManagement" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHFloorM.class json:[responseObject valueForKey:@"floors"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:YES];
}

//增加楼层信息
+(NSURLSessionDataTask*)postAddFloorWithFamilyId:(NSString*)familyId floorName:(NSString*)floorName block:(void(^)(GSHFloorM *floor, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:floorName forKey:@"floorName"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/addFloorMessage" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHFloorM *floor = [GSHFloorM yy_modelWithJSON:responseObject];
        if (familyId && [[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
            if (floor) {
                [[GSHOpenSDKShare share].currentFamily.floor addObject:floor];
                [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyUpdataNotification object:nil]];
            }
        }
        if (block) {
            block([GSHFloorM yy_modelWithJSON:responseObject],nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//修改楼层信息
+(NSURLSessionDataTask*)postUpdateFloorWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId floorName:(NSString*)floorName block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:floorId forKey:@"floorId"];
    [dic setValue:floorName forKey:@"floorName"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/updateFloorMessage" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (familyId && floorId && [[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
            GSHFloorM *f = [[GSHOpenSDKShare share].currentFamily getFloorWithFloorId:floorId];
            f.floorName = floorName;
            [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyUpdataNotification object:nil]];
        }
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

//删除楼层信息
+(NSURLSessionDataTask*)postDeleteFloorWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId block:(void(^)(NSError *error))block{
    if (!floorId) {
        if (block) {
            block([NSError errorWithDomain:GSHHTTPAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"参数错误"}]);
        }
        return nil;
    }
    return [self postDeleteFloorWithFamilyId:familyId floorIdList:@[floorId] block:block];
}

//批量删除楼层信息
+(NSURLSessionDataTask*)postDeleteFloorWithFamilyId:(NSString*)familyId floorIdList:(NSArray<NSNumber*>*)floorIdList block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:floorIdList forKey:@"floorIds"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/deleteFloorMessage" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (familyId && [[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
            for (NSNumber *floorId in floorIdList) {
                GSHFloorM *f = [[GSHOpenSDKShare share].currentFamily getFloorWithFloorId:floorId];
                [[GSHOpenSDKShare share].currentFamily.floor removeObject:f];
            }
        }
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyUpdataNotification object:nil]];
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

//更新楼层排序信息
+(NSURLSessionDataTask*)postUpdataRoomRankWithRoomList:(NSArray<GSHRoomM*>*)roomList familyId:(NSString*)familyId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    NSMutableArray<NSString*> *roomIdList = [NSMutableArray array];
    for (GSHRoomM *room in roomList) {
        [roomIdList addObject:room.roomId.stringValue];
    }
    [dic setValue:[roomIdList componentsJoinedByString:@","] forKey:@"roomIds"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/setRoomRank" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
