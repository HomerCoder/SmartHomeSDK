//
//  GSHFamilyMemberInfoVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/23.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHFamilyMemberInfoVC : UIViewController
+(instancetype)familyMemberInfoVCWithFamily:(GSHFamilyM*)family member:(GSHFamilyMemberM*)member creation:(BOOL)creation;
@end
