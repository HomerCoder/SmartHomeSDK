//
//  GSHUserInfoVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/11.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHUserInfoVC : UITableViewController
+(instancetype)newWithUserInfo:(GSHUserInfoM*)userInfo;//userinfo为空就网络请求userinfo
@end
