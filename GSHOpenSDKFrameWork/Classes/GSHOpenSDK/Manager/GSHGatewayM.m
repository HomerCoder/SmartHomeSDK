//
//  GSHGatewayM.m
//  SmartHome
//
//  Created by gemdale on 2018/5/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHGatewayM.h"
#import "GSHOpenSDKInternal.h"
#import "GSHFamilyM.h"
#import <YYCategories/YYCategories.h>

@implementation GSHGatewayVersionM
@end

@implementation GSHGatewayM
@end

@implementation GSHGatewayManager
//添加网关
+(NSURLSessionDataTask*)postAddGatewayWithFamilyId:(NSString*)familyId gatewayId:(NSString*)gatewayId gatewayName:(NSString*)gatewayName block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:gatewayId forKey:@"gatewayId"];
    [dic setValue:gatewayName forKey:@"gatewayName"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"setting/addGW" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (familyId) {
            if ([[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
                [GSHOpenSDKShare share].currentFamily.gatewayId = gatewayId;
                [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyUpdataNotification object:[GSHOpenSDKShare share].currentFamily]];
            }
        }
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}
// 删除网关 /setting/deleteGW
+ (NSURLSessionDataTask *)deleteGWWithFamilyId:(NSString *)familyId password:(NSString*)password block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (password.length > 0) {
        NSData *pwd = [password dataUsingEncoding:NSUTF8StringEncoding];
        pwd = [pwd md5Data];
        password = [pwd base64EncodedStringWithOptions:0];
        [dic setValue:password forKey:@"pwd"];
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"userInfo/confirmPwd" parameters:dic success:^(id operationOrTask, id responseObject) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:familyId forKey:@"familyId"];
            [[GSHOpenSDKInternal share].httpAPIClient POST:@"/setting/deleteGW" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
                if (familyId) {
                    if ([[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
                        [GSHOpenSDKShare share].currentFamily.gatewayId = nil;
                        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyUpdataNotification object:[GSHOpenSDKShare share].currentFamily]];
                    }
                }
                if (block) {
                    block(nil);
                }
            } failure:^(id operationOrTask, NSError *error) {
                if (block) {
                    block(error);
                }
            }];
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(error);
            }
        } useCache:NO];
    }else{
        [dic setValue:familyId forKey:@"familyId"];
        return [[GSHOpenSDKInternal share].httpAPIClient POST:@"/setting/deleteGW" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
            if (familyId) {
                if ([[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
                    [GSHOpenSDKShare share].currentFamily.gatewayId = nil;
                    [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyUpdataNotification object:[GSHOpenSDKShare share].currentFamily]];
                }
            }
            if (block) {
                block(nil);
            }
        } failure:^(id operationOrTask, NSError *error) {
            if (block) {
                block(error);
            }
        }];
    }
}
//获取网关
+(NSURLSessionDataTask*)getGatewayWithFamilyId:(NSString*)familyId gatewayId:(NSString*)gatewayId block:(void(^)(GSHGatewayM *gateWayM ,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:gatewayId forKey:@"gwId"];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getGW" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHGatewayM *gateWayM = [GSHGatewayM yy_modelWithJSON:responseObject];
        if (block) {
            block(gateWayM,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];

}

//获取网关信息
+(NSURLSessionDataTask*)getGatewayStateWithGatewayId:(NSString*)gatewayId block:(void(^)(GSHGatewayM *gateWayM ,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:gatewayId forKey:@"gatewayId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"general/queryGatewayStatus" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHGatewayM *gateWayM = [GSHGatewayM yy_modelWithJSON:responseObject];
        if (block) {
            block(gateWayM,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// 获取网关升级信息
+(NSURLSessionDataTask*)getGatewayUpdateMsgWithFamilyId:(NSString*)familyId gatewayId:(NSString*)gatewayId block:(void(^)(GSHGatewayVersionM *gateWayVersionM ,NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:gatewayId forKey:@"gatewayId"];
    [dic setValue:familyId forKey:@"familyId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getGatewayUpdateMsg" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHGatewayVersionM *gateWayVersionM = [GSHGatewayVersionM yy_modelWithJSON:responseObject];
        if (block) {
            block(gateWayVersionM,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    } useCache:NO];
}

// 远程升级 /setting/remoteGatewayUpdate
+(NSURLSessionDataTask*)updateGatewayWithFamilyId:(NSString*)familyId gatewayId:(NSString*)gatewayId versionId:(NSString *)versionId block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:gatewayId forKey:@"gatewayId"];
    [dic setValue:versionId forKey:@"versionId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"setting/remoteGatewayUpdate" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

+(NSURLSessionDataTask*)resetGatewayWithGatewayId:(NSString*)gatewayId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (gatewayId) {
        [dic setValue:@[gatewayId] forKey:@"gatewayList"];
    }
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"setting/rebootGW" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// 获取备份
+(NSURLSessionDataTask*)getCopyGatewayWithGatewayId:(NSString*)gatewayId familyId:(NSString*)familyId block:(void(^)(NSError *error,NSDictionary *dic))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:gatewayId forKey:@"gatewayId"];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"gateway/backup/getBackupInfo" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error,nil);
        }
    }];
}

// 恢复
+(NSURLSessionDataTask*)recoveryGatewayWithGatewayId:(NSString*)gatewayId familyId:(NSString*)familyId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:gatewayId forKey:@"gatewayId"];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"gateway/backup/doRecovery" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// 备份
+(NSURLSessionDataTask*)copyGatewayWithGatewayId:(NSString*)gatewayId familyId:(NSString*)familyId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:gatewayId forKey:@"gatewayId"];
    [dic setValue:familyId forKey:@"familyId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"gateway/backup/doBackup" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

// 替换
+(NSURLSessionDataTask*)changeGatewayWithGatewayId:(NSString*)gatewayId newGatewayId:(NSString*)newGatewayId familyId:(NSString*)familyId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:gatewayId forKey:@"gatewayId"];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:newGatewayId forKey:@"newGatewayId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"gateway/backup/replaceGateway" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (familyId) {
            if ([[GSHOpenSDKShare share].currentFamily.familyId isEqualToString:familyId]) {
                [GSHOpenSDKShare share].currentFamily.onlineStatus = GSHFamilyMGWStatusChange;
                [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHOpenSDKFamilyUpdataNotification object:[GSHOpenSDKShare share].currentFamily]];
            }
        }
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}
@end
