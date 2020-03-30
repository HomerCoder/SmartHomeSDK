//
//  GSHDoorLackOpenListVC.h
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHDoorLackOpenListVCCell : UITableViewCell
@end

@interface GSHDoorLackOpenListVC : UIViewController
+(instancetype)doorLackOpenListVCWithDevice:(GSHDeviceM*)device;
@end

NS_ASSUME_NONNULL_END
