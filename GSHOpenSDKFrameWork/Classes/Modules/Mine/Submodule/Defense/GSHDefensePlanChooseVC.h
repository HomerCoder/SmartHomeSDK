//
//  GSHDefensePlanChooseVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/6/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GSHDefensePlanM;

NS_ASSUME_NONNULL_BEGIN

@interface GSHDefensePlanChooseVC : UIViewController

+(instancetype)defensePlanChooseVCWithSelectTemplateId:(NSString *)templateId;

@property (copy , nonatomic) void (^updateSuccessBlock)(GSHDefensePlanM *planM);
@property (copy , nonatomic) void (^chooseBlock)(GSHDefensePlanM *planM);

@end

@interface GSHDefensePlanChooseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *defensePlanNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;


@end

NS_ASSUME_NONNULL_END
