//
//  GSHOSSManagerClient.h
//  SmartHome
//
//  Created by zhanghong on 2018/12/26.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface GSHOSSManagerClient : AFHTTPSessionManager

- (instancetype)initWithBaseURL:(NSURL *)url;

// seaweedfs 获取fid
- (NSURLSessionDataTask *)getFileIdFromSeaweedfsWithBlock:(void(^)(NSString *fid,NSString *url,NSError *error))block;

// seaweedfs 上传文件
- (NSURLSessionDataTask *)uploadFileToSeaweedfsWithUrl:(NSString *)url
                                              fileData:(NSData *)fileData
                                              fileName:(NSString *)fileName
                                              mimeType:(NSString *)mimeType
                                                 block:(void(^)(NSError *error))block;

// 读取文件 -- 获取local url
- (NSURLSessionDataTask *)getLocalUrlFromSeaweedfsWithVolumeId:(NSString *)volumeId
                                                         block:(void(^)(NSArray *urlArray,NSError *error))block;

// 读取文件
- (NSURLSessionDataTask *)getFileDataFromSeaweedfsWithUrl:(NSString *)url
                                                    block:(void(^)(NSString *json,NSError *error))block;

// 删除文件
- (NSURLSessionDataTask *)deleteFileFromSeaweedfsWithUrlStr:(NSString *)urlStr
                                                      block:(void(^)(NSError *error))block;

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(id operationOrTask, id responseObject))success
                      failure:(void (^)(id operationOrTask, NSError *error))failure;

@end

