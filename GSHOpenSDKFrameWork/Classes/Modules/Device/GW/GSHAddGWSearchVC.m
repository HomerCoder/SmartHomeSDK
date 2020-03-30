//
//  GSHAddGWSearchVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAddGWSearchVC.h"
#import "GSHAddGWListVC.h"
#import "GSHScanAnimationView.h"
#import "GSHAddGWListVC.h"
#import "GSHAlertManager.h"

@interface GSHAddGWSearchVC ()

@property (weak,nonatomic) IBOutlet GSHScanAnimationView *animationView;
@property (weak,nonatomic) IBOutlet UIButton *watchButton;
@property (weak,nonatomic) IBOutlet UILabel *showLabel;

@property (strong,nonatomic) NSMutableArray<NSDictionary*> *gwSearchArray;
@property (strong,nonatomic) GSHFamilyM *family;
@property (strong,nonatomic) NSTimer *requestTimer;
@property (nonatomic,assign) int searchCount;

@property (strong,nonatomic) GSHAsyncUdpSocketTask *socketTask;
@property(strong,nonatomic)GSHDeviceModelM *model;
@end

@implementation GSHAddGWSearchVC

+ (instancetype)addGWSearchVCWithFamily:(GSHFamilyM*)family deviceModel:(GSHDeviceModelM*)model{
    GSHAddGWSearchVC *vc = [GSHPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHAddGWSearchVC"];
    vc.family = family;
    vc.model = model;
    return vc;
}

-(void)dealloc {
    if (_requestTimer) {
        [self.requestTimer invalidate];
        _requestTimer = nil;
    }
}

- (NSMutableArray<NSDictionary *> *)gwSearchArray{
    if (!_gwSearchArray) {
        _gwSearchArray = [NSMutableArray array];
    }
    return _gwSearchArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchCount = 0;
    [self.requestTimer setFireDate:[NSDate distantPast]];
    [self searchGateWay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.socketTask.state != GSHAsyncUdpSocketTaskStateCanceled) {
        [self.socketTask cancel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy

- (NSTimer *)requestTimer {
    if (!_requestTimer) {
        @weakify(self)
        _requestTimer = [NSTimer scheduledTimerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            [self judgeIsPushGwListVC];
        } repeats:YES];
    }
    return _requestTimer;
}

#pragma mark - request
// 搜索网关
- (void)searchGateWay {
    __weak typeof(self)weakSelf = self;
    [[GSHAsyncUdpSocketClient shared] sendGWSearchMsgWithsendHandler:^(NSError *error) {
    } receiveHandler:^BOOL(NSDictionary *gwDic, NSError *error) {
        if (gwDic) {
            NSLog(@"----gwDic---%@",gwDic);
            NSString *gwId = [gwDic stringValueForKey:@"gwId" default:nil];
            NSString *deviceModel = [gwDic stringValueForKey:@"deviceModel" default:nil];
            if (deviceModel && weakSelf.model.deviceModelStr && (![weakSelf.model.deviceModelStr isEqualToString:deviceModel])) {
                return NO;
            }

            if (gwId && ![weakSelf isAddedIntoSearchArrayWIthGateWayId:gwId]) {
                @synchronized (weakSelf.gwSearchArray) {
                    [weakSelf.gwSearchArray addObject:gwDic];
                }
            }
        }
        return NO;
    }];
}

// 过滤已加入数组的网关
- (BOOL)isAddedIntoSearchArrayWIthGateWayId:(NSString *)gateWayId {
    BOOL isAdded = NO;
    for (NSDictionary *gwDic in self.gwSearchArray) {
        NSString *gwId = [gwDic stringValueForKey:@"gwId" default:nil];
        if ([gwId isEqualToString:gateWayId]) {
            isAdded = YES;
            break;
        }
    }
    return isAdded;
}

#pragma mark - method
- (IBAction)watchButtonClick:(id)sender {
    @weakify(self)
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        @strongify(self)
        if (buttonIndex == 1) {
            [self pushGWListVC];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确定取消搜索，查看新网关?" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
}

- (void)judgeIsPushGwListVC {
    if (self.gwSearchArray.count > 0) {
        self.watchButton.hidden = NO;
        NSString *showStr = [NSString stringWithFormat:@"已搜索到%d台新网关",(int)self.gwSearchArray.count];
        self.showLabel.text = showStr;
    }
    
    if (self.searchCount % 3 == 2) {
        if (self.socketTask.state != GSHAsyncUdpSocketTaskStateCanceled) {
            [self.socketTask cancel];
        }
        [self searchGateWay];
    }
    
    if (self.searchCount >= 60) {
        // 搜索超过60秒，若搜索到网关自动跳转到网关列表页面
        if (self.gwSearchArray.count > 0) {
            [self pushGWListVC];
        } else {
            [self.requestTimer setFireDate:[NSDate distantFuture]];
            @weakify(self)
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                @strongify(self)
                if (buttonIndex == 1) {
                    self.searchCount = 0;
                    [self.requestTimer setFireDate:[NSDate distantPast]];
                    [self searchGateWay];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"没有搜索到网关" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"重新搜索",nil];
        }
    }
    self.searchCount ++;
    NSLog(@"searchCount : %d",self.searchCount);
}

-(void)pushGWListVC{
    NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if ([vcs.lastObject isKindOfClass:GSHAddGWSearchVC.class]) {
        [vcs removeObject:vcs.lastObject];
    }
    for (NSDictionary *dic in self.gwSearchArray) {
        [dic setValue:self.model.homePageIcon forKey:@"image"];
    }
    [vcs addObject:[GSHAddGWListVC addGWListVCWithGWList:self.gwSearchArray family:self.family deviceModel:self.model]];
    [self.navigationController setViewControllers:vcs animated:YES];
}

@end
