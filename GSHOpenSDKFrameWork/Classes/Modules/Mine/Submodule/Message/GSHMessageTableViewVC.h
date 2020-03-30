//
//  GSHMessageTableViewVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJScrollPageViewDelegate.h"

@interface GSHMessageTableViewVC : UIViewController <ZJScrollPageViewChildVcDelegate>

//@property (copy , nonatomic) void (^cellClickBlock)(GSHSensorM *sensorM);

- (instancetype)initWithMsgType:(NSString *)msgType;

- (void)clearMsg;

- (void)refreshMsg;

@end
