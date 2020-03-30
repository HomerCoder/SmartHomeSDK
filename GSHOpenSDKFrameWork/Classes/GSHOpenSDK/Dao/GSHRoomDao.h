//
//  GSHRoomDao.h
//  SmartHome
//
//  Created by zhanghong on 2019/1/30.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHRoomM.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHRoomDao : NSObject

+ (instancetype)shareRoomDao;

/**
 *  查询 room_table 表中的全部记录
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectRoomTableWithFloorId:(NSString *)floorId;

/**
 *  向 room_table 插入一条记录
 *
 *  @param roomM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertRoomTableRecordWithModel:(GSHRoomM *)roomM floorId:(NSString *)floorId;

/**
 *  更新 room_table 一条记录
 *
 *  @param roomM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateRoomTableRecordWithModel:(GSHRoomM *)roomM;

/**
 *  根据 room_table  删除一条记录
 *
 *  @param roomId 传入roomId字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteRoomTableRecordWithRoomId:(NSString *)roomId;

- (BOOL)deleteAllRoomInfo;

@end

NS_ASSUME_NONNULL_END
