//
//  GSHDeviceShowVC.h
//  SmartHome
//
//  Created by gemdale on 2019/11/21.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "TZMBlanketVC.h"
#import "GSHDeviceVC.h"


@interface GSHDeviceShowVC : TZMBlanketVC
+(instancetype)deviceShowVCWithVC:(GSHDeviceVC*)vc;
-(void)hideTopView:(BOOL)hide;
@end
