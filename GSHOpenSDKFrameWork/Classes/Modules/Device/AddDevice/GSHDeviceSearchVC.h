//
//  GSHDeviceSearchVC.h
//  SmartHome
//
//  Created by gemdale on 2018/6/5.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHDeviceSearchVC : UIViewController
+(instancetype)deviceSearchVCWithDeviceCategory:(GSHDeviceModelM*)model deviceSn:(NSString *)deviceSn;
@end
