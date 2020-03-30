//
//  GSHSensorDao.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/16.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHSensorDao.h"
#import "GSHDataBaseManager.h"
#import <YYCategories/YYCategories.h>

@implementation GSHSensorDao

+ (instancetype)shareSensorDao {
    static GSHSensorDao *sensorDao = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sensorDao = [[GSHSensorDao alloc] init];
    });
    return sensorDao;
}

/**
 *  首页查询 sensor_table 表中的设备，排除传感器，网关
 *
 *  @return 查询到的结果
 */
- (NSArray <GSHSensorM *>*)selectSensorTableWithFloorId:(NSString *)floorId {
    
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) {
        return @[];
    }
    __block NSMutableArray *modelArray = [NSMutableArray array];
    
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQueryWithFormat:@"select * from sensor_table where floorId = %@",floorId];
        
        while(rs.next) {
            GSHSensorM *sensorM = [[GSHSensorM alloc] init];
            sensorM.deviceSn = [rs stringForColumn:@"deviceSn"];
            sensorM.deviceName = [rs stringForColumn:@"deviceName"];
            sensorM.roomName = [rs stringForColumn:@"roomName"];
            sensorM.deviceType = [[rs stringForColumn:@"deviceType"] numberValue];
            sensorM.deviceId = [[rs stringForColumn:@"deviceId"] numberValue];
            sensorM.deviceModel = [[rs stringForColumn:@"deviceModel"] numberValue];
            NSData *dataR = [rs dataForColumn:@"attributeList"];
            NSString *str = [NSKeyedUnarchiver unarchiveObjectWithData:dataR];
            NSArray *arr = [NSArray yy_modelArrayWithClass:GSHSensorMonitorM.class json:str];
            sensorM.attributeList = [NSMutableArray arrayWithArray:arr];
            sensorM.launchtime = [rs stringForColumn:@"launchtime"];
            [modelArray addObject:sensorM];
        }
        [rs close];
    }];

    return modelArray;
    
}

/**
 *  根据DeviceId 查询设备信息
 *
 *  @return 查询到的结果
 */
//- (GSHSensorM *)selectSensorInfoWithDeviceId:(NSString *)deviceId {
//    
//}

/**
 *  向 sensor_table 插入一条记录
 *
 *  @param sensorM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertSensorTableRecordWithModel:(GSHSensorM *)sensorM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL insert = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        insert = [self insertSensorTableRecordWithDB:db model:sensorM];
    }];
    
    return insert;
}

- (BOOL)insertSensorTableRecordWithDB:(FMDatabase *)db model:(GSHSensorM *)sensorM {
    
    FMResultSet *rs = [db executeQueryWithFormat:@"select * from sensor_table where deviceSn =%@", sensorM.deviceSn];
    
    while (rs.next) {
        // 存在两条deviceSn一样的记录 我们需要先删除再插入
        [db executeUpdate:@"delete from 'sensor_table' where deviceSn = ?", sensorM.deviceSn];
        break;
    }
    [rs close];
    
    return [db executeUpdate:@"insert into sensor_table (deviceSn,deviceName,deviceId,deviceType,roomName,floorId,familyId,deviceModel,launchtime,attributeList) values (?,?,?,?,?,?,?,?,?,?)",
            sensorM.deviceSn.length>0?sensorM.deviceSn:@"",
            sensorM.deviceName.length>0?sensorM.deviceName:@"",
            sensorM.deviceId?sensorM.deviceId.stringValue:@"",
            sensorM.deviceType?sensorM.deviceType.stringValue:@"",
            sensorM.roomName.length>0?sensorM.roomName:@"",
            sensorM.floorId?sensorM.floorId.stringValue:@"",
            sensorM.familyId?sensorM.familyId.stringValue:@"",
            sensorM.deviceModel?sensorM.deviceModel.stringValue:@"",
            sensorM.launchtime.length>0?sensorM.launchtime:@"",
            [NSKeyedArchiver archivedDataWithRootObject:[sensorM.attributeList yy_modelToJSONString]]];
    
}

/**
 *  更新 sensor_table 一条记录
 *
 *  @param sensorM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateSensorTableRecordWithModel:(GSHSensorM *)sensorM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL update = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        update = [self updateSensorTableRecordWithDB:db sensorM:sensorM];
    }];
    
    return update;
}

- (BOOL)updateSensorTableRecordWithDB:(FMDatabase *)db sensorM:(GSHSensorM *)sensorM {
    return [db executeUpdate:@"update sensor_table set deviceName=?,deviceId=?,deviceType=?,roomName=?,floorId=?,familyId=?,deviceModel=?,launchtime=?,attributeList=? where deviceSn=?",
            sensorM.deviceName.length>0?sensorM.deviceName:@"",
            sensorM.deviceId?sensorM.deviceId.stringValue:@"",
            sensorM.deviceType?sensorM.deviceType.stringValue:@"",
            sensorM.roomName.length>0?sensorM.roomName:@"",
            sensorM.floorId?sensorM.floorId.stringValue:@"",
            sensorM.familyId?sensorM.familyId.stringValue:@"",
            sensorM.deviceModel?sensorM.deviceModel.stringValue:@"",
            sensorM.launchtime.length>0?sensorM.launchtime:@"",
            [NSKeyedArchiver archivedDataWithRootObject:[sensorM.attributeList yy_modelToJSONString]]];
    
}

/**
 *  根据 sensor_table  删除一条记录
 *
 *  @param deviceSn 传入deviceSn字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteSensorTableRecordWithDeviceSn:(NSString *)deviceSn {
    
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'sensor_table' where deviceSn = ?", deviceSn];
    }];
    return result;
    
}

- (BOOL)deleteAllSensorInfo {
    
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'sensor_table'"];
    }];
    return result;
    
}

@end
