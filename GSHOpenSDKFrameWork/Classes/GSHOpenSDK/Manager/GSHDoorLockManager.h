//
//  GSHDoorLockManager.h
//  GSHOpenSDK
//
//  Created by 唐作明 on 2020/2/24.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"

extern NSString * _Nullable  const GSHDoorLockManagerPassWordChangeNotification;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    GSHDoorLockUsedTypeSingle,
    GSHDoorLockUsedTypePermanent,
} GSHDoorLockUsedType;

typedef enum : NSUInteger {
    GSHDoorLockSecretTypeFingerprint,
    GSHDoorLockSecretTypePassword,
} GSHDoorLockSecretType;

typedef enum : NSUInteger {
    GSHDoorLockSinglePasswordStatusUnvalid,
    GSHDoorLockSinglePasswordStatusValid,
} GSHDoorLockSinglePasswordStatus;

@interface GSHDoorLockRecordM : GSHBaseModel
@property(nonatomic,copy)NSString *createTime;
@property(nonatomic,copy)NSString *id;
@property(nonatomic,assign)NSInteger logType;
@property(nonatomic,copy)NSString *logTypeName;
@property(nonatomic,copy)NSString *secretName;
@property(nonatomic,copy)NSDate *date;
@property(nonatomic,copy)NSString *dateString;
@end

@interface GSHDoorLockRecordListM : GSHBaseModel
@property(nonatomic,copy)NSDate *date;
@property(nonatomic,copy)NSString *dateString;
@property(nonatomic,strong)NSMutableArray<GSHDoorLockRecordM*> *list;
@end

@interface GSHDoorLockPassWordM : GSHBaseModel
@property(nonatomic,copy)NSString *id;
@property(nonatomic,copy)NSString *createTime;
@property(nonatomic,assign)GSHDoorLockUsedType usedType;
@property(nonatomic,copy)NSString *secretName;
@property(nonatomic,copy)NSString *secretValue;
@property(nonatomic,assign)GSHDoorLockSecretType secretType;
@property(nonatomic,copy)NSString *expireTime;
@property(nonatomic,assign)GSHDoorLockSinglePasswordStatus status;

@property(nonatomic,strong)NSDate *date;
@property(nonatomic,strong)NSDate *createDate;
@end

@interface GSHDoorLockPassWordListM : GSHBaseModel
@property(nonatomic,strong)NSMutableArray<GSHDoorLockPassWordM*> *list;
@property(nonatomic,strong)NSDate *date;
@end

@interface GSHDoorLockManager : GSHBaseModel
+ (NSString *)dateDay:(NSDate*)date;

+ (NSURLSessionDataTask *)postSetLockSecretWithDeviceSn:(NSString*)deviceSN secretName:(NSString*)secretName secretValue:(NSString*)secretValue secretType:(GSHDoorLockSecretType)secretType usedType:(GSHDoorLockUsedType)usedType validMinis:(NSInteger)validMinis block:(void(^)(NSError *error, GSHDoorLockPassWordM *model))block;

+ (NSURLSessionDataTask *)postUpdateLockSecretWithDeviceSn:(NSString*)deviceSN secretId:(NSString*)secretId secretName:(NSString*)secretName secretValue:(NSString*)secretValue secretType:(GSHDoorLockSecretType)secretType usedType:(GSHDoorLockUsedType)usedType validMinis:(NSInteger)validMinis block:(void(^)(NSError *error))block;

+ (NSURLSessionDataTask *)postDeleteLockSecretWithDeviceSn:(NSString*)deviceSN secretId:(NSString*)secretId block:(void(^)(NSError *error))block;

+ (NSURLSessionDataTask *)getSingleLockSecretWithDeviceSn:(NSString*)deviceSN secretType:(GSHDoorLockSecretType)secretType usedType:(GSHDoorLockUsedType)usedType block:(void(^)(NSError *error, NSArray<GSHDoorLockPassWordListM*> *list))block;
+ (NSURLSessionDataTask *)getLockSecretWithDeviceSn:(NSString*)deviceSN secretType:(GSHDoorLockSecretType)secretType usedType:(GSHDoorLockUsedType)usedType block:(void(^)(NSError *error, NSArray<GSHDoorLockPassWordM*> *list))block;

+ (NSURLSessionDataTask *)getLockRecordListWithDeviceSn:(NSString*)deviceSN pageIndex:(NSInteger)pageIndex block:(void(^)(NSError *error, NSArray<GSHDoorLockRecordM*> *list))block;
@end

NS_ASSUME_NONNULL_END
