//
//  GSHShengBiKeListVC.h
//  SmartHome
//
//  Created by gemdale on 2019/12/16.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHShengBiKeListVCCell : UITableViewCell
@end

@interface GSHShengBiKeListVC : UIViewController
+(instancetype)shengBiKeListVCWithDeviceList:(NSMutableArray<GSHDeviceM *> *)deviceList;
@end

