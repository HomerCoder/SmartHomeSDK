//
// Created by Roy on 15/3/12.
// Copyright (c) 2015 DaDaBus. All rights reserved.
//



#import "GSHHTTPAPIClient.h"
#import "GSHJSONRequestSerializer.h"
#import "GSHJSONResponseSerializer.h"
#import <arpa/inet.h>
#import "sys/utsname.h"
#import "GSHOpenSDKInternal.h"

NSString * const GSHHTTPAPIErrorDomain  = @"GSHHTTPAPIErrorDomain";

NSString * const GSHHTTPServerTimeDiff  = @"GSHHTTPServerTimeDiff";
NSString * const GSHHTTPServerTimeKey  = @"server_time";
NSString * const GSHHTTPServerTimeFormat  = @"yyyy-MM-dd";


// 缓存任务
@interface GSHURLSessionCacheDataTask : NSURLSessionDataTask
- (instancetype)initWithRequest:(NSURLRequest *)request cachedURLResponse:(NSCachedURLResponse *)cachedURLResponse error:(NSError *)error;
@end

@implementation GSHURLSessionCacheDataTask {
    NSURLRequest *_request;
    NSCachedURLResponse *_cachedURLResponse;
    NSError *_error;
}
- (instancetype)initWithRequest:(NSURLRequest *)request cachedURLResponse:(NSCachedURLResponse *)cachedURLResponse error:(NSError *)error {
    self = [self init];
    if(self){
        _request = request;
        _cachedURLResponse = cachedURLResponse;
        _error = error;
    }
    return self;
}

- (NSURLRequest *)originalRequest {
    return _request;
}

- (NSURLRequest *)currentRequest {
    return _request;
}

- (NSURLResponse *)response {
    return _cachedURLResponse.response;
}

- (void)cancel {
}

- (NSURLSessionTaskState)state {
    return NSURLSessionTaskStateCompleted;
}

- (NSError *)error {
    return _error;
}

- (void)suspend {
}

- (void)resume {
}

@end

#pragma mark - initLocationManager

@interface GSHHTTPAPIClient ()
@end

@implementation GSHHTTPAPIClient {
}

-(void)setResponseBlock:(void (^)(NSError *))responseBlock{
    _responseBlock = responseBlock;
    if ([self.responseSerializer isKindOfClass:GSHJSONResponseSerializer.class]) {
        ((GSHJSONResponseSerializer*)self.responseSerializer).responseBlock = responseBlock;
    }
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if ( self ) {
        GSHJSONRequestSerializer *requestSerializer = [GSHJSONRequestSerializer serializer];
        requestSerializer.timeoutInterval = 60;
        [self setRequestSerializer:requestSerializer];
        GSHJSONResponseSerializer *responseSerializer = [GSHJSONResponseSerializer serializer];
        [self setResponseSerializer:responseSerializer];
        
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
        if ([GSHOpenSDKInternal share].appid) {
            [self.requestSerializer setValue:@"3.0.0" forHTTPHeaderField:@"appVersion"];
        }else{
            [self.requestSerializer setValue:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"appVersion"];
        }
        [self.requestSerializer setValue:[GSHOpenSDKInternal share].appid forHTTPHeaderField:@"appId"];
        [self.requestSerializer setValue:[NSString stringWithFormat:@"%@%@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]] forHTTPHeaderField:@"deviceOS"];
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        [self.requestSerializer setValue:deviceString forHTTPHeaderField:@"deviceModel"];
    }
    return self;
}

#pragma mark - -----------------------重写方法
//这里覆盖AF的私有方法来实现离线缓存
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure{
    __block NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    
    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        return nil;
    }

    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request uploadProgress:uploadProgress downloadProgress:downloadProgress  completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        // 如果有错误
        if (error) {
            
            if (request.cachePolicy != NSURLRequestReloadIgnoringCacheData ) {
                // 如果没有网则走缓存
                if ([error.domain isEqualToString:NSURLErrorDomain]) {
                    request.URL = [self filterInfluenceCacheParamsURL:request.URL]; //过滤参数
                    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
                    if (cachedResponse != nil && cachedResponse.data.length > 0) {
                        id output = [self.responseSerializer responseObjectForResponse:cachedResponse.response data:cachedResponse.data error:&serializationError];
                        if (serializationError) {
                            if (failure) {
                                failure(dataTask, error);
                            }
                            return;
                        }
                        if (success) {
                            success(nil, output);
                        }
                        return;
                    }

                    if (failure) {
                        failure(dataTask, error);
                    }
                    return;
                }
            }

            if (failure) {
                failure(dataTask, error);
            }
        } else {
            //保存服务器与本地的时间差
            if([responseObject isKindOfClass:NSDictionary.class]) {
                NSString *serverTimeStr = [responseObject valueForKey:GSHHTTPServerTimeKey];
                if ( serverTimeStr.length ) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:GSHHTTPServerTimeFormat];
                    NSDate *serverDate = [formatter dateFromString:serverTimeStr];
                    NSTimeInterval difference = [serverDate timeIntervalSinceDate:[NSDate date]];
                    [[NSUserDefaults standardUserDefaults] setDouble:difference forKey:GSHHTTPServerTimeDiff];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }

            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    return dataTask;
}

- (void)URLSession:(NSURLSession *)session
                task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
// 这里将所有GET请求做缓存，条件：没有错误或者是API错误
    if ( !error || [error.domain isEqualToString:GSHHTTPAPIErrorDomain] ) {
        NSURLRequest *request = task.originalRequest;

        if ([[request.HTTPMethod uppercaseString] isEqualToString:@"GET"]){
            id delegate;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([self respondsToSelector:@selector(delegateForTask:)]){
                delegate = [self performSelector:@selector(delegateForTask:) withObject:task];
            }
#pragma clang diagnostic pop

            id data = [delegate valueForKey:@"mutableData"];
            if ([data isKindOfClass:NSData.class]) {
                if (((NSData*)data).length > 0) {
                    NSMutableURLRequest *mutableURLRequest = request.mutableCopy;
                    mutableURLRequest.URL = [self filterInfluenceCacheParamsURL:mutableURLRequest.URL];
                    NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:task.response data:data];
                    [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:mutableURLRequest];
                }
            }
        }
    }

    [super URLSession:session task:task didCompleteWithError:error];
}

#pragma mark-----------------------过滤掉会影响缓存的参数
- (NSURL *)filterInfluenceCacheParamsURL:(NSURL *)URL {
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:YES];
    NSArray *params = [components.query componentsSeparatedByString:@"&"];
    if ( params.count > 0 ) {
        NSMutableString *query = [NSMutableString string];
        for (NSString *param in params){
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if (elts.count == 2){
                NSString *key = elts[0];
                // 排除 cache_time, gps_sampling_time, lat, lng, device_id
                static NSArray *filterParams;
                @synchronized (self) {
                    if (!filterParams) {
                        filterParams = @[];
                    }
                }
                if (![filterParams containsObject:key]){
                    NSString *val = elts[1];
                    [query appendFormat:@"%@=%@&",key,val];
                }
            }
        }
        [query deleteCharactersInRange:NSMakeRange(query.length - 1,1)];
        components.query = query;
    }
    return components.URL;
}

#pragma mark-----------------------Get请求缓存方法
- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id operationOrTask, id responseObject))success failure:(void (^)(id operationOrTask, NSError *error))failure useCache:(BOOL)useCache {
    if ( useCache ) {
        return [self GET:URLString parameters:parameters progress:nil success:success failure:failure];
    }else {
        NSError *serializationError = nil;
        NSMutableURLRequest *request = [[self requestSerializer] requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:[self baseURL]] absoluteString] parameters:parameters error:&serializationError];
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;//标记不使用缓存
        if (serializationError) {
            if (failure) {
                dispatch_async([self completionQueue] ?: dispatch_get_main_queue(), ^{
                    failure(nil, serializationError);
                });
            }
            return nil;
        }

        AFHTTPSessionManager *sessionManager = self;
        __block NSURLSessionDataTask *dataTask = [sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *__unused response, id responseObject, NSError *error) {
            if (error && failure) {
                failure(dataTask, error);
            } else if ( success ) {
                success(dataTask, responseObject);
            }
        }];

        [dataTask resume];
        return dataTask;
    }
    return nil;
}

+ (NSURLSessionDataTask *)getWithAllUrl:(NSString *)allUrl
                   parameters:(id)parameters
                      success:(void (^)(id operationOrTask, id responseObject))success
                      failure:(void (^)(id operationOrTask, NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/plain",@"text/javascript",@"application/x-gzip" ,nil];
    return [manager GET:allUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

//- (NSTimeInterval)remoteTimeDiff {
//    return [[NSUserDefaults standardUserDefaults] doubleForKey:GSHHTTPServerTimeDiff];
//}
//
//- (NSDate *)remoteTime {
//    NSDate *result = [[NSDate date] dateByAddingTimeInterval:self.remoteTimeDiff];
//    return result;
//}
//
//// 看本地缓存时间是否过期，返回 YES 代表缓存已过期或没有缓存
//- (BOOL)expiredCacheResponseObject:(NSDictionary *)cacheResponseObject cacheExpires:(NSTimeInterval)cacheExpires {
//    NSString *serverTimeStr = [cacheResponseObject stringValueForKey:GSHHTTPServerTimeKey default:nil];
//    if ( serverTimeStr.length > 0 ) {
//        NSDate *cacheDate = [NSDate dateWithString:serverTimeStr format:GSHHTTPServerTimeFormat];
//        NSDate *serverData = [self remoteTime];
//        // 比较时间算出缓存是否已经过期
//        double sinceDiff = [serverData timeIntervalSinceDate:cacheDate];
//        return sinceDiff >= cacheExpires;
//    }else {
//        return YES;
//    }
//}
//
//- (id)GETFromCacheWithURL:(NSString *)URLString parameters:(id)parameters error:(NSError * __autoreleasing *)error {
//    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:error];
//    request.URL = [self filterInfluenceCacheParamsURL:request.URL];
//    NSLog(@"GETFromCacheWithURL: %@",request);
//    NSCachedURLResponse *cachedURLResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
//    if ( cachedURLResponse ) {
//        return [self.responseSerializer responseObjectForResponse:cachedURLResponse.response data:cachedURLResponse.data error:error];
//    }else{
//        return nil;
//    }
//}
//
//- (id)GETFromCacheWithURL:(NSString *)URLString parameters:(id)parameters cacheExpires:(NSTimeInterval)cacheExpires {
//    NSError *error = nil;
//    id cacheResponseObject = [self GETFromCacheWithURL:URLString parameters:parameters error:&error];
//    // 如果缓存已经过期则返回空
//    if([self expiredCacheResponseObject:cacheResponseObject cacheExpires:cacheExpires]){
//        return nil;
//    }
//    return cacheResponseObject;
//}

//- (NSURLSessionDataTask *)GET:(NSString *)URLString
//                   parameters:(id)parameters
//                      success:(void (^)(id operationOrTask, id responseObject))success
//                      failure:(void (^)(id operationOrTask, NSError *error))failure
//                 cacheExpires:(NSTimeInterval)cacheExpires {
//    return [self GET:URLString parameters:parameters progress:nil success:success failure:failure cacheExpires:cacheExpires];
//}

//- (NSURLSessionDataTask *)GET:(NSString *)URLString
//                   parameters:(id)parameters
//                     progress:(void (^)(NSProgress *))downloadProgress
//                      success:(void (^)(id operationOrTask, id responseObject))success
//                      failure:(void (^)(id operationOrTask, NSError *error))failure
//                 cacheExpires:(NSTimeInterval)cacheExpires {
//
//    __block id cacheResponseObject = nil;
//    GSHURLSessionCacheDataTask *cacheDataTask = [self GETFromCache:URLString parameters:parameters success:^(id operationOrTask, id responseObject) {
//        cacheResponseObject = responseObject;
//    } failure:NULL];
//
//    // 如果缓存没过期则使用缓存
//    if(![self expiredCacheResponseObject:cacheResponseObject cacheExpires:cacheExpires]){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(!cacheDataTask.error){
//                if(success)success(cacheDataTask,cacheResponseObject);
//            } else {
//                if(failure)failure(cacheDataTask,cacheDataTask.error);
//            }
//        });
//        return cacheDataTask;
//    } else {
//        return [self GET:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
//    }
//}

//- (GSHURLSessionCacheDataTask *)GETFromCache:(NSString *)URLString
//                                  parameters:(id)parameters
//                                     success:(void (^)(id operationOrTask, id responseObject))success
//                                     failure:(void (^)(id operationOrTask, NSError *error))failure {
//
//    NSError *error = nil;
//    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&error];
//    request.URL = [self filterInfluenceCacheParamsURL:request.URL];
//    NSLog(@"GETFromCacheWithURL: %@",request);
//
//    NSCachedURLResponse *cachedURLResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
//
//    id responseObject = [self.responseSerializer responseObjectForResponse:cachedURLResponse.response data:cachedURLResponse.data error:&error];
//
//    GSHURLSessionCacheDataTask *cacheDataTask = [[GSHURLSessionCacheDataTask alloc] initWithRequest:request cachedURLResponse:cachedURLResponse error:error];
//    if(!error){
//        if(success)success(cacheDataTask,responseObject);
//    } else {
//        if(failure)failure(cacheDataTask,error);
//    }
//    return cacheDataTask;
//}

@end
