//
//  GSHChooseDeviceVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/24.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHChooseDeviceVC.h"
#import "GSHChooseDeviceListCell.h"

#import "GSHThreeWaySwitchHandleVC.h"   // 三路开关操作页面

#import "GSHChooseRoomVC.h"

#import "TZMButton.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "UIViewController+TZMPageStatusViewEx.h"

#import "GSHAutoCreateVC.h"

@interface GSHChooseDeviceVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) NSMutableArray *deviceArray;
@property (nonatomic , strong) NSMutableArray *chooseDeviceArray;
@property (nonatomic , strong) NSMutableArray *noChoosedDeviceArray;

@property (nonatomic , strong) UIButton *sureButton;
@property (nonatomic , strong) TZMButton *chooseRoomButton;
@property (nonatomic , strong) __block NSString *selectedFloorString;

@property (nonatomic , strong) NSMutableArray *selectedDeviceArray;

@property (nonatomic , strong) GSHFloorM *choosedFloorM;
@property (nonatomic , strong) GSHRoomM *choosedRoomM;
@property (nonatomic , strong) NSArray *floorArray;

@property (nonatomic , strong) UITableView *tableView;

@end

@implementation GSHChooseDeviceVC

- (instancetype)initWithSelectDeviceArray:(NSArray *)selectDeviceArray {
    self = [super init];
    if (self) {
        self.selectedDeviceArray = [NSMutableArray arrayWithArray:selectDeviceArray];
    }
    return self;
}

- (instancetype)initWithSelectDeviceArray:(NSArray *)selectDeviceArray floorM:(GSHFloorM *)floorM roomM:(GSHRoomM *)roomM floorArray:(NSArray *)floorArray
{
    self = [super init];
    if (self) {
        self.selectedDeviceArray = [NSMutableArray arrayWithArray:selectDeviceArray];
        self.choosedFloorM = floorM;
        self.choosedRoomM = roomM;
        self.floorArray = floorArray;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
    
    [self initNavigationView];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
    headView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F7"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexString:@"#3C4366"];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = @"请选择相应的设备";
    [headView addSubview:label];
    [self.tableView setTableHeaderView:headView];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)]];

    if (self.choosedRoomM) {
        [self refreshRoomInfoAndRequestDevicesList];
    } else {
        // 获取房间
        [self getRoomInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)initNavigationView {
    
    TZMButton *chooseRoomButton = [TZMButton buttonWithType:UIButtonTypeCustom];
    chooseRoomButton.frame = CGRectMake(0, 0, 180, 44);
    [chooseRoomButton setTitle:@"选择房间" forState:UIControlStateNormal];
    [chooseRoomButton setImage:[UIImage ZHImageNamed:@"app_icpnarrow_down"] forState:UIControlStateNormal];
    chooseRoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0];
    [chooseRoomButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [chooseRoomButton addTarget:self action:@selector(chooseRoomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    chooseRoomButton.imageDirection = 2;
    self.navigationItem.titleView = chooseRoomButton;
    self.chooseRoomButton = chooseRoomButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(SCREEN_WIDTH - 44, 0, 44, 44);
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"#2EB0FF"] forState:UIControlStateNormal];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.sureButton = rightButton;
}

- (void)showBlankView {
    [self showPageStatus:TZMPageStatusNormal
                   image:[UIImage ZHImageNamed:@"blankpage_icon_equipment"]
                   title:nil
                    desc:@"暂无设备"
              buttonText:nil
  didClickButtonCallback:nil];
}

- (void)hideBlankView {
    [self dismissPageStatusView];
}

#pragma mark - Lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KNavigationBar_Height) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerNib:[UINib nibWithNibName:@"GSHChooseDeviceListCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"chooseDeviceListCell"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableArray *)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray array];
    }
    return _deviceArray;
}

- (NSMutableArray *)chooseDeviceArray {
    if (!_chooseDeviceArray) {
        _chooseDeviceArray = [NSMutableArray array];
    }
    return _chooseDeviceArray;
}

- (NSMutableArray *)noChoosedDeviceArray {
    if (!_noChoosedDeviceArray) {
        _noChoosedDeviceArray = [NSMutableArray array];
    }
    return _noChoosedDeviceArray;
}

#pragma mark - method
// 确定按钮点击
- (void)sureButtonClick:(UIButton *)button {
    
    [self refreshSelectedDeviceArray];  // 点击确定时，记录当前页面设备选择情况
    
    if (self.selectDeviceBlock) {
        self.selectDeviceBlock(self.selectedDeviceArray);
    }
    switch (self.fromFlag) {
        case ChooseDeviceFromAddScene: {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case ChooseDeviceFromAddAutoAddCondition: {
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[GSHAutoCreateVC class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
            break;
        }
        case ChooseDeviceFromAddAutoAddAction: {
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[GSHAutoCreateVC class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
            break;
        }
        default:
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}

- (void)chooseRoomButtonClick:(UIButton *)button {
    
    [self transformChooseRoomButtonImageView];
    [self.sureButton setTitleColor:[UIColor colorWithHexString:@"#DEDEDE"] forState:UIControlStateNormal];
    GSHChooseRoomVC *chooseRoomVC = [[GSHChooseRoomVC alloc] initWithFloorM:self.choosedFloorM roomM:self.choosedRoomM floorArray:self.floorArray];
    chooseRoomVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    chooseRoomVC.modalPresentationStyle = UIModalPresentationCustom;
    @weakify(self)
    chooseRoomVC.chooseRoomBlock = ^(GSHFloorM *floorM , GSHRoomM *roomM) {
        @strongify(self)
        [self refreshSelectedDeviceArray];  // 切换房间时，先记录已经选择的设备
        [self.sureButton setTitleColor:[UIColor colorWithHexString:@"#2EB0FF"] forState:UIControlStateNormal];
        NSString *chooseButtonTitle = roomM.roomName;
        if (self.floorArray.count == 1) {
            chooseButtonTitle = roomM.roomName;
        } else {
            chooseButtonTitle = [NSString stringWithFormat:@"%@%@",floorM.floorName,roomM.roomName];
        }
        [self.chooseRoomButton setTitle:chooseButtonTitle forState:UIControlStateNormal];
        [self transformChooseRoomButtonImageView];
        self.choosedFloorM = floorM;
        self.choosedRoomM = roomM;
        [self getDevicesListWithRoomId:roomM.roomId.stringValue];
    };
    chooseRoomVC.dissmissBlock = ^{
        @strongify(self)
        [self.sureButton setTitleColor:[UIColor colorWithHexString:@"#2EB0FF"] forState:UIControlStateNormal];
        [self transformChooseRoomButtonImageView];
    };
    [self presentViewController:chooseRoomVC animated:YES completion:nil];
    
}

- (void)transformChooseRoomButtonImageView {
    [UIView animateWithDuration:0.25 animations:^{
        self.chooseRoomButton.imageView.transform =  CGAffineTransformRotate(self.chooseRoomButton.imageView.transform, M_PI);
    }];
}

- (void)getDevicesListWithRoomId:(NSString *)roomId {
    if (self.fromFlag == ChooseDeviceFromAddScene) {
        // 场景设置
        [self getSceneDevicesListWithRoomId:roomId];
    } else if (self.fromFlag == ChooseDeviceFromAddAutoAddCondition) {
        // 联动 -- 触发条件 -- 选择设备
        [self getAutoTriggerDevicesListWithRoomId:roomId];
    } else {
        // 联动 -- 执行动作 -- 选择设备
        [self getAutoActionDevicesListWithRoomId:roomId];
    }
}

// 刷新 房间显示信息 并 请求相应房间设备
- (void)refreshRoomInfoAndRequestDevicesList {
    
    if (self.floorArray.count > 1) {
        if (self.choosedFloorM && self.choosedRoomM) {
            NSString *str = [NSString stringWithFormat:@"%@%@",self.choosedFloorM.floorName,self.choosedRoomM.roomName];
            [self.chooseRoomButton setTitle:str forState:UIControlStateNormal];
        }
    } else {
        if (self.choosedRoomM) {
            [self.chooseRoomButton setTitle:self.choosedRoomM.roomName forState:UIControlStateNormal];
        }
    }
    [self getDevicesListWithRoomId:self.choosedRoomM.roomId.stringValue];
}

// 修改设备选择状态
- (void)alertDeviceIsSelectedWithSelectedArray {
    for (GSHDeviceM *selectDeviceM in self.selectedDeviceArray) {
        for (GSHDeviceM *deviceM in self.deviceArray) {
            if ([deviceM.deviceId isKindOfClass:NSNumber.class]) {
                if ([selectDeviceM.deviceId isEqualToNumber:deviceM.deviceId]) {
                    [deviceM setIsSelected:YES];
                }
            }
        }
    }
}

// 切换房间或点击确定时，处理已选择的设备
- (void)refreshSelectedDeviceArray {
    for (GSHDeviceM *deviceM in self.deviceArray) {
        if (deviceM.isSelected) {
            // 被选中
            if (![self isAddInSelectedArrayWithDeviceM:deviceM]) {
                [self.selectedDeviceArray addObject:deviceM];
            }
        } else {
            // 未被选中
            if ([self isAddInSelectedArrayWithDeviceM:deviceM]) {
                [self deleteDeviceFromSelectedDeviceArrayWithDeviceM:deviceM];
            }
        }
    }
}

// 查询设备是否已加入被选中设备数组
- (BOOL)isAddInSelectedArrayWithDeviceM:(GSHDeviceM *)deviceM {
    BOOL isIn = NO;
    for (GSHDeviceM *selectedDeviceM in self.selectedDeviceArray) {
        if ([deviceM.deviceId isKindOfClass:NSNumber.class]) {
            if ([selectedDeviceM.deviceId isEqualToNumber:deviceM.deviceId]) {
                isIn = YES;
                break;
            }
        }
    }
    return isIn;
}

// 从被选中设备数组中删除该设备
- (void)deleteDeviceFromSelectedDeviceArrayWithDeviceM:(GSHDeviceM *)deviceM {
    for (GSHDeviceM *selectedDeviceM in self.selectedDeviceArray) {
        if ([deviceM.deviceId isKindOfClass:NSNumber.class]) {
            if ([selectedDeviceM.deviceId isEqualToNumber:deviceM.deviceId]) {
                [self.selectedDeviceArray removeObject:selectedDeviceM];
                break;
            }
        }
    }
}

#pragma mark - request
// 场景 -- 可选设备列表
- (void)getSceneDevicesListWithRoomId:(NSString *)roomId {
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHSceneManager getSceneDevicesListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId
                                         roomId:roomId
                                          block:^(NSArray<GSHDeviceM *> *list, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (self.deviceArray.count > 0) {
                [self.deviceArray removeAllObjects];
            }
            [self.deviceArray addObjectsFromArray:list];
            if (self.selectedDeviceArray.count > 0) {
                [self alertDeviceIsSelectedWithSelectedArray];
            }
            if (self.deviceArray.count == 0) {
                [self showBlankView];
            } else {
                [self hideBlankView];
                [self.tableView reloadData];
            }
        }
    }];
}

// 联动 -- 触发条件 -- 可选设备列表
- (void)getAutoTriggerDevicesListWithRoomId:(NSString *)roomId {
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHAutoManager getAutoTriggerDevicesListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId
                                               roomId:roomId
                                                block:^(NSArray<GSHDeviceM *> *list, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (self.deviceArray.count > 0) {
                [self.deviceArray removeAllObjects];
            }
            [self.deviceArray addObjectsFromArray:list];
            if (self.selectedDeviceArray.count > 0) {
                [self alertDeviceIsSelectedWithSelectedArray];
            }
            if (self.deviceArray.count == 0) {
                [self showBlankView];
            } else {
                [self hideBlankView];
                [self.tableView reloadData];
            }
        }
    }];
}

// 联动 -- 执行动作 -- 可选设备列表
- (void)getAutoActionDevicesListWithRoomId:(NSString *)roomId {
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHAutoManager getAutoActionDevicesListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId
                                              roomId:roomId
                                               block:^(NSArray<GSHDeviceM *> *list, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (self.deviceArray.count > 0) {
                [self.deviceArray removeAllObjects];
            }
            [self.deviceArray addObjectsFromArray:list];
            if (self.selectedDeviceArray.count > 0) {
                [self alertDeviceIsSelectedWithSelectedArray];
            }
            if (self.deviceArray.count == 0) {
                [self showBlankView];
            } else {
                [self hideBlankView];
                [self.tableView reloadData];
            }
        }
    }];
}

// 获取房间信息
- (void)getRoomInfo {
    
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHSceneManager getAllFloorAndRoomWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSArray<GSHFloorM *> *list, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (list.count > 0) {
                self.floorArray = list;
                self.choosedFloorM = self.floorArray[0];
                if (self.choosedFloorM.rooms.count > 0) {
                    self.choosedRoomM = self.choosedFloorM.rooms[0];
                }
                [self refreshRoomInfoAndRequestDevicesList];
            }
        }
    }];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseDeviceListCell *chooseDeviceListCell = [tableView dequeueReusableCellWithIdentifier:@"chooseDeviceListCell" forIndexPath:indexPath];
    chooseDeviceListCell.selectionStyle = UITableViewCellSelectionStyleNone;
    chooseDeviceListCell.deviceActionLabel.hidden = YES;
    GSHDeviceM *deviceM = self.deviceArray[indexPath.row];
    [chooseDeviceListCell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:deviceM.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
    chooseDeviceListCell.deviceNameLabel.text = deviceM.deviceName;
    chooseDeviceListCell.checkButton.selected = deviceM.isSelected;
    return chooseDeviceListCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHChooseDeviceListCell *listCell = [tableView cellForRowAtIndexPath:indexPath];
    GSHDeviceM *deviceM = self.deviceArray[indexPath.row];
    listCell.checkButton.selected = !listCell.checkButton.selected;
    [deviceM setIsSelected:listCell.checkButton.selected];

}





@end
