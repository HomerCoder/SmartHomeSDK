//
//  GSHChooseRoomVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/27.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHChooseRoomVC : UIViewController

@property (copy, nonatomic) void (^chooseRoomBlock)(GSHFloorM *floorM,GSHRoomM *roomM);

@property (copy, nonatomic) void (^dissmissBlock)(void);

- (instancetype)initWithFloorM:(GSHFloorM *)floorM roomM:(GSHRoomM *)roomM floorArray:(NSArray *)floorArray;

@end
