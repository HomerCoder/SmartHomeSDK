//
//  GSHWeChatStyleActionSheetView.h
//  SmartHome
//
//  Created by zhanghong on 2018/11/28.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHWeChatStyleActionSheetView : UIView

+ (void)showWithTitle:(NSString *)title
    cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles
        selectedBlock:(void (^)(NSInteger index))selectedBlock;

@end

NS_ASSUME_NONNULL_END
