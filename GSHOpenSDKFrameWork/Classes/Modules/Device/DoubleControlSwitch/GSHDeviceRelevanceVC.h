//
//  GSHDeviceRelevanceVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHDeviceRelevanceVC : UIViewController

+ (instancetype)deviceRelevanceVCWithDeviceId:(NSString *)deviceId;

@end

@interface GSHDeviceRelevanceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *relevanceTypeLabel;


@end

@interface GSHDeviceRelevanceSecondCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceMeteNameLabel;

@property (copy, nonatomic) void (^bindBtnClickBlock)(void);

@end

NS_ASSUME_NONNULL_END
