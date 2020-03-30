//
//  GSHUserM.h
//  SmartHome
//
//  Created by gemdale on 2018/4/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"
#import <UIKit/UIKit.h>

extern NSString * const GSHUserMChangeNotification;          //登出成功
extern NSString * const GSHUserInfoMChangeNotification;             //个人信息发生改变
//登陆方式
typedef enum : NSUInteger {
    GSHUserMLoginTypePassWord = 0,                      //密码
    GSHUserMLoginTypeVerifyCode,                        //验证码
    GSHUserMLoginTypeWechat,                            //微信
    GSHUserMLoginTypeWebo,                              //微博
    GSHUserMLoginTypeQQ,                                //qq
    GSHUserMLoginTypeEnjoy,                             //享家
} GSHUserMLoginType;
//第三方登录方式
typedef enum : NSUInteger {
    GSHUserMThirdPartyLoginTypeWechat = 1,              //微信
    GSHUserMThirdPartyLoginTypeWebo,                    //微博
    GSHUserMThirdPartyLoginTypeQQ,                      //qq
    GSHUserMThirdPartyLoginTypeEnjoy,                   //享家
} GSHUserMThirdPartyLoginType;
//验证码种类
typedef enum : NSUInteger {
    GSHGetVerifyCodeTypeRegister = 1,                   //注册
    GSHGetVerifyCodeTypeLogin,                          //登录
    GSHGetVerifyCodeTypePWDUpdate,                      //重置密码
    GSHGetVerifyCodeTypePhoneUpdate,                    //更换手机号码
    GSHGetVerifyCodeTypeThirdBindMobile,                //第三方绑定手机
} GSHGetVerifyCodeType;
//上传图片类型
typedef enum : NSUInteger {
    GSHUploadingImageTypeHeadimage = 1,                 //头像
    GSHUploadingImageTypeFamily,                        //家庭图片
    GSHUploadingImageTypeIdea,                          //意见反馈图片
} GSHUploadingImageType;
//第三方绑定信息
@interface GSHThirdPartyUserM : GSHBaseModel
@property(nonatomic,copy)NSString *openId;              //开放id
@property(nonatomic,copy)NSString *userId;              //userID
@property(nonatomic,copy)NSString *userName;            //昵称
@property(nonatomic,assign)GSHUserMThirdPartyLoginType userType;        //来自哪个第三方平台
@end
//用户个人信息
@interface GSHUserInfoM : GSHBaseModel
@property (nonatomic, copy)NSString *nick;              //昵称
@property (nonatomic, copy)NSString *picPath;           //头像
@property (nonatomic, copy)NSString *phone;             //手机号码
@property (nonatomic, copy)NSString *birth ;            //生日
@property (nonatomic,strong)NSNumber *sex;              //性别
@property (nonatomic,strong)NSNumber *hasLoginPwd;      //是否有密码
@property (nonatomic, copy)NSMutableArray<GSHThirdPartyUserM*> *thirdPartyUserList; //第三方绑定信息
@end
//登录用户信息
@interface GSHUserM : GSHBaseModel
@property(nonatomic,copy)NSString *sessionId;               //鉴权Id
@property(nonatomic,copy)NSString *userId;                  //userId
@property(nonatomic,copy)NSString *phone;                   //手机号码
@property(nonatomic,copy)NSString *currentFamilyId;         //注册或登录后 -- 返回当前家庭id
@property(nonatomic,strong)NSNumber *voiceStatus;           //语音助手

@property(nonatomic,copy) NSString *accessToken; // 

-(void)updataCurrentFamilyId:(NSString*)currentFamilyId;    //更行当前用户当前家庭Id
-(void)updataVoiceStatus:(NSNumber*)voiceStatus;            //更行当前用户语音状态
@end

@interface GSHUserManager : NSObject

+(NSString*)encryptWithString:(NSString*)string;
+(NSString*)decryptWithString:(NSString*)string;
//当前登录用户
+(GSHUserM*)currentUser;
+(void)setCurrentUser:(GSHUserM*)user;
//当前登录用户个人（可能为空）
+(GSHUserInfoM*)currentUserInfo;
+(void)setCurrentUserInfo:(GSHUserInfoM*)userInfoM;
//手机密码登录
+(NSURLSessionDataTask*)postLoginWithPhoneNumber:(NSString*)phoneNumber passWord:(NSString*)passWord block:(void(^)(GSHUserM *user, NSError *error))block;
//手机验证码登录
+(NSURLSessionDataTask*)postLoginWithPhoneNumber:(NSString*)phoneNumber verifyCode:(NSString*)verifyCode block:(void(^)(GSHUserM *user, NSError *error))block;
//第三方登录  (openId是第三方唯一标示，type为登录类型)
+(NSURLSessionDataTask*)postThirdPartyLoginWithOpenId:(NSString*)openId userName:(NSString *)userName headImgUrl:(NSString *)headImgUrl type:(GSHUserMLoginType)type userThirdLoginType:(GSHUserMThirdPartyLoginType)userThirdLoginType block:(void(^)(GSHUserM *user, NSError *error))block;
//第三方登录 绑定手机号 /user/thirdPartyBindPhone
+(NSURLSessionDataTask*)postThirdPartyBindPhoneWithOpenId:(NSString*)openId userName:(NSString *)userName headImgUrl:(NSString *)headImgUrl type:(GSHUserMLoginType)type userThirdLoginType:(GSHUserMThirdPartyLoginType)userThirdLoginType phoneNumber:(NSString*)phoneNumber verifyCode:(NSString*)verifyCode block:(void(^)(GSHUserM *user, NSError *error))block;
//登出当前账号
+(NSURLSessionDataTask*)postLogoutWithBlock:(void(^)(NSError *error))block;
//注册
+(NSURLSessionDataTask*)postRegisterWithPhoneNumber:(NSString*)phoneNumber passWord:(NSString*)passWord verifyCode:(NSString*)verifyCode block:(void(^)(GSHUserM *user, NSError *error))block;
//重置密码
+(NSURLSessionDataTask*)postResetPassWordWithPhoneNumber:(NSString*)phoneNumber passWord:(NSString*)passWord verifyCode:(NSString*)verifyCode block:(void(^)(GSHUserM *user, NSError *error))block;
//获取验证码
+(NSURLSessionDataTask*)postVerifyCodeWithPhoneNumber:(NSString*)phoneNumber type:(GSHGetVerifyCodeType)type block:(void(^)(NSError *error))block;
//检验手机号是否被注册
+(NSURLSessionDataTask *)checkIsRegisteredWithPhoneNumber:(NSString *)phoneNumber block:(void(^)(NSError *error))block;
//用户上传图片
+(NSURLSessionDataTask*)postImage:(UIImage*)image type:(GSHUploadingImageType)type progress:(void (^)(NSProgress *))progress block:(void(^)(NSString *picPath ,NSError *error))block;
// 绑定第三方账号
+(NSURLSessionDataTask*)bindThirdPartyUserInfoWithOpenId:(NSString*)openId userName:(NSString *)userName userThirdLoginType:(GSHUserMThirdPartyLoginType)userThirdLoginType block:(void(^)(NSError *error))block;
// 解绑第三方帐号
+(NSURLSessionDataTask*)unbindThirdPartyUserInfoWithOpenId:(NSString*)openId block:(void(^)(NSError *error))block;
// 扫码登录 -- 手机扫描pad端二维码授权登录
+(NSURLSessionDataTask *)postToScanLoginWithDeviceId:(NSString *)deviceId block:(void(^)(NSError *error))block;
//获取当前用户信息
+(NSURLSessionDataTask*)getUserInfoWithBlock:(void(^)(GSHUserInfoM *userInfo, NSError *error))block;
//修改头像
+(NSURLSessionDataTask*)postUpdateHeadImageWithImage:(UIImage*)image progress:(void (^)(NSProgress *))progress block:(void(^)(GSHUserInfoM *userInfo, NSError *error))block;
//修改用户信息（目前只有修改昵称使用此接口）
//parameter 结构
//nick (string, optional): 用户昵称
+(NSURLSessionDataTask*)postUpdateUserInfoWithParameter:(NSDictionary*)parameter block:(void(^)(GSHUserInfoM *userInfo,NSError *error))block;
//更改密码
+(NSURLSessionDataTask*)postUpdatePassWordWithPhoneNumber:(NSString*)phoneNumber passWord:(NSString*)passWord oldPassWord:(NSString*)oldPassWord block:(void(^)(GSHUserInfoM *userInfo,NSError *error))block;
//更改手机号码前验证老的手机号码
+(NSURLSessionDataTask*)postUpdatePhoneWithOldPhoneNumber:(NSString*)phoneNumber verifyCode:(NSString*)verifyCode block:(void(^)(NSString *token,NSError *error))block;
//更改手机号码
+(NSURLSessionDataTask*)postUpdatePhoneWithOldPhoneNumber:(NSString*)oldPhoneNumber newPhoneNumber:(NSString*)newPhoneNumber token:(NSString*)token verifyCode:(NSString*)verifyCode block:(void(^)(GSHUserInfoM *userInfo,NSError *error))block;
//重置密码验证
+(NSURLSessionDataTask*)postResetPwdValidateWithPhone:(NSString*)phone vcode:(NSString*)vcode block:(void(^)(NSString *token,NSError *error))block;
//设置语音状态
+(NSURLSessionDataTask*)postSetVoiceService:(BOOL)open block:(void(^)(NSError *error))block;
@end
