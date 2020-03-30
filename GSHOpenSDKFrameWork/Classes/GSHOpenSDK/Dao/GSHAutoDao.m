//
//  GSHAutoDao.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/3.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAutoDao.h"
#import "GSHDataBaseManager.h"
#import <YYCategories/YYCategories.h>

@implementation GSHAutoDao

+ (instancetype)shareAutoDao {
    static GSHAutoDao *autoDao = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        autoDao = [[GSHAutoDao alloc] init];
    });
    return autoDao;
}

/**
 *  查询 auto_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectAutoTableWithFamilyId:(NSString *)familyId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) {
        return @[];
    }
    __block NSMutableArray *modelArray = [NSMutableArray array];
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQueryWithFormat:@"select * from auto_table where familyId = %@",familyId];
        
        while(rs.next) {
            GSHOssAutoM *ossAutoM = [[GSHOssAutoM alloc] init];
            ossAutoM.ruleId = [[rs stringForColumn:@"ruleId"] numberValue];
            ossAutoM.familyId = [[rs stringForColumn:@"familyId"] numberValue];
            ossAutoM.name = [rs stringForColumn:@"name"];
            ossAutoM.relationType = [[rs stringForColumn:@"relationType"] numberValue];
            ossAutoM.type = [[rs stringForColumn:@"type"] numberValue];
            ossAutoM.status = [[rs stringForColumn:@"status"] numberValue];
            [modelArray addObject:ossAutoM];
        }
        [rs close];
    }];
    return modelArray;
}

/**
 *  向 auto_table 插入一条记录
 *
 *  @param ossAutoM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertAutoTableRecordWithModel:(GSHOssAutoM *)ossAutoM familyId:(NSString *)familyId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL insert = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        insert = [self insertAutoTableRecordWithDB:db model:ossAutoM familyId:familyId];
    }];
    
    return insert;
}

- (BOOL)insertAutoTableRecordWithDB:(FMDatabase *)db model:(GSHOssAutoM *)ossAutoM familyId:(NSString *)familyId {
    
    FMResultSet *rs = [db executeQueryWithFormat:@"select * from auto_table where ruleId =%@", ossAutoM.ruleId];
    
    while (rs.next) {
        // 存在两条deviceSn一样的记录 我们需要先删除再插入
        [db executeUpdate:@"delete from 'auto_table' where ruleId = ?", ossAutoM.ruleId];
        break;
    }
    [rs close];
    
    BOOL result = [db executeUpdate:@"insert into auto_table (ruleId,familyId,name,relationType,type,status) values (?,?,?,?,?,?)",
                   ossAutoM.ruleId.stringValue.length > 0 ? ossAutoM.ruleId.stringValue:@"",
                   familyId,
                   ossAutoM.name.length > 0 ? ossAutoM.name : @"",
                   ossAutoM.relationType.stringValue.length > 0 ? ossAutoM.relationType.stringValue : @"",
                   ossAutoM.type.stringValue.length > 0 ? ossAutoM.type.stringValue : @"",
                   ossAutoM.status.stringValue.length > 0 ? ossAutoM.status.stringValue : @""];
    
    return result;
    
}

/**
 *  更新 auto_table 一条记录
 *
 *  @param ossAutoM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateAutoTableRecordWithModel:(GSHOssAutoM *)ossAutoM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL update = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        update = [self updateAutoTableRecordWithDB:db model:ossAutoM];
    }];
    
    return update;
}

- (BOOL)updateAutoTableRecordWithDB:(FMDatabase *)db model:(GSHOssAutoM *)ossAutoM {
    return [db executeUpdate:@"update auto_table set familyId=?,name=?,relationType=?,type=?,status=? where ruleId=?",
            ossAutoM.ruleId.stringValue.length > 0 ? ossAutoM.ruleId.stringValue:@"",
            ossAutoM.familyId.stringValue.length > 0 ? ossAutoM.familyId.stringValue : @"",
            ossAutoM.name.length > 0 ? ossAutoM.name : @"",
            ossAutoM.relationType.stringValue.length > 0 ? ossAutoM.relationType.stringValue : @"",
            ossAutoM.type.stringValue.length > 0 ? ossAutoM.type.stringValue : @"",
            ossAutoM.status.stringValue.length > 0 ? ossAutoM.status.stringValue : @""];
}

/**
 *  根据 auto_table  删除一条记录
 *
 *  @param autoId 传入autoId字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteAutoTableRecordWithautoId:(NSString *)autoId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'auto_table' where ruleId = ?", autoId];
    }];
    
    return result;
}

- (BOOL)deleteAllAutoInfo {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'auto_table'"];
    }];
    
    return result;
}

@end
