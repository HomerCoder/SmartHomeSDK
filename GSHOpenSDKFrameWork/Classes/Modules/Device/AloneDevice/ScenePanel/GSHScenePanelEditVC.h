//
//  GSHScenePanelEditVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    GSHScenePanelEditTypeAdd,
    GSHScenePanelEditTypeEdit,
} GSHScenePanelEditType;

@interface GSHScenePanelEditVC : UITableViewController

@property (nonatomic , assign) BOOL isLastDevice;

@property (nonatomic , copy) void (^deviceEditSuccessBlock)(GSHDeviceM *deviceM);

@property (nonatomic , copy) void (^deviceAddSuccessBlock)(NSString *deviceId);

@property (copy , nonatomic) void (^bindSceneSuccessBlock)(GSHOssSceneM *ossSceneM , int buttonIndex);

@property (copy , nonatomic) void (^unbindSceneSuccessBlock)(int buttonIndex);

+ (instancetype)scenePanelEditVCWithDeviceM:(GSHDeviceM*)deviceM type:(GSHScenePanelEditType)type;

@end

NS_ASSUME_NONNULL_END
