//
//  GSHBannerManager.h
//  GSHOpenSDK
//
//  Created by gemdale on 2019/11/12.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHBaseModel.h"

typedef enum : NSUInteger {
    GSHBannerMTypeShouYe = 1,
    GSHBannerMTypeChangJin,
    GSHBannerMTypeLianDong,
    GSHBannerMTypeWangZhuan
} GSHBannerMType;

//登录用户信息
@interface GSHBannerM : GSHBaseModel
@property(nonatomic,copy)NSNumber *bannerId;        //广告位id
@property(nonatomic,copy)NSString *content;         //广告位内容
@property(nonatomic,copy)NSString *fodderType;      //广告位类型
@property(nonatomic,copy)NSString *picUrl;          //广告位图片
@property(nonatomic,copy)NSString *title;           //广告位标题
@end

@interface GSHBannerManager : NSObject
+(NSURLSessionDataTask*)getBannerListWithBannerType:(GSHBannerMType)type block:(void(^)(NSArray<GSHBannerM*> *bannerList, NSError *error))block;
@end
