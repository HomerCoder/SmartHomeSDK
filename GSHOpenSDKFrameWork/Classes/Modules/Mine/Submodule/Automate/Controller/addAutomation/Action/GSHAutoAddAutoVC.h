//
//  GSHAutoAddAutoVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAutoAddAutoVC : UITableViewController

@property (nonatomic , strong) NSArray *choosedActionArray;

@property (nonatomic , strong) NSString *currentAutoId;

@property (nonatomic , copy) void (^chooseAutoBlock)(NSArray *choosedArray , NSArray *noChoosedArray);

+ (instancetype)autoAddAutoVC;

@end

@interface GSHAutoAddAutoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *autoNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@end
