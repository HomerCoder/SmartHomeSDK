//
//  GSHFileManager.m
//  SmartHome
//
//  Created by zhanghong on 2018/12/26.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHFileManager.h"

#define LocalFileDir_Scene @"SmartHome_Scene"
#define LocalFileDir_Auto @"SmartHome_Auto"

@implementation GSHFileManager

+ (instancetype)shared {
    static GSHFileManager *_fileManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fileManager = [[GSHFileManager alloc] init];
    });
    
    return _fileManager;
}

// 创建目录
+ (BOOL)createDocument:(NSString*)filePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err = nil;
    if ([fm fileExistsAtPath:filePath] == NO) {
        [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            return NO;
        }
    }
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createDirWithDirName:LocalFileDir_Scene];
        [self createDirWithDirName:LocalFileDir_Auto];
    }
    return self;
}

- (void)createDirWithDirName:(NSString *)dirName {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //文件夹
    documentsPath = [documentsPath stringByAppendingPathComponent:dirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //是否是文件夹
    BOOL isDir;
    BOOL isExit = [fileManager fileExistsAtPath:documentsPath isDirectory:&isDir];
    //文件夹是否存在
    if (!isExit || !isDir) {
        [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString *)getDirPathWithFileType:(LocalStoreFileType)fileType {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (fileType == LocalStoreFileTypeScene) {
        // 场景
        documentsPath = [documentsPath stringByAppendingPathComponent:LocalFileDir_Scene];
    } else if (fileType == LocalStoreFileTypeAuto) {
        // 联动
        documentsPath = [documentsPath stringByAppendingPathComponent:LocalFileDir_Auto];
    }
    return documentsPath;
}

// 写入文件
- (BOOL)writeDataToFileWithFileType:(LocalStoreFileType)fileType fileName:(NSString *)fileName fileContent:(NSString *)fileContent {
    NSString *documentsPath =[self getDirPathWithFileType:fileType];
    NSString *testPath = [documentsPath stringByAppendingPathComponent:fileName];
    NSLog(@"文件存储路径 : %@",testPath);
    BOOL res = [fileContent writeToFile:testPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return res;
}

// 读取文件
- (NSString *)readDataWithFileType:(LocalStoreFileType)fileType fileName:(NSString *)fileName {
    NSString *documentsPath =[self getDirPathWithFileType:fileType];
    NSString *testPath = [documentsPath stringByAppendingPathComponent:fileName];
    NSString *content = [NSString stringWithContentsOfFile:testPath encoding:NSUTF8StringEncoding error:nil];
    return content;
}

// 删除文件
- (BOOL)deleteFileWithFileType:(LocalStoreFileType)fileType fileName:(NSString *)fileName {

    NSString *documentsPath =[self getDirPathWithFileType:fileType];
    NSString *testPath = [documentsPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:testPath]) {
        return [fileManager removeItemAtPath:testPath error:nil];
    } else {
        return YES;
    }
}


@end
