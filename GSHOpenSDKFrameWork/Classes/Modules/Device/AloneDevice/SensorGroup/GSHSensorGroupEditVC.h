//
//  GSHSensorGroupEditVC.h
//  SmartHome
//
//  Created by gemdale on 2018/12/27.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHSensorGroupEditVC : UITableViewController
+ (instancetype)sensorGroupEditVCWithSensor:(GSHSensorM *)sensor category:(GSHDeviceModelM*)category;
@end
