//
//  GSHDoorLockManager.m
//  GSHOpenSDK
//
//  Created by 唐作明 on 2020/2/24.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDoorLockManager.h"
#import "GSHOpenSDKInternal.h"
#import "GSHUserM.h"
#import "YYCategories.h"

NSString *const GSHDoorLockManagerPassWordChangeNotification = @"GSHDoorLockManagerPassWordChangeNotification";

@implementation GSHDoorLockPassWordM
-(NSDate*)date{
    if (!_date) {
        _date = [NSDate dateWithTimeIntervalSince1970:(self.expireTime.doubleValue / 1000)];
    }
    return _date;
}
-(NSDate*)createDate{
    if (!_createDate) {
        _createDate = [NSDate dateWithTimeIntervalSince1970:(self.createTime.doubleValue / 1000)];
    }
    return _createDate;
}
@end

@implementation GSHDoorLockPassWordListM{
    NSString *_dateString;
}
-(NSString*)dateString{
    if (!_dateString) {
        if (_date) {
            _dateString = [_date stringWithFormat:@"yyyyMMdd"];
        }
    }
    return _dateString;
}
@end

@implementation GSHDoorLockRecordM
-(NSDate*)date{
    if (!_date) {
        _date = [NSDate dateWithTimeIntervalSince1970:(self.createTime.doubleValue / 1000)];
    }
    return _date;
}
-(NSString*)dateString{
    if (!_dateString) {
        if (self.date) {
            _dateString = [self.date stringWithFormat:@"yyyyMMdd"];
        }
    }
    return _dateString;
}
@end

@implementation GSHDoorLockRecordListM
-(NSString*)dateString{
    if (!_dateString) {
        if (_date) {
            _dateString = [_date stringWithFormat:@"yyyyMMdd"];
        }
    }
    return _dateString;
}
@end

@implementation GSHDoorLockManager

+(NSString *)dateDay:(NSDate*)date{
    if ([date isToday]) {
        return @"今天";
    }else if ([[date dateByAddingDays:1] isToday]){
        return @"昨天";
    }else if ([[date dateByAddingDays:2] isToday]){
        return @"前天";
    }else{
        return [date stringWithFormat:@"yyyy-MM-dd"];
    }
}

+ (NSURLSessionDataTask *)postSetLockSecretWithDeviceSn:(NSString*)deviceSN secretName:(NSString*)secretName secretValue:(NSString*)secretValue secretType:(GSHDoorLockSecretType)secretType usedType:(GSHDoorLockUsedType)usedType validMinis:(NSInteger)validMinis block:(void(^)(NSError *error, GSHDoorLockPassWordM *model))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSN forKey:@"deviceSn"];
    [dic setValue:secretName forKey:@"secretName"];
    [dic setValue:[GSHUserManager encryptWithString:secretValue] forKey:@"secretValue"];
    [dic setValue:@(secretType) forKey:@"secretType"];
    [dic setValue:@(usedType) forKey:@"usedType"];
    [dic setValue:@(validMinis) forKey:@"validMinis"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"locksecret" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHDoorLockPassWordM *model = [GSHDoorLockPassWordM yy_modelWithJSON:responseObject];
        model.secretValue = [GSHUserManager decryptWithString:model.secretValue];
        if (block) {
            block(nil,model);
        }
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHDoorLockManagerPassWordChangeNotification object:model]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error,nil);
        }
    }];
}

+ (NSURLSessionDataTask *)postUpdateLockSecretWithDeviceSn:(NSString*)deviceSN secretId:(NSString*)secretId secretName:(NSString*)secretName secretValue:(NSString*)secretValue secretType:(GSHDoorLockSecretType)secretType usedType:(GSHDoorLockUsedType)usedType validMinis:(NSInteger)validMinis block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSN forKey:@"deviceSn"];
    [dic setValue:secretName forKey:@"secretName"];
    [dic setValue:[GSHUserManager encryptWithString:secretValue] forKey:@"secretValue"];
    [dic setValue:@(secretType) forKey:@"secretType"];
    [dic setValue:@(usedType) forKey:@"usedType"];
    [dic setValue:@(validMinis) forKey:@"validMinis"];
    return [[GSHOpenSDKInternal share].httpAPIClient PUT:[NSString stringWithFormat:@"locksecret/%@",secretId] parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHDoorLockPassWordM *model = [GSHDoorLockPassWordM yy_modelWithJSON:responseObject];
        model.secretValue = [GSHUserManager decryptWithString:model.secretValue];
        if (block) {
            block(nil);
        }
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHDoorLockManagerPassWordChangeNotification object:model]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
    return nil;
}

+ (NSURLSessionDataTask *)postDeleteLockSecretWithDeviceSn:(NSString*)deviceSN secretId:(NSString*)secretId block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:secretId forKey:@"secretId"];
    return [[GSHOpenSDKInternal share].httpAPIClient DELETE:[NSString stringWithFormat:@"locksecret/%@",secretId] parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHDoorLockManagerPassWordChangeNotification object:nil]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
    return nil;
}

+ (NSURLSessionDataTask *)getSingleLockSecretWithDeviceSn:(NSString*)deviceSN secretType:(GSHDoorLockSecretType)secretType usedType:(GSHDoorLockUsedType)usedType block:(void(^)(NSError *error, NSArray<GSHDoorLockPassWordListM*> *list))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSN forKey:@"deviceSn"];
    [dic setValue:@(secretType) forKey:@"secretType"];
    [dic setValue:@(usedType) forKey:@"usedType"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"locksecret" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray<GSHDoorLockPassWordM*> *list = [NSArray yy_modelArrayWithClass:GSHDoorLockPassWordM.class json:responseObject];
        NSMutableArray<GSHDoorLockPassWordListM*> *arr = [NSMutableArray array];
        GSHDoorLockPassWordListM *listModel;
        for (GSHDoorLockPassWordM *model in list) {
            model.secretValue = [GSHUserManager decryptWithString:model.secretValue];
            NSString *string = [model.date stringWithFormat:@"yyyyMMdd"];
            if (string) {
                if (![listModel.dateString isEqualToString:string]) {
                    listModel = [GSHDoorLockPassWordListM new];
                    listModel.date = model.date;
                    listModel.list = [NSMutableArray array];
                    [arr addObject:listModel];
                }
                [listModel.list addObject:model];
            }
        }
        if (block) {
            block(nil,arr);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error,nil);
        }
    } useCache:NO];
}

+ (NSURLSessionDataTask *)getLockSecretWithDeviceSn:(NSString*)deviceSN secretType:(GSHDoorLockSecretType)secretType usedType:(GSHDoorLockUsedType)usedType block:(void(^)(NSError *error, NSArray<GSHDoorLockPassWordM*> *list))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSN forKey:@"deviceSn"];
    [dic setValue:@(secretType) forKey:@"secretType"];
    [dic setValue:@(usedType) forKey:@"usedType"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"locksecret" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray<GSHDoorLockPassWordM*> *list = [NSArray yy_modelArrayWithClass:GSHDoorLockPassWordM.class json:responseObject];
        for (GSHDoorLockPassWordM *model in list) {
            model.secretValue = [GSHUserManager decryptWithString:model.secretValue];
        }
        if (block) {
            block(nil,list);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error,nil);
        }
    } useCache:YES];
}

+ (NSURLSessionDataTask *)getLockRecordListWithDeviceSn:(NSString*)deviceSN pageIndex:(NSInteger)pageIndex block:(void(^)(NSError *error, NSArray<GSHDoorLockRecordM*> *list))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceSN forKey:@"deviceSn"];
    [dic setValue:@(pageIndex) forKey:@"pageIndex"];
    [dic setValue:@(20) forKey:@"pageSize"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"locksecret/moments" parameters:dic success:^(id operationOrTask, id responseObject) {
        NSArray<GSHDoorLockRecordM*> *list = [NSArray yy_modelArrayWithClass:GSHDoorLockRecordM.class json:responseObject];
        if (block) {
            block(nil,list);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error,nil);
        }
    } useCache:YES];
}

@end
