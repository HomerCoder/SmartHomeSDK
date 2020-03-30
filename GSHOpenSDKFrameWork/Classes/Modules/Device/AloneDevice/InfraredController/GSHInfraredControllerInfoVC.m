//
//  GSHInfraredControllerInfoVC.m
//  SmartHome
//
//  Created by gemdale on 2019/2/21.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHInfraredControllerInfoVC.h"
#import "GSHInfraredControllerTypeVC.h"
#import "GSHInfraredVirtualDeviceTVVC.h"
#import "GSHInfraredVirtualDeviceAirConditionerVC.h"
#import "UIViewController+TZMPageStatusViewEx.h"

@interface GSHInfraredControllerInfoVCCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageviewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end

@implementation GSHInfraredControllerInfoVCCell
-(void)setDevice:(GSHKuKongInfraredDeviceM *)device{
    _device = device;
    [self.imageviewIcon sd_setImageWithURL:[NSURL URLWithString:device.kkPicPath] placeholderImage:DeviceIconPlaceHoldImage];
    self.lblName.text = device.deviceName;
}
@end

@interface GSHInfraredControllerInfoVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchAdd:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property(nonatomic,strong)NSArray<GSHKuKongInfraredDeviceM*> *subDeviceList;
@end

@implementation GSHInfraredControllerInfoVC

+(instancetype)infraredControllerInfoVCWithDevice:(GSHDeviceM*)device{
    GSHInfraredControllerInfoVC *vc = [GSHPageManager viewControllerWithSB:@"GSHInfraredControllerSB" andID:@"GSHInfraredControllerInfoVC"];
    vc.deviceM = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.title = self.deviceM.deviceName;
    self.btnAdd.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember;
}

-(void)updateData{
    [TZMProgressHUDManager showWithStatus:@"获取设备中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHInfraredControllerManager getKuKongDeviceListWithParentDeviceId:self.deviceM.deviceId familyId:[GSHOpenSDKShare share].currentFamily.familyId kkDeviceType:nil deviceSn:nil block:^(NSArray<GSHKuKongInfraredDeviceM *> *list, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.subDeviceList = list;
            [weakSelf.tableView reloadData];
            if (weakSelf.subDeviceList.count == 0) {
                [weakSelf showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_equipment"] title:@"暂无设备" desc:nil buttonText:nil didClickButtonCallback:nil];
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.subDeviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHInfraredControllerInfoVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.subDeviceList.count) {
        cell.device = self.subDeviceList[indexPath.row];
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHInfraredControllerInfoVCCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.device.onlineStatus = self.deviceM.onlineStatus;
    GSHDeviceVC *vc;
    switch (cell.device.kkDeviceType.integerValue) {
        case 1:
            vc = [GSHInfraredVirtualDeviceTVVC tvHandleVCWithDevice:cell.device];
            vc.deviceEditType = GSHDeviceVCTypeControl;
            break;
        case 2:
            vc = [GSHInfraredVirtualDeviceTVVC tvHandleVCWithDevice:cell.device];
            break;
        case 5:
            vc = [GSHInfraredVirtualDeviceAirConditionerVC infraredVirtualDeviceAirConditionerVCWithDevice:cell.device];
            break;
        default:
            break;
    }
    vc.deviceEditType = GSHDeviceVCTypeControl;
    if (vc) {
        [vc show];
    }
    return nil;
}

- (IBAction)touchAdd:(UIButton *)sender {
    GSHInfraredControllerTypeVC *vc = [GSHInfraredControllerTypeVC infraredControllerTypeVCWithDevice:self.deviceM];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
