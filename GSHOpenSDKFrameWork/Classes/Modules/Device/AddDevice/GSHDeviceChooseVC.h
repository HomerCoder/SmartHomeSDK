//
//  GSHDeviceChooseVC.h
//  SmartHome
//
//  Created by gemdale on 2018/6/5.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHDeviceChooseVCCell : UITableViewCell
@property(nonatomic,strong)GSHDeviceM *device;
@end

@interface GSHDeviceChooseVC : UIViewController
+(instancetype)deviceChooseVCWithDeviceList:(NSMutableArray<GSHDeviceM*>*)deviceList;
@end
