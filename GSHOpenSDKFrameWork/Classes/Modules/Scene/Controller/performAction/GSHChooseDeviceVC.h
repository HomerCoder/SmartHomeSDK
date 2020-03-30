//
//  GSHChooseDeviceVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/24.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ChooseDeviceFromFlag) {
    ChooseDeviceFromAddScene  = 0,  // 从添加情景页面进入
    ChooseDeviceFromAddAutoAddCondition     = 1,    // 从添加联动 -- 触发条件 进入
    ChooseDeviceFromAddAutoAddAction  = 2,  // 从添加联动 -- 添加执行动作 进入
};

@interface GSHChooseDeviceVC : UIViewController

@property (nonatomic, assign) ChooseDeviceFromFlag fromFlag;

@property (nonatomic, copy) void (^selectDeviceBlock)(NSArray *selectedDeviceArray);

- (instancetype)initWithSelectDeviceArray:(NSArray *)selectDeviceArray;

- (instancetype)initWithSelectDeviceArray:(NSArray *)selectDeviceArray floorM:(GSHFloorM *)floorM roomM:(GSHRoomM *)roomM floorArray:(NSArray *)floorArray;

@end
