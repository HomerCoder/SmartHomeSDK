//
//  GSHFamilyMemberFloorAuthorityVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/23.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHFamilyMemberFloorAuthorityHeaderView : UITableViewHeaderFooterView
@property(nonatomic,strong)GSHFloorM *floor;
@end

@interface GSHFamilyMemberFloorAuthorityCell : UITableViewCell
@property(nonatomic,strong)GSHRoomM *room;
@property(nonatomic,strong)GSHFloorM *floor;
@end

@interface GSHFamilyMemberFloorAuthorityVC : UIViewController
+(instancetype)familyMemberFloorAuthorityVCWithMember:(GSHFamilyMemberM*)member;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
