//
//  GSHYingShiGaoJingListVC.h
//  SmartHome
//
//  Created by gemdale on 2018/8/20.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>

typedef enum : NSUInteger {
    GSHYingShiGaoJingListVCTypeAll,
    GSHYingShiGaoJingListVCTypeCollect,
} GSHYingShiGaoJingListVCType;

extern NSString * const GSHYingShiGaoJingDeleteNotification;

@interface GSHYingShiGaoJingListVCHeader :UITableViewHeaderFooterView
@end

@interface GSHYingShiGaoJingListVCCell : UITableViewCell
@end

@interface GSHYingShiGaoJingListVC : UIViewController
+(instancetype)yingShiGaoJingListVCWithtype:(GSHYingShiGaoJingListVCType)type device:(GSHDeviceM*)device alarmType:(GSHYingShiGaoJingMAlarmType)alarmType;
-(void)refreshSeleAll;
@end
