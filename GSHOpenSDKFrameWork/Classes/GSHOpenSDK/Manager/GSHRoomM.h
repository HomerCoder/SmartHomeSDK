//
//  GSHRoomM.h
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"
#import "GSHDeviceM.h"
#import "GSHSceneM.h"

//房间权限
typedef enum : NSUInteger {
    GSHRoomMAuthorityTypeNothing,//该房间没有一个设备权限
    GSHRoomMAuthorityTypeAll,//该房间拥有所有设备权限
    GSHRoomMAuthorityTypeSome,//该房间拥有部分设备权限
} GSHRoomMAuthorityType;

@interface GSHRoomM : GSHBaseModel
@property(nonatomic,strong)NSNumber *roomId;            //房间id
@property(nonatomic,strong)NSNumber *deviceCount;       //设备数
@property(nonatomic,strong)NSNumber *onlineDeviceCount; //在线设备数
@property(nonatomic,copy)NSString *roomName;            //房间名字
@property(nonatomic,copy)NSString *backgroundId;        //背景id
@property(nonatomic,strong)NSMutableArray<GSHDeviceM*> *devices;    //设备数组
@property(nonatomic,strong)NSMutableArray<GSHSceneM*> *scenarios;   //房间部分场景

//通过背景Id获取背景图片
+(UIImage*)getBackgroundImageWithId:(int)backgroundId;
//房间权限信息，通过devices的权限计算得出
-(GSHRoomMAuthorityType)authorityType;
-(void)setAuthorityType:(GSHRoomMAuthorityType)authorityType;
//刷新房间权限信息，devices中设备权限发生改变时需要调用此方法来刷新房间权限
-(void)refreshAuthority;

@end

@interface GSHRoomManager : NSObject
//增加房间信息
+(NSURLSessionDataTask*)postAddRoomWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId roomName:(NSString*)roomName roomBg:(NSString*)roomBg block:(void(^)(GSHRoomM *room, NSError *error))block;

//修改房间信息
+(NSURLSessionDataTask*)postUpdateRoomWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId roomId:(NSNumber*)roomId roomName:(NSString*)roomName roomBg:(NSString*)roomBg block:(void(^)(NSError *error))block;

//删除房间信息
+(NSURLSessionDataTask*)postDeleteRoomWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId roomId:(NSNumber*)roomId block:(void(^)(NSError *error))block;
@end
