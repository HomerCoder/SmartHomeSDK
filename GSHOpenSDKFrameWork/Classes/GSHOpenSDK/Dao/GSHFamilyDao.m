//
//  GSHFamilyDao.m
//  SmartHome
//
//  Created by zhanghong on 2019/1/30.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHFamilyDao.h"
#import "GSHDataBaseManager.h"
#import "GSHFamilyM.h"
#import <YYCategories/YYCategories.h>

@implementation GSHFamilyDao

+(instancetype)shareFamilyDao {
    static GSHFamilyDao *familyDao = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        familyDao = [[GSHFamilyDao alloc] init];
    });
    return familyDao;
}

/**
 *  查询 family_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectFamilyTableAllRecord {
    
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) {
        return @[];
    }
    __block NSMutableArray *modelArray = [NSMutableArray array];
    
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"select * from family_table"];
        
        while(rs.next) {
            GSHFamilyM *familyM = [[GSHFamilyM alloc] init];
            familyM.familyId = [rs stringForColumn:@"familyId"];
            familyM.familyName = [rs stringForColumn:@"familyName"];
            familyM.address = [rs stringForColumn:@"address"];
            familyM.gatewayId = [rs stringForColumn:@"gatewayId"];
            familyM.onlineStatus = [[rs stringForColumn:@"onlineStatus"] intValue];
            familyM.permissions = [[rs stringForColumn:@"permissions"] intValue];
            familyM.project = [[rs stringForColumn:@"project"] numberValue];
            familyM.projectName = [rs stringForColumn:@"projectName"];
            familyM.picPath = [rs stringForColumn:@"picPath"];
            familyM.deviceCount = [[rs stringForColumn:@"deviceCount"] numberValue];
            [modelArray addObject:familyM];
        }
        [rs close];
    }];

    return modelArray;
}

/**
 *  向 family_table 插入一条记录
 *
 *  @param familyM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertFamilyTableRecordWithModel:(GSHFamilyM *)familyM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL insert = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        insert = [self insertFamilyTableRecordWithDB:db model:familyM];
    }];
    
    return insert;
}

- (BOOL)insertFamilyTableRecordWithDB:(FMDatabase *)db model:(GSHFamilyM *)familyM {
    
    FMResultSet *rs = [db executeQueryWithFormat:@"select * from family_table where familyId =%@", familyM.familyId];
    
    while (rs.next) {
        // 存在两条deviceSn一样的记录 我们需要先删除再插入
        [db executeUpdate:@"delete from 'family_table' where familyId = ?", familyM.familyId];
        break;
    }
    [rs close];
    
    return [db executeUpdate:@"insert into family_table (familyId,familyName,address,gatewayId,onlineStatus,permissions,project,projectName,picPath,deviceCount) values (?,?,?,?,?,?,?,?,?,?)",
            [self checkNSString:familyM.familyId],
            [self checkNSString:familyM.familyName],
            [self checkNSString:familyM.address],
            [self checkNSString:familyM.gatewayId],
            [self checkNSString:[NSString stringWithFormat:@"%d",(int)familyM.onlineStatus]],
            [self checkNSString:[NSString stringWithFormat:@"%d",(int)familyM.permissions]],
            [self checkNSString:[NSString stringWithFormat:@"%@",familyM.project]],
            [self checkNSString:familyM.projectName],
            [self checkNSString:familyM.picPath],
            [self checkNSString:[NSString stringWithFormat:@"%@",familyM.deviceCount]]];
            
}

- (NSString*)checkNSString:(NSString*)contentString {
    return [contentString length] == 0 ? @"" : contentString;
}

/**
 *  更新 family_table 一条记录
 *
 *  @param familyM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateFamilyTableRecordWithModel:(GSHFamilyM *)familyM {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL update = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        update = [self updateFamilyTableRecordWithDB:db model:familyM];
    }];
    
    return update;
}

- (BOOL)updateFamilyTableRecordWithDB:(FMDatabase *)db model:(GSHFamilyM *)familyM {
    return [db executeUpdate:@"update family_table set familyName=? ,address=?,gatewayId=?,onlineStatus=?,permissions=?,project=?,projectName=?,picPath=?,deviceCount=? where familyId=?",
            [self checkNSString:familyM.familyName],
            [self checkNSString:familyM.address],
            [self checkNSString:familyM.gatewayId],
            [self checkNSString:[NSString stringWithFormat:@"%d",(int)familyM.onlineStatus]],
            [self checkNSString:[NSString stringWithFormat:@"%d",(int)familyM.permissions]],
            [self checkNSString:[NSString stringWithFormat:@"%@",familyM.project]],
            [self checkNSString:familyM.projectName],
            [self checkNSString:familyM.picPath],
            [self checkNSString:[NSString stringWithFormat:@"%@",familyM.deviceCount]]];
}

/**
 *  根据 family_table  删除一条记录
 *
 *  @param familyId 传入familyId字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteFamilyTableRecordWithFamilyId:(NSString *)familyId {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'family_table' where familyId = ?", familyId];
    }];
    
    return result;
}

- (BOOL)deleteAllFamilyInfo {
    if (![[GSHDataBaseManager shareDataBase] haveCreateDB]) return NO;
    
    __block BOOL result = NO;
    [[GSHDataBaseManager shareDataBase].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from 'family_table'"];
    }];
    
    return result;
}

@end
