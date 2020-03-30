//
//  GSHDeviceDao.m
//  SmartHome
//
//  Created by zhanghong on 2019/1/28.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDeviceDao.h"
#import "GSHDataBaseManager.h"
#import <YYCategories/YYCategories.h>

@implementation GSHDeviceDao

+(instancetype)shareDeviceDao {
    static GSHDeviceDao *deviceDao = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceDao = [[GSHDeviceDao alloc] init];
    });
    return deviceDao;
}

/**
 *  查询 device_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray<GSHDeviceM *> *)selectDeviceTableWithRoomId:(NSString *)roomId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) {
        return @[];
    }
    __block NSMutableArray *modelArray = [NSMutableArray array];
    
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQueryWithFormat:@"select * from device_table where roomId = %@",roomId];
        
        while(rs.next) {
            GSHDeviceM *deviceM = [[GSHDeviceM alloc] init];
            deviceM.deviceSn = [rs stringForColumn:@"deviceSn"];
            deviceM.deviceName = [rs stringForColumn:@"deviceName"];
            deviceM.validateCode = [rs stringForColumn:@"validateCode"];
            deviceM.firmwareVersion = [rs stringForColumn:@"firmwareVersion"];
            deviceM.agreementType = [rs stringForColumn:@"agreementType"];
            deviceM.manufacturer = [rs stringForColumn:@"manufacturer"];
            deviceM.deviceId = [[rs stringForColumn:@"deviceId"] numberValue];
            deviceM.deviceKind = [[rs stringForColumn:@"deviceKind"] numberValue];
            deviceM.deviceKindStr = [rs stringForColumn:@"deviceKindStr"];
            deviceM.deviceModel = [[rs stringForColumn:@"deviceModel"] numberValue];
            deviceM.deviceModelStr = [rs stringForColumn:@"deviceModelStr"];
            deviceM.deviceType = [[rs stringForColumn:@"deviceType"] numberValue];
            deviceM.deviceTypeStr = [rs stringForColumn:@"deviceTypeStr"];
            deviceM.gatewayId = [[rs stringForColumn:@"gatewayId"] numberValue];
            deviceM.familyId = [[rs stringForColumn:@"familyId"] numberValue];
            deviceM.floorId = [[rs stringForColumn:@"floorId"] numberValue];
            deviceM.floorName = [rs stringForColumn:@"floorName"];
            deviceM.roomId = [[rs stringForColumn:@"roomId"] numberValue];
            deviceM.roomName = [rs stringForColumn:@"roomName"];
            deviceM.defence = [[rs stringForColumn:@"defence"] numberValue];
            deviceM.onlineStatus = [[rs stringForColumn:@"onlineStatus"] numberValue];
            deviceM.permissionState = [[rs stringForColumn:@"permissionState"] numberValue];
            deviceM.rank = [[rs stringForColumn:@"rank"] numberValue];
            NSData *dataR = [rs dataForColumn:@"attribute"];
            NSString *str = [NSKeyedUnarchiver unarchiveObjectWithData:dataR];
            NSArray *arr = [NSArray yy_modelArrayWithClass:GSHDeviceAttributeM.class json:str];
            deviceM.attribute = [NSMutableArray arrayWithArray:arr];
            deviceM.launchtime = [rs stringForColumn:@"launchtime"];
            deviceM.homePageIcon = [rs stringForColumn:@"homePageIcon"];
            deviceM.controlPicPath = [rs stringForColumn:@"controlPicPath"];
            [modelArray addObject:deviceM];
        }
        [rs close];
    }];
    
    return modelArray;
}

- (NSArray<GSHDeviceM *> *)selectDeviceTableWithFloorId:(NSString *)floorId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) {
        return @[];
    }
    __block NSMutableArray *modelArray = [NSMutableArray array];
    
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQueryWithFormat:@"select * from device_table where floorId = %@",floorId];
        
        while(rs.next) {
            GSHDeviceM *deviceM = [[GSHDeviceM alloc] init];
            deviceM.deviceSn = [rs stringForColumn:@"deviceSn"];
            deviceM.deviceName = [rs stringForColumn:@"deviceName"];
            deviceM.validateCode = [rs stringForColumn:@"validateCode"];
            deviceM.firmwareVersion = [rs stringForColumn:@"firmwareVersion"];
            deviceM.agreementType = [rs stringForColumn:@"agreementType"];
            deviceM.manufacturer = [rs stringForColumn:@"manufacturer"];
            deviceM.deviceId = [[rs stringForColumn:@"deviceId"] numberValue];
            deviceM.deviceKind = [[rs stringForColumn:@"deviceKind"] numberValue];
            deviceM.deviceKindStr = [rs stringForColumn:@"deviceKindStr"];
            deviceM.deviceModel = [[rs stringForColumn:@"deviceModel"] numberValue];
            deviceM.deviceModelStr = [rs stringForColumn:@"deviceModelStr"];
            deviceM.deviceType = [[rs stringForColumn:@"deviceType"] numberValue];
            deviceM.deviceTypeStr = [rs stringForColumn:@"deviceTypeStr"];
            deviceM.gatewayId = [[rs stringForColumn:@"gatewayId"] numberValue];
            deviceM.familyId = [[rs stringForColumn:@"familyId"] numberValue];
            deviceM.floorId = [[rs stringForColumn:@"floorId"] numberValue];
            deviceM.floorName = [rs stringForColumn:@"floorName"];
            deviceM.roomId = [[rs stringForColumn:@"roomId"] numberValue];
            deviceM.roomName = [rs stringForColumn:@"roomName"];
            deviceM.defence = [[rs stringForColumn:@"defence"] numberValue];
            deviceM.onlineStatus = [[rs stringForColumn:@"onlineStatus"] numberValue];
            deviceM.permissionState = [[rs stringForColumn:@"permissionState"] numberValue];
            deviceM.rank = [[rs stringForColumn:@"rank"] numberValue];
            NSData *dataR = [rs dataForColumn:@"attribute"];
            NSString *str = [NSKeyedUnarchiver unarchiveObjectWithData:dataR];
            NSArray *arr = [NSArray yy_modelArrayWithClass:GSHDeviceAttributeM.class json:str];
            deviceM.attribute = [NSMutableArray arrayWithArray:arr];
            deviceM.launchtime = [rs stringForColumn:@"launchtime"];
            deviceM.homePageIcon = [rs stringForColumn:@"homePageIcon"];
            deviceM.controlPicPath = [rs stringForColumn:@"controlPicPath"];
            [modelArray addObject:deviceM];
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
- (GSHDeviceM *)selectDeviceInfoWithDeviceId:(NSString *)deviceId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) {
        return nil;
    }
    __block GSHDeviceM *deviceM = [[GSHDeviceM alloc] init];
    
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQueryWithFormat:@"select * from device_table where deviceId = %@",deviceId];
        
        while(rs.next) {
            deviceM.deviceSn = [rs stringForColumn:@"deviceSn"];
            deviceM.deviceName = [rs stringForColumn:@"deviceName"];
            deviceM.validateCode = [rs stringForColumn:@"validateCode"];
            deviceM.firmwareVersion = [rs stringForColumn:@"firmwareVersion"];
            deviceM.agreementType = [rs stringForColumn:@"agreementType"];
            deviceM.manufacturer = [rs stringForColumn:@"manufacturer"];
            deviceM.deviceId = [[rs stringForColumn:@"deviceId"] numberValue];
            deviceM.deviceKind = [[rs stringForColumn:@"deviceKind"] numberValue];
            deviceM.deviceKindStr = [rs stringForColumn:@"deviceKindStr"];
            deviceM.deviceModel = [[rs stringForColumn:@"deviceModel"] numberValue];
            deviceM.deviceModelStr = [rs stringForColumn:@"deviceModelStr"];
            deviceM.deviceType = [[rs stringForColumn:@"deviceType"] numberValue];
            deviceM.deviceTypeStr = [rs stringForColumn:@"deviceTypeStr"];
            deviceM.gatewayId = [[rs stringForColumn:@"gatewayId"] numberValue];
            deviceM.familyId = [[rs stringForColumn:@"familyId"] numberValue];
            deviceM.floorId = [[rs stringForColumn:@"floorId"] numberValue];
            deviceM.floorName = [rs stringForColumn:@"floorName"];
            deviceM.roomId = [[rs stringForColumn:@"roomId"] numberValue];
            deviceM.roomName = [rs stringForColumn:@"roomName"];
            deviceM.defence = [[rs stringForColumn:@"defence"] numberValue];
            deviceM.onlineStatus = [[rs stringForColumn:@"onlineStatus"] numberValue];
            deviceM.permissionState = [[rs stringForColumn:@"permissionState"] numberValue];
            deviceM.rank = [[rs stringForColumn:@"rank"] numberValue];
            NSData *dataR = [rs dataForColumn:@"attribute"];
            NSString *str = [NSKeyedUnarchiver unarchiveObjectWithData:dataR];
            NSArray *arr = [NSArray yy_modelArrayWithClass:GSHDeviceAttributeM.class json:str];
            deviceM.attribute = [NSMutableArray arrayWithArray:arr];
            deviceM.launchtime = [rs stringForColumn:@"launchtime"];
            deviceM.homePageIcon = [rs stringForColumn:@"homePageIcon"];
            deviceM.controlPicPath = [rs stringForColumn:@"controlPicPath"];
        }
        [rs close];
    }];
    
    return deviceM;
}

/**
 *  向 device_table 插入一条记录
 *
 *  @param deviceM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertDeviceTableRecordWithModel:(GSHDeviceM *)deviceM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL insert = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        insert = [self insertDeviceTableRecordWithDB:db model:deviceM];
    }];
    
    return insert;
}

- (BOOL)insertDeviceTableRecordWithDB:(FMDatabase *)db model:(GSHDeviceM *)deviceM {
    
    FMResultSet *rs = [db executeQueryWithFormat:@"select * from device_table where deviceSn =%@", deviceM.deviceSn];
    
    while (rs.next) {
        // 存在两条deviceSn一样的记录 我们需要先删除再插入
        [db executeUpdate:@"delete from 'device_table' where deviceSn = ?", deviceM.deviceSn];
        break;
    }
    [rs close];
    
    return [db executeUpdate:@"insert into device_table (deviceSn,deviceName,validateCode,firmwareVersion,agreementType,manufacturer,deviceId,deviceKind,deviceKindStr,deviceModel,deviceModelStr,deviceType,deviceTypeStr,gatewayId,familyId,floorId,floorName,roomId,roomName,defence,onlineStatus,permissionState,rank,attribute,launchtime,homePageIcon,controlPicPath) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            [self checkNSString:deviceM.deviceSn],
            [self checkNSString:deviceM.deviceName],
            [self checkNSString:deviceM.validateCode],
            [self checkNSString:deviceM.firmwareVersion],
            [self checkNSString:deviceM.agreementType],
            [self checkNSString:deviceM.manufacturer],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.deviceId]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.deviceKind]],
            [self checkNSString:deviceM.deviceKindStr],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.deviceModel]],
            [self checkNSString:[self checkNSString:deviceM.deviceModelStr]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.deviceType]],
            [self checkNSString:deviceM.deviceTypeStr],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.gatewayId]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.familyId]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.floorId]],
            [self checkNSString:deviceM.floorName],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.roomId]],
            [self checkNSString:deviceM.roomName],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.defence]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.onlineStatus]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.permissionState]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.rank]],
            [NSKeyedArchiver archivedDataWithRootObject:[deviceM.attribute yy_modelToJSONString]],
            [self checkNSString:deviceM.launchtime],
            [self checkNSString:deviceM.homePageIcon],
            [self checkNSString:deviceM.controlPicPath]];
    
}

- (NSString*)checkNSString:(NSString*)contentString {
    return [contentString length] == 0 ? @"" : contentString;
}

/**
 *  更新 device_table 一条记录
 *
 *  @param deviceM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateDeviceTableRecordWithModel:(GSHDeviceM *)deviceM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL update = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        update = [self updateDeviceTableRecordWithDB:db deviceModel:deviceM];
    }];
    
    return update;
}

- (BOOL)updateDeviceTableRecordWithDB:(FMDatabase *)db deviceModel:(GSHDeviceM *)deviceM {
    return [db executeUpdate:@"update device_table set deviceName=? ,validateCode=?,firmwareVersion=?,agreementType=?,manufacturer=?,deviceId=?,deviceKind=?,deviceKindStr=?,deviceModel=?, deviceModelStr=?,deviceType=?,deviceTypeStr=?,gatewayId=?,familyId=?,floorId=?,floorName=?,roomId=?,roomName=?,defence=?,onlineStatus=?,permissionState=?,rank=? where deviceSn=?",
            [self checkNSString:deviceM.deviceName],
            [self checkNSString:deviceM.validateCode],
            [self checkNSString:deviceM.firmwareVersion],
            [self checkNSString:deviceM.agreementType],
            [self checkNSString:deviceM.manufacturer],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.deviceId]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.deviceKind]],
            [self checkNSString:deviceM.deviceKindStr],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.deviceModel]],
            [self checkNSString:deviceM.deviceModelStr],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.deviceType]],
            [self checkNSString:deviceM.deviceTypeStr],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.gatewayId]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.familyId]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.floorId]],
            [self checkNSString:deviceM.floorName],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.roomId]],
            [self checkNSString:deviceM.roomName],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.defence]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.onlineStatus]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.permissionState]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.rank]],
            [self checkNSString:[NSString stringWithFormat:@"%@",deviceM.deviceSn]]];
    
}

/**
 *  根据 device_table  删除一条记录
 *
 *  @param deviceSn 传入deviceSn字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteDeviceTableRecordWithDeviceSn:(NSString *)deviceSn {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'device_table' where deviceSn = ?", deviceSn];
    }];
    
    return result;
}

- (BOOL)deleteAllDeviceInfo {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'device_table'"];
    }];
    
    return result;
}

@end
