//
//  GSHDeviceManagerVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/9/25.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHDeviceManagerDeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceSubLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deviceNameLabelCenterY;

@end

@interface GSHDeviceManagerVC : UIViewController



+(instancetype)deviceManagerVC;

@end

NS_ASSUME_NONNULL_END
