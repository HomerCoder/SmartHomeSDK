//
//  GSHDeviceSearchVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/5.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDeviceSearchVC.h"
#import "GSHDeviceChooseVC.h"
#import "GSHScanAnimationView.h"
#import "GSHAlertManager.h"

@interface GSHDeviceSearchVC ()
@property (weak, nonatomic) IBOutlet GSHScanAnimationView *viewSearch;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (weak, nonatomic) IBOutlet UIButton *watchButton;

@property (nonatomic, strong) GSHDeviceModelM *model;
@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSTimer *showTimer;
@property (nonatomic,assign) int showIndex;
@property (nonatomic,assign) __block int requestCount;

@property (nonatomic,strong) NSString *deviceSn;

@property (nonatomic,strong) NSURLSessionDataTask *openTask;
@property (nonatomic,strong) NSURLSessionDataTask *searchTask;

@end

@implementation GSHDeviceSearchVC
+(instancetype)deviceSearchVCWithDeviceCategory:(GSHDeviceModelM*)model deviceSn:(NSString *)deviceSn {
    GSHDeviceSearchVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddDeviceSB" andID:@"GSHDeviceSearchVC"];
    vc.model = model;
    vc.deviceSn = deviceSn;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startSearch];
    
    self.watchButton.hidden = YES;
    self.showIndex = 0;
    self.requestCount = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.openTask cancel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldHoldBackButtonEvent {
    return YES;
}

- (BOOL)canPopViewController {
    [self stopSearch];
    [self.navigationController popViewControllerAnimated:YES];
    return NO;
}

-(void)dealloc {
    
    if (_timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (_showTimer) {
        [self.showTimer invalidate];
        self.showTimer = nil;
    }
}

#pragma mark - Lazy

- (NSMutableArray *)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray array];
    }
    return _deviceArray;
}

- (NSTimer *)showTimer {
    if (!_showTimer) {
        __weak typeof(self) weakSelf = self;
        _showTimer = [NSTimer scheduledTimerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf showDeviceListVC];
        } repeats:YES];
    }
    return _showTimer;
}

- (NSTimer *)timer {
    if (!_timer) {
        __weak typeof(self) weakSelf = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:5 block:^(NSTimer * _Nonnull timer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf getDiscoveryDevices];
        } repeats:YES];
    }
    return _timer;
}

#pragma mark - method
// 查看新设备
- (IBAction)watchButtonClick:(id)sender {
    @weakify(self)
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        @strongify(self)
        if (buttonIndex == 1) {
            [self stopSearch];
            [self jumpToDeviceChooseVCWithDeviceList:self.deviceArray];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确定取消搜索，查看新设备?" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    
}

- (void)jumpToDeviceChooseVCWithDeviceList:(NSMutableArray<GSHDeviceM*>*)deviceList{
    GSHDeviceChooseVC *deviceChooseVC = [GSHDeviceChooseVC deviceChooseVCWithDeviceList:deviceList];
    NSMutableArray *vcs = [NSMutableArray array];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:GSHDeviceSearchVC.class]) {
            break;
        }
        [vcs addObject:vc];
    }
    [vcs addObject:deviceChooseVC];
    [self.navigationController setViewControllers:vcs animated:YES];
}

// 开组网
- (void)startSearch {
    
    @weakify(self)
    self.openTask = [GSHDeviceManager searchDevicesWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId
                                               scanStatus:@"1"
                                                 deviceSn:self.deviceSn
                                                    block:^(NSError *error) {
                        @strongify(self)
                        if (error) {
                            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
                            [self.navigationController popViewControllerAnimated:YES];
                        } else {
                            [self startToGetDiscoveryDevices];
                        }
                    }];
}

// 关闭组网
- (void)stopSearch {
    [GSHDeviceManager searchDevicesWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId
                               scanStatus:@"0"
                                 deviceSn:self.deviceSn
                                    block:^(NSError *error) {}];
}

- (void)startToGetDiscoveryDevices {

    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)getDiscoveryDevices {
    
    if (self.requestCount >= 12) {
        if (self.deviceArray.count > 0) {
            [self jumpToDeviceChooseVCWithDeviceList:self.deviceArray];
        } else {
            [self.timer setFireDate:[NSDate distantFuture]];
            @weakify(self)
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                @strongify(self)
                if (buttonIndex == 1) {
                    self.requestCount = 0;
                    [self startSearch];
                } else {
                    [self stopSearch];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"没有搜索到设备" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"重新搜索",nil];
            
        }
    } else {
        @weakify(self)
        [GSHDeviceManager getDiscoveryDevicesWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSArray<GSHDeviceM *> *list, NSError *error) {
            @strongify(self)
            if (!error) {
                if (list.count > self.deviceArray.count) {
                    [self.deviceArray removeAllObjects];
                    [self.deviceArray addObjectsFromArray:list];
                    [self showDiscoveryDevice];
                }
            }
        }];
    }
    self.requestCount ++;
}

- (void)showDiscoveryDevice {
        
    self.watchButton.hidden = NO;
    if (self.showIndex < self.deviceArray.count) {
        [self.showTimer setFireDate:[NSDate distantPast]];
    }
    
}

- (void)showDeviceListVC {
    NSString *showStr = [NSString stringWithFormat:@"已搜索到%d台新设备",self.showIndex];
    self.showLabel.text = showStr;
    if (self.showIndex < self.deviceArray.count) {
        self.showIndex ++;
    } else {
        [self.showTimer setFireDate:[NSDate distantFuture]];
    }
}

@end
