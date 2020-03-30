//
//  GSHLoginResetPasswordVC.h
//  SmartHome
//
//  Created by gemdale on 2019/11/7.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHLoginResetPasswordVC : UIViewController
+(instancetype)loginResetPasswordVCWithPhone:(NSString*)phone code:(NSString*)code;
@end
