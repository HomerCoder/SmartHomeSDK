//
//  GSHAutoTimeSetVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAutoTimeSetVC : UIViewController

+ (instancetype)autoTimeSetVCWithOldTime:(NSString *)oldTime choosedIndexSet:(NSIndexSet *)choosedIndexSet;

@property (strong, nonatomic) void (^compeleteSetTimeBlock)(NSString *time,NSString *repeatCount,NSIndexSet *indexSet);

@end
