//
//  GSHShengBiKePlayVC.h
//  SmartHome
//
//  Created by gemdale on 2019/12/12.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

@interface GSHShengBiKePlayVCCell : UITableViewCell

@end


@interface GSHShengBiKePlayVC : GSHDeviceVC
+(instancetype)shengBiKePlayVCWithDevice:(GSHDeviceM*)device;
-(void)deleteSongWithCell:(GSHShengBiKePlayVCCell *)cell;
@end

