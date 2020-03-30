//
//  GSHLackSensorListVC.h
//  SmartHome
//
//  Created by 唐作明 on 2020/2/13.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHSensorM.h"


@interface GSHLackSensorListVCCell : UITableViewCell

@end

@interface GSHLackSensorListVC : UIViewController
+(instancetype)lackSensorListVCWithList:(NSArray<GSHMissingSensorM *>*)list;
@end

