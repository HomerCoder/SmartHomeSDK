//
//  GSHFamilyMemberM.m
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFamilyMemberM.h"
#import "GSHOpenSDKInternal.h"

@implementation GSHFamilyMemberM
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"floor":[GSHFloorM class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"floor":@[@"floors",@"floor"]};
}

-(NSArray<GSHDeviceM*>*)getDeviceList{
    NSMutableArray *deviceList = [NSMutableArray array];
    for (GSHFloorM *floor in self.floor) {
        for (GSHRoomM *room in floor.rooms) {
            for (GSHDeviceM *device in room.devices) {
                if (device.permissionState.integerValue != 0) {
                    [deviceList addObject:device];
                }
            }
        }
    }
    return deviceList;
}
@end

@implementation GSHFamilyMemberManager
//获取每个家庭的成员
+(NSURLSessionDataTask*)getFamilyMemberListWithFamilyId:(NSString*)familyId block:(void(^)(NSArray<GSHFamilyMemberM*>*list,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"members/getChildUsers" parameters:dic success:^(id operationOrTask, id responseObject) {
        if (block) {
            NSArray<GSHFamilyMemberM*>*list = [NSArray yy_modelArrayWithClass:GSHFamilyMemberM.class json:[(NSDictionary *)responseObject objectForKey:@"list"]];
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:YES];
}

//获取成员详情（这里的member带floor）
+(NSURLSessionDataTask*)getFamilyMemberWithFamilyId:(NSString*)familyId memberId:(NSString*)memberId block:(void(^)(GSHFamilyMemberM *member,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:memberId forKey:@"childUserId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"members/getChildFamily" parameters:dic success:^(id operationOrTask, id responseObject) {
        if (block) {
            GSHFamilyMemberM *member = [GSHFamilyMemberM yy_modelWithJSON:responseObject];
            for (GSHFloorM *floor in member.floor) {
                int permissionRoomCount = 0;
                BOOL permissionRoomSame = NO;  //此楼层是不是有部分授权的房间
                for (GSHRoomM *room in floor.rooms) {
                    int permissionDeviceCount = 0;
                    for (GSHDeviceM *device in room.devices) {
                        if (device.permissionState.integerValue != 0) {
                            permissionDeviceCount++;
                        }
                    }
                    if (permissionDeviceCount == 0) {
                        room.authorityType = GSHRoomMAuthorityTypeNothing;
                    }else if(permissionDeviceCount == room.devices.count){
                        room.authorityType = GSHRoomMAuthorityTypeAll;
                        permissionRoomCount++;
                    }else{
                        room.authorityType = GSHRoomMAuthorityTypeSome;
                        permissionRoomSame = YES;
                    }
                }
                if (permissionRoomSame) {
                    floor.authorityType = GSHFloorMAuthorityTypeSome;
                }else{
                    if (permissionRoomCount == 0) {
                        floor.authorityType = GSHFloorMAuthorityTypeNothing;
                    }else if(permissionRoomCount == floor.rooms.count){
                        floor.authorityType = GSHFloorMAuthorityTypeAll;
                    }else{
                        floor.authorityType = GSHFloorMAuthorityTypeSome;
                    }
                }
            }
            block(member,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:YES];
}

//添加某个成员
+(NSURLSessionDataTask*)postAddFamilyMemberWithFamilyId:(NSString*)familyId userId:(NSString*)userId floorList:(NSArray<GSHFloorM*>*)floorList block:(void(^)(GSHFamilyMemberM *member,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:userId forKey:@"childUserId"];
    for (GSHFloorM *floor in floorList) {
        for (GSHRoomM *room in floor.rooms) {
            for (GSHDeviceM *device in room.devices) {
                device.attribute = nil;
                device.exts = nil;
            }
        }
    }
    [dic setValue:[floorList yy_modelToJSONObject] forKey:@"floorList"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"members/setChildFamily" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            GSHFamilyMemberM *member = [GSHFamilyMemberM yy_modelWithJSON:responseObject];
            block(member,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//修改某个成员
+(NSURLSessionDataTask*)postUpdateFamilyMemberWithFamilyId:(NSString*)familyId childUserId:(NSString*)childUserId floorList:(NSArray<GSHFloorM*>*)floorList block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:childUserId forKey:@"childUserId"];
    for (GSHFloorM *floor in floorList) {
        for (GSHRoomM *room in floor.rooms) {
            for (GSHDeviceM *device in room.devices) {
                device.attribute = nil;
                device.exts = nil;
            }
            room.scenarios = nil;
        }
    }
    [dic setValue:[floorList yy_modelToJSONObject] forKey:@"floorList"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"members/updateChildFamily" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

//解绑用户和家庭的绑定
+(NSURLSessionDataTask*)postDeleteFamilyMemberWithFamilyId:(NSString*)familyId childUserId:(NSString*)childUserId block:(void(^)(NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:childUserId forKey:@"childUserId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"members/deleteChildUser" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
