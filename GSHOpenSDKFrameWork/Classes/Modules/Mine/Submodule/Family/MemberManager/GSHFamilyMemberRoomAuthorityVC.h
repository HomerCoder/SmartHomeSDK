//
//  GSHFamilyMemberRoomAuthorityVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/23.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHFamilyMemberRoomAuthorityHeaderView : UITableViewHeaderFooterView
@property(nonatomic,strong)GSHRoomM *room;
@end

@interface GSHFamilyMemberRoomAuthorityCell : UITableViewCell
@property(nonatomic,strong)GSHRoomM *room;
@property(nonatomic,strong)GSHDeviceM *device;
@end

@interface GSHFamilyMemberRoomAuthorityVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
+(instancetype)familyMemberRoomAuthorityVCWithFloor:(GSHFloorM*)floor room:(GSHRoomM*)room;
@end
 
