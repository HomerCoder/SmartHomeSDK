//
//  GSHSceneModelBackVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHSceneBackgroundVC : UIViewController

@property (nonatomic , copy) void (^selectBackImage)(GSHSceneBackgroundImageM *sceneBackgroundImageM);

- (instancetype)initWithBackImgId:(NSNumber *)backImgIndex;

@end
