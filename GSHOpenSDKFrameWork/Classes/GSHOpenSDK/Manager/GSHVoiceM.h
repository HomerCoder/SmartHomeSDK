//
//  GSHVoiceM.h
//  SmartHome
//
//  Created by zhanghong on 2018/11/30.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHVoiceM : NSObject

@end

@interface GSHVoiceManager : NSObject

// 初始化讯飞SDK
+(void)initIFlyAppId:(NSString*)appId;

// POST 语音控制
+ (NSURLSessionDataTask *)voiceControlWithFamilyId:(NSString *)familyId
                                              text:(NSString *)text
                                             block:(void(^)(NSString *msg,NSError *error))block;

@end

NS_ASSUME_NONNULL_END
