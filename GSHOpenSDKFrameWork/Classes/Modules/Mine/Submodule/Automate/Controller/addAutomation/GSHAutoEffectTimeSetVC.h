//
//  GSHAutoEffectTimeSetVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/10/29.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GSHEffectTimeSetVCType) {
    GSHEffectTimeSetTypeVCAuto   = 0,  // 联动页面选择时间
    GSHEffectTimeSetTypeVCDefense  = 1, // 防御页面选择时间
};

@interface GSHAutoEffectTimeSetVC : UIViewController

+(instancetype)autoEffectTimeSetVCWithStartTime:(NSString *)startTime endTime:(NSString *)endTime weekIndexSet:(NSIndexSet *)weekIndexSet timeSetVCType:(GSHEffectTimeSetVCType)timeSetVCType;

@property (nonatomic , copy) void(^saveBlock)(BOOL isAllDay,NSIndexSet *repeatCountIndexSet ,NSString *startTime,NSString *endTime);

@end

NS_ASSUME_NONNULL_END
