//
//  GSHNetworkSetNotiVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/2/19.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHNetworkSetNotiVC : UIViewController

@property (nonatomic , assign) NSInteger controlType;   // 离线控制：0 外网控制：1

+ (instancetype)networkSetNotiVC;

@end

NS_ASSUME_NONNULL_END
