//
//  GSHSceneCustomVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/11/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHSceneCustomOneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *sceneBackImageView;
@property (weak, nonatomic) IBOutlet UILabel *sceneNameLabel;

@end

@interface GSHSceneCustomDeviceCell : UITableViewCell

@end

typedef NS_ENUM(NSInteger, SceneCustomType) {
    SceneCustomTypeAdd  = 0,  // 添加场景
    SceneCustomTypeEdit = 1,  // 编辑场景
    SceneCustomTypeTemplate = 2, // 场景模板详情
};

@interface GSHSceneCustomVC : UITableViewController

@property (nonatomic , assign) BOOL isAlertToNotiUser;

@property (nonatomic , copy) void (^saveSceneBlock)(GSHOssSceneM *ossSceneM);
@property (nonatomic , copy) void (^updateSceneBlock)(GSHOssSceneM *ossSceneM);

+ (instancetype)sceneCustomVCWithSceneM:(GSHSceneM *)sceneM
                             sceneListM:(GSHOssSceneM *)sceneListM
                               lastRank:(NSNumber *)lastRank
                             templateId:(NSNumber *)templateId
                        sceneCustomType:(SceneCustomType)sceneCustomType ;

@end


