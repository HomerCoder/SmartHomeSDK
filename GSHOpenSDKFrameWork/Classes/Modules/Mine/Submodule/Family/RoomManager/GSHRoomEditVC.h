//
//  GSHRoomEditVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/22.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHRoomEditVC : UIViewController
//编辑某个家庭的某个楼层的某个房间，家庭和楼层不能为空。房间可以为空，如果房间为空则为添加
+(instancetype)roomEditVCWithFamily:(GSHFamilyM*)family floor:(GSHFloorM*)floor room:(GSHRoomM*)room;
@end
