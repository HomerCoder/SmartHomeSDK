//
//  GSHDeviceManagerVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/9/25.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDeviceManagerVC.h"
#import "ZHSegmentView.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "GSHAddGWDetailVC.h"
#import "GSHScenePanelEditVC.h"
#import "GSHDeviceEditVC.h"
#import "GSHDeviceCategoryVC.h"
#import "GSHYingShiDeviceEditVC.h"

@implementation GSHDeviceManagerDeviceCell

@end

@interface GSHDeviceManagerVC () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *myDeviceLabel;

@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;
@property (strong, nonatomic) ZHSegmentView* zhSegmentView;
@property (assign, nonatomic) int selectIndex;

@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) GSHFamilyM *currentFamilyM;
@property (strong, nonatomic) NSMutableArray *foldStateArray;

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation GSHDeviceManagerVC

+(instancetype)deviceManagerVC {
    GSHDeviceManagerVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDeviceSB" andID:@"GSHDeviceManagerVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.deviceTableView.estimatedRowHeight = 0;
    self.deviceTableView.estimatedSectionFooterHeight = 0;
    self.deviceTableView.estimatedSectionHeaderHeight = 0;
    
    self.addButton.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember ? YES : NO;
    
    self.zhSegmentView = [[ZHSegmentView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.segmentView.frame.size.height)];
    [self.segmentView addSubview:self.zhSegmentView];

    @weakify(self)
    self.zhSegmentView.segmentItemClickBlock = ^(NSUInteger selectedIndex) {
        @strongify(self)
        self.selectIndex = (int)selectedIndex;
        [self.deviceTableView reloadData];
        [self.deviceTableView setContentOffset:CGPointZero animated:NO];
    };
    
    // 设置字体和颜色
    self.zhSegmentView.normalColor = [UIColor colorWithHexString:@"#222222"];
    self.zhSegmentView.selectedColor = [UIColor colorWithHexString:@"#2EB0FF"];
    self.zhSegmentView.selectedFont = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    self.zhSegmentView.normalFont = [UIFont systemFontOfSize:16];
    self.zhSegmentView.lineView.backgroundColor = [UIColor colorWithHexString:@"#2EB0FF"];
    
    // 获取设备数据
    [self getFamilyDevices];
    
    [self observerNotifications];
}

-(void)observerNotifications{
    [self observerNotification:GSHOpenSDKDeviceUpdataNotification];
    [self observerNotification:GSHOpenSDKFamilyUpdataNotification]; // 家庭发生改变的通知
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHOpenSDKDeviceUpdataNotification]) {
        // 设备修改成功通知
        [self getFamilyDevices];
    } else if ([notification.name isEqualToString:GSHOpenSDKFamilyUpdataNotification]) {
        // 家庭发生改变 刷新列表
        [self getFamilyDevices];
    }
}

-(void)dealloc{
    [self removeNotifications];
}

#pragma mark - Lazy
- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}

- (NSMutableArray *)foldStateArray {
    if (!_foldStateArray) {
        _foldStateArray = [NSMutableArray array];
    }
    return _foldStateArray;
}

#pragma mark - method
// 添加设备
- (IBAction)addDeviceButtonClick:(id)sender {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            return;
        }
        GSHDeviceCategoryVC *vc = [GSHDeviceCategoryVC deviceCategoryVC];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - request
- (void)getFamilyDevices {
    
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"加载设备中" inView:self.view];
    [GSHDeviceManager getFamilyDevicesListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(GSHGatewayM *gatewayM, GSHFamilyM *familyM, NSError *error) {
        @strongify(self)
        [self dismissPageStatusView];
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            if (self.titleArray.count > 0) {
                [self.titleArray removeAllObjects];
            }
            if (self.foldStateArray.count > 0) {
                [self.foldStateArray removeAllObjects];
            }
            [TZMProgressHUDManager dismissInView:self.view];
            
            NSString *str = [NSString stringWithFormat:@"我的设备(%@)",familyM.familyDevcieCount];
            NSDictionary *dict = @{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:16.0],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"],};
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
            [attributedString setAttributes:dict range:NSMakeRange(4, str.length-4)];
            self.myDeviceLabel.attributedText = attributedString;
            
            if (gatewayM) {
                GSHRoomM *roomM = [[GSHRoomM alloc] init];
                roomM.roomName = @"全局";
                roomM.deviceCount = @1;
                
                GSHDeviceM *deviceM = [[GSHDeviceM alloc] init];
                deviceM.gatewayId = [NSNumber numberWithString:gatewayM.gatewayId];
                deviceM.deviceName = gatewayM.gatewayName;
                deviceM.deviceType = @(GateWayDeviceType);
                deviceM.homePageIcon = gatewayM.homePageIcon;
                 
                [roomM.devices addObject:deviceM];
                
                if (familyM.floor.count == 1) {
                    // 只有一个楼层
                    GSHFloorM *floorM = familyM.floor.firstObject;
                    [floorM.rooms insertObject:roomM atIndex:0];
                } else {
                    //
                    GSHFloorM *floorM = [[GSHFloorM alloc] init];
                    floorM.floorName = @"全局";
                    floorM.floorDeviceCount = @1;
                    
                    [floorM.rooms addObject:roomM];
                    
                    [familyM.floor insertObject:floorM atIndex:0];
                }
            }
            self.currentFamilyM = familyM;
            
            if (self.currentFamilyM.floor.count < 2) {
                // 隐藏楼层
                self.segmentView.hidden = YES;
                self.segmentViewHeight.constant = 0;
                
                NSMutableArray *stateArr = [NSMutableArray array];
                for (int i = 0; i < self.currentFamilyM.floor.firstObject.rooms.count; i++) {
                    [stateArr addObject:@(1)];
                }
                [self.foldStateArray addObject:stateArr];
                
            } else {
                // 显示楼层
                self.segmentView.hidden = NO;
                self.segmentViewHeight.constant = 44.0f;
                
                for (GSHFloorM *floorM in familyM.floor) {
                    [self.titleArray addObject:[NSString stringWithFormat:@"%@(%d)",floorM.floorName,floorM.floorDeviceCount.intValue]];
                    
                    NSMutableArray *stateArr = [NSMutableArray array];
                    for (int i = 0; i < floorM.rooms.count; i++) {
                        [stateArr addObject:@(1)];
                    }
                    [self.foldStateArray addObject:stateArr];
                }
                self.zhSegmentView.titles = self.titleArray;
                self.zhSegmentView.currentIndex = self.selectIndex;
                [self.zhSegmentView reloadData];
            }
            [self.deviceTableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.currentFamilyM.floor.count > self.selectIndex) {
        GSHFloorM *floorM = self.currentFamilyM.floor[self.selectIndex];
        return floorM.rooms.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.currentFamilyM.floor.count > self.selectIndex) {
        GSHFloorM *floorM = self.currentFamilyM.floor[self.selectIndex];
        NSArray *stateArr = self.foldStateArray[self.selectIndex];
        if (floorM.rooms.count > section) {
            GSHRoomM *roomM = floorM.rooms[section];
            BOOL state = ((NSNumber *)stateArr[section]).boolValue;
            return state ? roomM.devices.count : 0;
        }
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHDeviceManagerDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"managerDeviceCell" forIndexPath:indexPath];
    cell.accessoryType = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    if (self.currentFamilyM.floor.count > self.selectIndex) {
        GSHFloorM *floorM = self.currentFamilyM.floor[self.selectIndex];
        if (floorM.rooms.count > indexPath.section) {
            GSHRoomM *roomM = floorM.rooms[indexPath.section];
            if (roomM.devices.count > indexPath.row) {
                GSHDeviceM *deviceM = roomM.devices[indexPath.row];
                if (deviceM.deviceType.integerValue == GateWayDeviceType || deviceM.deviceType.integerValue == GateWayDeviceType2) {
                    // 网关
                    cell.deviceNameLabelCenterY.constant = -10;
                    cell.deviceSubLabel.hidden = NO;
                    cell.deviceSubLabel.text = deviceM.gatewayId.stringValue;
                } else {
                    // 设备
                    cell.deviceNameLabelCenterY.constant = 0;
                    cell.deviceSubLabel.hidden = YES;
                }
                cell.deviceNameLabel.text = deviceM.deviceName;
                [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:deviceM.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
        return;
    }
    if (self.currentFamilyM.floor.count > self.selectIndex) {
        GSHFloorM *floorM = self.currentFamilyM.floor[self.selectIndex];
        if (floorM.rooms.count > indexPath.section) {
            GSHRoomM *roomM = floorM.rooms[indexPath.section];
            if (roomM.devices.count > indexPath.row) {
                __block GSHDeviceM *tmpDeviceM = roomM.devices[indexPath.row];
                if (tmpDeviceM.deviceType.integerValue == GateWayDeviceType || tmpDeviceM.deviceType.integerValue == GateWayDeviceType2) {
                    // 网关
                    GSHAddGWDetailVC *deviceEditVC = [GSHAddGWDetailVC editGWDetailVCWithDevice:tmpDeviceM];
                    [self.navigationController pushViewController:deviceEditVC animated:YES];
                } else {
                    // 设备
                    if ([tmpDeviceM.deviceType isEqual: GSHScenePanelDeviceType]) {
                        // 场景面板
                        GSHScenePanelEditVC *scenePanelEditVC = [GSHScenePanelEditVC scenePanelEditVCWithDeviceM:tmpDeviceM type:GSHScenePanelEditTypeEdit];
                        scenePanelEditVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:scenePanelEditVC animated:YES];
                        return;
                    }
                    if ([tmpDeviceM.deviceType isEqual:GSHYingShiMaoYanDeviceType] ||
                        [tmpDeviceM.deviceType isEqual:GSHYingShiSheXiangTou1DeviceType] ||
                        [tmpDeviceM.deviceType isEqual:GSHYingShiSheXiangTou2DeviceType] ) {
                        GSHYingShiDeviceEditVC *vc = [GSHYingShiDeviceEditVC yingShiDeviceEditVCWithDevice:tmpDeviceM];
                        [self.navigationController pushViewController:vc animated:YES];
                        return;
                    }
                    GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:tmpDeviceM type:GSHDeviceEditVCTypeEdit];
                    [self.navigationController pushViewController:deviceEditVC animated:YES];
                }
            }
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (self.currentFamilyM.floor.count > self.selectIndex) {
        GSHFloorM *floorM = self.currentFamilyM.floor[self.selectIndex];
        if (floorM.rooms.count > section) {
            GSHRoomM *roomM = floorM.rooms[section];
            
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
            headView.backgroundColor = [UIColor whiteColor];
            headView.tag = section;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-100, 50)];
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor colorWithHexString:@"#222222"];
            label.font = [UIFont systemFontOfSize:16.0];
            [headView addSubview:label];
            label.text = [NSString stringWithFormat:@"%@(%ld)",roomM.roomName,roomM.devices.count];
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 60, 50)];
            [button setImage:[UIImage ZHImageNamed:@"app_arrow_up_gray"] forState:UIControlStateNormal];
            [button setImage:[UIImage ZHImageNamed:@"app_arrow_down_gray"] forState:UIControlStateSelected];
            button.tag = section+10000;
            NSMutableArray *arr = self.foldStateArray[self.selectIndex];
            BOOL state = ((NSNumber *)arr[section]).boolValue;
            button.selected = state;
            button.userInteractionEnabled = NO;
            [headView addSubview:button];
            
            UITapGestureRecognizer *gesTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foldClick:)];
            [headView addGestureRecognizer:gesTap];
            
            return headView;
        }
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.f;
}

- (void)foldClick:(UITapGestureRecognizer *)tap {
    NSInteger tag = tap.view.tag;
    UIButton *button = (UIButton *)[self.view viewWithTag:tag+10000];
    button.selected = !button.selected;
    
    NSMutableArray *arr = self.foldStateArray[self.selectIndex];
    BOOL state = ((NSNumber *)arr[tag]).boolValue;
    state = !state;
    [arr replaceObjectAtIndex:tag withObject:[NSNumber numberWithBool:state]];
    [self.deviceTableView reloadData];
    
}

@end
