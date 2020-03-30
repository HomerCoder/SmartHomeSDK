//
//  GSHSceneCell.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/9.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Lottie/LOTAnimationView.h>

@interface GSHSceneCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *sceneNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sceneImageView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet LOTAnimationView *animationView;
@property (weak, nonatomic) IBOutlet UIView *backView;


@property (copy, nonatomic) void (^moreButtonClickBlock)(void);


@end
