//
//  GSHSensorListVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHSensorListVC : UIViewController
+ (instancetype)sensorListVCWithFloor:(GSHFloorM*)floor familyIndex:(NSMutableDictionary*)familyIndex;
@end

@interface GSHSensorCell : UITableViewCell
@property(nonatomic,strong)GSHSensorM *model;
@end
