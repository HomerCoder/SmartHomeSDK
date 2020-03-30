//
//  GSHYingShiVideoListVC.h
//  SmartHome
//
//  Created by gemdale on 2019/5/10.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>

@interface GSHYingShiVideoListVCCell : UITableViewCell
@property(nonatomic,strong)EZDeviceRecordFile *file;
@end

@interface GSHYingShiVideoListVC : UIViewController

+(instancetype)yingShiVideoListVCWithDeviceInfo:(EZDeviceInfo*)deviceInfo verifyCode:(NSString*)verifyCode;
@end
