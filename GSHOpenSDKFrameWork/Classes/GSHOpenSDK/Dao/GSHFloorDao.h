//
//  GSHFloorDao.h
//  SmartHome
//
//  Created by zhanghong on 2019/1/30.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHFloorM.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHFloorDao : NSObject

+ (instancetype)shareFloorDao;

/**
 *  查询 floor_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectFloorTableWithFamilyId:(NSString *)familyId;

/**
 *  向 floor_table 插入一条记录
 *
 *  @param floorM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertFloorTableRecordWithModel:(GSHFloorM *)floorM familyId:(NSString *)familyId;

/**
 *  更新 floor_table 一条记录
 *
 *  @param floorM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateFloorTableRecordWithModel:(GSHFloorM *)floorM;

/**
 *  根据 floor_table  删除一条记录
 *
 *  @param floorId 传入floorId字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteFloorTableRecordWithFloorId:(NSString *)floorId;

- (BOOL)deleteAllFloorInfo;

@end

NS_ASSUME_NONNULL_END
