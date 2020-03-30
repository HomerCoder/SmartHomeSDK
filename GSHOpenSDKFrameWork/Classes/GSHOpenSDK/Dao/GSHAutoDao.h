//
//  GSHAutoDao.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/3.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHAutoM.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHAutoDao : NSObject

+ (instancetype)shareAutoDao;

/**
 *  查询 auto_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectAutoTableWithFamilyId:(NSString *)familyId;

/**
 *  向 auto_table 插入一条记录
 *
 *  @param ossAutoM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertAutoTableRecordWithModel:(GSHOssAutoM *)ossAutoM familyId:(NSString *)familyId;


/**
 *  更新 auto_table 一条记录
 *
 *  @param ossAutoM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateAutoTableRecordWithModel:(GSHOssAutoM *)ossAutoM;

/**
 *  根据 auto_table  删除一条记录
 *
 *  @param autoId 传入autoId字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteAutoTableRecordWithautoId:(NSString *)autoId;

- (BOOL)deleteAllAutoInfo;

@end

NS_ASSUME_NONNULL_END
