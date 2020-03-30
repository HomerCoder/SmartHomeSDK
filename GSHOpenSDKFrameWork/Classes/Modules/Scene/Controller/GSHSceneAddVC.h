//
//  GSHSceneAddVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/11/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHSceneAddCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *templateImageView;
@property (weak, nonatomic) IBOutlet UILabel *templateNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateDesLabel;

@property (copy, nonatomic) void(^activeButtonClickBlock)(void);

@end

@interface GSHSceneAddVC : UITableViewController

+ (instancetype)sceneAddVCWithLastRank:(NSNumber *)lastRank;

@property (nonatomic , copy) void (^saveSceneBlock)(GSHOssSceneM *ossSceneM);
@property (nonatomic , copy) void (^updateSceneBlock)(GSHOssSceneM *ossSceneM);

@end

NS_ASSUME_NONNULL_END
