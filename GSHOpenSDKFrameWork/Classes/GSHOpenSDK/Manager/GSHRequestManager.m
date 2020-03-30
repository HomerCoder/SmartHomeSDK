//
//  GSHRequestManager.m
//  GSHOpenSDK
//
//  Created by gemdale on 2019/10/15.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHRequestManager.h"
#import "GSHOpenSDKInternal.h"

@implementation GSHRequestManager
+(NSURLSessionDataTask*)postWithPath:(NSString*)path parameters:(NSDictionary*)parameters block:(void(^)(id  _Nullable responseObjec, NSError *error))block{
    return [[GSHOpenSDKInternal share].httpAPIClient POST:path parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+(NSURLSessionDataTask*)getWithPath:(NSString*)path parameters:(NSDictionary*)parameters block:(void(^)(id  _Nullable responseObjec, NSError *error))block{
    return [[GSHOpenSDKInternal share].httpAPIClient GET:path parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    } useCache:NO];
}
@end
