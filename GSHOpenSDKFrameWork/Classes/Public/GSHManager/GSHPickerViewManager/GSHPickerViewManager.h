//
//  GSHPickerView.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "ZJPickerView.h"
#import "PGDatePickManager.h"

@interface GSHPickerViewManager : NSObject
+ (void)showPickerViewWithDataArray:(NSArray *)dataArray selectContent:(NSString*)selectContent completion:(void (^)(NSString *selectContent , NSArray *selectRowArray))completion;
+ (void)showPickerViewContainResetButtonWithDataArray:(NSArray *)dataArray
                                       cancelBenTitle:(NSString *)cancelBtnTitle
                                  cancelBenTitleColor:(UIColor *)cancelBenTitleColor
                                         sureBtnTitle:(NSString *)sureBtnTitle
                                          cancelBlock:(void(^)(void))cancelBlock
                                           completion:(void (^)(NSString *selectContent , NSArray *selectRowArray))completion;
+(void)showDatePickerViewWithDelegate:(id<PGDatePickerDelegate>)delegate mode:(PGDatePickerMode)mode maximumDate:(NSDate*)maximumDate minimumDate:(NSDate*)minimumDate cancelButtonMonitor:(void(^)(void))cancelButtonMonitor;
+(void)showPrecinctPickerViewWithPrecinctList:(NSArray<GSHPrecinctM*>*)precinctList completion:(void (^) (GSHPrecinctM *districtModel,NSString *address))completion;
@end
