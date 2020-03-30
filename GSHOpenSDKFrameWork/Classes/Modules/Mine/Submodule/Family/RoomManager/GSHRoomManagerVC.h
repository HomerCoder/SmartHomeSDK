//
//  GSHRoomManagerVC.h
//  SmartHome
//
//  Created by gemdale on 2018/5/22.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface GSHRoomManagerCell : UITableViewCell
@end

@interface GSHRoomManagerVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

+(instancetype)roomManagerVCWithFamily:(GSHFamilyM*)family;

//编辑某个楼层的某个房间，楼层不能为空。房间可以为空，如果房间为空则为添加
-(void)editRoomWithFloor:(GSHFloorM*)floor room:(GSHRoomM*)room;
-(void)deleteFloorWithFloor:(GSHFloorM*)floor;
-(void)roomRankVCWithFloor:(GSHFloorM*)floor;
@end
