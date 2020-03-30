//
//  GSHYingshiSettingVC.h
//  SmartHome
//
//  Created by gemdale on 2019/5/17.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHYingshiSettingVC : UIViewController
+(instancetype)yingshiSettingVCWithIPC:(NSMutableDictionary*)ipc device:(GSHDeviceM*)device;
@end

