//
//  GSHDefenseAddVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/6/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GSHDefenseDeviceTypeM;


@interface GSHDefenseSetOneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *typeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeValueLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end

@interface GSHDefenseAddVC : UIViewController

+(instancetype)defenseAddVCWithDefenseDeviceTypeM:(GSHDefenseDeviceTypeM *)defenseDeviceTypeM typeName:(NSString *)typeName;

@end


