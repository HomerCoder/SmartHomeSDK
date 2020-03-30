//
//  GSHDeviceDao.h
//  SmartHome
//
//  Created by zhanghong on 2019/1/28.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHDeviceM.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHDeviceDao : NSObject

+ (instancetype)shareDeviceDao;

/**
 *  首页查询 device_table 表中的设备，排除传感器，网关
 *
 *  @return 查询到的结果
 */
- (NSArray <GSHDeviceM *>*)selectDeviceTableWithRoomId:(NSString *)roomId;

/**
 *  首页查询 device_table 表中的设备，排除传感器，网关
 *
 *  @return 查询到的结果
 */
- (NSArray <GSHDeviceM *>*)selectDeviceTableWithFloorId:(NSString *)floorId;

/**
 *  根据DeviceId 查询设备信息
 *
 *  @return 查询到的结果
 */
- (GSHDeviceM *)selectDeviceInfoWithDeviceId:(NSString *)deviceId;

/**
 *  向 device_table 插入一条记录
 *
 *  @param deviceM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertDeviceTableRecordWithModel:(GSHDeviceM *)deviceM;

/**
 *  更新 device_table 一条记录
 *
 *  @param deviceM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateDeviceTableRecordWithModel:(GSHDeviceM *)deviceM;

/**
 *  根据 device_table  删除一条记录
 *
 *  @param deviceSn 传入deviceSn字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteDeviceTableRecordWithDeviceSn:(NSString *)deviceSn;


- (BOOL)deleteAllDeviceInfo;

@end

NS_ASSUME_NONNULL_END
