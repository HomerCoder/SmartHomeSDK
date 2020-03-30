//
//  GSHDefenseAddPlanVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/6/3.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GSHDefensePlanM;

@interface GSHDefenseAddPlanOneCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *typeNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *planNameTextField;

@end

@interface GSHDefenseAddPlanTwoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *typeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

typedef NS_ENUM(NSInteger, GSHDefensePlanSetType) {
    GSHDefensePlanSetAdd   = 0,  // 新增计划
    GSHDefensePlanSetEdit  = 1, //  编辑计划
};

@interface GSHDefenseAddPlanVC : UIViewController

@property (copy , nonatomic) void (^addButtonClickBlock)(void);
@property (copy , nonatomic) void (^deleteButtonClickBlock)(NSString *templateId);
@property (copy , nonatomic) void (^updateSuccessBlock)(GSHDefensePlanM *planM);

+(instancetype)defenseAddPlanVCWithPlanSetType:(GSHDefensePlanSetType)planSetType defensePlanM:(GSHDefensePlanM *)defensePlanM;

@end

