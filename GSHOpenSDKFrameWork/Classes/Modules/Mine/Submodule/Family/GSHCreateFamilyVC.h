//
//  GSHCreateFamilyVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHFamilyListVC.h"

@interface GSHCreateFamilyVC : UITableViewController
+(instancetype)createFamilyVCWithFamilyListVC:(GSHFamilyListVC*)familyListVC completeBlock:(void(^)(void))completeBlock;
@end
