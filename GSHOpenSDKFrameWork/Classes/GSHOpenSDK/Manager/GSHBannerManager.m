//
//  GSHBannerManager.m
//  GSHOpenSDK
//
//  Created by gemdale on 2019/11/12.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHBannerManager.h"
#import "GSHOpenSDKInternal.h"

@implementation GSHBannerM

@end

@implementation GSHBannerManager
+(NSURLSessionDataTask*)getBannerListWithBannerType:(GSHBannerMType)type block:(void(^)(NSArray<GSHBannerM*> *bannerList, NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(type) forKey:@"bannerType"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getBannerList" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray<GSHBannerM*> *list = [NSArray yy_modelArrayWithClass:GSHBannerM.class json:[(NSDictionary *)responseObject objectForKey:@"list"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:YES];
}
@end
