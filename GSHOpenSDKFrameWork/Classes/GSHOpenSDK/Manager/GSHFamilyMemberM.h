//
//  GSHFamilyMemberM.h
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"
#import "GSHFloorM.h"

@interface GSHFamilyMemberM : GSHBaseModel
@property(nonatomic,copy)NSString *childUserId;             //成员userId
@property(nonatomic,copy)NSString *familyId;                //家庭Id
@property(nonatomic,copy)NSString *childUserName;           //成员名字
@property(nonatomic,copy)NSString *childUserPhone;          //成员手机号码
@property(nonatomic,copy)NSString *childUserPicPath;        //成员头像
@property(nonatomic,strong)NSMutableArray<GSHFloorM*> *floor;   //权限信息
//获取该成员所有有权限设备
-(NSArray<GSHDeviceM*>*)getDeviceList;
@end

@interface GSHFamilyMemberManager : NSObject
//获取每个家庭的成员（这里的member不带成员信息）
+(NSURLSessionDataTask*)getFamilyMemberListWithFamilyId:(NSString*)familyId block:(void(^)(NSArray<GSHFamilyMemberM*>*list,NSError *error))block;

//获取成员详情（这里的member带floor）
+(NSURLSessionDataTask*)getFamilyMemberWithFamilyId:(NSString*)familyId memberId:(NSString*)memberId block:(void(^)(GSHFamilyMemberM *member,NSError *error))block;

//添加成员
+(NSURLSessionDataTask*)postAddFamilyMemberWithFamilyId:(NSString*)familyId userId:(NSString*)userId floorList:(NSArray<GSHFloorM*>*)floorList block:(void(^)(GSHFamilyMemberM *member,NSError *error))block;

//修改某个成员权限信息
+(NSURLSessionDataTask*)postUpdateFamilyMemberWithFamilyId:(NSString*)familyId childUserId:(NSString*)childUserId floorList:(NSArray<GSHFloorM*>*)floorList block:(void(^)(NSError *error))block;

//解绑用户和家庭的绑定
+(NSURLSessionDataTask*)postDeleteFamilyMemberWithFamilyId:(NSString*)familyId childUserId:(NSString*)childUserId block:(void(^)(NSError *error))block;
@end
