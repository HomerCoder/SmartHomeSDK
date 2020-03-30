//
//  GSHInputTextVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHInputTextVC : UIViewController
+(instancetype)inputTextVCWithOldText:(NSString*)oldText block:(void(^)(NSString *text,GSHInputTextVC *inputTextVC))block;
@end
