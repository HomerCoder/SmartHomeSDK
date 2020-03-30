//
//  GSHRoomDao.m
//  SmartHome
//
//  Created by zhanghong on 2019/1/30.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHRoomDao.h"
#import "GSHDataBaseManager.h"
#import "GSHRoomM.h"
#import <YYCategories/YYCategories.h>

@implementation GSHRoomDao

+(instancetype)shareRoomDao {
    static GSHRoomDao *roomDao = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        roomDao = [[GSHRoomDao alloc] init];
    });
    return roomDao;
}

/**
 *  查询 room_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectRoomTableWithFloorId:(NSString *)floorId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) {
        return @[];
    }
    __block NSMutableArray *modelArray = [NSMutableArray array];
    
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQueryWithFormat:@"select * from room_table where floorId = %@",floorId];
        
        while(rs.next) {
            GSHRoomM *roomM = [[GSHRoomM alloc] init];
            roomM.roomId = [[rs stringForColumn:@"roomId"] numberValue];
            roomM.roomName = [rs stringForColumn:@"roomName"];
            [modelArray addObject:roomM];
        }
        [rs close];
    }];
    
    return modelArray;
}

/**
 *  向 room_table 插入一条记录
 *
 *  @param roomM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertRoomTableRecordWithModel:(GSHRoomM *)roomM floorId:(NSString *)floorId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL insert = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        insert = [self insertRoomTableRecordWithDB:db model:roomM floorId:floorId];
    }];
    
    return insert;
}

- (BOOL)insertRoomTableRecordWithDB:(FMDatabase *)db model:(GSHRoomM *)roomM floorId:(NSString *)floorId {
    
    FMResultSet *rs = [db executeQueryWithFormat:@"select * from room_table where roomId =%@", roomM.roomId];
    
    while (rs.next) {
        // 存在两条deviceSn一样的记录 我们需要先删除再插入
        [db executeUpdate:@"delete from 'room_table' where roomId = ?", roomM.roomId];
        break;
    }
    [rs close];
    
    BOOL result = [db executeUpdate:@"insert into room_table (roomId,roomName,floorId) values (?,?,?)",
                   roomM.roomId.stringValue.length > 0 ? roomM.roomId.stringValue:@"",
                   roomM.roomName.length > 0 ? roomM.roomName : @"",
                   floorId.length > 0 ? floorId : @""];
    
    return result;
    
}

/**
 *  更新 room_table 一条记录
 *
 *  @param roomM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateRoomTableRecordWithModel:(GSHRoomM *)roomM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL update = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        update = [self updateRoomTableRecordWithDB:db model:roomM];
    }];
    
    return update;
}

- (BOOL)updateRoomTableRecordWithDB:(FMDatabase *)db model:(GSHRoomM *)roomM {
    return [db executeUpdate:@"update room_table set roomName=? where roomId=?",
            roomM.roomId.stringValue.length > 0 ? roomM.roomId.stringValue:@"",
            roomM.roomName.length > 0 ? roomM.roomName : @""];
}

/**
 *  根据 room_table  删除一条记录
 *
 *  @param roomId 传入roomId字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteRoomTableRecordWithRoomId:(NSString *)roomId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'room_table' where roomId = ?", roomId];
    }];
    
    return result;
}

- (BOOL)deleteAllRoomInfo {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'room_table'"];
    }];
    
    return result;
}

@end
