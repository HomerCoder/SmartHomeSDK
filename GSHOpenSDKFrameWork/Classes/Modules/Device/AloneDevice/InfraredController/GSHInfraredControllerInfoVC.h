//
//  GSHInfraredControllerInfoVC.h
//  SmartHome
//
//  Created by gemdale on 2019/2/21.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

@interface GSHInfraredControllerInfoVCCell : UITableViewCell
@property(nonatomic,strong)GSHKuKongInfraredDeviceM *device;
@end

@interface GSHInfraredControllerInfoVC : GSHDeviceVC
+(instancetype)infraredControllerInfoVCWithDevice:(GSHDeviceM*)device;
@end

