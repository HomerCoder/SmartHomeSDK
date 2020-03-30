//
//  GSHInfraredControllerBrandVC.h
//  SmartHome
//
//  Created by gemdale on 2019/2/22.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GSHInfraredControllerBrandVCCell : UITableViewCell

@end

@interface GSHInfraredControllerBrandVC : UIViewController
+(instancetype)infraredControllerBrandVCWithType:(GSHKuKongDeviceTypeM*)type device:(GSHDeviceM*)device;
@end
