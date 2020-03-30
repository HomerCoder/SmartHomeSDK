//
//  GSHDefenceAlarmAuthBindFactoryList.h
//  SmartHome
//
//  Created by zhanghong on 2020/2/28.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHDefenceAlarmAuthBindHouseListVC : UIViewController

@property (copy , nonatomic) void(^saveBlock)(GSHSDKEnjoyHomeHouseM *houseM);

+(instancetype)defenceAlarmAuthBindHouseListVCWithSmartHomeFamilyId:(NSNumber *)smartHomeFamilyId SelectHouseId:(NSNumber *)mhouseId;

@end

@interface GSHDefenceAlarmAuthBindHouseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *houseNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@end

NS_ASSUME_NONNULL_END
