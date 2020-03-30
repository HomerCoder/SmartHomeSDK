//
//  GSHSensorGroupVC.m
//  SmartHome
//
//  Created by gemdale on 2018/12/26.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHSensorGroupVC.h"
#import "GSHSensorGroupTypeVC.h"
#import "UIView+TZM.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "GSHDeviceEditVC.h"
#import "GSHAlertManager.h"
#import "GSHSensorDetailVC.h"

@interface GSHSensorGroupVCCell ()
@property (weak, nonatomic) IBOutlet UIView *viewBinded;
@property (weak, nonatomic) IBOutlet UIView *viewUnbind;
@property (weak, nonatomic) IBOutlet UIImageView *imageSensorType;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

- (IBAction)touchBinding:(UIButton *)sender;
- (IBAction)touchDelete:(UIButton *)sender;
- (IBAction)touchDetail:(UIButton *)sender;

@property(nonatomic,strong)GSHSensorM *sensor;
@end

@implementation GSHSensorGroupVCCell

-(void)setSensor:(GSHSensorM *)sensor{
    _sensor = sensor;
    if (sensor.deviceType.intValue == -2) {
        self.viewBinded.hidden = YES;
        self.viewUnbind.hidden = NO;
    }else{
        self.viewBinded.hidden = NO;
        self.viewUnbind.hidden = YES;
        [self.imageSensorType sd_setImageWithURL:[NSURL URLWithString:sensor.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
        if (((GSHSensorMonitorM *)sensor.attributeList.firstObject).valueString) {
            self.lblName.text = [NSString stringWithFormat:@"%@(%@)",sensor.deviceName,((GSHSensorMonitorM *)sensor.attributeList.firstObject).valueString.integerValue == 1 ? @"告警" : @"正常"];
        }else{
            self.lblName.text = sensor.deviceName;
        }

    }
}

-(void)refreshUIWithSensor:(GSHSensorM*)sensor index:(NSInteger)index{
    self.sensor = sensor;
    switch (index) {
        case 0:
            self.lblTitle.text = @"第一路";
            break;
        case 1:
            self.lblTitle.text = @"第二路";
            break;
        case 2:
            self.lblTitle.text = @"第三路";
            break;
        case 3:
            self.lblTitle.text = @"第四路";
            break;
        case 4:
            self.lblTitle.text = @"第五路";
            break;
        case 5:
            self.lblTitle.text = @"第六路";
            break;
        case 6:
            self.lblTitle.text = @"第七路";
            break;
        case 7:
            self.lblTitle.text = @"第八路";
            break;
            
        default:
            break;
    }
}

-(void)unbindSelf{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"解绑中" inView:self.viewController.view];
    [GSHSensorManager postSensorGroupUnindWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.sensor.deviceId.stringValue block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.viewController.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.viewController.view];
            weakSelf.sensor.roomId = @(-2);
            weakSelf.sensor.roomName = nil;
            weakSelf.sensor.floorName = nil;
            weakSelf.sensor.floorId = nil;
            weakSelf.sensor.deviceName = nil;
            weakSelf.sensor.deviceType = @(-2);
            weakSelf.sensor.deviceTypeStr = nil;
            weakSelf.sensor = weakSelf.sensor;
        }
    }];
}

- (IBAction)touchBinding:(UIButton *)sender {
    GSHSensorGroupTypeVC *vc = [GSHSensorGroupTypeVC sensorGroupTypeVCWithSensor:self.sensor];
    [self.tzm_navigationController pushViewController:vc animated:YES];
}

- (IBAction)touchDelete:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 0) {
            [weakSelf unbindSelf];
        }
    } textFieldsSetupHandler:NULL andTitle:@"确认解绑此传感器吗？" andMessage:@"解绑后传感器模块将删除此传感器" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"解绑" cancelButtonTitle:@"取消" otherButtonTitles:nil];
}

- (IBAction)touchDetail:(UIButton *)sender {
    GSHSensorDetailVC *vc = [GSHSensorDetailVC sensorDetailVCWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId sensor:self.sensor];
    [self.tzm_navigationController pushViewController:vc animated:YES];
}
@end


@interface GSHSensorGroupVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *butRightNav;
- (IBAction)touchRightNav:(UIButton *)sender;
@property (nonatomic,strong) NSArray<GSHSensorM*> *list;
@end

@implementation GSHSensorGroupVC

+ (instancetype)sensorGroupVCWithDeviceM:(GSHDeviceM *)deviceM{
    GSHSensorGroupVC *vc = [GSHPageManager viewControllerWithSB:@"GSHSensorGroupSB" andID:@"GSHSensorGroupVC"];
    vc.deviceM = deviceM;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.deviceM.deviceName;
    self.butRightNav.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember;
    [self reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

-(void)reloadData{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [GSHSensorManager getSensorGroupDetailWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue block:^(NSArray<GSHSensorM*> *list, NSError *error) {
        [TZMProgressHUDManager dismissInView:weakSelf.view];
        [weakSelf.view dismissPageStatusView];
        if (error) {
            [weakSelf.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [weakSelf reloadData];
            }];
        }else{
            weakSelf.list = list;
            [weakSelf refreshRealData];
        }
    }];
}

- (void)refreshRealData {
    __weak typeof(self)weakSelf = self;
    [GSHSensorManager getSensorRealDataWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceSn:self.deviceM.deviceSn block:^(GSHSensorM *sensorM, NSError *error) {
        for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
            for (GSHSensorM *sensor in weakSelf.list) {
                if ([[sensor.deviceSn componentsSeparatedByString:@"_"].lastObject isEqualToString:monitorM.basMeteId]) {
                    sensor.attributeList = @[monitorM];
                    break;
                }
            }
        }
        [weakSelf.collectionView reloadData];
    }];
}

#pragma mark - Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 8;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GSHSensorGroupVCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (self.list.count > indexPath.row) {
        [cell refreshUIWithSensor:self.list[indexPath.row] index:indexPath.row];
    }else{
        [cell refreshUIWithSensor:nil index:indexPath.row];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((collectionView.frame.size.width - 16 * 3) / 2, (collectionView.frame.size.width - 16 * 3) / 2 / 164 * 240);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (IBAction)touchRightNav:(UIButton *)sender {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
       [TZMProgressHUDManager showInfoWithStatus:@"离线环境无法查看" inView:self.view];
       return;
    }
    // 设备控制 -- 进入设备
    if (!self.deviceM) {
        [TZMProgressHUDManager showErrorWithStatus:@"设备数据出错" inView:self.view];
        return;
    }
    GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:self.deviceM type:GSHDeviceEditVCTypeEdit];
    @weakify(self)
    deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
        @strongify(self)
        self.deviceM = deviceM;
        self.title = self.deviceM.deviceName;
    };
    [self.navigationController pushViewController:deviceEditVC animated:YES];
}
@end
