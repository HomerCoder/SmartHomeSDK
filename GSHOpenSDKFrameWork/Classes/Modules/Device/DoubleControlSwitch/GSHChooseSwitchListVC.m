//
//  GSHChooseSwitchListVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHChooseSwitchListVC.h"
#import "TZMButton.h"
#import "GSHChooseRoomVC.h"
#import "GSHChooseSwitchItemVC.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "UIViewController+TZMPageStatusViewEx.h"

@interface GSHChooseSwitchListVC () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , strong) TZMButton *chooseRoomButton;
@property (nonatomic , strong) GSHFloorM *choosedFloorM;
@property (nonatomic , strong) GSHRoomM *choosedRoomM;
@property (nonatomic , strong) NSMutableArray *switchArray;
@property (weak, nonatomic) IBOutlet UITableView *switchTableView;
@property (strong, nonatomic) GSHSwitchBindM *switchBindM;
@property (strong, nonatomic) GSHSwitchMeteBindInfoModelM *switchMeteBindInfoModelM;

@end

@implementation GSHChooseSwitchListVC

+ (instancetype)chooseSwitchListVCWithSwitchBindM:(GSHSwitchBindM *)switchBindM switchMeteBindInfoModelM:(GSHSwitchMeteBindInfoModelM *)switchMeteBindInfoModelM {
    GSHChooseSwitchListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoubleControlSwitchSB" andID:@"GSHChooseSwitchListVC"];
    vc.switchBindM = switchBindM;
    vc.switchMeteBindInfoModelM = switchMeteBindInfoModelM;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.titleView = self.chooseRoomButton;
    
    GSHFloorM *floorM = (GSHFloorM *)[GSHOpenSDKShare share].currentFamily.floor[0];
    GSHRoomM *roomM = (GSHRoomM *)floorM.rooms[0];
    NSString *roomString = nil;
    if ([GSHOpenSDKShare share].currentFamily.floor.count == 1) {
        roomString = roomM.roomName;
    } else {
        roomString = [NSString stringWithFormat:@"%@%@",floorM.floorName,roomM.roomName];
    }
    [self.chooseRoomButton setTitle:roomString forState:UIControlStateNormal];
    self.choosedFloorM = floorM;
    self.choosedRoomM = roomM;
    // 请求房间下所有开关
    [self getSwitchWithRoomId:roomM.roomId.stringValue];
    
}

#pragma mark - Lazy
- (TZMButton *)chooseRoomButton {
    if (!_chooseRoomButton) {
        _chooseRoomButton = [TZMButton buttonWithType:UIButtonTypeCustom];
        _chooseRoomButton.frame = CGRectMake(0, 0, 180, 44);
        [_chooseRoomButton setTitle:@"选择房间" forState:UIControlStateNormal];
        _chooseRoomButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_chooseRoomButton setImage:[UIImage ZHImageNamed:@"app_icpnarrow_down"] forState:UIControlStateNormal];
        _chooseRoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0];
        [_chooseRoomButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_chooseRoomButton addTarget:self action:@selector(chooseRoomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _chooseRoomButton.imageDirection = 2;
    }
    return _chooseRoomButton;
}

- (NSMutableArray *)switchArray {
    if (!_switchArray) {
        _switchArray = [NSMutableArray array];
    }
    return _switchArray;
}

#pragma mark - method

- (void)chooseRoomButtonClick:(UIButton *)button {
    [self transformChooseRoomButtonImageView];
    GSHChooseRoomVC *chooseRoomVC = [[GSHChooseRoomVC alloc] initWithFloorM:self.choosedFloorM roomM:self.choosedRoomM floorArray:[GSHOpenSDKShare share].currentFamily.floor];
    chooseRoomVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    chooseRoomVC.modalPresentationStyle = UIModalPresentationCustom;
    @weakify(self)
    chooseRoomVC.chooseRoomBlock = ^(GSHFloorM *floorM , GSHRoomM *roomM) {
        @strongify(self)
        
//        [self refreshSelectedDeviceArray];  // 切换房间时，先记录已经选择的设备
        
        NSString *chooseButtonTitle = roomM.roomName;
        if ([GSHOpenSDKShare share].currentFamily.floor.count == 1) {
            chooseButtonTitle = roomM.roomName;
        } else {
            chooseButtonTitle = [NSString stringWithFormat:@"%@%@",floorM.floorName,roomM.roomName];
        }
        [self.chooseRoomButton setTitle:chooseButtonTitle forState:UIControlStateNormal];
        [self transformChooseRoomButtonImageView];
        self.choosedFloorM = floorM;
        self.choosedRoomM = roomM;
        [self getSwitchWithRoomId:roomM.roomId.stringValue];
    };
    chooseRoomVC.dissmissBlock = ^{
        @strongify(self)
        [self transformChooseRoomButtonImageView];
    };
    [self presentViewController:chooseRoomVC animated:YES completion:nil];
}

- (void)transformChooseRoomButtonImageView {
    [UIView animateWithDuration:0.25 animations:^{
        self.chooseRoomButton.imageView.transform =  CGAffineTransformRotate(self.chooseRoomButton.imageView.transform, M_PI);
    }];
}

#pragma mark - request
// 请求房间下所有开关
- (void)getSwitchWithRoomId:(NSString *)roomId {
    if (!roomId) {
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHDeviceManager getSwitchDevicesListWithroomId:roomId block:^(NSArray<GSHDeviceM *> *list, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (self.switchArray.count > 0) {
                [self.switchArray removeAllObjects];
            }
            [self.switchArray addObjectsFromArray:list];
            if (self.switchArray.count > 0) {
                [self handleSwitchArray];
            }
            if (self.switchArray.count == 0) {
                [self showBlankView];
            } else {
                [self hideBlankView];
                [self.switchTableView reloadData];
            }
        }
    }];
}

// 过滤掉 本身的开关 以及 本路绑定开关
- (void)handleSwitchArray {
    NSMutableArray *deleteSwitchArray = [NSMutableArray array];
    for (GSHDeviceM *tmpDeviceM in self.switchArray) {
        if ([tmpDeviceM.deviceSn isEqualToString:self.switchBindM.deviceSn]) {
            [deleteSwitchArray addObject:tmpDeviceM];
        }
        for (GSHMeteBindedInfoListM *bindedInfoListM in self.switchMeteBindInfoModelM.meteBindedInfoList) {
            if ([tmpDeviceM.deviceSn isEqualToString:bindedInfoListM.deviceSn]) {
                [deleteSwitchArray addObject:tmpDeviceM];
            }
        }
    }
    if (deleteSwitchArray.count > 0) {
        [self.switchArray removeObjectsInArray:deleteSwitchArray];
    }
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

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.switchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseSwitchListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHChooseSwitchListCell" forIndexPath:indexPath];
    GSHDeviceM *deviceM = self.switchArray[indexPath.row];
    [cell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:deviceM.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
    cell.deviceNameLabel.text = deviceM.deviceName;
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.switchArray.count > indexPath.row) {
        GSHDeviceM *deviceM = self.switchArray[indexPath.row];
        GSHChooseSwitchItemVC *chooseSwitchItemVC = [GSHChooseSwitchItemVC chooseSwitchItemVCWithDeviceM:deviceM switchBindM:self.switchBindM switchMeteBindInfoModelM:self.switchMeteBindInfoModelM];
        chooseSwitchItemVC.bindSuccessBlock = self.bindSuccessBlock;
        chooseSwitchItemVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chooseSwitchItemVC animated:YES];
    }
    return nil;
}


@end


@implementation GSHChooseSwitchListCell



@end
