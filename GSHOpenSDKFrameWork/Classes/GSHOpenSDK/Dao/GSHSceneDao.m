//
//  GSHSceneDao.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/3.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHSceneDao.h"
#import "GSHDataBaseManager.h"
#import <YYCategories/YYCategories.h>

@implementation GSHSceneDao

+ (instancetype)shareSceneDao {
    static GSHSceneDao *sceneDao = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sceneDao = [[GSHSceneDao alloc] init];
    });
    return sceneDao;
}

/**
 *  查询 scene_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectSceneTableWithFamilyId:(NSString *)familyId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) {
        return @[];
    }
    __block NSMutableArray *modelArray = [NSMutableArray array];
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQueryWithFormat:@"select * from scene_table where familyId = %@",familyId];
        
        while(rs.next) {
            GSHOssSceneM *ossSceneM = [[GSHOssSceneM alloc] init];
            ossSceneM.scenarioId = [[rs stringForColumn:@"scenarioId"] numberValue];
            ossSceneM.backgroundId = [[rs stringForColumn:@"backgroundId"] numberValue];
            ossSceneM.familyId = [[rs stringForColumn:@"familyId"] numberValue];
            ossSceneM.scenarioName = [rs stringForColumn:@"scenarioName"];
            ossSceneM.floorName = [rs stringForColumn:@"floorName"];
            ossSceneM.roomName = [rs stringForColumn:@"roomName"];
            ossSceneM.roomId = [[rs stringForColumn:@"roomId"] numberValue];
            ossSceneM.backgroundUrl = [rs stringForColumn:@"backgroundUrl"];
            [modelArray addObject:ossSceneM];
        }
        [rs close];
    }];
    return modelArray;
}

/**
 *  查询 scene_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectSceneTableWithRoomId:(NSString *)roomId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) {
        return @[];
    }
    __block NSMutableArray *modelArray = [NSMutableArray array];
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQueryWithFormat:@"select * from scene_table where roomId = %@",roomId];
        
        while(rs.next) {
            GSHOssSceneM *ossSceneM = [[GSHOssSceneM alloc] init];
            ossSceneM.scenarioId = [[rs stringForColumn:@"scenarioId"] numberValue];
            ossSceneM.backgroundId = [[rs stringForColumn:@"backgroundId"] numberValue];
            ossSceneM.familyId = [[rs stringForColumn:@"familyId"] numberValue];
            ossSceneM.scenarioName = [rs stringForColumn:@"scenarioName"];
            ossSceneM.floorName = [rs stringForColumn:@"floorName"];
            ossSceneM.roomName = [rs stringForColumn:@"roomName"];
            ossSceneM.roomId = [[rs stringForColumn:@"roomId"] numberValue];
            ossSceneM.backgroundUrl = [rs stringForColumn:@"backgroundUrl"];
            [modelArray addObject:ossSceneM];
        }
        [rs close];
    }];
    return modelArray;
}

/**
 *  向 scene_table 插入一条记录
 *
 *  @param GSHOssSceneM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertSceneTableRecordWithModel:(GSHOssSceneM *)ossSceneM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL insert = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        insert = [self insertSceneTableRecordWithDB:db model:ossSceneM];
    }];
    
    return insert;
}

- (BOOL)insertSceneTableRecordWithDB:(FMDatabase *)db model:(GSHOssSceneM *)ossSceneM {
    
    FMResultSet *rs = [db executeQueryWithFormat:@"select * from scene_table where scenarioId =%@", ossSceneM.scenarioId];
    
    while (rs.next) {
        // 存在两条deviceSn一样的记录 我们需要先删除再插入
        [db executeUpdate:@"delete from 'scene_table' where scenarioId = ?", ossSceneM.scenarioId];
        break;
    }
    [rs close];
    
    BOOL result = [db executeUpdate:@"insert into scene_table (scenarioId,backgroundId,familyId,scenarioName,floorName,roomName,roomId,backgroundUrl) values (?,?,?,?,?,?,?,?)",
                   ossSceneM.scenarioId.stringValue.length > 0 ? ossSceneM.scenarioId.stringValue:@"",
                   ossSceneM.backgroundId.stringValue.length > 0 ? ossSceneM.backgroundId.stringValue : @"",
                   ossSceneM.familyId.stringValue.length > 0 ? ossSceneM.familyId.stringValue : @"",
                   ossSceneM.scenarioName.length > 0 ? ossSceneM.scenarioName : @"",
                   ossSceneM.floorName.length > 0 ? ossSceneM.floorName : @"",
                   ossSceneM.roomName.length > 0 ? ossSceneM.roomName : @"",
                   ossSceneM.roomId.stringValue.length > 0 ? ossSceneM.roomId.stringValue : @"",
                   ossSceneM.backgroundUrl.length > 0 ? ossSceneM.backgroundUrl : @""];
    
    return result;
    
}

/**
 *  更新 scene_table 一条记录
 *
 *  @param GSHOssSceneM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateSceneTableRecordWithModel:(GSHOssSceneM *)ossSceneM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL update = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        update = [self updateSceneTableRecordWithDB:db model:ossSceneM];
    }];
    
    return update;
}

- (BOOL)updateSceneTableRecordWithDB:(FMDatabase *)db model:(GSHOssSceneM *)ossSceneM {
    return [db executeUpdate:@"update scene_table set backgroundId=?,familyId=?,scenarioName=?,floorName=?,roomName=?,roomId=?,backgroundUrl=? where scenarioId=?",
            ossSceneM.backgroundId.stringValue.length > 0 ? ossSceneM.backgroundId.stringValue:@"",
            ossSceneM.familyId.stringValue.length > 0 ? ossSceneM.familyId.stringValue : @"",
            ossSceneM.scenarioName.length > 0 ? ossSceneM.scenarioName : @"",
            ossSceneM.floorName.length > 0 ? ossSceneM.floorName : @"",
            ossSceneM.roomName.length > 0 ? ossSceneM.roomName : @"",
            ossSceneM.roomId.stringValue.length > 0 ? ossSceneM.roomId.stringValue : @"",
            ossSceneM.scenarioId.stringValue.length > 0 ? ossSceneM.scenarioId.stringValue : @"",
            ossSceneM.backgroundUrl.length > 0 ? ossSceneM.backgroundUrl : @""];
}

/**
 *  根据 scene_table  删除一条记录
 *
 *  @param sceneId 传入sceneId字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteSceneTableRecordWithSceneId:(NSString *)sceneId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'scene_table' where scenarioId = ?", sceneId];
    }];
    
    return result;
}

- (BOOL)deleteAllSceneInfo {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'scene_table'"];
    }];
    
    return result;
}

@end
