//
//  GSHChooseSceneListVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/10.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface GSHChooseSceneListVC : UIViewController

+ (instancetype)chooseSceneListVCWithDeviceM:(GSHDeviceM *)deviceM indexValue:(int)indexValue basMeteId:(NSString *)basMeteId;

@property (copy , nonatomic) void (^bindSceneSuccessBlock)(GSHOssSceneM *ossSceneM);

@end

@interface GSHChooseSceneListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sceneNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@end

NS_ASSUME_NONNULL_END
