//
//  TZMActionViewManager.m
//  SmartHome
//
//  Created by gemdale on 2018/5/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAlertManager.h"
#import "UIViewController+TZM.h"
#import "LGAlertView.h"
#import "GSHWeChatStyleActionSheetView.h"

@implementation GSHAlertManager

+ (id)showAlertWithBlock:(void (^)(NSInteger buttonIndex, id alert))block
  textFieldsSetupHandler:(void (^)(UITextField * textField, NSUInteger index))textFieldsSetupHandler
                andTitle:(NSString *)title
              andMessage:(NSString *)message
                   image:(UIImage*)image
          preferredStyle:(GSHAlertManagerStyle)style
  destructiveButtonTitle:(NSString *)destructiveButtonTitle
       cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitles:(NSString *)otherButtonTitles,...{
    
    NSMutableArray *btnText = [NSMutableArray array];
    if( otherButtonTitles != nil ){
        [btnText addObject:otherButtonTitles];
        va_list args;
        va_start( args, otherButtonTitles );
        for ( ;; ){
            NSString * otherButtonTitle = va_arg( args, NSString * );
            if ( nil == otherButtonTitle) break;
            [btnText addObject:otherButtonTitle];
        }
        va_end( args );
    }
    NSInteger count = btnText.count;
    
    if(style == GSHAlertManagerStyleActionSheet){
        [GSHWeChatStyleActionSheetView showWithTitle:title
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:destructiveButtonTitle
                                   otherButtonTitles:btnText
                                       selectedBlock:^(NSInteger index) {
                                           if (block) {
                                               block(index,nil);
                                           }
                                       }];
        return nil;
        
    } else {
        LGAlertView *alertView;
        if (image) {
            //只有图片的弹框
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 150)];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 0, 80, 80)];
            imageView.image = image;
            [view addSubview:imageView];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 90, 200, 20)];
            label.text = title;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18.0];
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 114, 200, 36)];
            label1.text = message;
            label1.numberOfLines = 2;
            label1.textColor = [UIColor colorWithHexString:@"#222222"];
            label1.font = [UIFont systemFontOfSize:15.f];
            label1.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label1];
            
            alertView = [[LGAlertView alloc] initWithViewAndTitle:nil message:nil style:LGAlertViewStyleAlert view:view buttonTitles:btnText cancelButtonTitle:destructiveButtonTitle destructiveButtonTitle:cancelButtonTitle actionHandler:^(LGAlertView * _Nonnull alertView, NSUInteger index, NSString * _Nullable title) {
                if (block) {
                    block(index + 1,alertView);
                }
            } cancelHandler:^(LGAlertView * _Nonnull alertView) {
                if (block) {
                    block(0,alertView);
                }
            } destructiveHandler:^(LGAlertView * _Nonnull alertView) {
                if (block) {
                    block(count + 1,alertView);
                }
            }];
        }else if (textFieldsSetupHandler) {
            //只有输入框
            UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 270 - 42, 36)];
            textFieldsSetupHandler(textField,0);
            
            alertView = [[LGAlertView alloc] initWithViewAndTitle:title message:message style:LGAlertViewStyleAlert view:textField buttonTitles:btnText cancelButtonTitle:destructiveButtonTitle destructiveButtonTitle:cancelButtonTitle actionHandler:^(LGAlertView * _Nonnull alertView, NSUInteger index, NSString * _Nullable title) {
                if (block) {
                    block(index + 1,alertView);
                }
            } cancelHandler:^(LGAlertView * _Nonnull alertView) {
                if (block) {
                    block(0,alertView);
                }
            } destructiveHandler:^(LGAlertView * _Nonnull alertView) {
                if (block) {
                    block(count + 1,alertView);
                }
            }];
//                alertView.destructiveButtonEnabled = NO;
                alertView.destructiveButtonTitleColorDisabled = [UIColor colorWithRGBA:0xE60B0D64];
        }else{
            alertView = [[LGAlertView alloc] initWithTitle:title message:message style:LGAlertViewStyleAlert buttonTitles:btnText cancelButtonTitle:destructiveButtonTitle destructiveButtonTitle:cancelButtonTitle actionHandler:^(LGAlertView * _Nonnull alertView, NSUInteger index, NSString * _Nullable title) {
                if (block) {
                    block(index + 1,alertView);
                }
            } cancelHandler:^(LGAlertView * _Nonnull alertView) {
                if (block) {
                    block(0,alertView);
                }
            } destructiveHandler:^(LGAlertView * _Nonnull alertView) {
                if (block) {
                    block(count + 1,alertView);
                }
            }];
        }
        
        alertView.windowLevel = LGAlertViewWindowLevelAboveStatusBar;
        alertView.titleTextColor = [UIColor blackColor];
        alertView.titleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:18.0];
        alertView.messageTextColor = [UIColor colorWithHexString:@"#222222"];
        alertView.messageFont = [UIFont systemFontOfSize:15.f];
        alertView.cancelOnTouch = NO;

        alertView.buttonsFont = [UIFont systemFontOfSize:17.f];
        alertView.buttonsTitleColor = [UIColor colorWithHexString:@"#2EB0FF"];
        alertView.buttonsTitleColorHighlighted = [UIColor colorWithHexString:@"#2EB0FF"];
        alertView.buttonsBackgroundColorHighlighted = [UIColor whiteColor];
        alertView.buttonsBackgroundColor = [UIColor whiteColor];

        alertView.destructiveButtonFont = [UIFont systemFontOfSize:17.f];
        alertView.destructiveButtonTitleColor = [UIColor colorWithHexString:@"#222222"];
        alertView.destructiveButtonTitleColorHighlighted = [UIColor colorWithHexString:@"#222222"];
        alertView.destructiveButtonBackgroundColorHighlighted = [UIColor whiteColor];
        alertView.destructiveButtonBackgroundColor = [UIColor whiteColor];

        alertView.cancelButtonFont = [UIFont systemFontOfSize:17.f];
        alertView.cancelButtonTitleColor = [UIColor colorWithHexString:@"#f4333c"];
        alertView.cancelButtonTitleColorHighlighted = [UIColor colorWithHexString:@"#f4333c"];
        alertView.cancelButtonBackgroundColorHighlighted = [UIColor whiteColor];
        alertView.cancelButtonBackgroundColor = [UIColor whiteColor];

        alertView.layerCornerRadius = 7.0f;
        alertView.shouldDismissAnimated = NO;
        alertView.heightMax = 320;
        alertView.width = 270;
        alertView.buttonsHeight = 50;
        [alertView showAnimated:NO completionHandler:nil];
        return nil;
    }
}

LGAlertView *soleAlertView;
NSString *soleMessage;
+(void)showAlertWithTitle:(NSString*)title text:(NSString*)text block:(void (^)(NSInteger buttonIndex, id alert))block{
    if (soleAlertView) {
        [soleAlertView dismissAnimated:NO completionHandler:^{
        }];
        soleAlertView = nil;
    }
    if (soleMessage.length > 0) {
        soleMessage = [NSString stringWithFormat:@"%@\n%@",text,soleMessage];
    }else{
        soleMessage = text;
    }
    
    UIScrollView *scrollView = [UIScrollView new];
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    label.attributedText = [[NSAttributedString alloc] initWithString:soleMessage attributes:attributes];
    label.textColor = [UIColor colorWithHexString:@"#222222"];
    label.font = [UIFont systemFontOfSize:15.f];
    
    [scrollView addSubview:label];
    scrollView.frame = CGRectMake(0.0, 0.0, 270, 145.0);
    
    
    CGSize labelSize = [label sizeThatFits:CGSizeMake(270 - 16.0, CGFLOAT_MAX)];
    label.frame = CGRectMake(20.0, 0.0, 270 - 40.0, labelSize.height);
    
    scrollView.frame = CGRectMake(0.0, 0.0, 270, labelSize.height > 200 ? 200 : labelSize.height);
    scrollView.contentSize = CGSizeMake(270, labelSize.height);
    
    soleAlertView = [[LGAlertView alloc] initWithViewAndTitle:title message:nil style:LGAlertViewStyleAlert view:scrollView buttonTitles:@[@"立即查看"] cancelButtonTitle:@"暂不处理" destructiveButtonTitle:nil actionHandler:^(LGAlertView * _Nonnull alertView, NSUInteger index, NSString * _Nullable title) {
        if (block) {
            block(1,alertView);
        }
        soleMessage = nil;
    } cancelHandler:^(LGAlertView * _Nonnull alertView) {
        if (block) {
            block(2,alertView);
        }
        soleMessage = nil;
    } destructiveHandler:^(LGAlertView * _Nonnull alertView) {
        if (block) {
            block(0,alertView);
        }
        soleMessage = nil;
    }];
    soleAlertView.windowLevel = LGAlertViewWindowLevelAboveStatusBar;
    soleAlertView.titleTextColor = [UIColor blackColor];
    soleAlertView.titleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:18.0];
    soleAlertView.cancelOnTouch = NO;
    
    soleAlertView.buttonsFont = [UIFont systemFontOfSize:17.f];
    soleAlertView.buttonsTitleColor = [UIColor colorWithHexString:@"#2EB0FF"];
    soleAlertView.buttonsTitleColorHighlighted = [UIColor colorWithHexString:@"#2EB0FF"];
    soleAlertView.buttonsBackgroundColorHighlighted = [UIColor whiteColor];
    soleAlertView.buttonsBackgroundColor = [UIColor whiteColor];
    
    soleAlertView.cancelButtonFont = [UIFont systemFontOfSize:17.f];
    soleAlertView.cancelButtonTitleColor = [UIColor colorWithHexString:@"#222222"];
    soleAlertView.cancelButtonTitleColorHighlighted = [UIColor colorWithHexString:@"#222222"];
    soleAlertView.cancelButtonBackgroundColorHighlighted = [UIColor whiteColor];
    soleAlertView.cancelButtonBackgroundColor = [UIColor whiteColor];
    
    soleAlertView.layerCornerRadius = 7.0f;
    soleAlertView.shouldDismissAnimated = NO;
    soleAlertView.heightMax = 320;
    soleAlertView.width = 270;
    soleAlertView.buttonsHeight = 50;
    
    [soleAlertView showAnimated:NO completionHandler:nil];
}

@end
