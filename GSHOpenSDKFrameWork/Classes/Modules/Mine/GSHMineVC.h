//
//  GSHMineVC.h
//  SmartHome
//
//  Created by gemdale on 2018/4/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHMineItemCell : UITableViewCell
-(void)setImage:(UIImage*)image title:(NSString*)title;
@end

@interface GSHMineVC : UIViewController
+(instancetype)mineVC;
@end
