//
//  GSHRoomManagerVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/22.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHRoomManagerVC.h"
#import "UIView+TZM.h"
#import "GSHRoomEditVC.h"
#import "GSHFloorEditVC.h"
#import "GSHAlertManager.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "GSHRoomRankVC.h"
#import "PopoverView.h"

@interface GSHRoomManagerCell()
@property (weak, nonatomic) IBOutlet UILabel *lblFloorName;
@property (weak, nonatomic) IBOutlet UIView *viewRoom;
- (IBAction)touchSetting:(UIButton *)sender;
@property(nonatomic,strong)GSHFloorM *floor;
@property(nonatomic,strong)NSArray<PopoverAction*> *actions;
@end

@implementation GSHRoomManagerCell
-(void)refreshWithFloor:(GSHFloorM *)floor tableViewWidth:(CGFloat)tableViewWidth{
    self.floor = floor;
    self.lblFloorName.text = floor.floorName;
    [self.viewRoom removeAllSubviews];
    CGFloat width = (tableViewWidth - 48) / 3;
    CGFloat height = 54;
    for (int i = 0; i < floor.rooms.count; i++) {
        GSHRoomM *room = floor.rooms[i];
        UIButton *but = [[UIButton alloc]initWithFrame:CGRectMake((i % 3) * (width + 8) + 16, (i / 3) * (height + 8) + 16.5, width, height)];
        but.layer.cornerRadius = 4;
        but.clipsToBounds = YES;
        but.backgroundColor = [UIColor colorWithRGB:0x3C4366];
        but.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [but setTitle:room.roomName forState:UIControlStateNormal];
        but.tag = 1000 + i;
        [but addTarget:self action:@selector(touchRoom:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewRoom addSubview:but];
    }
    UIButton *but = [[UIButton alloc]initWithFrame:CGRectMake((floor.rooms.count % 3) * (width + 8) + 16, (floor.rooms.count / 3) * (height + 8) + 16.5, width, height)];
    but.tag = 1000 + floor.rooms.count;
    [but setBackgroundImage:[UIImage ZHImageNamed:@"roomManagerVC_room_add_icon"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(touchRoom:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewRoom addSubview:but];
    
    __weak typeof(self)weakSelf = self;
    PopoverAction *action1 = [PopoverAction actionWithImage:nil title:@"房间排序" handler:^(PopoverAction *action) {
        if ([weakSelf.viewController isKindOfClass:GSHRoomManagerVC.class]) {
            [((GSHRoomManagerVC*)weakSelf.viewController) roomRankVCWithFloor:weakSelf.floor];
        }
    }];
    PopoverAction *action2 = [PopoverAction actionWithImage:nil title:@"删除楼层" handler:^(PopoverAction *action) {
        if ([weakSelf.viewController isKindOfClass:GSHRoomManagerVC.class]) {
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                if (buttonIndex == 0) {
                    [((GSHRoomManagerVC*)weakSelf.viewController) deleteFloorWithFloor:weakSelf.floor];
                }
            } textFieldsSetupHandler:NULL andTitle:nil andMessage:[NSString stringWithFormat:@"确认删除%@吗？",weakSelf.floor.floorName] image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"确认" cancelButtonTitle:@"取消" otherButtonTitles:nil];
        }
    }];
    self.actions = @[action1,action2];
}

-(void)touchRoom:(UIButton*)btn{
    NSInteger tag = btn.tag - 1000;
    GSHRoomM *room = nil;
    if (tag >= 0 && tag < self.floor.rooms.count) {
        room = self.floor.rooms[tag];
    }
    if ([self.viewController isKindOfClass:GSHRoomManagerVC.class]) {
        [((GSHRoomManagerVC*)self.viewController) editRoomWithFloor:self.floor room:room];
    }
}

- (IBAction)touchSetting:(UIButton *)sender {
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.arrowStyle = PopoverViewArrowStyleTriangle;
    popoverView.showShade = YES;
    [popoverView showToView:sender isLeftPic:NO isTitleLabelCenter:NO withActions:self.actions hideBlock:NULL];
}
@end

@interface GSHRoomManagerVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)GSHFamilyM *family;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
- (IBAction)touchAddFloor:(UIButton *)sender;
@end

@implementation GSHRoomManagerVC

+(instancetype)roomManagerVCWithFamily:(GSHFamilyM*)family{
    GSHRoomManagerVC *vc = [GSHPageManager viewControllerWithSB:@"GSHRoomManagerSB" andID:@"GSHRoomManagerVC"];
    vc.family = family;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    if (self.family.floor.count == 1 && self.family.floor.firstObject.rooms.count == 0){
        GSHFloorM *floor = self.family.floor.firstObject;
        TZMPageStatusView *statusView = [self showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_room"] title:@"暂无房间" desc:nil buttonText:@"添加房间" didClickButtonCallback:^(TZMPageStatus status) {
            [self editRoomWithFloor:floor room:nil];
        }];
        statusView.backgroundColor = [UIColor whiteColor];
    }else{
        [self dismissPageStatusView];
        [self.tableView reloadData];
    }
}

- (void)reloadData{
    __weak typeof(self)weakSelf = self;
    [self dismissPageStatusView];
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [GSHFloorManager getFloorListWithFamilyId:self.family.familyId block:^(NSArray<GSHFloorM *> *floorList, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            weakSelf.family.floor = [NSMutableArray arrayWithArray:floorList];
            if (floorList.count == 1 && floorList.firstObject.rooms.count == 0) {
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                GSHFloorM *floor = floorList.firstObject;
                [weakSelf showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_room"] title:@"暂无房间" desc:nil buttonText:@"添加房间" didClickButtonCallback:^(TZMPageStatus status) {
                    [weakSelf editRoomWithFloor:floor room:nil];
                }];
            }else{
                if (floorList) {
                    [TZMProgressHUDManager dismissInView:weakSelf.view];
                    [weakSelf.tableView reloadData];
                }else{
                    [TZMProgressHUDManager showErrorWithStatus:@"暂无楼层信息" inView:weakSelf.view];
                }
            }
        }
    }];
}

-(void)roomRankVCWithFloor:(GSHFloorM*)floor{
    [self.navigationController pushViewController:[GSHRoomRankVC roomRankVCWithFloor:floor familyId:self.family.familyId] animated:YES];
}

-(void)editRoomWithFloor:(GSHFloorM*)floor room:(GSHRoomM*)room{
    GSHRoomEditVC *vc = [GSHRoomEditVC roomEditVCWithFamily:self.family floor:floor room:room];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)deleteFloorWithFloor:(GSHFloorM*)floor{
    __weak typeof(self) weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
    [GSHFloorManager postDeleteFloorWithFamilyId:weakSelf.family.familyId floorId:floor.floorId block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"删除成功" inView:weakSelf.view];
            [weakSelf.family.floor removeObject:floor];
            if (weakSelf.family.floor.count == 1 && weakSelf.family.floor.firstObject.rooms.count == 0) {
                GSHFloorM *floor = weakSelf.family.floor.firstObject;
                [weakSelf showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_room"] title:@"暂无房间" desc:nil buttonText:@"添加房间" didClickButtonCallback:^(TZMPageStatus status) {
                    [weakSelf editRoomWithFloor:floor room:nil];
                }];
            }else{
                [weakSelf.tableView reloadData];
            }
        }
    }];
}

-(void)editFloorWithFloor:(GSHFloorM*)floor{
    GSHFloorEditVC *vc = [GSHFloorEditVC floorEditVCWithFamily:self.family floor:floor];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark --tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.family.floor.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.family.floor.count > indexPath.row) {
        GSHFloorM *floor = self.family.floor[indexPath.row];
        return 77 + 24 + (floor.rooms.count / 3 + 1) * 62 - 8;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHRoomManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.family.floor.count > indexPath.row) {
        [cell refreshWithFloor:self.family.floor[indexPath.row] tableViewWidth:tableView.frame.size.width];
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (IBAction)touchAddFloor:(UIButton *)sender {
    [self editFloorWithFloor:nil];
}
@end
