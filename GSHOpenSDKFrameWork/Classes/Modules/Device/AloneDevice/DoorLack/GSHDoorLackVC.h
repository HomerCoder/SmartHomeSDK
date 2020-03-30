//
//  GSHDoorLackVC.h
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDeviceVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSHDoorLackVCCell : UITableViewCell

@end


@interface GSHDoorLackVC : GSHDeviceVC
+(instancetype)doorLackVCWithDevice:(GSHDeviceM*)device;
@end

NS_ASSUME_NONNULL_END
