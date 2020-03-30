//
//  GSHAirBoxSensorSetVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/11/21.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHAirBoxSensorSetVC : GSHDeviceVC

+ (instancetype)airBoxSensorSetVCWithDeviceM:(GSHDeviceM *)deviceM;

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

@end


@interface GSHAirBoxSensorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIPickerView *middlePickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *leftPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *rightPickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftPickerViewCenterX;
@end


NS_ASSUME_NONNULL_END
