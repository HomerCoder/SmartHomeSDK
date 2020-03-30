//
//  GSHRoomM.m
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHRoomM.h"
#import "GSHOpenSDKInternal.h"
#import "GSHFamilyM.h"
#import "GSHFloorM.h"
#import "GSHDeviceDao.h"
#import "GSHSceneDao.h"

@interface GSHRoomM()
@end

@implementation GSHRoomM{
    GSHRoomMAuthorityType _authorityType;
}
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"devices":[GSHDeviceM class],
             @"scenarios":[GSHSceneM class]
             };
}
+(UIImage*)getBackgroundImageWithId:(int)backgroundId{
    return [UIImage ZHImageNamed:[NSString stringWithFormat:@"room_bg_%d",backgroundId + 1]];
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.scenarios = [NSMutableArray array];
        self.devices = [NSMutableArray array];
    }
    return self;
}

-(GSHRoomMAuthorityType)authorityType{
    return _authorityType;
}
- (void)setAuthorityType:(GSHRoomMAuthorityType)authorityType{
    _authorityType = authorityType;
    if (authorityType == GSHRoomMAuthorityTypeAll) {
        for (GSHDeviceM *device in self.devices) {
            device.permissionState = @(1);
        }
    }else if (authorityType == GSHRoomMAuthorityTypeSome){
        
    }else{
        for (GSHDeviceM *device in self.devices) {
            device.permissionState = @(0);
        }
    }
}
-(void)refreshAuthority{
    NSUInteger deviceHaveNoRight = 0;
    NSUInteger deviceHaveRight = 0;
    for (GSHDeviceM *device in self.devices) {
        if (device.permissionState.integerValue != 0) {
            deviceHaveRight++;
        }else{
            deviceHaveNoRight++;
        }
    }
    //根据房间权限个数设置楼层权限
    if (deviceHaveRight > 0) {
        self.authorityType = deviceHaveNoRight > 0 ? GSHRoomMAuthorityTypeSome : GSHRoomMAuthorityTypeAll;
    }else{
        self.authorityType = GSHRoomMAuthorityTypeNothing;
    }
}

@end

@implementation GSHRoomManager
//增加房间信息
+(NSURLSessionDataTask*)postAddRoomWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId roomName:(NSString*)roomName roomBg:(NSString*)roomBg block:(void(^)(GSHRoomM *room, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:floorId forKey:@"floorId"];
    [dic setValue:roomName forKey:@"roomName"];
    [dic setValue:roomBg forKey:@"backgroundId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/addRoomMessage" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHRoomM *room = [GSHRoomM yy_modelWithJSON:responseObject];
        if (familyId && floorId && [[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
            if (room) {
                GSHFloorM *f = [[GSHOpenSDKShare share].currentFamily getFloorWithFloorId:floorId];
                [f.rooms addObject:room];
                [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyUpdataNotification object:nil]];
            }
        }
        if (block) {
            block([GSHRoomM yy_modelWithJSON:responseObject],nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//修改房间信息
+(NSURLSessionDataTask*)postUpdateRoomWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId roomId:(NSNumber*)roomId roomName:(NSString*)roomName roomBg:(NSString*)roomBg block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:floorId forKey:@"floorId"];
    [dic setValue:roomId forKey:@"roomId"];
    [dic setValue:roomName forKey:@"roomName"];
    [dic setValue:roomBg forKey:@"backgroundId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/updateRoomMessage" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (familyId && roomId && [[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
            GSHRoomM *room = nil;
            BOOL remove = NO;
            for (GSHFloorM *f in [GSHOpenSDKShare share].currentFamily.floor) {
                for (GSHRoomM *r in f.rooms) {
                    if ([r.roomId isEqualToNumber:roomId]) {
                        room = r;
                        if (floorId && ![f.floorId isEqualToNumber:floorId]) {
                            [f.rooms removeObject:r];
                            remove = YES;
                            break;
                        }
                    }
                }
                if (room) {
                    break;
                }
            }
            if (remove) {
                GSHFloorM *floor = [[GSHOpenSDKShare share].currentFamily getFloorWithFloorId:floorId];
                [floor.rooms addObject:room];
            }
            room.roomName = roomName;
            room.backgroundId = roomBg;
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

//删除房间信息
+(NSURLSessionDataTask*)postDeleteRoomWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId roomId:(NSNumber*)roomId block:(void(^)(NSError *error))block{
    if (!floorId) {
        if (block) {
            block([NSError errorWithDomain:GSHHTTPAPIErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"参数错误"}]);
        }
        return nil;
    }
    return [self postDeleteRoomWithFamilyId:familyId floorId:floorId roomIdList:@[roomId] block:block];
}

+(NSURLSessionDataTask*)postDeleteRoomWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId roomIdList:(NSArray<NSNumber*>*)roomIdList block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:floorId forKey:@"floorId"];
    [dic setValue:roomIdList forKey:@"roomIds"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"familyInfo/deleteRoomMessage" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (familyId && floorId && [[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
            GSHFloorM *f = [[GSHOpenSDKShare share].currentFamily getFloorWithFloorId:floorId];
            for (NSNumber *roomId in roomIdList) {
                GSHRoomM *r = [[GSHOpenSDKShare share].currentFamily getRoomWithRoomId:roomId];
                [f.rooms removeObject:r];
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

@end
