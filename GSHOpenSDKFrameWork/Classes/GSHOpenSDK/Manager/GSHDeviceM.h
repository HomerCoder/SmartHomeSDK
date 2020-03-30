//
//  GSHDeviceM.h
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"
#import <UIKit/UIKit.h>
#import "GSHGatewayM.h"
#import "GSHFamilyM.h"

@class GSHSceneM;

extern NSString * const GSHDeviceAddFinishNotification;

@interface GSHMeteBindedInfoListM : GSHBaseModel
@property (nonatomic , copy) NSString *basMeteId;
@property (nonatomic , copy) NSString *meteName;
@property (nonatomic , copy) NSString *deviceName;
@property (nonatomic , copy) NSString *deviceSn;
@property (nonatomic , copy) NSString *deviceId;
@property (nonatomic , copy) NSString *meteId;
@end

@interface GSHSwitchMeteBindInfoModelM : GSHBaseModel
@property (nonatomic , copy) NSString *basMeteId;
@property (nonatomic , copy) NSString *meteName;
@property (nonatomic , strong) NSMutableArray <GSHMeteBindedInfoListM *> *meteBindedInfoList;
@end

@interface GSHSwitchBindM : NSObject
@property (nonatomic , copy) NSString *deviceId;
@property (nonatomic , copy) NSString *deviceName;
@property (nonatomic , copy) NSString *deviceSn;
@property (nonatomic , strong) NSMutableArray <GSHSwitchMeteBindInfoModelM *> *switchMeteBindInfoModels;
@end

@interface GSHDeviceAttributeM : GSHBaseModel
@property (nonatomic , copy) NSString *basMeteId;
@property (nonatomic , copy) NSString *meteName;
@property (nonatomic , copy) NSString *scenarioName;
@property (nonatomic , strong) NSNumber *channelNo;
@property (nonatomic , strong) NSNumber *meteIndex;
@property (nonatomic , strong) NSNumber *meteType;
@property (nonatomic , strong) NSNumber *meteKind;
@property (nonatomic , strong) NSNumber *lastValue;

@end

@interface GSHDeviceExtM : GSHBaseModel
@property (nonatomic , strong) NSNumber *cmdId;
@property (nonatomic , copy) NSString *basMeteId;
@property (nonatomic , copy) NSString *conditionOperator;
@property (nonatomic , copy) NSString *param;
@property (nonatomic , copy) NSString *rightValue;
@end

@interface GSHDeviceCategoryM : GSHBaseModel
@property (nonatomic ,strong)NSNumber *deviceType;
@property (nonatomic ,strong)NSNumber *deviceModel;
@property (nonatomic ,copy) NSString *deviceTypeStr;
@property (nonatomic ,copy) NSString *deviceModelStr;
@property (nonatomic ,copy) NSString *picPath;
@end

@interface GSHDeviceModelM : GSHBaseModel

@property (nonatomic , strong) NSNumber *deviceModel;
@property (nonatomic , strong) NSString *deviceModelStr;
@property (nonatomic , strong) NSString *modelNameDesc;
@property (nonatomic , strong) NSString *hardModel;
@property (nonatomic , strong) NSString *introPic;
@property (nonatomic , strong) NSNumber *deviceType;
@property (nonatomic , copy) NSString *deviceTypeStr;
@property (nonatomic , strong) NSString *homePageIcon;
@property (nonatomic , strong) NSNumber *deviceKind;
@property (nonatomic , copy) NSString *kindName;

@end

@class GSHDeviceM;
@interface GSHDeviceTypeM : GSHBaseModel

@property (nonatomic , strong) NSNumber *deviceKind;
@property (nonatomic , strong) NSNumber *deviceType;
@property (nonatomic , copy) NSString *deviceTypeStr;
@property (nonatomic , strong) NSMutableArray <GSHDeviceModelM *> *deviceModelList;

// 此处增加的属性，用于获取场景模版详情时解析数据
@property (nonatomic , strong) NSString *picPath;
@property (nonatomic , strong) NSMutableArray <GSHDeviceM *> *devices;
@property (nonatomic , strong) NSMutableArray <GSHDeviceExtM *> *exts;


@end

@interface GSHDeviceKindM : GSHBaseModel

@property (nonatomic , strong) NSNumber *deviceKind;
@property (nonatomic , copy) NSString *kindName;
@property (nonatomic,strong) NSMutableArray <GSHDeviceTypeM *> *deviceTypeList;
@end

@interface GSHDeviceM : GSHBaseModel
@property(nonatomic,strong) NSNumber *deviceId;         // 设备id
@property(nonatomic,copy) NSString *deviceSn;           // 设备SN
@property(nonatomic,copy) NSString *deviceName;         // 设备名称
@property(nonatomic,copy) NSString *validateCode;       // 设备验证码 只有萤石设备有 红外设备是父转发器的SN
@property(nonatomic,copy) NSString *firmwareVersion;    // 设备固件版本
@property(nonatomic,copy) NSString *agreementType;      // 设备协议
@property(nonatomic,copy) NSString *manufacturer;       // 厂家

@property(nonatomic,strong) NSNumber *deviceKind;       // 设备种类
@property(nonatomic,copy) NSString *deviceKindStr;      // 设备种类str
@property(nonatomic,strong) NSNumber *deviceModel;      // 设备型号
@property(nonatomic,copy) NSString *deviceModelStr;     // 设备型号str
@property(nonatomic,strong) NSNumber *deviceType;       // 设备类型
@property(nonatomic,copy) NSString *deviceTypeStr;      // 设备类型str
@property(nonatomic,copy) NSString *hardModel;          // 硬件型号
@property(nonatomic,copy) NSString *modelNameDesc;      // 设备型号描述

@property(nonatomic,strong) NSNumber *gatewayId;        // 网关id (部分接口回有这个字段，其他接口没有这个字段)
@property(nonatomic,strong) NSNumber *familyId;         // 家庭id (只有离线模式获取所有设备的时候回有这个字段，其他接口没有这个字段)
@property(nonatomic,strong) NSNumber *floorId;          // 楼层id
@property(nonatomic,copy) NSString *floorName;          // 楼层名称
@property(nonatomic,strong) NSNumber *roomId;           // 房间id
@property(nonatomic,copy) NSString *roomName;           // 房间名称

@property(nonatomic,strong) NSNumber *defence;          // 检测
@property(nonatomic,strong) NSNumber *onlineStatus;     // 在线
@property(nonatomic,strong) NSNumber *permissionState;  // 权限状态
@property(nonatomic,strong) NSNumber *rank;             // 排名
@property(nonatomic,copy) NSString *launchtime;       // 设备入网时间
@property(nonatomic,copy) NSString *globalId;         // globalId

@property(nonatomic,strong) NSString *homePageIcon;     // 首页设备图标
@property(nonatomic,strong) NSString *controlPicPath;   // 设备控制页面 - 设备图

@property(nonatomic,strong) NSMutableArray <GSHDeviceExtM *> *exts;                 //控制参数
@property(nonatomic,strong) NSMutableArray <GSHDeviceAttributeM *> *attribute;      //设备可控制

- (NSDictionary*)realTimeDic;   //实时数据字典
- (GSHDeviceCategoryM *)category;
- (BOOL)isSelected;
- (void)setIsSelected:(BOOL)isSelected;
//组合传感器专用方法，组合传感器的BaseMeteId是不确定的可以通过deviceSn获取到
- (NSString *)getBaseMeteIdFromDeviceSn:(NSString *)deviceSn;
@end

@interface GSHDeviceManager : NSObject
#pragma mark--基本功能
// 获取设备品类
+ (NSURLSessionDataTask *)getDeviceTypesWithBlock:(void(^)(NSArray<GSHDeviceCategoryM*> *list,NSError *error))block;

// 通过二维码获取设备信息
+ (NSURLSessionDataTask *)postDeviceModelListWithQRCode:(NSString*)qrCode block:(void(^)(NSArray<GSHDeviceModelM*> *list,NSString *sn,NSError *error))block;

// v2.4.0 获取设备品类
+ (NSURLSessionDataTask *)getSystemDeviceTemplateWithBlock:(void(^)(NSArray<GSHDeviceKindM*> *list,NSError *error))block;

// 开组网（通知网关搜索设备，scanStatus==1为开组网，scanStatus==0为关组网）
+ (NSURLSessionDataTask *)searchDevicesWithFamilyId:(NSString *)familyId scanStatus:(NSString *)scanStatus deviceSn:(NSString *)deviceSn block:(void(^)(NSError *error))block;
// 查询组网到的设备
+ (NSURLSessionDataTask *)getDiscoveryDevicesWithFamilyId:(NSString *)familyId block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block;

// 添加设备
+ (NSURLSessionDataTask *)postAddDeviceWithFamilyId:(NSString *)familyId deviceId:(NSString *)deviceId deviceType:(NSString *)deviceType roomId:(NSString*)roomId deviceName:(NSString *)deviceName attribute:(NSArray *)attribute block:(void(^)(GSHDeviceM *device, NSError *error))block;

// 修改设备
+ (NSURLSessionDataTask *)postUpdateDeviceWithFamilyId:(NSString *)familyId deviceId:(NSString *)deviceId deviceSn:(NSString *)deviceSn deviceType:(NSString *)deviceType roomId:(NSString*)roomId newRoomId:(NSString*)newRoomId deviceName:(NSString *)deviceName attribute:(NSArray *)attribute block:(void(^)(GSHDeviceM *device,NSError *error))block;

// 删除设备
+ (NSURLSessionDataTask *)deleteDeviceWithFamilyId:(NSString *)familyId roomId:(NSString*)roomId deviceId:(NSString *)deviceId deviceSn:(NSString *)deviceSn deviceModel:(NSString *)deviceModel deviceType:(NSString *)deviceType block:(void(^)(NSError *error))block;

// 获取所有设备
+(NSURLSessionDataTask*)getDevicesListWithFamilyId:(NSString*)familyId block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block;

// v2.4 设备管理 - 获取所有设备
+(NSURLSessionDataTask*)getFamilyDevicesListWithFamilyId:(NSString*)familyId block:(void(^)(GSHGatewayM *gatewayM,GSHFamilyM *familyM,NSError *error))block;

// 设备控制
+ (void)deviceControlWithDeviceId:(NSString *)deviceId deviceSN:(NSString *)deviceSN familyId:(NSString *)familyId basMeteId:(NSString *)basMeteId value:(NSString *)value block:(void(^)(NSError *error))block;

#pragma mark--首页单独
//首页单独获取设备
+(NSURLSessionDataTask*)getHomeVCDevicesListWithFamilyId:(NSString*)familyId roomId:(NSNumber*)roomId pageIndex:(NSNumber*)pageIndex block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block;

//首页设备排序
+(NSURLSessionDataTask*)postHomeVCSortDeviceRoomId:(NSNumber*)roomId globalIdList:(NSArray<NSString*>*)globalIdList block:(void(^)(NSError *error))block;

//获取房间设备与场景
+(NSURLSessionDataTask*)getFamilyDeviceAndScenariosWithFamilyId:(NSString*)familyId roomId:(NSNumber*)roomId floorId:(NSNumber*)floorId block:(void(^)(NSArray<GSHDeviceM*> *devices,NSArray<GSHSceneM*> *scenarios,NSError *error))block;

//首页单独交换设备位置
+(NSURLSessionDataTask*)postHomeVCMoveDeviceWithRoomId:(NSNumber*)roomId deviceId:(NSString*)deviceId targetDeviceId:(NSString*)targetDeviceId block:(void(^)(NSError *error))block;

#pragma mark--扩展功能
// 获取设备及其监控量详细信息
+ (NSURLSessionDataTask *)getDeviceInfoWithFamilyId:(NSString *)familyId deviceId:(NSString *)deviceId deviceSign:(NSString*)deviceSign block:(void(^)(GSHDeviceM *device, NSError *error))block;

#pragma mark--双控开光接口
// 获取房间下所有开关设备
+(NSURLSessionDataTask *)getSwitchDevicesListWithroomId:(NSString *)roomId block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block;

// 绑定多控开关关联关系
+(NSURLSessionDataTask *)bindMultiControlWithDeviceId:(NSString *)deviceId deviceSn:(NSString *)deviceSn basMeteId:(NSString *)basMeteId relDeviceId:(NSString *)relDeviceId relDeviceSn:(NSString *)relDeviceSn relBasMeteId:(NSString *)relBasMeteId block:(void(^)(NSError *error))block;

#pragma mark--场景面板接口
// 场景面板 -- 解绑
+ (NSURLSessionDataTask *)unbindScenarioBoardWithFamilyId:(NSString *)familyId basMeteId:(NSString *)basMeteId deviceId:(NSString *)deviceId block:(void(^)(NSError *error))block;

#pragma mark--双控开关相关接口
// APP查询设备绑定详情
+ (NSURLSessionDataTask *)getDeviceBIndInfoWithDeviceId:(NSString *)deviceId block:(void(^)(GSHSwitchBindM *switchBindM,NSError *error))block;

// 解绑多控开关关联关系
+ (NSURLSessionDataTask *)unBindMultiControlWithDeviceId:(NSString *)deviceId deviceSn:(NSString *)deviceSn basMeteId:(NSString *)basMeteId relDeviceId:(NSString *)relDeviceId relDeviceSn:(NSString *)relDeviceSn relBasMeteId:(NSString *)relBasMeteId block:(void(^)(NSError *error))block;

#pragma mark--声必可
+ (NSURLSessionDataTask *)addIpcDeviceWithFamilyId:(NSString *)familyId ipcName:(NSString *)ipcName ipcModel:(NSString *)ipcModel modelName:(NSString *)modelName areaId:(NSString *)areaId deviceSerial:(NSString *)deviceSerial firmwareVersion:(NSString *)firmwareVersion block:(void(^)(NSError *error))block;

+ (NSURLSessionDataTask *)updateIpcDeviceWithIpcId:(NSString *)ipcId familyId:(NSString *)familyId ipcName:(NSString *)ipcName areaId:(NSString *)areaId newAreaId:(NSString *)newAreaId firmwareVersion:(NSString *)firmwareVersion block:(void(^)(NSError *error))block;

+ (NSURLSessionDataTask *)deleteIpcDeviceWithFamilyId:(NSString *)familyId ipcId:(NSString *)ipcId areaId:(NSString *)areaId block:(void(^)(NSError *error))block;
@end

