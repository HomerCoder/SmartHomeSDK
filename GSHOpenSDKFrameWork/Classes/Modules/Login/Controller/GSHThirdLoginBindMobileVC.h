//
//  GSHThirdLoginBindMobileVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHThirdLoginBindMobileVC : UIViewController

@property (nonatomic , strong) NSString *openId;
@property (nonatomic , strong) NSString *userName;
@property (nonatomic , strong) NSString *headImgUrl;
@property (nonatomic , assign) GSHUserMLoginType type;
@property (nonatomic , assign) GSHUserMThirdPartyLoginType userThirdLoginType;

@end
