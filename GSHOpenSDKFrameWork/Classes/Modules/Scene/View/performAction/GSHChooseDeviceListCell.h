//
//  GSHChooseDeviceListCell.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHChooseDeviceListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *deviceIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceActionLabel;


@end
