//
//  GSHChooseSwitchItemVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHChooseSwitchItemVC : UIViewController

@property (copy , nonatomic) void(^bindSuccessBlock)(void);

+ (instancetype)chooseSwitchItemVCWithDeviceM:(GSHDeviceM *)deviceM switchBindM:(GSHSwitchBindM *)switchBindM switchMeteBindInfoModelM:(GSHSwitchMeteBindInfoModelM *)switchMeteBindInfoModelM;

@end

@interface GSHChooseSwitchItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *switchItemNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;


@end

NS_ASSUME_NONNULL_END
