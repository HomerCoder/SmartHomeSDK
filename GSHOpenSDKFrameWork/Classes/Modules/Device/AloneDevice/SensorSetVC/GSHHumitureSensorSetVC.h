//
//  GSHHumitureSensorSetVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/11/15.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHHumitureSensorSetVC : GSHDeviceVC

+ (instancetype)humitureSensorSetVCWithDeviceM:(GSHDeviceM *)deviceM;

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

@end

@interface GSHHumitureSenSorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIPickerView *leftPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *rightPickerView;


@end

NS_ASSUME_NONNULL_END
