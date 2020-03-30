//
//  GSHFloorDao.m
//  SmartHome
//
//  Created by zhanghong on 2019/1/30.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHFloorDao.h"
#import "GSHDataBaseManager.h"
#import <YYCategories/YYCategories.h>

@implementation GSHFloorDao

+(instancetype)shareFloorDao {
    static GSHFloorDao *floorDao = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        floorDao = [[GSHFloorDao alloc] init];
    });
    return floorDao;
}

/**
 *  查询 floor_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectFloorTableWithFamilyId:(NSString *)familyId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) {
        return @[];
    }
    __block NSMutableArray *modelArray = [NSMutableArray array];
    
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQueryWithFormat:@"select * from floor_table where familyId = %@",familyId];
        
        while(rs.next) {
            GSHFloorM *floorM = [[GSHFloorM alloc] init];
            floorM.floorId = [[rs stringForColumn:@"floorId"] numberValue];
            floorM.floorName = [rs stringForColumn:@"floorName"];
            [modelArray addObject:floorM];
        }
        [rs close];
    }];
    return modelArray;
}

/**
 *  向 floor_table 插入一条记录
 *
 *  @param floorM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertFloorTableRecordWithModel:(GSHFloorM *)floorM familyId:(NSString *)familyId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL insert = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        insert = [self insertFloorTableRecordWithDB:db model:floorM familyId:familyId];
    }];
    
    return insert;
}

- (BOOL)insertFloorTableRecordWithDB:(FMDatabase *)db model:(GSHFloorM *)floorM familyId:(NSString *)familyId {
    
    FMResultSet *rs = [db executeQueryWithFormat:@"select * from floor_table where floorId =%@", floorM.floorId];
    
    while (rs.next) {
        // 存在两条deviceSn一样的记录 我们需要先删除再插入
        [db executeUpdate:@"delete from 'floor_table' where floorId = ?", floorM.floorId];
        break;
    }
    [rs close];
    
    return [db executeUpdate:@"insert into floor_table (floorId,floorName,familyId) values (?,?,?)",
            floorM.floorId.stringValue.length > 0 ? floorM.floorId.stringValue:@"",
            floorM.floorName.length > 0 ? floorM.floorName : @"",
            familyId.length > 0 ? familyId : @""];
    
}

/**
 *  更新 floor_table 一条记录
 *
 *  @param floorM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateFloorTableRecordWithModel:(GSHFloorM *)floorM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL update = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        update = [self updateFloorTableRecordWithDB:db model:floorM];
    }];
    
    return update;
}

- (BOOL)updateFloorTableRecordWithDB:(FMDatabase *)db model:(GSHFloorM *)floorM {
    return [db executeUpdate:@"update floor_table set floorName=? where floorId=?",
            floorM.floorId.stringValue.length > 0 ? floorM.floorId.stringValue:@"",
            floorM.floorName.length > 0 ? floorM.floorName : @""];
}

/**
 *  根据 floor_table  删除一条记录
 *
 *  @param floorId 传入floorId字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteFloorTableRecordWithFloorId:(NSString *)floorId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'floor_table' where floorId = ?", floorId];
    }];
    
    return result;
}

- (BOOL)deleteAllFloorInfo {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'floor_table'"];
    }];
    
    return result;
}

@end
