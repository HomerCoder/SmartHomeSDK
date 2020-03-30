//
//  GSHFamilyDao.h
//  SmartHome
//
//  Created by zhanghong on 2019/1/30.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHFamilyM.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHFamilyDao : NSObject

+ (instancetype)shareFamilyDao;

/**
 *  查询 family_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectFamilyTableAllRecord;

/**
 *  向 family_table 插入一条记录
 *
 *  @param familyM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertFamilyTableRecordWithModel:(GSHFamilyM *)familyM;

/**
 *  更新 family_table 一条记录
 *
 *  @param familyM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateFamilyTableRecordWithModel:(GSHFamilyM *)familyM;

/**
 *  根据 family_table  删除一条记录
 *
 *  @param familyId 传入familyId字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteFamilyTableRecordWithFamilyId:(NSString *)familyId;

- (BOOL)deleteAllFamilyInfo;

@end

NS_ASSUME_NONNULL_END
