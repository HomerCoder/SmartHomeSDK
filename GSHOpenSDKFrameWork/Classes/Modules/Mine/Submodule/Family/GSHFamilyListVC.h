//
//  GSHFamilyListVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHFamilyListCell : UITableViewCell
@property (nonatomic,strong)GSHFamilyM *family;
@end

@interface GSHFamilyListVC : UIViewController
+(instancetype)familyListVC;
@property(nonatomic,strong)NSMutableArray<GSHFamilyM*>*list;
@end
