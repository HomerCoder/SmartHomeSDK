//
//  GSHInfraredControllerTypeVC.h
//  SmartHome
//
//  Created by gemdale on 2019/2/22.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHInfraredControllerTypeVCCell : UITableViewCell

@end

@interface GSHInfraredControllerTypeVC : UIViewController
+(instancetype)infraredControllerTypeVCWithDevice:(GSHDeviceM*)device;
@end
