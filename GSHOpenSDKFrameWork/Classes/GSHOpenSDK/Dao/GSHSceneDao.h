//
//  GSHSceneDao.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/3.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHSceneM.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHSceneDao : NSObject

+ (instancetype)shareSceneDao;

/**
 *  查询 scene_table 表中的全部记录 返回类型为GSHOssSceneM
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectSceneTableWithFamilyId:(NSString *)familyId;

/**
 *  查询 scene_table 表中的全部记录 主要用于首页场景查询，返回类型为GSHSceneM
 *
 *  @return 查询到的结果
 */
- (NSArray *)selectSceneTableWithRoomId:(NSString *)roomId;

/**
 *  向 scene_table 插入一条记录
 *
 *  @param ossSceneM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)insertSceneTableRecordWithModel:(GSHOssSceneM *)ossSceneM;


/**
 *  更新 scene_table 一条记录
 *
 *  @param ossSceneM 传入模型
 *
 *  @return 成功或失败
 */
- (BOOL)updateSceneTableRecordWithModel:(GSHOssSceneM *)ossSceneM;

/**
 *  根据 scene_table  删除一条记录
 *
 *  @param sceneId 传入sceneId字符串
 *
 *  @return 成功或失败
 */
- (BOOL)deleteSceneTableRecordWithSceneId:(NSString *)sceneId;

- (BOOL)deleteAllSceneInfo;

@end

NS_ASSUME_NONNULL_END
