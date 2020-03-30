//
//  GSHOSSManagerClient.m
//  SmartHome
//
//  Created by zhanghong on 2018/12/26.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHOSSManagerClient.h"
#import "NSDictionary+TZM.h"

@implementation GSHOSSManagerClient

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if ( self ) {
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
    }
    return self;
}

// seaweedfs 获取fid
- (NSURLSessionDataTask *)getFileIdFromSeaweedfsWithBlock:(void(^)(NSString *fid,NSString *url,NSError *error))block {
    return [self GET:@"dir/assign" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *fileId,*url;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            fileId = [(NSDictionary *)responseObject objectForKey:@"fid"];
            url = [(NSDictionary *)responseObject objectForKey:@"publicUrl"];
        }
        if (block) {
            block(fileId,url,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,nil,error);
        }
    }];
}

// seaweedfs 上传文件
- (NSURLSessionDataTask *)uploadFileToSeaweedfsWithUrl:(NSString *)url
                                              fileData:(NSData *)fileData
                                              fileName:(nonnull NSString *)fileName
                                              mimeType:(NSString *)mimeType
                                                 block:(void(^)(NSError *error))block {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/plain",@"text/javascript" ,nil];
    
    return [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:mimeType];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// 读取文件 -- 获取local url
- (NSURLSessionDataTask *)getLocalUrlFromSeaweedfsWithVolumeId:(NSString *)volumeId block:(void(^)(NSArray *urlArray,NSError *error))block {

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:volumeId?volumeId:@"" forKey:@"volumeId"];

    return [self GET:@"dir/lookup" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *arr;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            arr = [(NSDictionary *)responseObject objectForKey:@"locations"];
        }
        if (block) {
            block(arr,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// 读取文件
- (NSURLSessionDataTask *)getFileDataFromSeaweedfsWithUrl:(NSString *)url block:(void(^)(NSString *json,NSError *error))block {
    return [self GET:url parameters:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(responseObject,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

// 删除文件
- (NSURLSessionDataTask *)deleteFileFromSeaweedfsWithUrlStr:(NSString *)urlStr block:(void(^)(NSError *error))block {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"DELETE";
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (block) {
                block(error);
            }
        } else {
            if (block) {
                block(nil);
            }
        }
    }];
    [dataTask resume];
    return dataTask;
}


- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(id operationOrTask, id responseObject))success
                      failure:(void (^)(id operationOrTask, NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/plain",@"text/javascript",@"application/x-gzip" ,nil];
    return [manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *json = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Response GET: %@ , %@ \njson : %@", task.currentRequest.URL,parameters?parameters:@"",json);
        if (success) {
            success(task,json);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task,error);
        }
    }];
}


@end
