//
//  GSHDefenseMeteChooseVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/6/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHDefenseMeteChooseVC : UIViewController

@property (copy , nonatomic) void (^chooseBlock)(NSString *reportLevel , NSString *reportName);

// flag : 1 开 % 关 2 告警等级
+(instancetype)defenseMeteChooseVCWithTitle:(NSString *)title flag:(int)flag selectValue:(NSString *)selectValue;

@end

@interface GSHDefenseMeteChooseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chooseImageView;

@end

NS_ASSUME_NONNULL_END
