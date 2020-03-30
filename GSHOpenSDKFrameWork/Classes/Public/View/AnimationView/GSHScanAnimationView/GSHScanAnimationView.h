//
//  GSHScanAnimationView.h
//  SmartHome
//
//  Created by gemdale on 2018/7/5.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHScanAnimationView : UIView
@property(nonatomic,assign)BOOL animation;

-(void)stop;

-(void)start;
@end
