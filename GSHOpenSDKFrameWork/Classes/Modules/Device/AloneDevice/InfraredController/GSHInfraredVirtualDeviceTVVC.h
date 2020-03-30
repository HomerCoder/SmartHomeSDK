//
//  GSHInfraredVirtualDeviceTVVC.h
//  SmartHome
//
//  Created by gemdale on 2019/4/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

@interface GSHInfraredVirtualDeviceTVVC : GSHDeviceVC
+ (instancetype)tvHandleVCWithDevice:(GSHKuKongInfraredDeviceM *)device;
@end
