//
//  GSHYingShiCameraM.h
//  SmartHome
//
//  Created by gemdale on 2018/7/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#import "GSHDeviceM.h"

//检测是否有录像
typedef enum : NSUInteger {
    GSHYingShiGaoJingMCheckRecordStateNone,         //没有录像
    GSHYingShiGaoJingMCheckRecordStateChecking,     //检测中
    GSHYingShiGaoJingMCheckRecordStateError,        //检测录像失败
    GSHYingShiGaoJingMCheckRecordStateSucceed,      //检测录像成功
} GSHYingShiGaoJingMCheckRecordState;
//告警类型
typedef enum : NSUInteger {
    GSHYingShiGaoJingMAlarmTypeDoorbell,            //门铃告警
    GSHYingShiGaoJingMAlarmTypeYiDong,              //移动检测告警
    GSHYingShiGaoJingMAlarmTypeRenTiGanYing,        //人体感应告警
} GSHYingShiGaoJingMAlarmType;
//告警设置提示音
typedef enum : NSUInteger {
    GSHYingShiCameraMAlarmSoundModeTiShi = 0,//轻微提示
    GSHYingShiCameraMAlarmSoundModeGaoJing,//报警
    GSHYingShiCameraMAlarmSoundModeJingYin,//静音
} GSHYingShiCameraMAlarmSoundMode;

@interface GSHYingShiGaoJingM : GSHBaseModel
/// 告警ID
@property (nonatomic, copy) NSString *alarmId;
/// 告警名称
@property (nonatomic, copy) NSString *alarmName;
/// 告警图片
@property (nonatomic, copy) NSString *alarmPicUrl;
/// 告警类型
@property (nonatomic) NSString *alarmType;
/// 通道号
@property (nonatomic) NSInteger channelNo;
/// 存储类型，0-无存储，1-萤石，2-百度，4-sd卡存储，5-萤石和sd卡，6-百度和sd卡
@property (nonatomic) NSInteger recState;
/// 告警开始时间
@property (nonatomic) long long alarmTime;
/// 告警录像结束时间时间延后偏移量，通过alarmStartTime加上延后偏移量获得告警录像的具体结束时间
@property (nonatomic) NSInteger delayTime;
/// 告警录像开始时间提前偏移量，通过alarmStartTime减去提前偏移量获得告警录像的具体开始时间
@property (nonatomic) NSInteger preTime;
// 是否加密
@property (nonatomic) NSInteger isEncrypt;
/// 收藏标记
@property (nonatomic) NSInteger collectState;
// 已读未读
@property (nonatomic) NSInteger isChecked;
// 已接未接
@property (nonatomic) NSInteger isPicked;
// 房间id
@property (nonatomic, copy) NSString *roomId;
// 房间名
@property (nonatomic, copy) NSString *roomName;
// 楼层id
@property (nonatomic, copy) NSString *floorId;
// 楼层名
@property (nonatomic, copy) NSString *floorName;

//viewModel范畴
/// 告警时间
@property (nonatomic,strong) NSDate *alarmTimeDate;
/// 所属时间
@property (nonatomic,copy) NSString *dateDay;
/// 开始时间
@property (nonatomic,copy) NSString *startTime;
//是否选中
@property (nonatomic) BOOL isSele;
//检测是否有录像状态
@property (nonatomic) GSHYingShiGaoJingMCheckRecordState checkRecord;
//录像文件
@property (nonatomic, strong) EZDeviceRecordFile *file;
@end

//在获取告警列表后为了按日期分组显示制作的容器
@interface GSHYingShiGaoJingGroupM : GSHBaseModel;
@property (nonatomic,strong) NSMutableArray<GSHYingShiGaoJingM*> *list;//告警列表
@property (nonatomic) BOOL isSele;    //是否选中
@property (nonatomic,copy) NSString *dateDay;   //所属时间
@end

//移动监测类
@interface GSHYingShiCameraDefenceM : GSHBaseModel
@property(nonatomic,copy)NSString *startTime;//开始时间
@property(nonatomic,copy)NSString *stopTime;//结束时间
@property(nonatomic,copy)NSString *period;  //周期
@property(nonatomic,copy)NSString *defenceEnable;   //是否开启
@end

@interface GSHYingShiManager : GSHBaseModel
//初始化萤石SDK
+(void)initEZOpenSDK:(NSString*)appkey;
//获取萤石token
+(NSURLSessionDataTask *)updataAccessTokenWithBlock:(void(^)(NSString *token,NSError *error))block;
//添加设备
+(NSURLSessionDataTask *)postAddDeviceWithIpcName:(NSString *)ipcName familyId:(NSString *)familyId ipcModel:(NSString *)ipcModel areaId:(NSString *)areaId validateCode:(NSString*)validateCode deviceSerial:(NSString *)deviceSerial modelName:(NSString*)modelName block:(void(^)(GSHDeviceM *device, NSError *error))block;
//删除设备
+(NSURLSessionDataTask *)postDeleteDeviceWithDeviceSerial:(NSString *)deviceSerial deviceId:(NSString*)deviceId areaId:(NSString*)areaId block:(void(^)(NSError *error))block;
//更新设备
+(NSURLSessionDataTask *)postUpdateDeviceWithIpcName:(NSString *)ipcName deviceSerial:(NSString *)deviceSerial areaId:(NSString *)areaId newAreaId:(NSString *)newAreaId block:(void(^)(NSError *error))block;
//获取布防计划
+(NSURLSessionDataTask *)getDefencePlanWithDeviceSerial:(NSString *)deviceSerial channelNo:(NSInteger)channelNo block:(void(^)(GSHYingShiCameraDefenceM *model,NSError *error))block;
//设置布防计划
+(NSURLSessionDataTask *)postDefencePlanWithDeviceSerial:(NSString *)deviceSerial startTime:(NSString*)startTime stopTime:(NSString*)stopTime period:(NSString*)period channelNo:(NSInteger)channelNo defenceEnable:(BOOL)defenceEnable block:(void(^)(NSError *error))block;
//检测设备是否可添加（是否已经添加等等）
+(NSURLSessionDataTask *)getIsDeviceAddableWithDeviceSerial:(NSString *)deviceSerial modelName:(NSString *)modelName familyId:(NSString*)familyId block:(void(^)(NSDictionary *data, NSError *error))block;
//获取设备各种状态
+(NSURLSessionDataTask *)getIPCStatusWithDeviceSerial:(NSString *)deviceSerial block:(void(^)(NSDictionary *data, NSError *error))block;
//获取一个房间下所有设备的状态，包括在离线和活动检测
+(NSURLSessionDataTask *)getDeviceOnlineStatusByRoom:(NSNumber *)roomId block:(void(^)(NSArray<NSDictionary*> *data, NSError *error))block;
//布撤防
+(NSURLSessionDataTask *)postDefenceWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block;
//设置设备移动跟踪开关
+(NSURLSessionDataTask *)postDeviceMobileStatusWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block;
//设置消息免打扰
+(NSURLSessionDataTask *)postDisturbStateWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block;
//设置镜头遮蔽开关
+(NSURLSessionDataTask *)postSceneSwitchStatusWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block;
//设置全天录像开关
+(NSURLSessionDataTask *)postFulldaySwitchStatusWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block;
//设置告警声音模式
+(NSURLSessionDataTask *)postAlarmSoundModeWithDeviceSerial:(NSString *)deviceSerial mode:(GSHYingShiCameraMAlarmSoundMode)mode block:(void(^)(NSError *error))block;
//某条猫眼推送已接
+(NSURLSessionDataTask *)postPickUpCallingWithAlarmId:(NSString *)alarmId block:(void(^)(NSError *error))block;
//获取摄像头信息
+(NSURLSessionDataTask *)getIPCInfoWithDeviceSerial:(NSString *)deviceSerial block:(void(^)(NSError *error))block;
//获取告警列表（alarmTime为最后那个时间之后的告警）
+(NSURLSessionDataTask *)getAlarmListWithDeviceSerial:(NSString *)deviceSeriale alarmType:(GSHYingShiGaoJingMAlarmType)type alarmTime:(NSNumber*)alarmTime startTime:(NSNumber*)startTime endTime:(NSNumber*)endTime block:(void(^)(NSArray<GSHYingShiGaoJingM*> *list, NSError *error))block;
//获取收藏告警
+(NSURLSessionDataTask *)getCollectAlarmListWithDeviceSerial:(NSString *)deviceSerial alarmType:(GSHYingShiGaoJingMAlarmType)type alarmTime:(NSNumber*)alarmTime block:(void(^)(NSArray<GSHYingShiGaoJingM*> *list, NSError *error))block;
//给某告警标记已读
+(NSURLSessionDataTask *)postAlarmReadWithAlarmIdList:(NSArray<NSString *>*)alarmIdList block:(void(^)(NSError *error))block;
//收藏告警
+(NSURLSessionDataTask *)postCollectAlarmWithAlarmIdList:(NSArray<NSString *>*)alarmIdList block:(void(^)(NSError *error))block;
//删除告警
+(NSURLSessionDataTask *)postDeleteAlarmWithAlarmIdList:(NSArray<NSString *>*)alarmIdList deleteFlag:(NSNumber*)deleteFlag block:(void(^)(NSError *error))block;
//取消收藏告警
+(NSURLSessionDataTask *)postUncollectAlarmWithAlarmIdList:(NSArray<NSString *>*)alarmIdList block:(void(^)(NSError *error))block;

// 设置告警消息免打扰
+(NSURLSessionDataTask *)postAlarmPushConfigWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on familyId:(NSString*)familyId block:(void(^)(NSError *error))block;

// 设置猫眼门铃免打扰
+(NSURLSessionDataTask *)postCallingPushConfigWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on familyId:(NSString*)familyId block:(void(^)(NSError *error))block;

// 检查摄像头是否支持AP配网
+(NSURLSessionDataTask *)getCheckAPAvailableWithModelName:(NSString *)modelName block:(void(^)(id responseObject, NSError *error))block;

// 设置全天录像开关
+(NSURLSessionDataTask *)postSetFulldaySwitchStatusWithDeviceSerial:(NSString *)deviceSerial on:(BOOL)on block:(void(^)(NSError *error))block;

@end
