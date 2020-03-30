//
//  GSHSensorDetailVC.m
//  SmartHome
//
//  Created by gemdale on 2018/11/13.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHSensorDetailVC.h"
#import "GSHDeviceEditVC.h"

@interface GSHSensorDetailVC ()
@property(nonatomic,strong)GSHSensorM *sensor;
@end

@implementation GSHSensorDetailVC

+(instancetype)sensorDetailVCWithFamilyId:(NSString*)familyId sensor:(GSHSensorM*)sensor{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    GSHUserM *user = [GSHUserManager currentUser];
    if (user.userId.length > 0) {
        [dic setValue:user.userId forKey:@"userId"];
    }
    if (user.sessionId.length > 0) {
        [dic setValue:user.sessionId forKey:@"sessionId"];
    }
    if (sensor.deviceType) {
        [dic setValue:sensor.deviceType forKey:@"deviceType"];
    }
    if (sensor.deviceId) {
        [dic setValue:sensor.deviceId forKey:@"deviceId"];
    }
    if (sensor.deviceSn) {
        [dic setValue:sensor.deviceSn forKey:@"deviceSn"];
    }
    if ([GSHOpenSDKShare share].currentFamily.familyId) {
        [dic setValue:[GSHOpenSDKShare share].currentFamily.familyId forKey:@"familyId"];
    }
    if ([GSHOpenSDKShare share].currentFamily) {
        [dic setValue:@([GSHOpenSDKShare share].currentFamily.permissions) forKey:@"familyPermission"];
    }
    GSHSensorDetailVC *vc = [[GSHSensorDetailVC alloc]initWithURL:[GSHWebViewController webUrlWithType:GSHAppConfigH5TypeSensor parameter:dic]];
    vc.sensor = sensor;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = self.sensor.deviceName;
}

-(void)enterEditDevice:(NSDictionary *)dic{
    GSHDeviceM *deviceM = self.sensor;
    GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:deviceM type:GSHDeviceEditVCTypeEdit];
    __weak typeof(self)weakSelf = self;
    deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
//        weakSelf.lblWhiteTitle.text = deviceM.deviceName;
//        weakSelf.lblBlackTitle.text = deviceM.deviceName;
        weakSelf.sensor.deviceName = deviceM.deviceName;
        if (deviceM.floorName.length > 0) {
            weakSelf.sensor.floorName = deviceM.floorName;
        }
        if (deviceM.roomName.length > 0) {
            weakSelf.sensor.roomName = deviceM.roomName;
        }
    };
    [self.navigationController pushViewController:deviceEditVC animated:YES];

}

@end
