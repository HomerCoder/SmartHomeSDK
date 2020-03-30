//
//  GSHFamilyMemberAuthorityVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/15.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFamilyMemberAuthorityVC.h"
@interface GSHFamilyMemberAuthorityVCFloorCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end

@interface GSHFamilyMemberAuthorityVCRoomCell ()
@property (weak, nonatomic) IBOutlet UIView *viewLine;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnShow;
- (IBAction)touchShow:(UIButton *)sender;
@end

@interface GSHFamilyMemberAuthorityVCDeviceCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end

@interface GSHFamilyMemberAuthorityVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)GSHFamilyMemberM *member;
@property(nonatomic,strong)NSMutableArray<GSHFloorM*> *floorList;
@property(nonatomic,strong)NSMutableArray *dataList;
@property(nonatomic,strong)NSMutableDictionary *hideRooms;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation GSHFamilyMemberAuthorityVC
+(instancetype)familyMemberAuthorityVCWithMember:(GSHFamilyMemberM*)member{
    GSHFamilyMemberAuthorityVC *vc = [GSHPageManager viewControllerWithSB:@"GSHMemberManagerSB" andID:@"GSHFamilyMemberAuthorityVC"];
    vc.member = member;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hideRooms = [NSMutableDictionary dictionary];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadData{
    [TZMProgressHUDManager showWithStatus:@"加载权限中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHFamilyManager getAllDevicesWithFamilyId:self.member.familyId block:^(NSArray<GSHFloorM *> *list, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.floorList = [NSMutableArray arrayWithArray:list];
            [weakSelf reloadUI];
        }
    }];
}

-(void)reloadUI{
    NSMutableArray *array = [NSMutableArray array];
    for (GSHFloorM *floor in self.floorList) {
        [array addObject:floor];
        for (GSHRoomM *room in floor.rooms) {
            [array addObject:room];
            if ([self.hideRooms objectForKey:room.roomId] == nil) {
                for (GSHDeviceM *device in room.devices) {
                    [array addObject:device];
                }
            }
        }
    }
    self.dataList = array;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

static id previousData; //上一个数据是啥
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *returnCell;
    if (indexPath.row < self.dataList.count) {
        id data = self.dataList[indexPath.row];
        if ([data isKindOfClass:GSHFloorM.class]) {
            GSHFamilyMemberAuthorityVCFloorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"floorCell" forIndexPath:indexPath];
            cell.floor = data;
            returnCell = cell;
        }else if ([data isKindOfClass:GSHRoomM.class]){
            GSHFamilyMemberAuthorityVCRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomCell" forIndexPath:indexPath];
            cell.room = data;
            cell.viewLine.hidden = [previousData isKindOfClass:GSHFloorM.class];
            returnCell = cell;
        }else{
            GSHFamilyMemberAuthorityVCDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
            if ([data isKindOfClass:GSHDeviceM.class]) {
                cell.device = data;
            }
            returnCell = cell;
        }
        previousData = data;
    }
    return returnCell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
@end


@implementation GSHFamilyMemberAuthorityVCRoomCell
-(void)setRoom:(GSHRoomM *)room{
    _room = room;
    self.lblName.text = room.roomName;
    
    UIViewController *vc = self.viewController;
    if ([vc isKindOfClass:GSHFamilyMemberAuthorityVC.class]) {
        self.btnShow.selected = [((GSHFamilyMemberAuthorityVC*)vc).hideRooms objectForKey:room.roomId] == nil;
        [(GSHFamilyMemberAuthorityVC*)vc reloadUI];
    }
}
- (IBAction)touchShow:(UIButton *)sender {
    if ([self.viewController isKindOfClass:GSHFamilyMemberAuthorityVC.class]) {
        GSHFamilyMemberAuthorityVC *vc = (GSHFamilyMemberAuthorityVC*)self.viewController;
        if ([vc.hideRooms objectForKey:self.room.roomId] == nil) {
            [vc.hideRooms setValue:@"1" forKey:self.room.roomId.stringValue];
        }else{
            [vc.hideRooms removeObjectForKey:self.room.roomId.stringValue];
        }
        [(GSHFamilyMemberAuthorityVC*)vc reloadUI];
    }
}
@end

@implementation GSHFamilyMemberAuthorityVCDeviceCell
-(void)setDevice:(GSHDeviceM *)device{
    _device = device;
    self.lblName.text = device.deviceName;
}
@end

@implementation GSHFamilyMemberAuthorityVCFloorCell
-(void)setFloor:(GSHFloorM *)floor{
    _floor = floor;
    self.lblName.text = floor.floorName;
}
@end
