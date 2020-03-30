//
//  GSHAddGWApIntroVC.h
//  SmartHome
//
//  Created by gemdale on 2019/12/18.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAddGWApIntroVC : UIViewController
+(instancetype)addGWApIntroVCWithSn:(NSString*)sn deviceModel:(GSHDeviceModelM*)model bind:(BOOL)bind;
@end

