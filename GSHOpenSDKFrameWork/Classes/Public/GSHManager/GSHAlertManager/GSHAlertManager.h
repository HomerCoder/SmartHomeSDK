//
//  TZMActionViewManager.h
//  SmartHome
//
//  Created by gemdale on 2018/5/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GSHAlertManagerStyle) {
    GSHAlertManagerStyleActionSheet = 0,
    GSHAlertManagerStyleAlert
};

@interface GSHAlertManager : NSObject
+ (id)showAlertWithBlock:(void (^)(NSInteger buttonIndex, id alert))block textFieldsSetupHandler:(void (^)(UITextField * textField, NSUInteger index))textFieldsSetupHandler andTitle:(NSString *)title andMessage:(NSString *)message image:(UIImage*)image preferredStyle:(GSHAlertManagerStyle)style destructiveButtonTitle:(NSString *)destructiveButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles,...;

+(void)showAlertWithTitle:(NSString*)title text:(NSString*)text block:(void (^)(NSInteger buttonIndex, id alert))block;
@end
