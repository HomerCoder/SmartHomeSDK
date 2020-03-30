//
//  GSHAutoAddActionVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAutoAddActionVC : UITableViewController

+ (instancetype)autoAddActionVC;

@property (nonatomic , copy) void (^chooseSceneBlock)(NSArray *choosedArray , NSArray *noChoosedArray);

@property (nonatomic , copy) void (^chooseAutoBlock)(NSArray *choosedArray , NSArray *noChoosedArray);

@property (nonatomic , copy) void (^chooseDeviceBlock)(NSArray *selectedDeviceArray);

@property (nonatomic , strong) NSArray *choosedActionArray;

@property (nonatomic , strong) NSString *currentAutoId;

@end
