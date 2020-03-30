//
//  GSHLackDefenseDeviceListVC.h
//  SmartHome
//
//  Created by 唐作明 on 2020/2/13.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDefenseM.h"


@interface GSHLackDefenseDeviceListVCCell : UITableViewCell

@end

@interface GSHLackDefenseDeviceListVC : UIViewController
+(instancetype)lackDefenseDeviceListVCWithList:(NSArray<GSHDefenseDeviceTypeM *>*)list;
@end

