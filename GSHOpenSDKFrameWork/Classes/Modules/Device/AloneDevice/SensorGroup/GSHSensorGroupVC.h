//
//  GSHSensorGroupVC.h
//  SmartHome
//
//  Created by gemdale on 2018/12/26.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

@interface GSHSensorGroupVCCell : UICollectionViewCell

@end

@interface GSHSensorGroupVC : GSHDeviceVC
+ (instancetype)sensorGroupVCWithDeviceM:(GSHDeviceM *)deviceM;
@end

