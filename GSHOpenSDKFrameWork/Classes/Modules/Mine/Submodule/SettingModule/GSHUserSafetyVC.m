//
//  GSHUserSafetyVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHUserSafetyVC.h"
#import <OpenShareHeader.h>
#import "NSDictionary+TZM.h"
#import "GSHAlertManager.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <AFNetworking.h>
#import "GSHChangePasswordVC.h"
#import "GSHPhoneInfoVC.h"
#import <EnjoyHomeOpenSDK.h>

@interface GSHUserSafetyVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblEnjoyName;
@property (weak, nonatomic) IBOutlet UILabel *lblWechatName;
@property (weak, nonatomic) IBOutlet UILabel *lblQQName;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblPassWord;
@property (nonatomic, strong)GSHUserInfoM *userInfo;
@end

@implementation GSHUserSafetyVC
+(instancetype)userSafetyVC{
    GSHUserSafetyVC *vc = [GSHPageManager viewControllerWithSB:@"SettingSB" andID:@"GSHUserSafetyVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userInfo = [GSHUserManager currentUserInfo];
    [self refreshUI];
}

- (void)refreshUI{
    self.lblPhone.text = self.userInfo.phone;
    GSHThirdPartyUserM *wechat = [self getThirdPartyUserMWithType:GSHUserMThirdPartyLoginTypeWechat];
    if (wechat.openId) {
        self.lblWechatName.text = wechat.userName;
        self.lblWechatName.textColor = [UIColor colorWithRGB:0x222222];
    }else{
        self.lblWechatName.text = @"未绑定";
        self.lblWechatName.textColor = [UIColor colorWithRGB:0x999999];
    }
    GSHThirdPartyUserM *qq = [self getThirdPartyUserMWithType:GSHUserMThirdPartyLoginTypeQQ];
    if (qq.openId) {
        self.lblQQName.text = qq.userName;
        self.lblQQName.textColor = [UIColor colorWithRGB:0x222222];
    }else{
        self.lblQQName.text = @"未绑定";
        self.lblQQName.textColor = [UIColor colorWithRGB:0x999999];
    }
    GSHThirdPartyUserM *enjoy = [self getThirdPartyUserMWithType:GSHUserMThirdPartyLoginTypeEnjoy];
    if (enjoy.openId) {
        self.lblEnjoyName.text = enjoy.userName;
        self.lblEnjoyName.textColor = [UIColor colorWithRGB:0x222222];
    }else{
        self.lblEnjoyName.text = @"未绑定";
        self.lblEnjoyName.textColor = [UIColor colorWithRGB:0x999999];
    }
    
    if (self.userInfo.hasLoginPwd.intValue == 1) {
        self.lblPassWord.text = nil;
    }else{
        self.lblPassWord.text = @"未设置";
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshUI];
}

-(GSHThirdPartyUserM*)getThirdPartyUserMWithType:(GSHUserMThirdPartyLoginType)type{
    GSHThirdPartyUserM *model = nil;
    for (GSHThirdPartyUserM *m in self.userInfo.thirdPartyUserList) {
        if (type == m.userType) {
            model = m;
            break;
        }
    }
    return model;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 代理
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 12.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self.navigationController pushViewController:[GSHPhoneInfoVC phoneInfoVCWithUserInfo:self.userInfo] animated:YES];
                break;
            case 1:
                [self.navigationController pushViewController:[GSHChangePasswordVC changePasswordVC] animated:YES];
                break;
            default:
                break;
        }
    }else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                [self touchWeChat];
                break;
            case 1:
                [self touchQQ];
                break;
            case 2:
                [self touchEnjoy];
                break;
            default:
                break;
        }
    }
    return nil;
}

#pragma mark - method
- (void)touchEnjoy{
    GSHThirdPartyUserM *enjoy = [self getThirdPartyUserMWithType:GSHUserMThirdPartyLoginTypeEnjoy];
    if (enjoy.openId) {
        // 解除绑定享家
        @weakify(self)
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            @strongify(self)
            if (buttonIndex == 1) {
                for (GSHThirdPartyUserM *model in [GSHUserManager currentUserInfo].thirdPartyUserList) {
                    if (model.userType == GSHUserMThirdPartyLoginTypeEnjoy) {
                        [self unbindThirdPartyUserWithOpenId:model.openId userThirdLoginType:GSHUserMThirdPartyLoginTypeEnjoy];
                    }
                }
            }
        } textFieldsSetupHandler:NULL andTitle:@"" andMessage:@"确定要解除绑定？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    } else {
        // 绑定享家
        if ([EnjoyHomeOpenSDK isAppInstalled]) {
        __weak typeof(self)weakSelf = self;
            [EnjoyHomeOpenSDK sendAuthLoginReqWithAppId:@"enjoyHome" authFetchInfoMode:EHAuthFetchInfoModeBasic Success:^(NSString *authCode) {
                NSLog(@"authCode : %@",authCode);
                if (authCode) {
                    [weakSelf getEnjoyUserInfoWithAuthCode:authCode];
                }
            } Fail:^(NSError *error) {
            }];
        } else {
            [TZMProgressHUDManager showErrorWithStatus:@"请先安装享家客户端" inView:self.view];
        }
    }
}

- (void)touchQQ{
    GSHThirdPartyUserM *qq= [self getThirdPartyUserMWithType:GSHUserMThirdPartyLoginTypeQQ];
    if (qq.openId) {
        // 解除绑定QQ
        @weakify(self)
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            @strongify(self)
            if (buttonIndex == 1) {
                for (GSHThirdPartyUserM *model in [GSHUserManager currentUserInfo].thirdPartyUserList) {
                    if (model.userType == GSHUserMThirdPartyLoginTypeQQ) {
                        [self unbindThirdPartyUserWithOpenId:model.openId userThirdLoginType:GSHUserMThirdPartyLoginTypeQQ];
                    }
                }
            }
        } textFieldsSetupHandler:NULL andTitle:@"" andMessage:@"确定要解除绑定？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    } else {
        // 绑定QQ
        if ([OpenShare isQQInstalled]) {
            @weakify(self)
            [OpenShare QQAuth:kOPEN_PERMISSION_GET_INFO Success:^(NSDictionary *message) {
                @strongify(self)
                NSLog(@"message : %@",message);
                [self getUnionIdWithDictionary:message];
            } Fail:^(NSDictionary *message, NSError *error) {
                
            }];
        } else {
            [TZMProgressHUDManager showErrorWithStatus:@"请先安装QQ客户端" inView:self.view];
        }
    }
}

- (void)touchWeChat{
    GSHThirdPartyUserM *wechat = [self getThirdPartyUserMWithType:GSHUserMThirdPartyLoginTypeWechat];
    if (wechat.openId) {
        // 解除绑定微信
        @weakify(self)
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            @strongify(self)
            if (buttonIndex == 1) {
                for (GSHThirdPartyUserM *model in [GSHUserManager currentUserInfo].thirdPartyUserList) {
                    if (model.userType == GSHUserMThirdPartyLoginTypeWechat) {
                        [self unbindThirdPartyUserWithOpenId:model.openId userThirdLoginType:GSHUserMThirdPartyLoginTypeWechat];
                    }
                }
            }
        } textFieldsSetupHandler:NULL andTitle:@"" andMessage:@"确定要解除绑定？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    } else {
        // 绑定微信
        if ([OpenShare isWeixinInstalled]) {
            @weakify(self)
            [OpenShare WeixinAuth:@"snsapi_userinfo" Success:^(NSDictionary *message) {
                @strongify(self)
                NSLog(@"微信登录成功:\n%@",message);
                [self getAccessTokenWithCode:[message objectForKey:@"code"] userType:GSHUserMThirdPartyLoginTypeWechat];
            } Fail:^(NSDictionary *message, NSError *error) {
                NSLog(@"微信登录失败:\n%@\n%@",message,error);
            }];
        } else {
            [TZMProgressHUDManager showErrorWithStatus:@"请先安装微信客户端" inView:self.view];
        }
    }
}

- (NSURLSessionDataTask *)getWithAllUrl:(NSString *)allUrl
                             parameters:(id)parameters
                                success:(void (^)(id operationOrTask, id responseObject))success
                                failure:(void (^)(id operationOrTask, NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/plain",@"text/javascript",@"application/x-gzip" ,nil];
    return [manager GET:allUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *json = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Response GET: %@ , %@ \njson : %@", task.currentRequest.URL,parameters?parameters:@"",json);
        if (success) {
            success(task,json);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task,error);
        }
    }];
}

// 使用code获取access token
- (void)getAccessTokenWithCode:(NSString *)code userType:(GSHUserMThirdPartyLoginType)userType {
    [TZMProgressHUDManager showWithStatus:@"绑定中" inView:self.view];
    NSString *urlString = @"https://api.weixin.qq.com/sns/oauth2/access_token";
    NSDictionary *dict = @{@"appid":WX_App_ID,@"secret":WX_AppSecret,@"code":code,@"grant_type":@"authorization_code"};
    @weakify(self)
    [self getWithAllUrl:urlString parameters:dict success:^(id operationOrTask, id responseObject) {
        @strongify(self)
        NSDictionary *dict = [NSDictionary tzm_dictionaryWithJsonString:responseObject];
        if ([dict objectForKey:@"errcode"]) {
            //获取token错误
            [TZMProgressHUDManager showErrorWithStatus:[dict objectForKey:@"errcode"] inView:self.view];
        } else {
            NSString *openID = [dict objectForKey:WX_OPEN_ID];
            NSString *accessToken = [dict objectForKey:WX_ACCESS_TOKEN];
            [self wechatLoginByRequestForUserInfoWithOpenId:openID
                                                accessToken:accessToken
                                                   userType:userType];
        }
    } failure:^(id operationOrTask, NSError *error) {
        @strongify(self)
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
    }];
}

// 获取用户个人信息（UnionID机制）
- (void)wechatLoginByRequestForUserInfoWithOpenId:(NSString *)openId
                                      accessToken:(NSString *)accessToken
                                         userType:(GSHUserMThirdPartyLoginType)userType {
    NSString *userUrlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo"];
    NSDictionary *dict = @{@"access_token":accessToken,@"openid":openId};
    @weakify(self)
    [self getWithAllUrl:userUrlStr parameters:dict success:^(id operationOrTask, id responseObject) {
        @strongify(self)
        NSLog(@"请求用户信息的response = %@", responseObject);
        NSDictionary *userDict = [NSDictionary tzm_dictionaryWithJsonString:responseObject];
        NSString *nickName = [userDict objectForKey:@"nickname"];
        NSString *openId = [userDict objectForKey:@"openid"];
        [self bindThirdPartyUserWithOpenId:openId userName:nickName userThirdLoginType:userType];
    } failure:^(id operationOrTask, NSError *error) {
        NSLog(@"获取用户信息时出错 = %@", error);
        @strongify(self)
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
    }];
}
- (void)getUnionIdWithDictionary:(NSDictionary *)message {
    NSString *access_token = [message objectForKey:@"access_token"];
    NSString *urlString = @"https://graph.qq.com/oauth2.0/me";
    NSDictionary *dict = @{@"access_token":access_token,@"unionid":@"1"};
    [TZMProgressHUDManager showWithStatus:@"绑定中" inView:self.view];
    @weakify(self)
    [self getWithAllUrl:urlString parameters:dict success:^(id operationOrTask, id responseObject) {
        @strongify(self)
        NSString *result = [responseObject substringFromIndex:10];
        result = [result substringToIndex:result.length-3];
        NSDictionary *dict = [NSDictionary tzm_dictionaryWithJsonString:result];
        [self getUserInfoWithDictionary:message unionid:[dict objectForKey:@"unionid"]];
    } failure:^(id operationOrTask, NSError *error) {
        @strongify(self)
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
    }];
}

- (void)getUserInfoWithDictionary:(NSDictionary *)message unionid:(NSString *)unionid {
    NSString *urlString = @"https://graph.qq.com/user/get_user_info";
    NSString *openId = [message objectForKey:@"openid"];
    NSString *access_token = [message objectForKey:@"access_token"];
    NSString *oauth_consumer_key = QQ_App_ID;
    NSDictionary *dict = @{@"access_token":access_token,@"oauth_consumer_key":oauth_consumer_key,@"openid":openId};
    @weakify(self)
    [self getWithAllUrl:urlString parameters:dict success:^(id operationOrTask, id responseObject) {
        @strongify(self)
        [TZMProgressHUDManager dismissInView:self.view];
        NSDictionary *dict = [NSDictionary tzm_dictionaryWithJsonString:responseObject];
        NSString *userName = [dict valueForKey:@"nickname"];
        [self bindThirdPartyUserWithOpenId:unionid userName:userName userThirdLoginType:GSHUserMThirdPartyLoginTypeQQ];
    } failure:^(id operationOrTask, NSError *error) {
        @strongify(self)
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
    }];
    
}

#pragma mark -享家登录
- (void)getEnjoyUserInfoWithAuthCode:(NSString *)authCode {
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"" inView:self.view];
    [GSHRequestManager postWithPath:@"user/getEnjoyUserInfo" parameters:@{@"accessToken":authCode} block:^(id responseObjec, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if ([responseObjec isKindOfClass:NSDictionary.class]){
                NSString *openId = [((NSDictionary*)responseObjec) stringValueForKey:@"openId" default:nil];
                NSString *userName = [((NSDictionary*)responseObjec) stringValueForKey:@"nickName" default:nil];
                [weakSelf bindThirdPartyUserWithOpenId:openId userName:userName userThirdLoginType:GSHUserMThirdPartyLoginTypeEnjoy];
            }
        }
    }];
}


#pragma mark - request
// 绑定第三方
- (void)bindThirdPartyUserWithOpenId:(NSString *)openId
                            userName:(NSString *)userName
                  userThirdLoginType:(GSHUserMThirdPartyLoginType)userThirdLoginType {
    __weak typeof(self)weakSelf = self;
    [GSHUserManager bindThirdPartyUserInfoWithOpenId:openId
                                      userName:userName
                            userThirdLoginType:userThirdLoginType
                                         block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"绑定成功" inView:weakSelf.view];
            GSHThirdPartyUserM *m = [weakSelf getThirdPartyUserMWithType:userThirdLoginType];
            if (!m) {
                m = [GSHThirdPartyUserM new];
                NSMutableArray<GSHThirdPartyUserM*> *list = [NSMutableArray arrayWithArray:weakSelf.userInfo.thirdPartyUserList];
                [list addObject:m];
                weakSelf.userInfo.thirdPartyUserList = list;
            }
            m.openId = openId;
            m.userName = userName;
            m.userType = userThirdLoginType;
            [GSHUserManager setCurrentUserInfo:weakSelf.userInfo];
            [weakSelf refreshUI];
        }
    }];
}
// 解绑第三方
- (void)unbindThirdPartyUserWithOpenId:(NSString *)openId
                    userThirdLoginType:(GSHUserMThirdPartyLoginType)userThirdLoginType {
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"解绑中" inView:self.view];
    [GSHUserManager unbindThirdPartyUserInfoWithOpenId:openId block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"解绑成功" inView:weakSelf.view];
            GSHThirdPartyUserM *m = [weakSelf getThirdPartyUserMWithType:userThirdLoginType];
            if (m) {
                m.openId = nil;
            }
            [GSHUserManager setCurrentUserInfo:weakSelf.userInfo];
            [weakSelf refreshUI];
        }
    }];
}
@end
