//
//  GSHAddGWListVC.h
//  SmartHome
//
//  Created by gemdale on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAddGWListVCCell : UITableViewCell
@property(nonatomic,strong)NSDictionary *model;
@end


@interface GSHAddGWListVC : UIViewController
+(instancetype)addGWListVCWithGWList:(NSArray<NSDictionary*>*)list family:(GSHFamilyM*)family deviceModel:(GSHDeviceModelM*)model;
@end
