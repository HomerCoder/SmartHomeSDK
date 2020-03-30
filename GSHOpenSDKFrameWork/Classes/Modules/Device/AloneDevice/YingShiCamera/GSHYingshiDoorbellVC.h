//
//  GSHYingshiDoorbellVC.h
//  SmartHome
//
//  Created by gemdale on 2019/5/15.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GSHYingshiDoorbellVC : UIViewController
+(instancetype)yingshiDoorbellVCWithDeviceSn:(NSString*)deviceSn cameraNo:(NSInteger)cameraNo validateCode:(NSString*)validateCode name:(NSString*)name alarmId:(NSString*)alarmId;
@end

