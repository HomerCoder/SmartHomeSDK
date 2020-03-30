//
//  GSHYingShiAlarmSoundModeVC.m
//  SmartHome
//
//  Created by gemdale on 2019/5/20.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHYingShiAlarmSoundModeVC.h"

@interface GSHYingShiAlarmSoundModeVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewGaoJing;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTiShi;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewJingYin;

@property(nonatomic,strong)NSMutableDictionary *ipc;
@property(nonatomic,strong)GSHDeviceM *device;
@end

@implementation GSHYingShiAlarmSoundModeVC

+(instancetype)yingShiAlarmSoundModeVCWithIPC:(NSMutableDictionary*)ipc device:(GSHDeviceM*)device{
    GSHYingShiAlarmSoundModeVC *vc =  [GSHPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingShiAlarmSoundModeVC"];
    vc.ipc = ipc;
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshUI];
}

-(void)refreshUI{
    self.imageViewTiShi.hidden = YES;
    self.imageViewGaoJing.hidden = YES;
    self.imageViewJingYin.hidden = YES;
    NSNumber *alarmSoundMode = [self.ipc numverValueForKey:@"alarmSoundMode" default:nil];
    if (alarmSoundMode == nil) {
        return;
    }
    switch (alarmSoundMode.intValue) {
        case GSHYingShiCameraMAlarmSoundModeTiShi:
            self.imageViewTiShi.hidden = NO;
            break;
        case GSHYingShiCameraMAlarmSoundModeGaoJing:
            self.imageViewGaoJing.hidden = NO;
            break;
        case GSHYingShiCameraMAlarmSoundModeJingYin:
            self.imageViewJingYin.hidden = NO;
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self seleAlarmSoundMode:GSHYingShiCameraMAlarmSoundModeGaoJing];
    }else if (indexPath.row == 1){
        [self seleAlarmSoundMode:GSHYingShiCameraMAlarmSoundModeTiShi];
    }else if (indexPath.row == 2){
        [self seleAlarmSoundMode:GSHYingShiCameraMAlarmSoundModeJingYin];
    }
    return nil;
}

-(void)seleAlarmSoundMode:(GSHYingShiCameraMAlarmSoundMode)model{
    NSNumber *alarmSoundMode = [self.ipc numverValueForKey:@"alarmSoundMode" default:nil];
    if (alarmSoundMode.intValue != model || alarmSoundMode == nil) {
        __weak typeof(self)weakSelf = self;
        [TZMProgressHUDManager showWithStatus:@"设置中" inView:self.view];
        [GSHYingShiManager postAlarmSoundModeWithDeviceSerial:weakSelf.device.deviceSn mode:model block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [weakSelf.ipc setValue:@(model) forKey:@"alarmSoundMode"];
                [weakSelf refreshUI];
            }
        }];
    }
}
@end
