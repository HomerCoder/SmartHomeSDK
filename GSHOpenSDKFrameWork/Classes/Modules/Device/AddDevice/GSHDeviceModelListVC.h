//
//  GSHDeviceModelListVC.h
//  SmartHome
//
//  Created by gemdale on 2019/11/26.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface GSHDeviceModelListVCCell : UITableViewCell

@end

@interface GSHDeviceModelListVC : UIViewController
+(instancetype)deviceModelListVCWithList:(NSArray<GSHDeviceModelM*>*)list sn:(NSString*)sn;
@end
