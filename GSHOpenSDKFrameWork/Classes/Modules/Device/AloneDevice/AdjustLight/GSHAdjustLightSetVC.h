//
//  GSHAdjustLightSetVC.h
//  SmartHome
//
//  Created by gemdale on 2019/10/11.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDeviceVC.h"

typedef enum : NSUInteger {
    GSHAdjustLightViewModelTypeError,
    GSHAdjustLightViewModelTypeMoRen,
    GSHAdjustLightViewModelTypeYueDu,
    GSHAdjustLightViewModelTypeShengHuo,
    GSHAdjustLightViewModelTypeRouHe,
    GSHAdjustLightViewModelTypeYeDeng,
    GSHAdjustLightViewModelTypeWenXin,
} GSHAdjustLightViewModelType;

@interface GSHAdjustLightViewModel : NSObject
@property(nonatomic,assign)NSInteger seWen;
@property(nonatomic,assign)NSInteger liangDu;
+(instancetype)adjustLightViewModelWithType:(GSHAdjustLightViewModelType)type;
+(GSHAdjustLightViewModelType)typeWithSeWen:(NSInteger)seWen liangDu:(NSInteger)liangDu;
@end

@interface GSHAdjustLightSetVC : GSHDeviceVC
+(instancetype)adjustLightSetVCWithDevice:(GSHDeviceM*)device type:(GSHDeviceVCType)type block:(void(^)(NSArray *exts))block;
@end
