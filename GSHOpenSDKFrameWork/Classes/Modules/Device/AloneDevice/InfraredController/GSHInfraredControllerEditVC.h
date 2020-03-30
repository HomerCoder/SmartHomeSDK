//
//  GSHInfraredControllerEditVC.h
//  SmartHome
//
//  Created by gemdale on 2019/3/22.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHInfraredControllerEditVC : UITableViewController
+(instancetype)infraredControllerEditVCWithType:(GSHKuKongDeviceTypeM*)type remote:(GSHKuKongRemoteM*)remote superDevice:(GSHDeviceM*)superDevice brand:(GSHKuKongBrandM*)brand;
+(instancetype)infraredControllerEditVCWithDevice:(GSHKuKongInfraredDeviceM*)device;
@end
