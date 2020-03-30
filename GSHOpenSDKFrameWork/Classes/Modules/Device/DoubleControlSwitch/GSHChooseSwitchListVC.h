//
//  GSHChooseSwitchListVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHChooseSwitchListVC : UIViewController

@property (copy , nonatomic) void(^bindSuccessBlock)(void);

+ (instancetype)chooseSwitchListVCWithSwitchBindM:(GSHSwitchBindM *)switchBindM switchMeteBindInfoModelM:(GSHSwitchMeteBindInfoModelM *)switchMeteBindInfoModelM;

@end

@interface GSHChooseSwitchListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *deviceIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;


@end

NS_ASSUME_NONNULL_END
