//
//  GSHLoginVerificationCodeVC.h
//  SmartHome
//
//  Created by gemdale on 2019/11/7.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHLoginVerificationCodeVC : UIViewController
+(instancetype)loginVerificationCodeVCWithPhone:(NSString*)phone second:(NSInteger)second getCodeBlock:(void(^)(void))block;
@end
