//
//  GSHFamilyMemberListVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/21.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHFamilyMemberListCell : UICollectionViewCell
@property(nonatomic,strong)GSHFamilyMemberM *member;
@end

@interface GSHFamilyMemberListVC : UIViewController
+(instancetype)familyMemberListVCWithFamily:(GSHFamilyM*)family;
@end
