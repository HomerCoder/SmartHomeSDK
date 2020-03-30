//
//  GSHAutomateCell.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/9.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface GSHAutomateCell : MGSwipeTableCell

@property (copy , nonatomic) void (^openSwitchClickBlock)(UISwitch *openSwitch);
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (copy, nonatomic) void (^moreButtonClickBlock)(void);

- (void)setAutoCellValueWithOssAutoM:(GSHOssAutoM *)ossAutoM;


@end
