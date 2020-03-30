//
//  GSHShengBiKeSearchVC.m
//  SmartHome
//
//  Created by gemdale on 2019/12/16.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHShengBiKeSearchVC.h"
#import "GSHScanAnimationView.h"
#import <JdPlaySdk/JdPlaySdk.h>
#import "GSHAlertManager.h"
#import "GSHShengBiKeListVC.h"

@interface GSHShengBiKeSearchVC ()
@property(nonatomic,strong)GSHDeviceModelM *category;
- (IBAction)touchSearch:(UIButton *)sender;
- (IBAction)touchNext:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *viewNoData;
@property (weak, nonatomic) IBOutlet GSHScanAnimationView *viewSearch;
@property (weak, nonatomic) IBOutlet UIButton *watchButton;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;

@property (nonatomic,strong) NSMutableArray *deviceArray;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) int showIndex;

@property (nonatomic,strong)JdDeviceListPresenter *jdDeviceListPresenter;
@end

@implementation GSHShengBiKeSearchVC
+(instancetype)shengBiKeSearchVCWithGategory:(GSHDeviceModelM*)category{
    GSHShengBiKeSearchVC *vc = [GSHPageManager viewControllerWithSB:@"ShengBiKeSB" andID:@"GSHShengBiKeSearchVC"];
    vc.category = category;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.watchButton.hidden = YES;
    self.showIndex = 0;
    [JdShareClass sharedInstance];
    self.jdDeviceListPresenter = [JdDeviceListPresenter sharedManager];
    [self startSearch];
}

-(void)dealloc{
    if (_timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (NSMutableArray *)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray array];
    }
    return _deviceArray;
}

- (NSTimer *)timer {
    if (!_timer) {
        __weak typeof(self) weakSelf = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:5 block:^(NSTimer * _Nonnull timer) {
            NSArray *list = [NSArray arrayWithArray:weakSelf.jdDeviceListPresenter.deviceListArr];
            for (JdDeviceInfo *obj in list) {
                if ([obj isKindOfClass:JdDeviceInfo.class]) {
                    BOOL add = YES;
                    if ([obj.hardwareVersion.model rangeOfString:@"B5"].location == NSNotFound) {
                        add = NO;
                    }else{
                        for (GSHDeviceM *device in weakSelf.deviceArray) {
                            if (obj.uuid && [device.deviceSn isEqualToString:obj.uuid]) {
                                add = NO;
                            }
                        }
                    }
                    if (add) {
                        GSHDeviceM *device = [GSHDeviceM new];
                        device.deviceSn = obj.uuid;
                        device.hardModel = obj.hardwareVersion.model;
                        device.firmwareVersion = obj.softwareVersion.releaseV;
                        device.manufacturer = @"声必可";
                        device.agreementType = @"wifi";
                        device.deviceType = weakSelf.category.deviceType;
                        device.deviceModel = weakSelf.category.deviceModel;
                        device.deviceModelStr = weakSelf.category.deviceModelStr;
                        device.deviceTypeStr = weakSelf.category.deviceTypeStr;
                        device.homePageIcon = weakSelf.category.homePageIcon;
                        [weakSelf.deviceArray addObject:device];
                    }
                }
            }
            NSString *showStr = [NSString stringWithFormat:@"已搜索到%d台新设备",(int)weakSelf.deviceArray.count];
            weakSelf.showLabel.text = showStr;
            weakSelf.watchButton.hidden = weakSelf.deviceArray.count == 0;
        } repeats:YES];
    }
    return _timer;
}

-(void)startSearch{
    [self.timer setFireDate:[NSDate distantPast]];
    [self performSelector:@selector(stopSearch) withObject:nil afterDelay:60];
}

-(void)stopSearch{
    [self.timer setFireDate:[NSDate distantFuture]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopSearch) object:nil];
    if (self.deviceArray.count > 0) {
        GSHShengBiKeListVC *vc = [GSHShengBiKeListVC shengBiKeListVCWithDeviceList:self.deviceArray];
        NSMutableArray *vcs = [NSMutableArray array];
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:GSHShengBiKeSearchVC.class]) {
                break;
            }
            [vcs addObject:vc];
        }
        [vcs addObject:vc];
        [self.navigationController setViewControllers:vcs animated:YES];
    }else{
        self.viewNoData.hidden = NO;
    }
}

#pragma mark - DeviceListView
- (IBAction)touchSearch:(UIButton *)sender {
    self.viewNoData.hidden = YES;
    [self startSearch];
}

- (IBAction)touchNext:(UIButton *)sender {
    [self stopSearch];
}
@end
