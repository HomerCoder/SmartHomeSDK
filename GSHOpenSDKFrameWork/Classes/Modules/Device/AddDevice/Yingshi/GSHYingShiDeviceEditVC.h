//
//  GSHYingShiDeviceEditVC.h
//  SmartHome
//
//  Created by gemdale on 2019/1/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHYingShiDeviceEditVC : UITableViewController
@property (nonatomic , copy) void (^deviceEditSuccessBlock)(GSHDeviceM *deviceM);
+(instancetype)yingShiDeviceEditVCWithDevice:(GSHDeviceM*)device;
@end
