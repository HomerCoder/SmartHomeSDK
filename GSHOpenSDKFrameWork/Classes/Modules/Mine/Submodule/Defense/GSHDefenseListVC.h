//
//  GSHDefenseListVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/5/23.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GSHDefenseDeviceTypeM;

NS_ASSUME_NONNULL_BEGIN

@interface GSHDefenseListVC : UIViewController

+(instancetype)defenseListVC;

@end

@interface GSHDefenseListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *defenceStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *defenceStateButton;

@property (copy , nonatomic) void(^defenceStateButtonClickBlock)(UIButton *button);

- (void)layoutCellWithDeviceTypeM:(GSHDefenseDeviceTypeM *)deviceTypeM;

@end

NS_ASSUME_NONNULL_END
