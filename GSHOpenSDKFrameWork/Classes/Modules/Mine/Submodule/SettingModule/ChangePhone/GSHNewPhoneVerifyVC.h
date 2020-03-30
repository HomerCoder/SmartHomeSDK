//
//  GSHNewPhoneVerifyVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/15.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface GSHNewPhoneVerifyVC : UIViewController
+(instancetype)newPhoneVerifyVCWithToken:(NSString*)token userInfo:(GSHUserInfoM*)userInfo;
@end
