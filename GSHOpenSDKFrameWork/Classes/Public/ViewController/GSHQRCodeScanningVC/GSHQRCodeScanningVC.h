//
//  GSHQRCodeScanningVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/21.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+TZM.h"
#import <AVFoundation/AVFoundation.h>
#import "GSHAlertManager.h"

@interface GSHQRCodeScanningVC : UIViewController
+(UINavigationController*)qrCodeScanningNavWithText:(NSString*)text title:(NSString*)title block:(BOOL(^)(NSString *code, GSHQRCodeScanningVC *vc))block;
+(GSHQRCodeScanningVC*)qrCodeScanningVCWithText:(NSString*)text title:(NSString*)title block:(BOOL(^)(NSString *code, GSHQRCodeScanningVC *vc))block;
@end
