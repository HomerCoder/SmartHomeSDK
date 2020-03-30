//
//  GSHRecommendSceneCell.h
//  SmartHome
//
//  Created by zhanghong on 2019/11/7.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHRecommendSceneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *templateImageView;
@property (weak, nonatomic) IBOutlet UILabel *templateNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateDesLabel;

@property (copy, nonatomic) void(^activeButtonClickBlock)(void);
@end

NS_ASSUME_NONNULL_END
