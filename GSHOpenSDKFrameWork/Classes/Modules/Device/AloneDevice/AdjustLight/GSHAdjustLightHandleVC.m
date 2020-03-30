//
//  GSHAdjustLightHandleVC.m
//  SmartHome
//
//  Created by gemdale on 2019/10/11.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAdjustLightHandleVC.h"
#import <UINavigationController+TZM.h>
#import "TZMSlider.h"
#import "GSHDeviceEditVC.h"
#import "GSHAdjustLightSetVC.h"

@interface GSHAdjustLightHandleVC ()
@property(nonatomic,assign)BOOL isOpen;

@property(nonatomic,assign)NSInteger seWenMin;
@property(nonatomic,assign)NSInteger seWenMax;
@property(nonatomic,assign)NSInteger seWen;
@property(nonatomic,assign)NSInteger light;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelList;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonList;
@property (weak, nonatomic) IBOutlet UIButton *btnOpen;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet TZMSlider *sliderLiangDu;
@property (weak, nonatomic) IBOutlet TZMSlider *sliderSeWen;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
- (IBAction)changeLight:(UISlider *)sender;
- (IBAction)changeSeWen:(TZMSlider *)sender;
- (IBAction)goDetail:(UIButton *)sender;
- (IBAction)touchModel:(UIButton *)sender;
- (IBAction)touchOpen:(UIButton *)sender;
@end

@implementation GSHAdjustLightHandleVC
+(instancetype)adjustLightHandleVCWithDevice:(GSHDeviceM*)device{
    GSHAdjustLightHandleVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAdjustLight" andID:@"GSHAdjustLightHandleVC"];
    vc.deviceM = device;
    vc.deviceEditType = GSHDeviceVCTypeControl;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)setIsOpen:(BOOL)isOpen{
    _isOpen = isOpen;
    self.btnOpen.selected = !isOpen;
    self.sliderSeWen.isClose = !isOpen;
    self.sliderLiangDu.isClose = !isOpen;
    if (isOpen) {
        for (UIButton *but in self.buttonList) {
            but.enabled = YES;
        }
    }else{
        for (UIButton *but in self.buttonList) {
            but.enabled = NO;
        }
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tzm_prefersNavigationBarHidden = YES;
    
    self.seWenMin = 2700;
    self.seWenMax = 6500;
    self.seWen = 2700;
    self.light = 1;
    self.sliderSeWen.isGradual = YES;
    
    [self refreshUI];
    [self observerNotifications];
}

-(void)observerNotifications{
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification]) {
        [self refreshUI];
    }
}

- (void)refreshUI {
    self.lblTitle.text = self.deviceM.deviceName;
    NSDictionary *realTimeDict = [self.deviceM realTimeDic];
    NSString *off = [realTimeDict objectForKey:GSHAdjustLight_offMeteId];
    NSString *wenSe = [realTimeDict objectForKey:GSHAdjustLight_wenSeMeteId];
    NSString *light = [realTimeDict objectForKey:GSHAdjustLight_lightMeteId];
    
    self.isOpen = off.intValue;
    if (wenSe) {
        self.seWen = wenSe.intValue;
    }
    self.light = light.intValue;
    self.sliderLiangDu.value = (CGFloat)self.light / 100.0;
    self.sliderSeWen.value = (CGFloat)(self.seWen - self.seWenMin) / (CGFloat)(self.seWenMax - self.seWenMin);
    self.lblContent.text = [NSString stringWithFormat:@"色温：%dk | 亮度：%d%%",(int)self.seWen,(int)self.light];
}

- (void)handelWithOpen{
    [self controlUnderFloorHeatWithBasMeteId:GSHAdjustLight_offMeteId value:self.isOpen ? @"1" : @"0" failBlock:^(NSError *error) {
    } successBlock:^{
    }];
}

- (void)handelWithWenSe{
    self.sliderSeWen.value = (CGFloat)(self.seWen - self.seWenMin) / (CGFloat)(self.seWenMax - self.seWenMin);
    self.lblContent.text = [NSString stringWithFormat:@"色温：%dk | 亮度：%d%%",(int)self.seWen,(int)self.light];
    [self controlUnderFloorHeatWithBasMeteId:GSHAdjustLight_wenSeMeteId value:[NSString stringWithFormat:@"%d",(int)self.seWen] failBlock:^(NSError *error) {
    } successBlock:^{
    }];
}

- (void)handelWithLight{
    self.sliderLiangDu.value = (CGFloat)self.light / 100.0;
    self.lblContent.text = [NSString stringWithFormat:@"色温：%dk | 亮度：%d%%",(int)self.seWen,(int)self.light];
    [self controlUnderFloorHeatWithBasMeteId:GSHAdjustLight_lightMeteId value:[NSString stringWithFormat:@"%d",(int)self.light] failBlock:^(NSError *error) {
    } successBlock:^{
    }];
}

// 设备控制
- (void)controlUnderFloorHeatWithBasMeteId:(NSString *)basMeteId
                                     value:(NSString *)value
                                 failBlock:(void(^)(NSError *error))failBlock
                              successBlock:(void(^)(void))successBlock {
    [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue deviceSN:self.deviceM.deviceSn familyId:[GSHOpenSDKShare share].currentFamily.familyId basMeteId:basMeteId value:value block:^(NSError *error) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            if (error) {
                if (failBlock) {
                    failBlock(error);
                }
            } else {
                if (successBlock) {
                    successBlock();
                }
            }
        }
    }];
}

- (IBAction)changeLight:(UISlider *)sender {
    self.light = (NSInteger)(sender.value * 100);
    [self handelWithLight];
}

- (IBAction)changeSeWen:(TZMSlider *)sender {
    self.seWen = (sender.value * (self.seWenMax - self.seWenMin)) + self.seWenMin;
    [self handelWithWenSe];
}

- (IBAction)goDetail:(UIButton *)sender{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        [TZMProgressHUDManager showInfoWithStatus:@"离线环境无法查看" inView:self.view];
        return;
    }
    GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:self.deviceM type:GSHDeviceEditVCTypeEdit];
    __weak typeof(self)weakSelf = self;
    deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
        weakSelf.deviceM = deviceM;
        [weakSelf refreshUI];
    };
    [self closeWithComplete:^{
        [[UIViewController visibleTopViewController].navigationController pushViewController:deviceEditVC animated:YES];
    }];
}

- (IBAction)touchModel:(UIButton *)sender{
    GSHAdjustLightViewModel *model;
    switch (sender.tag) {
        case 1001:
            model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeYueDu];
            break;
        case 1002:
            model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeShengHuo];
            break;
        case 1003:
            model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeRouHe];
            break;
        case 1004:
            model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeYeDeng];
            break;
        case 1005:
            model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeWenXin];
            break;
        default:
            model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeMoRen];
            break;
    }
    self.light = model.liangDu;
    self.seWen = model.seWen;
    [self handelWithLight];
    [self handelWithWenSe];
}
- (IBAction)touchOpen:(UIButton *)sender{
    self.isOpen = !self.isOpen;
    [self handelWithOpen];
}
@end
