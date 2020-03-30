//
//  GSHPickerView.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHPickerView.h"

@implementation GSHPickerView

+ (void)showPickerViewWithDataArray:(NSArray *)dataArray
                         completion:(void (^)(NSString *selectContent , NSArray *selectRowArray))completion {
    
    NSDictionary *propertyDict = @{
                                   ZJPickerViewPropertyCanceBtnTitleKey : @"取消",
                                   ZJPickerViewPropertySureBtnTitleKey  : @"确定",
                                   ZJPickerViewPropertyTipLabelTextKey  : @"",
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

+ (UIPickerView*)showPickerViewWithDelegate:(id<UIPickerViewDataSource, UIPickerViewDelegate>)delegate completion:(void (^)(void))completion{
    NSDictionary *propertyDict = @{
                                   ZJPickerViewPropertyCanceBtnTitleKey : @"取消",
                                   ZJPickerViewPropertySureBtnTitleKey  : @"确定",
                                   ZJPickerViewPropertyTipLabelTextKey  : @"",
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
    
    return [ZJPickerView zj_showWithDelegate:delegate propertyDict:propertyDict completion:^(NSString * _Nullable selectContent, NSArray * _Nullable selectRowArray) {
        if (completion) {
            completion();
        }
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

@end
