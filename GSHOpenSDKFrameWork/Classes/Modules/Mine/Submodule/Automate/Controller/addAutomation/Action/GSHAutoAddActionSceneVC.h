//
//  GSHAutoAddActionSceneVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAutoAddActionSceneVC : UITableViewController

+ (instancetype)autoAddActionSceneVC;

@property (nonatomic , copy) void (^chooseSceneBlock)(NSArray *choosedArray , NSArray *noChoosedArray);

@property (nonatomic , strong) NSArray *choosedActionArray;

@end

@interface GSHAutoAddActionSceneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sceneNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@end
