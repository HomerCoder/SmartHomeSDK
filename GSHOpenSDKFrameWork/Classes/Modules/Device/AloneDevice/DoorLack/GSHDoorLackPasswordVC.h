//
//  GSHDoorLackPasswordVC.h
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDoorLockManager.h"

@interface GSHDoorLackPasswordVC : UIViewController
+(instancetype)doorLackPasswordVCWithPassword:(GSHDoorLockPassWordM*)password device:(GSHDeviceM*)device;
@end
