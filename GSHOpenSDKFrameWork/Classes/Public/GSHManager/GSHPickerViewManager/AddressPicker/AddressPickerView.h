//
//  AddressPickerView.h
//  addressPicker
//
//  Created by 汪泽天 on 2018/7/26.
//  Copyright © 2018年 霍. All rights reserved.
//


#import <UIKit/UIKit.h>

@class GSHPrecinctM;

typedef NS_ENUM(NSUInteger, pickerViewSelectType) {
    PickerViewSelectTypeProvince,
    PickerViewSelectTypeCity,
    PickerViewSelectTypeDistrict
};

@interface AddressPickerView : UIView

typedef void (^selectBlock)(GSHPrecinctM *provinceModel , GSHPrecinctM *cityModel , GSHPrecinctM *districtModel, NSString *addressStr);

+ (void)showPickerViewWithFrame:(CGRect)frame AddressDataArray:(NSArray *)dataArray resultBlock:(selectBlock)block;


//访问
@property (nonatomic) pickerViewSelectType selectType;

@property (nonatomic, strong) GSHPrecinctM *provinceModel;
@property (nonatomic, strong) GSHPrecinctM *cityModel;
@property (nonatomic, strong) GSHPrecinctM *districtModel;

@end
