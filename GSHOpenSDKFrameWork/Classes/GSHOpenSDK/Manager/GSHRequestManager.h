//
//  GSHRequestManager.h
//  GSHOpenSDK
//
//  Created by gemdale on 2019/10/15.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSHRequestManager : NSObject
+(NSURLSessionDataTask*)postWithPath:(NSString*)path parameters:(NSDictionary*)parameters block:(void(^)(id responseObjec, NSError *error))block;

+(NSURLSessionDataTask*)getWithPath:(NSString*)path parameters:(NSDictionary*)parameters block:(void(^)(id responseObjec, NSError *error))block;
@end
