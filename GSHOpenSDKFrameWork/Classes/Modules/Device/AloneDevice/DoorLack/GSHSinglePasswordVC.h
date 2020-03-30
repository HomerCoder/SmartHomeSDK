//
//  GSHSinglePasswordVC.h
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDoorLockManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHSinglePasswordVC : UIViewController
+(instancetype)singlePasswordVCWithPassword:(GSHDoorLockPassWordM*)model device:(GSHDeviceM*)device;
@end

NS_ASSUME_NONNULL_END
