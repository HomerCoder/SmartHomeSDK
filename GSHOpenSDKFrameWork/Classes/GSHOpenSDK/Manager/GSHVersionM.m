//
//  GSHVersionM.m
//  SmartHome
//
//  Created by gemdale on 2018/5/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHVersionM.h"
#import "GSHOpenSDKInternal.h"
@implementation GSHVersionM
-(BOOL)versionGreaterThan:(NSString*)version{
    // 获取版本号字段
    NSArray<NSString*> *localityArray = [version componentsSeparatedByString:@"."];
    NSArray<NSString*> *cloudsArray = [self.version componentsSeparatedByString:@"."];
    NSUInteger count = (localityArray.count > cloudsArray.count) ? cloudsArray.count : localityArray.count;
    for (int i = 0; i < count; i++) {
        if (cloudsArray[i].integerValue > localityArray[i].integerValue) {
            return YES;
        }
    }
    return cloudsArray.count > localityArray.count;
}

+(NSURLSessionDataTask*)getVersionWithBlock:(void(^)(GSHVersionM *version,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    [dic setValue:version forKey:@"version"];
    [dic setValue:@(4) forKey:@"type"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"general/checkVersion" parameters:dic success:^(id operationOrTask, id responseObject) {
        GSHVersionM *m = [GSHVersionM yy_modelWithJSON:responseObject];
        if (block) {
            block(m,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}
@end
