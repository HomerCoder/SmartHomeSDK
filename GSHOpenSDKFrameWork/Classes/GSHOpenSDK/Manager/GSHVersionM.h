//
//  GSHVersionM.h
//  SmartHome
//
//  Created by gemdale on 2018/5/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"
//检测版本类型
typedef enum : NSUInteger {
    GSHVersionMTypeApp,             //检测app
    GSHVersionMTypeGateway,         //检测网关
} GSHVersionMType;

@interface GSHVersionM : GSHBaseModel
@property (nonatomic,copy) NSString *version;           //新版本的版本号
@property (nonatomic,copy) NSString *name;              //标题
@property (nonatomic,copy) NSString *descInfo;          //更新说明文本
@property (nonatomic,copy) NSString *ext;               //版本简介
@property (nonatomic,copy) NSString *url;               //地址
@property (nonatomic,strong) NSNumber *force;           //是否需要强制更新。0.不需要更新 1.需要更新 2.强制更新 ,
//是否有最新版本大于本地版本
-(BOOL)versionGreaterThan:(NSString*)version;
//获取版本
+(NSURLSessionDataTask*)getVersionWithBlock:(void(^)(GSHVersionM *version,NSError *error))block;
@end
