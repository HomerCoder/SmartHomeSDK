//
//  GSHFileManager.h
//  SmartHome
//
//  Created by zhanghong on 2018/12/26.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LocalStoreFileType) {
    LocalStoreFileTypeScene  = 0,  // 场景数据
    LocalStoreFileTypeAuto   = 1,  // 联动数据
    LocalStoreFileTypeOther   = 2,  // 其他数据 -- 不创建文件夹
};

@interface GSHFileManager : NSObject

+ (instancetype)shared;

// 创建目录
+ (BOOL)createDocument:(NSString*)filePath;

// 写入文件
- (BOOL)writeDataToFileWithFileType:(LocalStoreFileType)fileType fileName:(NSString *)fileName fileContent:(NSString *)fileContent;

// 读取文件
- (NSString *)readDataWithFileType:(LocalStoreFileType)fileType fileName:(NSString *)fileName;

// 删除文件
- (BOOL)deleteFileWithFileType:(LocalStoreFileType)fileType fileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
