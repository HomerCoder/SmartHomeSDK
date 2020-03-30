//
//  GSHInfraredControllerVerifyVC.h
//  SmartHome
//
//  Created by gemdale on 2019/2/26.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHInfraredControllerVerifyVC : UIViewController
+(instancetype)infraredControllerVerifyVCWithType:(GSHKuKongDeviceTypeM*)type brand:(GSHKuKongBrandM*)brand device:(GSHDeviceM*)device;
@end
