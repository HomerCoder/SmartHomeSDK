//
//  GSHFamilyMemberFloorAuthorityVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/23.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFamilyMemberFloorAuthorityVC.h"
#import "GSHFamilyMemberRoomAuthorityVC.h"
#import "UIView+TZM.h"

@interface GSHFamilyMemberFloorAuthorityHeaderView()
@property(nonatomic,assign)BOOL canSele;
@end

@implementation GSHFamilyMemberFloorAuthorityHeaderView{
    UILabel *_lblName;
    UIButton *_seleBut;
}

-(void)setFloor:(GSHFloorM *)floor{
    _floor = floor;
    _lblName.text = floor.floorName;
    
    BOOL haveAll = NO,haveNone = NO;
    NSInteger count = 0;
    for (GSHRoomM *room in floor.rooms) {
        if (room.devices.count > 0) {
            count = count + room.devices.count;
            if (room.authorityType == GSHRoomMAuthorityTypeAll) {
                haveAll = YES;
            }else if (room.authorityType == GSHRoomMAuthorityTypeSome) {
                haveAll = YES;haveNone = YES;
            }else{
                haveNone = YES;
            }
        }
    }
    self.canSele = count > 0;
    
    if (haveAll && !haveNone) {
        [_seleBut setImage:[UIImage ZHImageNamed:@"app_icon_checkbox_select"] forState:UIControlStateNormal];
    }else if (!haveAll){
        [_seleBut setImage:[UIImage ZHImageNamed:@"app_icon_checkbox_normal"] forState:UIControlStateNormal];
    }else{
        [_seleBut setImage:[UIImage ZHImageNamed:@"app_icon_checkbox_same"] forState:UIControlStateNormal];
    }
}

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        //选中按钮
        _seleBut = [[UIButton alloc]init];
        [_seleBut addTarget:self action:@selector(touchSele) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_seleBut];
        //楼层名字
        _lblName = [[UILabel alloc]init];
        _lblName.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [self.contentView addSubview:_lblName];
        self.contentView.backgroundColor = [UIColor colorWithRGB:0xf6f7fa];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _lblName.frame = CGRectMake(54, 16, 200, 25);
    _seleBut.frame = CGRectMake(2, 3.5, 50, 50);
}

-(void)touchSele{
    if (!self.canSele) {
        [TZMProgressHUDManager showErrorWithStatus:@"楼层下无设备，无需授权" inView:self.viewController.view];
        return;
    }
    if (self.floor.authorityType == GSHFloorMAuthorityTypeAll) {
        self.floor.authorityType = GSHFloorMAuthorityTypeNothing;
    }else{
        self.floor.authorityType = GSHFloorMAuthorityTypeAll;
    }
    UIViewController *vc = self.viewController;
    if ([vc isKindOfClass:GSHFamilyMemberFloorAuthorityVC.class]) {
        [((GSHFamilyMemberFloorAuthorityVC*)vc).tableView reloadData];
    }
}
@end

@interface GSHFamilyMemberFloorAuthorityCell()
@property (weak, nonatomic) IBOutlet UILabel *lblRoomName;
@property (weak, nonatomic) IBOutlet UIButton *btnSele;
- (IBAction)touchSele:(UIButton *)sender;
@end
@implementation GSHFamilyMemberFloorAuthorityCell
-(void)setRoom:(GSHRoomM *)room{
    _room = room;
    self.lblRoomName.text = room.roomName;
    if (room.authorityType == GSHRoomMAuthorityTypeAll) {
        [self.btnSele setImage:[UIImage ZHImageNamed:@"app_icon_checkbox_select"] forState:UIControlStateNormal];
    }else if (room.authorityType == GSHRoomMAuthorityTypeNothing){
        [self.btnSele setImage:[UIImage ZHImageNamed:@"app_icon_checkbox_normal"] forState:UIControlStateNormal];
    }else{
        [self.btnSele setImage:[UIImage ZHImageNamed:@"app_icon_checkbox_same"] forState:UIControlStateNormal];
    }
    if (room.devices.count == 0) {
         [self.btnSele setImage:[UIImage ZHImageNamed:@"app_icon_checkbox_normal"] forState:UIControlStateNormal];
    }
    self.lblRoomName.textColor = room.devices.count == 0 ? [UIColor colorWithRGB:0x999999] : [UIColor colorWithRGB:0x222222];
}

- (IBAction)touchSele:(UIButton *)sender {
    if (self.room.devices.count == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"房间下无设备，无需授权" inView:self.viewController.view];
        return;
    }
    if (self.room.authorityType == GSHRoomMAuthorityTypeAll) {
        self.room.authorityType = GSHRoomMAuthorityTypeNothing;
    }else{
        self.room.authorityType = GSHRoomMAuthorityTypeAll;
    }
    
    [self.floor refreshAuthority];
    
    UIViewController *vc = self.viewController;
    if ([vc isKindOfClass:GSHFamilyMemberFloorAuthorityVC.class]) {
        [((GSHFamilyMemberFloorAuthorityVC*)vc).tableView reloadData];
    }
}
@end

@interface GSHFamilyMemberFloorAuthorityVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)GSHFamilyMemberM *member;
- (IBAction)touchSave:(UIButton *)sender;
@end

@implementation GSHFamilyMemberFloorAuthorityVC

+(instancetype)familyMemberFloorAuthorityVCWithMember:(GSHFamilyMemberM*)member{
    GSHFamilyMemberFloorAuthorityVC *vc = [GSHPageManager viewControllerWithSB:@"GSHMemberManagerSB" andID:@"GSHFamilyMemberFloorAuthorityVC"];
    vc.member = member;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerClass:GSHFamilyMemberFloorAuthorityHeaderView.class forHeaderFooterViewReuseIdentifier:@"header"];
    if (self.member.floor) {
        [self.tableView reloadData];
    }else{
        [self reloadFloor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)reloadFloor{
    [TZMProgressHUDManager showWithStatus:@"加载权限中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHFamilyMemberManager getFamilyMemberWithFamilyId:self.member.familyId memberId:self.member.childUserId block:^(GSHFamilyMemberM *member, NSError *error) {
        if (!error) {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.member.floor = member.floor;
            [weakSelf.tableView reloadData];
        }else{
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)touchSave:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.member.floor.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.member.floor.count > section) {
        return self.member.floor[section].rooms.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHFamilyMemberFloorAuthorityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.member.floor.count > indexPath.section) {
        if (self.member.floor[indexPath.section].rooms.count > indexPath.row) {
            cell.floor = self.member.floor[indexPath.section];
            cell.room = self.member.floor[indexPath.section].rooms[indexPath.row];
        }
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHFamilyMemberFloorAuthorityCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.room.devices.count == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"房间下无设备，无需授权" inView:self.view];
        return nil;
    }
    if (cell) {
        GSHFamilyMemberRoomAuthorityVC *vc = [GSHFamilyMemberRoomAuthorityVC familyMemberRoomAuthorityVCWithFloor:cell.floor room:cell.room];
        [self.navigationController pushViewController:vc animated:YES];
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.member.floor.count <= 1){
        return 0;
    }else{
        return 57;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.member.floor.count <= 1){
        return nil;
    }else{
        GSHFamilyMemberFloorAuthorityHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
        if (self.member.floor.count > section) {
            GSHFloorM *floor = self.member.floor[section];
            header.floor = floor;
        }
        return header;
    }
}

@end
