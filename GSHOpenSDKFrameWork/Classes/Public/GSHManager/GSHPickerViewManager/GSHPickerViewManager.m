//
//  GSHPickerView.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHPickerViewManager.h"
#import "AddressPickerView.h"

@implementation GSHPickerViewManager
+ (void)showPickerViewWithDataArray:(NSArray *)dataArray selectContent:(NSString*)selectContent completion:(void (^)(NSString *selectContent , NSArray *selectRowArray))completion{
    NSDictionary *propertyDict = @{
                                   ZJPickerViewPropertyCanceBtnTitleKey : @"取消",
                                   ZJPickerViewPropertySureBtnTitleKey  : @"确定",
                                   ZJPickerViewPropertyTipLabelTextKey  : selectContent,
                                   ZJPickerViewPropertyCanceBtnTitleColorKey : [UIColor colorWithHexString:@"#999999"],
                                   ZJPickerViewPropertySureBtnTitleColorKey : [UIColor colorWithHexString:@"#2EB0FF"],
                                   ZJPickerViewPropertyTipLabelTextColorKey : [UIColor colorWithHexString:@"#999999"],
                                   ZJPickerViewPropertyLineViewBackgroundColorKey : [UIColor colorWithHexString:@"#EAEAEA"],
                                   ZJPickerViewPropertyCanceBtnTitleFontKey : [UIFont systemFontOfSize:17.0f],
                                   ZJPickerViewPropertySureBtnTitleFontKey : [UIFont systemFontOfSize:17.0f],
                                   ZJPickerViewPropertyTipLabelTextFontKey : [UIFont systemFontOfSize:17.0f],
                                   ZJPickerViewPropertyPickerViewHeightKey : @275.0f,
                                   ZJPickerViewPropertyOneComponentRowHeightKey : @50.0f,
                                   ZJPickerViewPropertySelectRowTitleAttrKey : @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#222222"], NSFontAttributeName : [UIFont systemFontOfSize:18.0f]},
                                   ZJPickerViewPropertyUnSelectRowTitleAttrKey : @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#222222"], NSFontAttributeName : [UIFont systemFontOfSize:16.0f]},
                                   ZJPickerViewPropertySelectRowLineBackgroundColorKey : [UIColor colorWithHexString:@"#EAEAEA"],
                                   ZJPickerViewPropertyIsTouchBackgroundHideKey : @YES,
                                   ZJPickerViewPropertyIsShowSelectContentKey : @NO,
                                   ZJPickerViewPropertyIsScrollToSelectedRowKey: @YES,
                                   ZJPickerViewPropertyIsAnimationShowKey : @YES
                                   };
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    [ZJPickerView zj_showWithDataList:dataArray propertyDict:propertyDict completion:^(NSString *selectContent , NSArray *selectRowArray) {
        
        NSArray *selectStrings = [selectContent componentsSeparatedByString:@","];
        NSMutableString *selectStringCollection = [[NSMutableString alloc] initWithString:@""];
        [selectStrings enumerateObjectsUsingBlock:^(NSString *selectString, NSUInteger idx, BOOL * _Nonnull stop) {
            if (selectString.length && ![selectString isEqualToString:@""]) {
                [selectStringCollection appendString:selectString];
            }
        }];
        completion(selectStringCollection , selectRowArray);
    }];
}

+ (void)showPickerViewContainResetButtonWithDataArray:(NSArray *)dataArray
                                       cancelBenTitle:(NSString *)cancelBtnTitle
                                       cancelBenTitleColor:(UIColor *)cancelBenTitleColor
                                         sureBtnTitle:(NSString *)sureBtnTitle
                                          cancelBlock:(void(^)(void))cancelBlock
                                           completion:(void (^)(NSString *selectContent , NSArray *selectRowArray))completion {
    
    NSDictionary *propertyDict = @{
                                   ZJPickerViewPropertyCanceBtnTitleKey : cancelBtnTitle,
                                   ZJPickerViewPropertySureBtnTitleKey  : sureBtnTitle,
                                   ZJPickerViewPropertyTipLabelTextKey  : @"",
                                   ZJPickerViewPropertyCanceBtnTitleColorKey : cancelBenTitleColor ? cancelBenTitleColor : [UIColor colorWithHexString:@"#2EB0FF"],
                                   ZJPickerViewPropertySureBtnTitleColorKey : [UIColor colorWithHexString:@"#2EB0FF"],
                                   ZJPickerViewPropertyTipLabelTextColorKey : [UIColor colorWithHexString:@"#999999"],
                                   ZJPickerViewPropertyLineViewBackgroundColorKey : [UIColor colorWithHexString:@"#EAEAEA"],
                                   ZJPickerViewPropertyCanceBtnTitleFontKey : [UIFont systemFontOfSize:17.0f],
                                   ZJPickerViewPropertySureBtnTitleFontKey : [UIFont systemFontOfSize:17.0f],
                                   ZJPickerViewPropertyTipLabelTextFontKey : [UIFont systemFontOfSize:17.0f],
                                   ZJPickerViewPropertyPickerViewHeightKey : @275.0f,
                                   ZJPickerViewPropertyOneComponentRowHeightKey : @50.0f,
                                   ZJPickerViewPropertySelectRowTitleAttrKey : @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#222222"], NSFontAttributeName : [UIFont systemFontOfSize:18.0f]},
                                   ZJPickerViewPropertyUnSelectRowTitleAttrKey : @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#222222"], NSFontAttributeName : [UIFont systemFontOfSize:16.0f]},
                                   ZJPickerViewPropertySelectRowLineBackgroundColorKey : [UIColor colorWithHexString:@"#EAEAEA"],
                                   ZJPickerViewPropertyIsTouchBackgroundHideKey : @YES,
                                   ZJPickerViewPropertyIsShowSelectContentKey : @NO,
                                   ZJPickerViewPropertyIsScrollToSelectedRowKey: @YES,
                                   ZJPickerViewPropertyIsAnimationShowKey : @YES
                                   };
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    [ZJPickerView zj_showWithDataList:dataArray
                         propertyDict:propertyDict
                          cancelBlock:^{
                              cancelBlock();
                          }
                           completion:^(NSString *selectContent , NSArray *selectRowArray) {
        
        NSArray *selectStrings = [selectContent componentsSeparatedByString:@","];
        NSMutableString *selectStringCollection = [[NSMutableString alloc] initWithString:@""];
        [selectStrings enumerateObjectsUsingBlock:^(NSString *selectString, NSUInteger idx, BOOL * _Nonnull stop) {
            if (selectString.length && ![selectString isEqualToString:@""]) {
                [selectStringCollection appendString:selectString];
            }
        }];
        completion(selectStringCollection , selectRowArray);
    }];
}

+(void)showDatePickerViewWithDelegate:(id<PGDatePickerDelegate>)delegate mode:(PGDatePickerMode)mode maximumDate:(NSDate*)maximumDate minimumDate:(NSDate*)minimumDate cancelButtonMonitor:(void(^)(void))cancelButtonMonitor{
    PGDatePickManager *datePickManager = [[PGDatePickManager alloc]init];
    PGDatePicker *datePicker = datePickManager.datePicker;
    datePickManager.cancelButtonMonitor = cancelButtonMonitor;
    datePicker.delegate = delegate;
    datePicker.datePickerMode = mode;
    datePicker.isHiddenMiddleText = NO;
    datePicker.middleTextColor = [UIColor clearColor];
    datePicker.maximumDate = maximumDate;
    datePicker.minimumDate = minimumDate;
    //设置线条的颜色
    datePicker.lineBackgroundColor = [UIColor colorWithHexString:@"#eaeaea"];
    //设置选中行的字体颜色
    datePicker.textColorOfSelectedRow = [UIColor colorWithHexString:@"#222222"];
    //设置未选中行的字体颜色
    datePicker.textColorOfOtherRow = [UIColor colorWithHexString:@"#999999"];
    //设置半透明的背景颜色
    datePickManager.isShadeBackgroud = YES;
    datePickManager.style = PGDatePickerType1;
    //设置头部的背景颜色
    datePickManager.headerViewBackgroundColor = [UIColor whiteColor];
    datePickManager.headerHeight = 45;
    //设置取消按钮的字体颜色
    datePickManager.cancelButtonTextColor = [UIColor colorWithHexString:@"#999999"];
    //设置取消按钮的字
    datePickManager.cancelButtonText = @"重置";
    //设置取消按钮的字体大小
    datePickManager.cancelButtonFont = [UIFont systemFontOfSize:17];
    //设置确定按钮的字体颜色
    datePickManager.confirmButtonTextColor = [UIColor colorWithHexString:@"#2EB0FF"];
    //设置确定按钮的字
    datePickManager.confirmButtonText = @"完成";
    //设置确定按钮的字体大小
    datePickManager.confirmButtonFont = [UIFont systemFontOfSize:17];
    [[UIViewController visibleTopViewController] presentViewController:datePickManager animated:NO completion:nil];
}

+(void)showPrecinctPickerViewWithPrecinctList:(NSArray<GSHPrecinctM*>*)precinctList completion:(void (^) (GSHPrecinctM *districtModel,NSString *address))completion{
    [AddressPickerView showPickerViewWithFrame:CGRectMake(0, kScreenHeight-300, kScreenWidth, 300) AddressDataArray:precinctList resultBlock:^(GSHPrecinctM *provinceModel, GSHPrecinctM *cityModel, GSHPrecinctM *districtModel, NSString *addressStr) {
        if (completion && districtModel) {
            completion(districtModel,addressStr);
        }
    }];
}

@end
