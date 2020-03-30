//
//  GSHFamilyMemberAuthorityVC.h
//  SmartHome
//
//  Created by gemdale on 2018/6/15.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHFamilyMemberAuthorityVCFloorCell :UITableViewCell
@property(nonatomic,strong)GSHFloorM *floor;
@end

@interface GSHFamilyMemberAuthorityVCRoomCell :UITableViewCell
@property(nonatomic,strong)GSHRoomM *room;
@end

@interface GSHFamilyMemberAuthorityVCDeviceCell :UITableViewCell
@property(nonatomic,strong)GSHDeviceM *device;
@end

@interface GSHFamilyMemberAuthorityVC : UIViewController
+(instancetype)familyMemberAuthorityVCWithMember:(GSHFamilyMemberM*)member;
@end
