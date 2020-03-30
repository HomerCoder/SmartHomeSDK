//
//  GSHFamilyM.h
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"

//该用户在该家庭的身份
typedef enum : NSUInteger {
    GSHFamilyMPermissionsManager = 0,//管理员
    GSHFamilyMPermissionsMember,//成员
} GSHFamilyMPermissions;
//当前家庭网关状态
typedef enum : NSInteger {
    GSHFamilyMGWStatusOffLine = 0,  //离线
    GSHFamilyMGWStatusOnLine = 1,   //在线
    GSHFamilyMGWStatusChange = 2,   //替换中
    GSHFamilyMGWStatusNoNetwork = 10,   //未连接
} GSHFamilyMGWStatus;

@class GSHFloorM,GSHFamilyMemberM,GSHRoomM;

//区域类，新建家庭时需要标识该家庭属于哪个区域
@interface GSHPrecinctM : GSHBaseModel
@property (nonatomic,copy)NSString *precinctName;   //区域名
@property (nonatomic,strong)NSNumber *precinctId;   //区域Id
@property (nonatomic,strong)NSNumber *upPrecinctId; //上一级区域Id
@property (nonatomic,strong)NSMutableArray<GSHPrecinctM*> *childPrecincts;  //子区域列表
@end

@interface GSHFamilyM : GSHBaseModel
@property (nonatomic,copy)NSString *familyId;       //家庭Id
@property (nonatomic,copy)NSString *familyName;     //家庭名字
@property (nonatomic,copy)NSString *address;        //家庭地址
@property (nonatomic,copy)NSString *gatewayId;      //网关Id
@property (nonatomic,copy)NSString *projectName;    //项目名
@property (nonatomic,copy)NSString *picPath;        //家庭头像
@property (nonatomic,copy)NSString *mhomeId;       //绑定别名
@property (nonatomic,strong)NSNumber *project;      //项目Id
@property (nonatomic,strong)NSNumber *deviceCount;  //设备总数
@property (nonatomic,strong)NSNumber *familyDevcieCount;  // 家庭设备总数
@property (nonatomic,strong)NSNumber *familyFloorCount;  // 楼层数量
@property (nonatomic,assign)GSHFamilyMPermissions permissions;  //权限
@property (nonatomic,assign)GSHFamilyMGWStatus onlineStatus;    //网关状态
@property (nonatomic,strong)NSMutableArray<GSHFloorM*> *floor;  //房间楼层信息
@property (nonatomic,strong)NSMutableArray<GSHFamilyMemberM*> *members; //成员信息
//复制familyName，picPath，address，projectName，project等信息
-(void)copyCommonData:(GSHFamilyM*)family;
//过滤掉没有房间的楼层
-(NSArray<GSHFloorM *> *)filterFloor;
//获取家庭下某个楼层
-(GSHFloorM*)getFloorWithFloorId:(NSNumber*)floorId;
//获取家庭下某个房间
-(GSHRoomM*)getRoomWithRoomId:(NSNumber*)roomId;
@end

@interface GSHFamilyManager : NSObject
//获取用户家庭指数
+(NSURLSessionDataTask*)getFamilyIndexWithFamilyId:(NSString*)familyId block:(void(^)(NSDictionary *familyIndex,NSError *error))block;

//获取用户家庭列表（首页专用）
+(NSURLSessionDataTask*)getHomeVCFamilyListWithblock:(void(^)(NSArray<GSHFamilyM*> *familyList,NSError *error))block;

//获取当前用户家庭列表 （我的家庭列表中获取列表）
+(NSURLSessionDataTask*)getFamilyListWithblock:(void(^)(NSArray<GSHFamilyM*> *familyList,NSError *error))block;

//家庭用户切换默认家庭，在登录后会返回这个ID
+(NSURLSessionDataTask*)postHomeVCChangeFamilyWithFamilyId:(NSString*)familyId block:(void(^)(NSError *error))block;

//获取当前支持智能家居的项目
+(NSURLSessionDataTask*)getPrecinctListWithblock:(void(^)(NSArray<GSHPrecinctM*> *precinctList,NSError *error))block;

//添加家庭
+(NSURLSessionDataTask*)postSetFamilyWithFamilyName:(NSString*)familyName familyPic:(NSString*)familyPic project:(NSString*)project address:(NSString*)address block:(void(^)(GSHFamilyM *family,NSError *error))block;

//修改家庭信息
+(NSURLSessionDataTask*)postUpdateFamilyWithFamilyId:(NSString*)familyId familyName:(NSString*)familyName familyPic:(NSString*)familyPic project:(NSString*)project projectName:(NSString*)projectName address:(NSString*)address block:(void(^)(GSHFamilyM *family,NSError *error))block;

//删除当前家庭
+(NSURLSessionDataTask*)postDeleteFamilyWithFamilyId:(NSString*)familyId block:(void(^)(NSError *error))block;

//转移管理权限
+(NSURLSessionDataTask*)postTransferFamilyWithFamilyId:(NSString*)familyId childUserId:(NSString*)childUserId block:(void(^)(NSError *error))block;

//获取家庭下所有信息：楼层，房间，设备（切换离线模式的时候需要拉取信息）
+(NSURLSessionDataTask *)getAllInfoFromFamilyWithFamilyId:(NSString *)familyId block:(void(^)(NSError *error))block;

//获取所有设备(有房间信息)（获取该家庭有权限的所有设备，无权限设备不会返回）
+(NSURLSessionDataTask*)getAllDevicesWithFamilyId:(NSString*)familyId block:(void(^)(NSArray<GSHFloorM*> *list,NSError *error))block;

//绑定别名
+(NSURLSessionDataTask*)postBindFamilyWithFamilyId:(NSString*)familyId aliasName:(NSString*)aliasName mhomeName:(NSString*)mhomeName block:(void(^)(NSError *error))block;

//解绑别名
+(NSURLSessionDataTask*)postUnBindFamilyWithFamilyId:(NSString*)familyId aliasName:(NSString*)aliasName block:(void(^)(NSError *error))block;

//通过别名获取family
+(NSURLSessionDataTask*)postFamilyWithAliasName:(NSString*)aliasName block:(void(^)(NSError *error,GSHFamilyM *family))block;

//第三方获取familylist
+(NSURLSessionDataTask*)postThirdpPartyFamilyListWithBlock:(void(^)(NSError *error,NSArray<GSHFamilyM*> *list))block;
@end
