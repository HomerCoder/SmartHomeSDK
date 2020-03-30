//
//  TZMProgressBar.h
//  SmartHome
//
//  Created by gemdale on 2018/9/13.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XXNibBridge.h>

@interface TZMProgressBar : UIView <XXNibBridge>
@property(nonatomic,copy)NSString *text;
@property(nonatomic) float progress; 
@end
