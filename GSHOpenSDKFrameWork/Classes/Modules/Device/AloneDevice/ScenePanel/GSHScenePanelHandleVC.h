//
//  GSHScenePanelHandleVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/9/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"


@interface GSHScenePanelHandleVC : GSHDeviceVC

+ (instancetype)scenePanelHandleVCDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType;

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

@end


@interface GSHScenePanelHandleCell : UITableViewCell

@property (nonatomic , copy) void (^execButtonClickBlock)(UIButton *button);

@property (weak, nonatomic) IBOutlet UILabel *bindNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *buttonNameLabel;


- (void)setCellValueWithDeviceEditType:(GSHDeviceVCType)deviceEditType;

- (void)layoutCellIsSelected:(BOOL)isSelected;
@end

