//
//  GSHDateBaseManager.h
//  SmartHome
//
//  Created by zhanghong on 2019/1/25.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHDataBaseManager : NSObject

+(instancetype)shareDataBase;

- (BOOL)haveCreateDB;

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

//@property (nonatomic, strong) FMDatabase *database;

- (BOOL)isExitTableWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
