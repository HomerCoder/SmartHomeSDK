//
//  GSHFamilyTransferVC.h
//  SmartHome
//
//  Created by gemdale on 2019/1/4.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHFamilyTransferVCCell : UITableViewCell
@property(nonatomic,strong)GSHFamilyMemberM *member;
@end

@interface GSHFamilyTransferVC : UIViewController

@property (copy,nonatomic) void (^refreshFamilyListBlock)(void);

+(instancetype)familyTransferVCWithFamily:(GSHFamilyM*)family;

@end
