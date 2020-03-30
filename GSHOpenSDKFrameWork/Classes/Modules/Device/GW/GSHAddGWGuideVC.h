//
//  GSHAddGWGuideVC.h
//  SmartHome
//
//  Created by gemdale on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//


@interface GSHAddGWGuideVC : UIViewController
+(instancetype)addGWGuideVCWithFamily:(GSHFamilyM*)family deviceModel:(GSHDeviceModelM*)model sn:(NSString*)sn;
@end
