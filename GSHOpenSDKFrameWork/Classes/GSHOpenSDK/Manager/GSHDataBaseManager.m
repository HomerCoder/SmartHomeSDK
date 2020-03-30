//
//  GSHDateBaseManager.m
//  SmartHome
//
//  Created by zhanghong on 2019/1/25.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDataBaseManager.h"

#import "GSHFileManager.h"
#import <FMDBHelpers.h>
#import "GSHOpenSDKInternal.h"

@interface GSHDataBaseManager ()

@end

@implementation GSHDataBaseManager

+(instancetype)shareDataBase {
    static GSHDataBaseManager *dataBaseManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataBaseManager = [[GSHDataBaseManager alloc] init];
    });
    return dataBaseManager;
}

- (BOOL)haveCreateDB {
    
    if ([GSHOpenSDKShare share].userId.length > 0) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *dbDocPath = [NSString stringWithFormat:@"%@/DateBase", documentsPath];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@_db.sqlite", dbDocPath,[GSHOpenSDKShare share].userId];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            BOOL doc = [GSHFileManager createDocument:dbDocPath];
            if (!doc) {
                return NO;
            }
            if ([filePath length]) {
                self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
                [self createTable];
                return YES;
            }
        } else {
            if ([filePath length]) {
                self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
            }
            if (![self isExitTableWithName:@"scene_table"]) {
                // 创建场景表
                [self createSceneTable];
            }
            if (![self isExitTableWithName:@"auto_table"]) {
                // 创建联动表
                [self createAutoTable];
            }
            if (![self isExitTableWithName:@"sensor_table"]) {
                // 场景传感器表
                [self createSensorTable];
            }
            [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                if (![db columnExists:@"launchtime" inTableWithName:@"sensor_table"]) {
                    [db addColumn:@"launchtime" toTable:@"sensor_table" error:NULL];
                }
                if (![db columnExists:@"deviceModel" inTableWithName:@"sensor_table"]) {
                    [db addColumn:@"deviceModel" toTable:@"sensor_table" error:NULL];
                }
                if (![db columnExists:@"homePageIcon" inTableWithName:@"device_table"]) {
                    [db addColumn:@"homePageIcon" toTable:@"device_table" error:NULL];
                }
                if (![db columnExists:@"controlPicPath" inTableWithName:@"device_table"]) {
                    [db addColumn:@"controlPicPath" toTable:@"device_table" error:NULL];
                }
                if (![db columnExists:@"backgroundUrl" inTableWithName:@"scene_table"]) {
                    [db addColumn:@"backgroundUrl" toTable:@"scene_table" error:NULL];
                }
            }];
            return YES;
        }
    }
    return NO;
    
}

- (void)createTable {

    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"create table if not exists device_table (deviceId text not null,deviceName text,validateCode text,firmwareVersion text,agreementType text,manufacturer text,deviceSn text,deviceKind text,deviceKindStr text,deviceModel text,deviceModelStr text,deviceType text,deviceTypeStr text,gatewayId text,familyId text,floorId text,floorName text,roomId text,roomName text,defence text,onlineStatus text,permissionState text,rank text,attribute blob,launchtime text,homePageIcon text,controlPicPath text,dataId integer primary key AUTOINCREMENT)"];
        
        [db executeUpdate:@"create table if not exists family_table (familyId text not null,familyName text,address text,gatewayId text,onlineStatus text,permissions text,project text,projectName text,picPath text,deviceCount text,dataId integer primary key AUTOINCREMENT)"];
        
        [db executeUpdate:@"create table if not exists floor_table (floorId text not null,floorName text,familyId text,dataId integer primary key AUTOINCREMENT)"];
        
        [db executeUpdate:@"create table if not exists room_table (roomId text not null,roomName text,floorId text,dataId integer primary key AUTOINCREMENT)"];
        // 场景表
        [db executeUpdate:@"create table if not exists scene_table (scenarioId text not null,backgroundId text,familyId text,scenarioName text,floorName text,roomName text,roomId text,backgroundUrl text,dataId integer primary key AUTOINCREMENT)"];
        // 联动表
        [db executeUpdate:@"create table if not exists auto_table (ruleId text not null,familyId text,name text,relationType text,type text,status text,dataId integer primary key AUTOINCREMENT)"];
        // 传感器表
        [db executeUpdate:@"create table if not exists sensor_table (deviceSn text not null,deviceName text,deviceId text,deviceType text,roomName text,floorId text,familyId text,deviceModel text,launchtime text,attributeList blob,dataId integer primary key AUTOINCREMENT)"];
        
    }];

}

// 创建场景表
- (void)createSceneTable {
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"create table if not exists scene_table (scenarioId text not null,backgroundId text,familyId text,scenarioName text,floorName text,roomName text,roomId text ,backgroundUrl text,dataId integer primary key AUTOINCREMENT)"];
    }];
}

// 创建联动表
- (void)createAutoTable {
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"create table if not exists auto_table (ruleId text not null,familyId text,name text,relationType text,type text,status text,dataId integer primary key AUTOINCREMENT)"];
    }];
}

// 传感器表 deviceSn,deviceName,deviceId,deviceType,roomName,floorId,familyId,attributeList
- (void)createSensorTable {
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"create table if not exists sensor_table (deviceSn text not null,deviceName text,deviceId text,deviceType text,roomName text,floorId text,familyId text,deviceModel text,launchtime text,attributeList blob,dataId integer primary key AUTOINCREMENT)"];
    }];
}

- (BOOL)isExitTableWithName:(NSString *)name {
    __block BOOL isExit = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", name];
        while (rs.next) {
            NSInteger count = [rs intForColumn:@"count"];
            if (0 == count) {
                isExit = NO;
            } else {
                isExit = YES;
            }
        }
    }];
    return isExit;
}

@end
