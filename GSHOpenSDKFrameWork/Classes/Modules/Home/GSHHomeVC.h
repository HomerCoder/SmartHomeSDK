//
//  GSHHomeVC.h
//  SmartHome
//
//  Created by gemdale on 2018/4/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const GSHRefreshHomeDataNotifacation; //首页数据更新通知

@interface GSHHomeVC : UIViewController
+(instancetype)homeVC;
-(void)switchoverRoomWithRoomId:(NSString*)roomId;
@end
