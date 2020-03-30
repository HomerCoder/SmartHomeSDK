//
//  GSHFloorEditVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/22.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHFloorEditVC : UIViewController
//编辑某个家庭的某个楼层，家庭不能为空，楼层可以为空，为空的时候为添加楼层
+(instancetype)floorEditVCWithFamily:(GSHFamilyM*)family floor:(GSHFloorM*)floor;
@end
