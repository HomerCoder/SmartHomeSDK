//
//  GSHTVSeleAlertVC.h
//  SmartHome
//
//  Created by gemdale on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TZMOpenLib/TZMBlanketVC.h>

@interface GSHTVSeleAlertVC : TZMBlanketVC
+(instancetype)tvSeleAlertVCWithList:(NSArray<GSHKuKongInfraredDeviceM*> *)list seleBlock:(void(^)(NSInteger index))seleBlock;
@end
