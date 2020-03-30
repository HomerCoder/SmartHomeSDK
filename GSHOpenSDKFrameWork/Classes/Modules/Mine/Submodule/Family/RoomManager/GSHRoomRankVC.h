//
//  GSHRoomRankVC.h
//  SmartHome
//
//  Created by gemdale on 2019/7/3.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHRoomRankVCCell : UITableViewCell

@end

@interface GSHRoomRankVC : UIViewController
+(instancetype)roomRankVCWithFloor:(GSHFloorM*)floor familyId:(NSString*)familyId;
@end
