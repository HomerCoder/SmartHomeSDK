//
//  GSHFamilyMemberRoomAuthorityVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/23.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFamilyMemberRoomAuthorityVC.h"
#import "UIView+TZM.h"

@interface GSHFamilyMemberRoomAuthorityHeaderView()
@end

@implementation GSHFamilyMemberRoomAuthorityHeaderView{
    UILabel *_lblName;
    UIButton *_seleBut;
}

-(void)setRoom:(GSHRoomM *)room{
    _room = room;
    _lblName.text = room.roomName;
    if (room.authorityType == GSHRoomMAuthorityTypeAll) {
        [_seleBut setImage:[UIImage ZHImageNamed:@"app_icon_checkbox_select"] forState:UIControlStateNormal];
    }else if (room.authorityType == GSHRoomMAuthorityTypeNothing){
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
    if (self.room.authorityType == GSHRoomMAuthorityTypeAll) {
        self.room.authorityType = GSHRoomMAuthorityTypeNothing;
    }else{
        self.room.authorityType = GSHRoomMAuthorityTypeAll;
    }
    UIViewController *vc = self.viewController;
    if ([vc isKindOfClass:GSHFamilyMemberRoomAuthorityVC.class]) {
        [((GSHFamilyMemberRoomAuthorityVC*)vc).tableView reloadData];
    }
}
@end


@interface GSHFamilyMemberRoomAuthorityCell()
@property (weak, nonatomic) IBOutlet UILabel *lblDeviceName;
@property (weak, nonatomic) IBOutlet UIButton *butSele;
- (IBAction)touchSele:(UIButton *)sender;
@end

@implementation GSHFamilyMemberRoomAuthorityCell
-(void)setDevice:(GSHDeviceM *)device{
    _device = device;
    self.lblDeviceName.text = device.deviceName;
    self.butSele.selected = [device.permissionState boolValue];
}

- (IBAction)touchSele:(UIButton *)sender {
    self.device.permissionState = @(!(self.device.permissionState.boolValue));
    [self.room refreshAuthority];
    UIViewController *vc = self.viewController;
    if ([vc isKindOfClass:GSHFamilyMemberRoomAuthorityVC.class]) {
        [((GSHFamilyMemberRoomAuthorityVC*)vc).tableView reloadData];
    }
}
@end

@interface GSHFamilyMemberRoomAuthorityVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)GSHFloorM *floor;
@property (nonatomic, strong)GSHRoomM *room;
- (IBAction)touchSave:(UIButton *)sender;
@end

@implementation GSHFamilyMemberRoomAuthorityVC
+(instancetype)familyMemberRoomAuthorityVCWithFloor:(GSHFloorM*)floor room:(GSHRoomM*)room{
    GSHFamilyMemberRoomAuthorityVC *vc = [GSHPageManager viewControllerWithSB:@"GSHMemberManagerSB" andID:@"GSHFamilyMemberRoomAuthorityVC"];
    vc.floor = floor;
    vc.room = room;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerClass:GSHFamilyMemberRoomAuthorityHeaderView.class forHeaderFooterViewReuseIdentifier:@"header"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.floor refreshAuthority];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchSave:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.room.devices.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHFamilyMemberRoomAuthorityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.room.devices.count > indexPath.row) {
        cell.room = self.room;
        cell.device = self.room.devices[indexPath.row];
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 57;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    GSHFamilyMemberRoomAuthorityHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    header.room = self.room;
    return header;
}
@end
