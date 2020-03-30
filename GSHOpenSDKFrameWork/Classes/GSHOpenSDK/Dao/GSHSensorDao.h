//
//  GSHSensorDao.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/16.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHSensorM.h"

@interface GSHSensorDao : NSObject

+ (instancetype)shareSensorDao;

/**
 *  首页查询 sensor_table 表中的传感器
 *
 *  @return 查询到的结果
 */
- (NSArray <GSHSensorM *>*)selectSensorTableWithFloorId:(NSString *)floorId;

/**
 *  根据DeviceId 查询设备信息
 *
 *  @return 查询到的结果
 */
//- (GSHSensorM *)selectSensorInfoWithDeviceId:(NSString *)deviceId;

/**
 *  向 sensor_table 插入一条记录
 *
 *  @param sensorM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertSensorTableRecordWithModel:(GSHSensorM *)sensorM;

/**
 *  更新 sensor_table 一条记录
 *
 *  @param sensorM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateSensorTableRecordWithModel:(GSHSensorM *)sensorM;

/**
 *  根据 sensor_table  删除一条记录
 *
 *  @param deviceSn 传入deviceSn字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteSensorTableRecordWithDeviceSn:(NSString *)deviceSn;


- (BOOL)deleteAllSensorInfo;

@end

