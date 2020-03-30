//
//  GSHUserM.m
//  SmartHome
//
//  Created by gemdale on 2018/4/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHUserM.h"
#import "UIDevice+TZM.h"
#import "GSHOSSManagerClient.h"
#import "GSHYingShiManager.h"
#import <YYCategories.h>
#import "GSHOpenSDKInternal.h"
#import "LBXDataHandler.h"

NSString *const GSHCurrentUserDict = @"GSHCurrentUserDict";
NSString *const GSHCurrentUserInfoDict = @"GSHCurrentUserInfoDict";
NSString *const GSHUserMChangeNotification = @"GSHUserMChangeNotification";
NSString *const GSHUserInfoMChangeNotification = @"GSHUserInfoMChangeNotification";

@implementation GSHThirdPartyUserM
@end

@implementation GSHUserInfoM
-(instancetype)init{
    self = [super init];
    if (self) {
        self.thirdPartyUserList = [NSMutableArray array];
    }
    return self;
}
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"thirdPartyUserList":[GSHThirdPartyUserM class]
             };
}
@end

@implementation GSHUserM
-(void)updataCurrentFamilyId:(NSString*)currentFamilyId{
    @synchronized (self){
        self.currentFamilyId = currentFamilyId;
        if ([GSHUserManager currentUser].userId && [self.userId isEqualToString:[GSHUserManager currentUser].userId]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            id currentUserObj = [self yy_modelToJSONObject];
            if (currentUserObj) {
                [userDefaults setObject:currentUserObj forKey:GSHCurrentUserDict];
                [userDefaults synchronize];
            }
        }
    }
}

-(void)updataVoiceStatus:(NSNumber*)voiceStatus{
    @synchronized (self){
        self.voiceStatus = voiceStatus;
        if ([GSHUserManager currentUser].userId && [self.userId isEqualToString:[GSHUserManager currentUser].userId]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            id currentUserObj = [self yy_modelToJSONObject];
            if (currentUserObj) {
                [userDefaults setObject:currentUserObj forKey:GSHCurrentUserDict];
                [userDefaults synchronize];
            }
        }
    }
}
@end

@implementation GSHUserManager
static GSHUserM *_currentUser = nil;

+(NSString*)encryptWithString:(NSString*)string{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    data = [data LBXCryptWithOp:LBXOperaton_Encrypt algorithm:LBXAlgorithm_3DES optionMode:LBXOptionMode_CBC padding:LBXPaddingMode_PKCS5 key:@"AOSw9O!^lgquMP$nZDvo%koJ" iv:@"gemdaleh" error:&error];
    NSString *encrypt = [data base64EncodedString];
    return encrypt;
}

+(NSString*)decryptWithString:(NSString*)string{
    NSData *data = [NSData dataWithBase64EncodedString:string];
    NSError *error;
    data = [data LBXCryptWithOp:LBXOperaton_Decrypt algorithm:LBXAlgorithm_3DES optionMode:LBXOptionMode_CBC padding:LBXPaddingMode_PKCS5 key:@"AOSw9O!^lgquMP$nZDvo%koJ" iv:@"gemdaleh" error:&error];
    NSString *encrypt = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return encrypt;
}

+(GSHUserM*)currentUser{
    @synchronized (self){
        if (_currentUser == nil) {
            id currentUserObj = [[NSUserDefaults standardUserDefaults] objectForKey:GSHCurrentUserDict];
            if (!currentUserObj) {
                return nil;
            }
            _currentUser = [GSHUserM yy_modelWithJSON:currentUserObj];
        }
    }
    return _currentUser;
}
+(void)setCurrentUser:(GSHUserM*)user{
    @synchronized (self){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //会在更新本地用户之前发送通知,在收到通知时老的用户信息还没改
        if (user) {
            [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHUserMChangeNotification object:user]];
            id currentUserObj = [user yy_modelToJSONObject];
            [userDefaults setObject:currentUserObj forKey:GSHCurrentUserDict];
            [GSHUserManager getUserInfoWithBlock:NULL];
            [GSHYingShiManager updataAccessTokenWithBlock:NULL];
        }else{
            [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHUserMChangeNotification object:nil]];
            [userDefaults removeObjectForKey:GSHCurrentUserDict];
            [GSHUserManager setCurrentUserInfo:nil];
            [GSHOpenSDKShare share].currentFamily = nil;
        }
        [userDefaults synchronize];
        _currentUser = user;
    }
}
static GSHUserInfoM *_currentUserInfo = nil;
+(GSHUserInfoM*)currentUserInfo{
    @synchronized (self){
        if (_currentUserInfo == nil) {
            id currentUserObj = [[NSUserDefaults standardUserDefaults] objectForKey:GSHCurrentUserInfoDict];
            if (!currentUserObj) {
                return nil;
            }
            _currentUserInfo = [GSHUserInfoM yy_modelWithJSON:currentUserObj];
        }
    }
    return _currentUserInfo;
}
+(void)setCurrentUserInfo:(GSHUserInfoM*)userInfoM{
    @synchronized (self){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (userInfoM) {
            id currentUserObj = [userInfoM yy_modelToJSONObject];
            [userDefaults setObject:currentUserObj forKey:GSHCurrentUserInfoDict];
        }else{
            [userDefaults removeObjectForKey:GSHCurrentUserInfoDict];
        }
        [userDefaults synchronize];
        _currentUserInfo = userInfoM;
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:GSHUserInfoMChangeNotification object:userInfoM]];
    }
}
//密码验证登录
+(NSURLSessionDataTask *)postLoginWithPhoneNumber:(NSString *)phoneNumber passWord:(NSString *)passWord block:(void (^)(GSHUserM *user, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:phoneNumber forKey:@"phone"];
    [dic setValue:[self encryptWithString:passWord] forKey:@"pwd"];
    [dic setValue:@"0" forKey:@"type"];
    [dic setValue:[UIDevice tzm_getUUID] forKey:@"clientSN"];
    [dic setValue:@"1" forKey:@"clientType"];
    [dic setValue:[UIDevice tzm_getIPhoneType] forKey:@"phoneModel"];
    [dic setValue:[NSString stringWithFormat:@"iOS|%@",[UIDevice currentDevice].systemVersion] forKey:@"systemVersion"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/login" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHUserM *user = [GSHUserM yy_modelWithJSON:responseObject];
        [GSHUserManager setCurrentUser:user];
        if (block) {
            block(user, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
}
//手机验证码登录
+(NSURLSessionDataTask*)postLoginWithPhoneNumber:(NSString*)phoneNumber verifyCode:(NSString*)verifyCode block:(void(^)(GSHUserM *user, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:phoneNumber forKey:@"phone"];
    [dic setValue:[self encryptWithString:verifyCode] forKey:@"vcode"];
    [dic setValue:@"1" forKey:@"type"];
    [dic setValue:[UIDevice tzm_getUUID] forKey:@"clientSN"];
    [dic setValue:@"1" forKey:@"clientType"];
    [dic setValue:[UIDevice tzm_getIPhoneType] forKey:@"phoneModel"];
    [dic setValue:[NSString stringWithFormat:@"iOS|%@",[UIDevice currentDevice].systemVersion] forKey:@"systemVersion"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/login" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHUserM *user = [GSHUserM yy_modelWithJSON:responseObject];
        [GSHUserManager setCurrentUser:user];
        if (block) {
            block(user, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
}

//第三方登录  (openId是第三方唯一标示，type为登录类型)
+(NSURLSessionDataTask*)postThirdPartyLoginWithOpenId:(NSString*)openId userName:(NSString *)userName headImgUrl:(NSString *)headImgUrl type:(GSHUserMLoginType)type userThirdLoginType:(GSHUserMThirdPartyLoginType)userThirdLoginType block:(void(^)(GSHUserM *user, NSError *error))block;{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(type) forKey:@"type"];      // 登录类型
    [dic setValue:@(userThirdLoginType) forKey:@"userType"];  // 第三方用户类型
    [dic setValue:[UIDevice tzm_getUUID] forKey:@"clientSN"];
    [dic setValue:@"1" forKey:@"clientType"];
    [dic setValue:[UIDevice tzm_getIPhoneType] forKey:@"phoneModel"];
    [dic setValue:[NSString stringWithFormat:@"iOS|%@",[UIDevice currentDevice].systemVersion] forKey:@"systemVersion"];
    [dic setValue:openId forKey:@"openId"];
    [dic setValue:userName forKey:@"userName"];
    [dic setValue:headImgUrl forKey:@"picPath"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/thirdPartyLogin" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHUserM *user = [GSHUserM yy_modelWithJSON:responseObject];
        if (user.userId.length > 0 && [user.userId intValue] != 0) {
            [GSHUserManager setCurrentUser:user];
        }
        if (block) {
            block(user, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
}

//第三方登录 绑定手机号
+(NSURLSessionDataTask*)postThirdPartyBindPhoneWithOpenId:(NSString*)openId
                                                 userName:(NSString *)userName
                                               headImgUrl:(NSString *)headImgUrl
                                                     type:(GSHUserMLoginType)type
                                       userThirdLoginType:(GSHUserMThirdPartyLoginType)userThirdLoginType
                                              phoneNumber:(NSString*)phoneNumber
                                               verifyCode:(NSString*)verifyCode
                                                    block:(void(^)(GSHUserM *user, NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:openId forKey:@"openId"];
    [dic setValue:userName forKey:@"userName"];
    [dic setValue:@(type) forKey:@"type"];
    [dic setValue:@(userThirdLoginType) forKey:@"userType"];  // 第三方用户类型
    [dic setValue:phoneNumber forKey:@"phone"];
    [dic setValue:[self encryptWithString:verifyCode] forKey:@"vcode"];
    [dic setValue:[UIDevice tzm_getUUID] forKey:@"clientSN"];
    [dic setValue:@"1" forKey:@"clientType"];
    [dic setValue:[UIDevice tzm_getIPhoneType] forKey:@"phoneModel"];
    [dic setValue:[NSString stringWithFormat:@"iOS|%@",[UIDevice currentDevice].systemVersion] forKey:@"systemVersion"];
    [dic setValue:headImgUrl forKey:@"picPath"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/thirdPartyBindPhoneAndLogin" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHUserM *user = [GSHUserM yy_modelWithJSON:responseObject];
        [GSHUserManager setCurrentUser:user];
        if (block) {
            block(user, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
}

//登出当前账号
+(NSURLSessionDataTask*)postLogoutWithBlock:(void(^)(NSError *error))block;{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[UIDevice tzm_getUUID] forKey:@"clientSN"];
    [dic setValue:@"1" forKey:@"clientType"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/logout" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [GSHUserManager setCurrentUser:nil];
        if (block) {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

//注册
+(NSURLSessionDataTask*)postRegisterWithPhoneNumber:(NSString*)phoneNumber passWord:(NSString*)passWord verifyCode:(NSString*)verifyCode block:(void(^)(GSHUserM *user, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:phoneNumber forKey:@"phone"];
    [dic setValue:[self encryptWithString:passWord] forKey:@"pwd"];
    [dic setValue:[self encryptWithString:verifyCode] forKey:@"vcode"];
    [dic setValue:[UIDevice tzm_getUUID] forKey:@"clientSN"];
    [dic setValue:@"1" forKey:@"clientType"];
    [dic setValue:[UIDevice tzm_getIPhoneType] forKey:@"phoneModel"];
    [dic setValue:[NSString stringWithFormat:@"iOS|%@",[UIDevice currentDevice].systemVersion] forKey:@"systemVersion"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/register" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHUserM *user = [GSHUserM yy_modelWithJSON:responseObject];
        [GSHUserManager setCurrentUser:user];
        if (block) {
            block(user, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
}

//重置密码
+(NSURLSessionDataTask*)postResetPassWordWithPhoneNumber:(NSString*)phoneNumber passWord:(NSString*)passWord verifyCode:(NSString*)verifyCode block:(void(^)(GSHUserM *user, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:phoneNumber forKey:@"phone"];
    [dic setValue:[self encryptWithString:passWord] forKey:@"pwd"];
    [dic setValue:verifyCode forKey:@"token"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/resetPwd" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHUserM *user = [GSHUserM yy_modelWithJSON:responseObject];
        [GSHUserManager setCurrentUser:user];
        if (block) {
            block(user, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
}
//获取验证码
+(NSURLSessionDataTask*)postVerifyCodeWithPhoneNumber:(NSString*)phoneNumber type:(GSHGetVerifyCodeType)type block:(void(^)(NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:phoneNumber forKey:@"phone"];
    [dic setValue:@(type) forKey:@"bizCode"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"general/sendVcode" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
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

// 检验手机号是否被注册
+(NSURLSessionDataTask *)checkIsRegisteredWithPhoneNumber:(NSString *)phoneNumber block:(void(^)(NSError *error))block {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:phoneNumber forKey:@"phone"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/checkPhone" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
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
+(NSURLSessionDataTask*)postImage:(UIImage*)image type:(GSHUploadingImageType)type progress:(void (^)(NSProgress * _Nonnull))progress block:(void(^)(NSString *picPath ,NSError *error))block{
    //压缩图片到200k以下
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.1f;
    NSData *photoData = UIImageJPEGRepresentation(image, compression);
    while ([photoData length] > 2*100*1000 && compression > maxCompression) {
        compression -= 0.1;
        photoData = UIImageJPEGRepresentation(image, compression);
    }
    //不能能压缩到200k就裁剪成640*640
    if ([photoData length] > 2*100*1000) {
        if (image.size.height > 640 || image.size.width > 640) {
            image = [image imageByResizeToSize:CGSizeMake(640, 640) contentMode:UIViewContentModeScaleAspectFit];
        }
        photoData = UIImageJPEGRepresentation(image, 0.5);
    }
    
    return [[GSHOpenSDKInternal share].ossManagerClient getFileIdFromSeaweedfsWithBlock:^(NSString *fid,NSString *url,NSError *error) {
        if (error) {
            block(nil,error);
        } else {
            NSString *urlStr = [NSString stringWithFormat:@"http://%@/%@",url,fid];
            [[GSHOpenSDKInternal share].ossManagerClient uploadFileToSeaweedfsWithUrl:urlStr fileData:photoData fileName:fid mimeType:@"image/jpeg" block:^(NSError * _Nonnull error) {
                if (error) {
                    block(nil,error);
                } else {
                    block(urlStr,nil);
                }
            }];
        }
    }];
}

// 绑定第三方账号
+(NSURLSessionDataTask*)bindThirdPartyUserInfoWithOpenId:(NSString*)openId
                                                userName:(NSString *)userName
                                      userThirdLoginType:(GSHUserMThirdPartyLoginType)userThirdLoginType
                                                   block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:openId forKey:@"openId"];
    [dic setValue:userName forKey:@"userName"];
    [dic setValue:@(userThirdLoginType) forKey:@"userType"];  // 第三方用户类型
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"/userInfo/bindThirdPartyUser" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
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

// 解绑第三方帐号
+(NSURLSessionDataTask*)unbindThirdPartyUserInfoWithOpenId:(NSString*)openId block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:openId forKey:@"openId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"/userInfo/unbindThirdPartyUser" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
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

// 扫码登录 -- 手机扫描pad端二维码授权登录
+(NSURLSessionDataTask *)postToScanLoginWithDeviceId:(NSString *)deviceId block:(void(^)(NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:deviceId forKey:@"deviceId"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/scanLogin" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
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
//获取当前用户信息
+(NSURLSessionDataTask*)getUserInfoWithBlock:(void(^)(GSHUserInfoM *userInfo, NSError *error))block{
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"userInfo/queryUserInfo" parameters:nil success:^(id operationOrTask, id responseObject) {
        GSHUserInfoM *userInfo = [GSHUserInfoM yy_modelWithJSON:responseObject];
        [GSHUserManager setCurrentUserInfo:userInfo];
        if (block) {
            block(userInfo,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    } useCache:YES];
}

//修改头像
+(NSURLSessionDataTask*)postUpdateHeadImageWithImage:(UIImage*)image progress:(void (^)(NSProgress * _Nonnull))progress block:(void(^)(GSHUserInfoM *userInfo, NSError *error))block{
    return [GSHUserManager postImage:image type:GSHUploadingImageTypeHeadimage progress:progress block:^(NSString *picPath, NSError *error) {
        if (picPath) {
            [GSHUserManager postUpdateUserInfoWithParameter:@{@"picPath":picPath} block:^(GSHUserInfoM *userInfo, NSError *error) {
                if (block) {
                    block(userInfo,error);
                }
            }];
        }else{
            if (block) {
                block(nil,error);
            }
        }
    }];
}

//修改用户信息（目前只有修改昵称使用此接口）
//parameter 结构
//nick (string, optional): 用户昵称
+(NSURLSessionDataTask*)postUpdateUserInfoWithParameter:(NSDictionary*)parameter block:(void(^)(GSHUserInfoM *userInfo,NSError *error))block{
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"userInfo/updateUserInfo" parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHUserInfoM *user = [GSHUserManager currentUserInfo];
        NSMutableDictionary *dic = [user yy_modelToJSONObject];
        [dic setValuesForKeysWithDictionary:parameter];
        user = [GSHUserInfoM yy_modelWithJSON:dic];
        [GSHUserManager setCurrentUserInfo:user];
        if (block) {
            block(user,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//更改密码(在登录状态下才可以)
+(NSURLSessionDataTask*)postUpdatePassWordWithPhoneNumber:(NSString*)phoneNumber passWord:(NSString*)passWord oldPassWord:(NSString*)oldPassWord block:(void(^)(GSHUserInfoM *userInfo,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:phoneNumber forKey:@"phone"];
    [dic setValue:[self encryptWithString:passWord] forKey:@"pwd"];
    [dic setValue:[self encryptWithString:oldPassWord] forKey:@"oldPwd"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/updatePwd" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block([GSHUserManager currentUserInfo],nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//更改手机号码前验证老的手机号码
+(NSURLSessionDataTask*)postUpdatePhoneWithOldPhoneNumber:(NSString*)phoneNumber verifyCode:(NSString*)verifyCode block:(void(^)(NSString *token,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:phoneNumber forKey:@"phone"];
    [dic setValue:[self encryptWithString:verifyCode] forKey:@"vcode"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/updatePhoneValidate" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *token = [responseObject valueForKey:@"token"];
        if (block) {
            if ([token isKindOfClass:NSString.class]) {
                block(token,nil);
            }else{
                block(nil,nil);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//更改手机号码
+(NSURLSessionDataTask*)postUpdatePhoneWithOldPhoneNumber:(NSString*)oldPhoneNumber newPhoneNumber:(NSString*)newPhoneNumber token:(NSString*)token verifyCode:(NSString*)verifyCode block:(void(^)(GSHUserInfoM *userInfo,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:oldPhoneNumber forKey:@"oldPhone"];
    [dic setValue:newPhoneNumber forKey:@"phone"];
    [dic setValue:[self encryptWithString:verifyCode] forKey:@"vcode"];
    [dic setValue:token forKey:@"token"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/updatePhone" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GSHUserInfoM *userInfo = [GSHUserManager currentUserInfo];
        userInfo.phone = newPhoneNumber;
        [GSHUserManager setCurrentUserInfo:userInfo];
        if (block) {
            block(userInfo,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//重置密码验证
+(NSURLSessionDataTask*)postResetPwdValidateWithPhone:(NSString*)phone vcode:(NSString*)vcode block:(void(^)(NSString *token,NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:phone forKey:@"phone"];
    [dic setValue:@"1" forKey:@"clientType"];
    [dic setValue:[self encryptWithString:vcode] forKey:@"vcode"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"user/resetPwdValidate" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *token = @"";
        if ([responseObject isKindOfClass:NSDictionary.class]) {
            token = [(NSDictionary*)responseObject stringValueForKey:@"token" default:@""];
        }
        if (block) {
            block(token,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil,error);
        }
    }];
}

//设置语音状态
+(NSURLSessionDataTask*)postSetVoiceService:(BOOL)open block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (open) {
        [dic setValue:@(2) forKey:@"voiceStatus"];
    }else{
        [dic setValue:@(1) forKey:@"voiceStatus"];
    }
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"general/voiceServiceIndexInit" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            block(nil);
        }
        [[GSHUserManager currentUser] updataVoiceStatus:open ? @(2) : @(1)];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(error);
        }
    }];
}

@end

