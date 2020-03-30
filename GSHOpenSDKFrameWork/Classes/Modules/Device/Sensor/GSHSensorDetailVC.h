//
//  GSHSensorDetailVC.h
//  SmartHome
//
//  Created by gemdale on 2018/11/13.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHWebViewController.h"

@interface GSHSensorDetailVC : GSHWebViewController
+(instancetype)sensorDetailVCWithFamilyId:(NSString*)familyId sensor:(GSHSensorM*)sensor;
@end
