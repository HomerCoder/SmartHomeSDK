//
//  GSHFamilyManagerVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHFamilyListVC.h"

@interface GSHFamilyManagerCell : UITableViewCell
@end

@interface GSHFamilyManagerVC : UIViewController

@property (copy,nonatomic) void (^refreshFamilyListBlock)(void);

+(instancetype)familyManagerVCWithFamily:(GSHFamilyM*)family familyListVC:(GSHFamilyListVC*)familyListVC;
@end
