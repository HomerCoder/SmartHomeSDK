//
//  GSHPickerView.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "ZJPickerView.h"

@interface GSHPickerView : ZJPickerView

+ (void)showPickerViewWithDataArray:(NSArray *)dataArray completion:(void (^)(NSString *selectContent , NSArray *selectRowArray))completion;

+ (void)showPickerViewWithDataArray:(NSArray *)dataArray selectContent:(NSString*)selectContent completion:(void (^)(NSString *selectContent , NSArray *selectRowArray))completion;

+ (UIPickerView*)showPickerViewWithDelegate:(id<UIPickerViewDataSource, UIPickerViewDelegate>)delegate completion:(void (^)(void))completion;

+ (void)showPickerViewContainResetButtonWithDataArray:(NSArray *)dataArray
                                       cancelBenTitle:(NSString *)cancelBtnTitle
                                  cancelBenTitleColor:(UIColor *)cancelBenTitleColor
                                         sureBtnTitle:(NSString *)sureBtnTitle
                                          cancelBlock:(void(^)(void))cancelBlock
                                           completion:(void (^)(NSString *selectContent , NSArray *selectRowArray))completion;

@end
