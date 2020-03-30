//
//  GSHDoorLackSetVC.h
//  SmartHome
//
//  Created by 唐作明 on 2020/3/2.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDeviceVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHDoorLackSetVCCell : UITableViewCell
@end

@interface GSHDoorLackSetVC : GSHDeviceVC
+(instancetype)doorLackSetVCWithDevice:(GSHDeviceM*)device type:(GSHDeviceVCType)type block:(void(^)(NSArray *exts))block;
@end

NS_ASSUME_NONNULL_END
