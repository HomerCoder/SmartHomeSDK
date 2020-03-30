//
//  GSHSensorListVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSensorListVC.h"
#import "PopoverView.h"
#import "UINavigationController+TZM.h"
#import "Masonry.h"
#import "GSHSensorDetailVC.h"
#import "UIScrollView+TZMRefreshAndLoadMore.h"
#import "NSObject+TZM.h"
#import "GSHLackSensorListVC.h"

@interface GSHSensorCell ()
@property (weak, nonatomic) IBOutlet UILabel *mainNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@end

@implementation GSHSensorCell
-(void)setModel:(GSHSensorM *)model{
    _model = model;
    self.mainNameLabel.text = model.deviceName;
    NSMutableAttributedString *attributedString = nil;
    if (model.deviceId) {
        self.roomLabel.text = model.roomName;
        self.height.constant = 20;
        NSArray<GSHSensorMonitorM*> *showAttributeList = model.showAttributeList;
        attributedString = [[NSMutableAttributedString alloc] init];
        for (int i = 0; i < showAttributeList.count; i++) {
            GSHSensorMonitorM *monitor = showAttributeList[i];
            if (monitor.showMeteStr.length > 0){
                if (monitor.unit && ![model.deviceType isEqualToNumber:GSHHuanjingSensorDeviceType]) {
                    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@%@",monitor.showMeteStr,monitor.unit] attributes:@{NSForegroundColorAttributeName : (model.grade > 2 ?  [UIColor colorWithRGB:0xF63737] :  [UIColor colorWithRGB:0x3C4366])}]];
                }else{
                    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",monitor.showMeteStr] attributes:@{ NSForegroundColorAttributeName : (model.grade > 2 ?  [UIColor colorWithRGB:0xF63737] :  [UIColor colorWithRGB:0x3C4366])}]];
                }
            }
        }
        if (attributedString.length == 0) {
            attributedString = [[NSMutableAttributedString alloc] initWithString:@"暂无" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRGB:0x999999]}];
        }
    }
    self.lblContent.attributedText = attributedString;
}
@end

@interface GSHSensorListVC () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *imageFloor;
- (IBAction)backButtonClick:(id)sender;
- (IBAction)chooseFloorButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewChangeFloor;
@property (weak, nonatomic) IBOutlet UILabel *lblFloor;

@property (weak, nonatomic) IBOutlet UITableView *sensorListTableView;
@property (weak, nonatomic) IBOutlet UILabel *lblHuangjin;
@property (weak, nonatomic) IBOutlet UILabel *lblHuangjinDengji;
@property (weak, nonatomic) IBOutlet UILabel *lblAnfang;
@property (weak, nonatomic) IBOutlet UILabel *lblAnfangDengji;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcLackHeigh;
@property (weak, nonatomic) IBOutlet UIView *viewLack;
@property (weak, nonatomic) IBOutlet UIButton *btnLack;
@property (weak, nonatomic) IBOutlet UIView *viewNoData;
- (IBAction)touchLackSensor:(id)sender;

@property (strong, nonatomic)GSHFloorM *floor;
@property (strong, nonatomic)NSArray<GSHSensorM*> *sensorList;
@property (strong, nonatomic)NSArray<GSHMissingSensorM*> *lackSensorList;
@property (strong, nonatomic)NSString *tip;

@property (strong, nonatomic)NSMutableArray<PopoverAction*> *actionArray;
@property (assign,nonatomic)NSInteger seleNumber;
@property (strong, nonatomic)NSMutableDictionary *familyIndex;
@end

@implementation GSHSensorListVC

+ (instancetype)sensorListVCWithFloor:(GSHFloorM*)floor familyIndex:(NSMutableDictionary*)familyIndex{
    GSHSensorListVC *vc = [GSHPageManager viewControllerWithSB:@"SensorListSB" andID:@"GSHSensorListVC"];
    vc.floor = floor;
    vc.familyIndex = familyIndex;
    return vc;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)setFloor:(GSHFloorM *)floor{
    _floor = floor;
    self.lblFloor.text = floor.floorName;
    [self refreshSensor];
    self.seleNumber = [[GSHOpenSDKShare share].currentFamily.floor indexOfObject:floor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.sensorListTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tzm_prefersNavigationBarHidden = YES;
    self.viewChangeFloor.hidden = [GSHOpenSDKShare share].currentFamily.floor.count <= 1;
    if (self.floor) {
        self.floor = self.floor;
    }else{
        self.floor = [GSHOpenSDKShare share].currentFamily.floor.firstObject;
    }
    [self initActionArray];
    [self refreshFamilyIndexUI];
    
    [self observerNotifications];
}

-(void)dealloc{
    [self removeNotifications];
}

#pragma mark - 通知
-(void)observerNotifications{
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];
}

-(void)handleNotifications:(NSNotification *)notification {
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification]) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            [self refreshSensorAfterReceiceRealTimeData];
        }
    }
}

-(void)refreshFamilyIndexUI{
    if (GSHNetworkTypeLAN == [GSHWebSocketClient shared].networkType) {
        return;
    }
    if(!self.familyIndex){
        __weak typeof(self)weakself = self;
        [GSHFamilyManager getFamilyIndexWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSDictionary *familyIndex, NSError *error) {
            weakself.familyIndex = [NSMutableDictionary dictionaryWithDictionary:familyIndex];
            [weakself refreshFamilyIndexUI];
        }];
    }
    
    NSString *envScore,*envColor,*envAlarmColor,*envAlarmTip,*securityScore,*securityColor,*securityAlarmColor,*securityAlarmTip,*tip;
    NSArray *alarms;
    
    envScore = [self.familyIndex stringValueForKey:@"envScore" default:@"0"];
    envColor = [self.familyIndex stringValueForKey:@"envColor" default:@"222222"];
    NSDictionary *envAlarm = [self.familyIndex objectForKey:@"envAlarm"];
    if ([envAlarm isKindOfClass:NSDictionary.class]) {
        envAlarmColor = [envAlarm stringValueForKey:@"color" default:nil];
        envAlarmTip = [envAlarm stringValueForKey:@"tip" default:nil];
    }

    securityScore = [self.familyIndex stringValueForKey:@"securityScore" default:@"0"];
    securityColor = [self.familyIndex stringValueForKey:@"securityColor" default:@"222222"];
    NSDictionary *securityAlarm = [self.familyIndex objectForKey:@"securityAlarm"];
    if ([securityAlarm isKindOfClass:NSDictionary.class]) {
        securityAlarmColor = [securityAlarm stringValueForKey:@"color" default:nil];
        securityAlarmTip = [securityAlarm stringValueForKey:@"tip" default:nil];
    }
    
    tip = [self.familyIndex stringValueForKey:@"tip" default:@""];
    if ([[self.familyIndex objectForKey:@"alarms"] isKindOfClass:NSArray.class]) {
        alarms = [self.familyIndex objectForKey:@"alarms"];
    }
    
    if (envAlarmTip.length > 0) {
        self.lblHuangjin.text = envAlarmTip;
        self.lblHuangjin.textColor = [UIColor colorWithHexString:envAlarmColor];
    }else{
        self.lblHuangjin.text = envScore;
        self.lblHuangjin.textColor = [UIColor colorWithHexString:envColor];
    }
    
    if (securityAlarmTip.length > 0) {
        self.lblAnfang.text = securityAlarmTip;
        self.lblAnfang.textColor = [UIColor colorWithHexString:securityAlarmColor];
    }else{
        self.lblAnfang.text = securityScore;
        self.lblAnfang.textColor = [UIColor colorWithHexString:securityColor];
    }
}

- (void)initActionArray{
    self.actionArray = [NSMutableArray array];
    for (GSHFloorM *floor in [GSHOpenSDKShare share].currentFamily.floor) {
        __weak typeof(self)weakSelf = self;
        PopoverAction *action = [PopoverAction actionWithImage:[UIImage ZHImageNamed:@"app_sele_b"] title:floor.floorName handler:^(PopoverAction *action) {
            weakSelf.lblFloor.text = floor.floorName;
            weakSelf.floor = floor;
            [UIView animateWithDuration:0.25 animations:^{
                weakSelf.imageFloor.transform =  CGAffineTransformRotate(weakSelf.imageFloor.transform, M_PI);
            }];
        }];
        [self.actionArray addObject:action];
    }
}

-(void)refreshSensor{
    __weak typeof(self)weakSelf = self;
    __weak typeof(GSHFloorM*)weakFloor = self.floor;
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [GSHSensorManager getFamilyIndexDeviceWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId floorId:self.floor.floorId block:^(NSArray<GSHSensorM *> *list, NSArray<GSHMissingSensorM *> *missingList, NSString *tip, NSError *error) {
        [weakSelf.sensorListTableView.tzm_refreshControl stopIndicatorAnimation];
        if (![weakFloor.floorId isEqual:weakSelf.floor.floorId]) {
           if (list.count > 0) {
               weakFloor.sensorMsgList = [NSMutableArray arrayWithArray:list];
           }
           return;
        }
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:@"获取传感器失败" inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if (list.count > 0) {
               weakFloor.sensorMsgList = [NSMutableArray arrayWithArray:list];
            }else{
               weakFloor.sensorMsgList = nil;
            }
            weakSelf.sensorList = list;
            weakSelf.lackSensorList = missingList;
            weakSelf.tip = tip;
        }
        [weakSelf refreshUI];
    }];
}

-(void)refreshUI{
    if (self.sensorList.count == 0) {
        self.viewNoData.hidden = NO;
        self.viewLack.hidden = YES;
    }else{
        self.viewNoData.hidden = YES;
        if (self.lackSensorList.count == 0) {
            self.viewLack.hidden = YES;
            self.lcLackHeigh.constant = 0;
        }else{
            self.viewLack.hidden = NO;
            self.lcLackHeigh.constant = 53;
            [self.btnLack setTitle:self.tip forState:UIControlStateNormal];
        }
    }
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
        [self.sensorListTableView reloadData];
    }else{
        [self refreshSensorAfterReceiceRealTimeData];
    }
}

#pragma mark - method

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)chooseFloorButtonClick:(id)sender {
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.25
                     animations:^{
                         weakSelf.imageFloor.transform =  CGAffineTransformRotate(weakSelf.imageFloor.transform, M_PI);
                     } completion:^(BOOL finished) {
                         PopoverView *popoverView = [PopoverView popoverView];
                         popoverView.arrowStyle = PopoverViewArrowStyleTriangle;
                         popoverView.showShade = YES;
                         popoverView.seleNumber = weakSelf.seleNumber;
                         [popoverView showToView:weakSelf.lblFloor isLeftPic:NO isTitleLabelCenter:NO withActions:weakSelf.actionArray hideBlock:^{
                             [UIView animateWithDuration:0.25 animations:^{
                                 weakSelf.imageFloor.transform =  CGAffineTransformRotate(weakSelf.imageFloor.transform, M_PI);
                             }];
                         }];
                     }];
}

#pragma mark - UITableViewDataSource
- (void)tzm_scrollViewRefresh:(UIScrollView *)scrollView refreshControl:(TZMPullToRefresh *)refreshControl{
    [self refreshSensor];
    __weak typeof(self)weakself = self;
    if (GSHNetworkTypeLAN == [GSHWebSocketClient shared].networkType) {
        return;
    }
    [GSHFamilyManager getFamilyIndexWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSDictionary *familyIndex, NSError *error) {
        weakself.familyIndex = [NSMutableDictionary dictionaryWithDictionary:familyIndex];
        [weakself refreshFamilyIndexUI];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sensorList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHSensorCell *sensorCell = [tableView dequeueReusableCellWithIdentifier:@"sensorCell" forIndexPath:indexPath];
    if (self.sensorList.count > indexPath.row) {
        sensorCell.model = self.sensorList[indexPath.row];
    }
    return sensorCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHSensorCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell.model.deviceId) {
        return nil;
    }
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        [TZMProgressHUDManager showInfoWithStatus:@"离线环境无法查看" inView:self.view];
        return nil;
    }
    [self.navigationController pushViewController:[GSHSensorDetailVC sensorDetailVCWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId sensor:[cell.model yy_modelCopy]] animated:YES];
    return nil;
}

#pragma mark - 刷新传感器列表状态
- (void)refreshSensorAfterReceiceRealTimeData{
    NSArray *sensorList = [self.sensorList copy];
    for (GSHSensorM *sensorM in sensorList) {
        NSDictionary *dic = [sensorM realTimeDic];
        if (dic) {
            if ([sensorM.deviceType isEqualToNumber:GSHHumitureSensorDeviceType] &&
                ([dic objectForKey:GSHHumitureSensor_temMeteId] || [dic objectForKey:GSHHumitureSensor_humMeteId])) {
                // 温湿度
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHHumitureSensor_temMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHHumitureSensor_temMeteId];
                    } else if ([monitorM.basMeteId isEqualToString:GSHHumitureSensor_humMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHHumitureSensor_humMeteId];
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHGateMagetismSensorDeviceType] && [dic objectForKey:GSHGateMagetismSensor_isOpenedMeteId]) {
                // 门磁
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHGateMagetismSensor_isOpenedMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHGateMagetismSensor_isOpenedMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType] && [dic objectForKey:GSHAirBoxSensor_pmMeteId]) {
                // 空气盒子
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHAirBoxSensor_pmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHAirBoxSensor_pmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType] && [dic objectForKey:GSHSomatasensorySensor_alarmMeteId]) {
                // 人体红外
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHSomatasensorySensor_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHSomatasensorySensor_alarmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHGasSensorDeviceType] && [dic objectForKey:GSHGasSensor_alarmMeteId]) {
                // 烟雾传感器
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHGasSensor_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHGasSensor_alarmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHCoGasSensorDeviceType] && [dic objectForKey:GSHCoGasSensor_alarmMeteId]) {
                // 一氧化碳传感器
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHCoGasSensor_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHCoGasSensor_alarmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHCombustibleGasDeviceType] && [dic objectForKey:GSHCombustibleGas_alarmMeteId]) {
                // 可燃气体传感器
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHCombustibleGas_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHCombustibleGas_alarmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType] && [dic objectForKey:GSHWaterLoggingSensor_alarmMeteId]) {
                // 水浸传感器
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHWaterLoggingSensor_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHWaterLoggingSensor_alarmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHSOSSensorDeviceType] && [dic objectForKey:GSHSOSSensor_alarmMeteId]) {
                // 紧急按钮
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHSOSSensor_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHSOSSensor_alarmMeteId];
                        break;
                    }
                }
            } else if ([sensorM.deviceType isEqualToNumber:GSHInfrareCurtainDeviceType] && [dic objectForKey:GSHInfrareCurtain_alarmMeteId]) {
                // 红外幕帘
                for (GSHSensorMonitorM *monitorM in sensorM.attributeList) {
                    if ([monitorM.basMeteId isEqualToString:GSHInfrareCurtain_alarmMeteId]) {
                        monitorM.valueString = [dic objectForKey:GSHInfrareCurtain_alarmMeteId];
                        break;
                    }
                }
            }
        }
    }
    self.sensorList = [NSMutableArray arrayWithArray:sensorList];
    [self.sensorListTableView reloadData];
}

- (IBAction)touchLackSensor:(id)sender {
    GSHLackSensorListVC *vc = [GSHLackSensorListVC lackSensorListVCWithList:self.lackSensorList];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
