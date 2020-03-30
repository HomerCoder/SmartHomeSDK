//
//  GSHSensorGroupTypeVC.h
//  SmartHome
//
//  Created by gemdale on 2018/12/26.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHSensorGroupTypeVCCell : UICollectionViewCell

@end

@interface GSHSensorGroupTypeVC : UIViewController
+ (instancetype)sensorGroupTypeVCWithSensor:(GSHSensorM *)sensor;
@end
