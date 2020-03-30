//
//  GSHMessageVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const GSHQueryIsHasUnReadMsgNotification;

@interface GSHMessageVC : UIViewController

- (instancetype)initWithSelectIndex:(NSInteger)selectIndex;

- (void)changeSelectIndex:(NSInteger)selectIndex;

@end
