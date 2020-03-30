//
//  GSHSpreadAnimationView.h
//  SmartHome
//
//  Created by gemdale on 2018/9/5.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHSpreadAnimationView : UIView
@property(nonatomic,assign)BOOL animation;

-(void)stop;

-(void)start;
@end
