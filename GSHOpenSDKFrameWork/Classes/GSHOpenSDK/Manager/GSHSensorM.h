//
//  GSHSensorM.h
//  SmartHome
//
//  Created by gemdale on 2018/11/13.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHDeviceM.h"

//传感器历史数据曲线类型
typedef enum : NSUInteger {
    GSHSensorHistoryMonitorMTypeContinuous,//连续的曲线（温湿度）
    GSHSensorHistoryMonitorMTypeBreak,//不连续的曲线 （告警等级）
} GSHSensorHistoryMonitorMType;

//代表一个监控值
@interface GSHSensorMonitorM : NSObject
@property(nonatomic,copy)NSString *basMeteId;       //监控值Id
@property(nonatomic,copy)NSString *unit;            //监控值单位   可以为空，比如一氧化碳报警的时候就是这个值不填
@property(nonatomic,copy)NSString *valueString;     //监控值的值字符串   字符串类型，比如一氧化碳报警的时候就是这个值为告警或正常，pm2.5为优良差等等
@property(nonatomic,assign)NSInteger grade;         //监控值的值数值数值等级 为一个int类型，前端要根据此数值改变背景颜色，如pm2.5>200这个值为3，前端背景为红色，200>pm2.5>100这个值为2，前端背景为黄色 ，100>pm2.5这个值为1，前端背景为绿色;
@property(nonatomic,copy)NSString *name;            //监控值在前端显示的名字
@property(nonatomic,copy)NSString *showMeteStr;     //属性值显示在前端的文字
@end

//时间对应值
@interface GSHSensorHistoryMonitorValueM : NSObject
@property(nonatomic,assign)CGFloat value;        //值
@property(nonatomic,assign)CGFloat time;        //时间
@end

//代表一组监控值历史数据（获取历史数据信息时返回此模型列表）绘制历史数据曲线需要用到
@interface GSHSensorHistoryMonitorM : NSObject
@property(nonatomic,assign) GSHSensorHistoryMonitorMType lineType;          //线条类型
@property(nonatomic,copy)NSString *basMeteId;                               //监控量ID
@property(nonatomic,copy)NSString *unit;                                    //单位   可以为空，比如一氧化碳报警的时候就是这个值不填
@property(nonatomic,copy)NSString *meteName;                                //名字
@property(nonatomic,assign)CGFloat maxValue;                                //最大值
@property(nonatomic,assign)CGFloat minValue;                                //最小值
@property(nonatomic,assign)CGFloat startTime;                               //开始时间
@property(nonatomic,assign)CGFloat endTime;                                 //结束时间
@property(nonatomic,strong)NSArray<GSHSensorHistoryMonitorValueM*> *timeValueList;        //格式件点对应的值
- (NSString *)lineColor;
@end

//代表告警数据（获取告警列表时返回此模型列表）
@interface GSHSensorAlarmM : NSObject
@property(nonatomic,copy)NSString *msgId;
@property(nonatomic,copy)NSString *msgTime;            //时间
@property(nonatomic,copy)NSString *msgBody;            //内容
@end

@interface GSHMissingSensorM : NSObject
@property(nonatomic,strong)NSString *deviceName;
@property(nonatomic,strong)NSString *deviceType;
@property(nonatomic,strong)NSString *statusDesc;
@end

@interface GSHSensorM : GSHDeviceM
@property(nonatomic,strong)NSString *statusDesc;
@property(nonatomic,strong)NSArray<GSHSensorMonitorM*> *attributeList;  //每个传感器都有一个监控值列表（取最新数据）
//最新数据字符串
- (NSString *)monitorString;
//最新数据
- (NSArray<GSHSensorMonitorM*>*)showAttributeList;
//实时数据等级
- (NSInteger)grade;
//设备添加时间
- (NSDate *)launchDate;
//当前电量状态（电量正常，低电量，或空）
- (NSString *)electricString;
@end

@interface GSHSensorManager : NSObject
// 按楼层获取传感器
+ (NSURLSessionDataTask *)getSensorListWithFamilyId:(NSString*)familyId floorId:(NSString*)floorId block:(void(^)(NSArray<GSHSensorM*> *list,NSError *error))block;

// 更新传感器排序
+ (NSURLSessionDataTask *)postSensorRankWithFamilyId:(NSString*)familyId floorId:(NSString*)floorId sensorList:(NSArray<GSHSensorM*> *)sensorList block:(void(^)(NSError *error))block;

// 获取传感器实时数据
+ (NSURLSessionDataTask *)getSensorRealDataWithFamilyId:(NSString*)familyId deviceSn:(NSString*)deviceSn block:(void(^)(GSHSensorM *sensorM, NSError *error))block;

// 获取某一天的历史数据信息
+ (NSURLSessionDataTask *)getSensorHistoryDataWithFamilyId:(NSString*)familyId deviceSn:(NSString*)deviceSn deviceType:(NSString*)deviceType hisDate:(NSString*)hisDate block:(void(^)(NSArray<GSHSensorHistoryMonitorM*>*monitorList, NSArray<GSHSensorAlarmM*>*alarmList, NSError *error))block;

#pragma mark -- 组合传感器相关方法
// 获取组合传感器中的子传感器
+ (NSURLSessionDataTask *)getSensorGroupDetailWithFamilyId:(NSString*)familyId deviceId:(NSString*)deviceId block:(void(^)(NSArray<GSHSensorM*> *list, NSError *error))block;

// 获取组合传感器支持类型
+ (NSURLSessionDataTask *)getSensorGroupTypeWithBlock:(void(^)(NSArray<GSHDeviceCategoryM*> *list, NSError *error))block;

// 删除组合传感器中的子传感器
+ (NSURLSessionDataTask *)postSensorGroupUnindWithFamilyId:(NSString*)familyId deviceId:(NSString*)deviceId block:(void(^)(NSError *error))block;

// 更新组合传感器中的子传感器
+ (NSURLSessionDataTask *)postSensorGroupUpdataWithFamilyId:(NSString*)familyId deviceId:(NSString*)deviceId deviceType:(NSString*)deviceType roomId:(NSString*)roomId deviceName:(NSString*)deviceName block:(void(^)(NSError *error))block;

//获取指数设备
+(NSURLSessionDataTask*)getFamilyIndexDeviceWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId block:(void(^)(NSArray<GSHSensorM*> *list,NSArray<GSHMissingSensorM*> *missingList,NSString *tip,NSError *error))block;
@end
