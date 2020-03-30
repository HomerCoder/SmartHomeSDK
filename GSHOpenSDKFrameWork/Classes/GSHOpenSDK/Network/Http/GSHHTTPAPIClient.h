//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

extern NSString * const GSHHTTPAPIErrorDomain;

@interface GSHHTTPAPIClient : AFHTTPSessionManager
@property(nonatomic,copy)void(^responseBlock)(NSError *error);
- (instancetype)initWithBaseURL:(NSURL *)url;

// 在默认的GET方法后多加一个 useCache 参数，决定是否不使用离线缓存
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(id operationOrTask, id responseObject))success
                      failure:(void (^)(id operationOrTask, NSError *error))failure
                     useCache:(BOOL)useCache;

+ (NSURLSessionDataTask *)getWithAllUrl:(NSString *)allUrl
                   parameters:(id)parameters
                      success:(void (^)(id operationOrTask, id responseObject))success
                      failure:(void (^)(id operationOrTask, NSError *error))failure;
@end
