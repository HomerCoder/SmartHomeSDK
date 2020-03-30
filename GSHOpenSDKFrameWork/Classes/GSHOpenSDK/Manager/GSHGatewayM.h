//
//  GSHGatewayM.h
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"

@interface GSHGatewayVersionM : GSHBaseModel
@property(nonatomic, copy) NSString *updateFlag;    // 是否有更新的标志
@property(nonatomic, copy) NSString *versionId; // 版本号id
@property(nonatomic, copy) NSString *versionTarget; // 版本号
@property(nonatomic, copy) NSString *descInfo;    // 版本描述
@property(nonatomic, copy) NSString *firmwareVersion;    // 网关当前版本号
@property(nonatomic, copy) NSString *size;    // 版本大小，单位M
@end

@interface GSHGatewayM : GSHBaseModel
@property(nonatomic, copy) NSString *gatewayId;
@property(nonatomic, copy) NSString *agreementName; // 协议名称
@property(nonatomic, copy) NSString *coordinatorVersion; //协调器版本
@property(nonatomic, copy) NSString *deviceId; // 网关设备id
@property(nonatomic, copy) NSString *deviceKind; //
@property(nonatomic, copy) NSString *deviceKindStr; //
@property(nonatomic, copy) NSString *deviceModel; //
@property(nonatomic, copy) NSString *deviceModelStr; //
@property(nonatomic, copy) NSString *deviceType; //
@property(nonatomic, copy) NSString *deviceTypeStr; //
@property(nonatomic, copy) NSString *familyId; //家庭id
@property(nonatomic, copy) NSString *firmwareVersion; //固件版本
@property(nonatomic, copy) NSString *gatewayMac; //mac地址
@property(nonatomic, copy) NSString *gatewayName; //网关名称
@property(nonatomic, copy) NSString *gatewayState; // 网关状态（0：在线 1：离线）
@property(nonatomic, copy) NSString *gatewayType; //网关类型
@property(nonatomic, copy) NSString *hardwareVersion; //硬件版本
@property(nonatomic, copy) NSString *launchtime; //投入使用时间
@property(nonatomic, copy) NSString *manufacturerName; //厂家名称
@property(nonatomic, copy) NSString *siteId; //网点id
@property(nonatomic, copy) NSString *homePageIcon; //网关图片
@end

@interface GSHGatewayManager : NSObject
//添加网关
+(NSURLSessionDataTask*)postAddGatewayWithFamilyId:(NSString*)familyId gatewayId:(NSString*)gatewayId gatewayName:(NSString*)gatewayName block:(void(^)(NSError *error))block;

//获取网关信息
+(NSURLSessionDataTask*)getGatewayWithFamilyId:(NSString*)familyId gatewayId:(NSString*)gatewayId block:(void(^)(GSHGatewayM *gateWayM ,NSError *error))block;
//获取网关信息
+(NSURLSessionDataTask*)getGatewayStateWithGatewayId:(NSString*)gatewayId block:(void(^)(GSHGatewayM *gateWayM ,NSError *error))block;

// 删除网关 /setting/deleteGW
+ (NSURLSessionDataTask *)deleteGWWithFamilyId:(NSString *)familyId password:(NSString*)password block:(void(^)(NSError *error))block;

// 获取网关升级信息
+(NSURLSessionDataTask*)getGatewayUpdateMsgWithFamilyId:(NSString*)familyId gatewayId:(NSString*)gatewayId block:(void(^)(GSHGatewayVersionM *gateWayVersionM ,NSError *error))block;

// 远程升级 /setting/remoteGatewayUpdate
+(NSURLSessionDataTask*)updateGatewayWithFamilyId:(NSString*)familyId gatewayId:(NSString*)gatewayId versionId:(NSString *)versionId block:(void(^)(NSError *error))block;

// 重启
+(NSURLSessionDataTask*)resetGatewayWithGatewayId:(NSString*)gatewayId block:(void(^)(NSError *error))block;

// 获取备份
+(NSURLSessionDataTask*)getCopyGatewayWithGatewayId:(NSString*)gatewayId familyId:(NSString*)familyId block:(void(^)(NSError *error,NSDictionary *dic))block;

// 恢复
+(NSURLSessionDataTask*)recoveryGatewayWithGatewayId:(NSString*)gatewayId familyId:(NSString*)familyId block:(void(^)(NSError *error))block;

// 备份
+(NSURLSessionDataTask*)copyGatewayWithGatewayId:(NSString*)gatewayId familyId:(NSString*)familyId block:(void(^)(NSError *error))block;

// 替换
+(NSURLSessionDataTask*)changeGatewayWithGatewayId:(NSString*)gatewayId newGatewayId:(NSString*)newGatewayId familyId:(NSString*)familyId block:(void(^)(NSError *error))block;
@end
