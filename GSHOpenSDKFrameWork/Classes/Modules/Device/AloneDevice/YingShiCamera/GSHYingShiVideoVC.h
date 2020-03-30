//
//  GSHYingShiVideoVC.h
//  SmartHome
//
//  Created by gemdale on 2018/8/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>

@interface GSHYingShiVideoVC : UIViewController
+(instancetype)yingShiCameraVCWithDeviceSerial:(NSString *)deviceSerial cameraNo:(NSInteger)cameraNo recordFile:(EZDeviceRecordFile*)recordFile verifyCode:(NSString *)verifyCode;
+(instancetype)yingShiCameraVCWithDeviceSerial:(NSString *)deviceSerial cameraNo:(NSInteger)cameraNo recordFileList:(NSArray<EZDeviceRecordFile*> *)recordFileList seleIndex:(NSInteger)seleIndex verifyCode:(NSString *)verifyCode;
@end
