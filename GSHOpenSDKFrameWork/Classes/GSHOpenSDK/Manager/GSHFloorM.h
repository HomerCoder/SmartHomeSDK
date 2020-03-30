//
//  GSHFloorM.h
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"
#import "GSHRoomM.h"
#import "GSHSensorM.h"

//楼层权限
typedef enum : NSUInteger {
    GSHFloorMAuthorityTypeNothing,  //该楼层没有一个设备权限
    GSHFloorMAuthorityTypeAll,      //该楼层拥有所有设备权限
    GSHFloorMAuthorityTypeSome,     //该楼层拥有部分设备权限
} GSHFloorMAuthorityType;

@interface GSHFloorM : GSHBaseModel
@property(nonatomic,strong)NSNumber *floorId;                           //楼层Id
@property(nonatomic,copy)NSString *floorName;                           //楼层名字
@property(nonatomic,strong)NSNumber *floorDeviceCount;                  //楼层设备数量
@property(nonatomic,strong)NSMutableArray<GSHRoomM*> *rooms;            //楼层所属房间
@property(nonatomic,strong)NSMutableArray<GSHSensorM*> *sensorMsgList;  //传感器列表
//楼层权限信息，通过房间的权限计算得出
-(void)setAuthorityType:(GSHFloorMAuthorityType)authorityType;
-(GSHFloorMAuthorityType)authorityType;
//刷新楼层权限信息，房间权限发生改变时需要调用此方法来刷新楼层权限
-(void)refreshAuthority;
@end

@interface GSHFloorManager : NSObject
//首页单独获取楼层房间信息
+(NSURLSessionDataTask*)getHomeVCFloorListWithFamilyId:(NSString*)familyId flag:(NSNumber*)flag block:(void(^)(NSArray<GSHFloorM*> *floorList,NSError *error,NSString *gatewayId,NSString *onlineStatus,NSInteger familyDeviceCount))block;

//获取楼层房间信息
+(NSURLSessionDataTask*)getFloorListWithFamilyId:(NSString*)familyId block:(void(^)(NSArray<GSHFloorM*> *floorList,NSError *error))block;

//增加楼层信息
+(NSURLSessionDataTask*)postAddFloorWithFamilyId:(NSString*)familyId floorName:(NSString*)floorName block:(void(^)(GSHFloorM *floor, NSError *error))block;

//修改楼层信息
+(NSURLSessionDataTask*)postUpdateFloorWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId floorName:(NSString*)floorName block:(void(^)(NSError *error))block;

//删除楼层信息
+(NSURLSessionDataTask*)postDeleteFloorWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId block:(void(^)(NSError *error))block;

//更新楼层房间排序信息
+(NSURLSessionDataTask*)postUpdataRoomRankWithRoomList:(NSArray<GSHRoomM*>*)roomList familyId:(NSString*)familyId block:(void(^)(NSError *error))block;
@end
