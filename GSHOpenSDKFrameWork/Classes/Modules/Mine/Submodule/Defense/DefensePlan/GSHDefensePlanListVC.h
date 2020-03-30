//
//  GSHDefensePlanListVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/5/31.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GSHDefensePlanM;

NS_ASSUME_NONNULL_BEGIN

@interface GSHDefensePlanListVC : UIViewController

@property (copy , nonatomic) void (^updateSuccessBlock)(GSHDefensePlanM *planM);
@property (copy , nonatomic) void (^deleteButtonClickBlock)(NSString *templateId);
@property (copy , nonatomic) void (^addButtonClickBlock)(void);

+(instancetype)defensePlanListVC;

@end

@interface GSHDefensePlanListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *defensePlanNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end

NS_ASSUME_NONNULL_END
