//
//  GSHBothwayCutainSetVC.h
//  SmartHome
//
//  Created by zhanghong on 2020/2/20.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDeviceVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHBothwayCurtainSetVC : GSHDeviceVC

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

+ (instancetype)bothwayCurtainSetVCWithDeviceM:(GSHDeviceM *)deviceM;


@end

NS_ASSUME_NONNULL_END
