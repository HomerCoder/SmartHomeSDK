//
//  GSHQRCodeVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHUserInfoVC.h"

@interface GSHQRCodeVC : UIViewController
+(instancetype)qrCodeVCWithUserInfo:(GSHUserInfoM*)userInfo;
@end
