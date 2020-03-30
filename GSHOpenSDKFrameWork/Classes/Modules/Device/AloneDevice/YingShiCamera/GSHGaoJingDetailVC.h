//
//  GSHGaoJingDetailVC.h
//  SmartHome
//
//  Created by gemdale on 2018/8/10.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>

extern NSString * const GSHYingShiGaoJingCollectChangeNotification;

@interface GSHGaoJingDetailVCCell : UICollectionViewCell
@end

@interface GSHGaoJingDetailVC : UIViewController
+(instancetype)gaoJingDetailVCWithModel:(GSHYingShiGaoJingM*)model verifyCode:(NSString *)verifyCode deviceSerial:(NSString*)deviceSerial modelList:(NSArray<GSHYingShiGaoJingM*>*)modelList;
@end
