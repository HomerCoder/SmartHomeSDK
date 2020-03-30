//
//  GSHSceneInfoVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/11/6.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHSceneInfoVC : UITableViewController

+ (instancetype)sceneInfoVCWithSceneSetM:(GSHSceneM *)sceneSetM;

@property (nonatomic , copy) void (^saveButtonClickBlock)(GSHSceneM *sceneM);

@end

NS_ASSUME_NONNULL_END
