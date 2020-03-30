//
//  GSHHomeRoomVC.m
//  SmartHome
//
//  Created by gemdale on 2018/11/1.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHHomeRoomVC.h"
#import "UIScrollView+TZMRefreshAndLoadMore.h"
#import "UINavigationController+TZM.h"
#import "UIView+TZM.h"

#import "GSHDeviceCategoryVC.h"
#import "GSHYingShiCameraVC.h"

#import "GSHDeviceMachineViewModel.h"
#import "SDCycleScrollView.h"
#import "GSHWebViewController.h"
#import "GSHShengBiKePlayVC.h"
#import <JdPlaySdk/JdPlaySdk.h>

@interface GSHHomeRoomVCErrorCell()
@property (weak, nonatomic) IBOutlet TZMRefreshView *refreshView;
@end
@implementation GSHHomeRoomVCErrorCell
@end

@interface GSHHomeRoomVCAddDeviceCell1()
@property (weak, nonatomic) IBOutlet UIImageView *imageAdd;
@property (weak, nonatomic) IBOutlet UILabel *lblAdd;
@end
@implementation GSHHomeRoomVCAddDeviceCell1
@end

@interface GSHHomeRoomVCAddDeviceCell2()
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
- (IBAction)touchAddDevice:(UIButton *)sender;
@end
@implementation GSHHomeRoomVCAddDeviceCell2
- (IBAction)touchAddDevice:(UIButton *)sender {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 离线模式
        [TZMProgressHUDManager showErrorWithStatus:@"离线模式无法添加设备" inView:self.viewController.view];
        return;
    }
    if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsManager) {
        GSHDeviceCategoryVC *vc = [GSHDeviceCategoryVC deviceCategoryVC];
        vc.hidesBottomBarWhenPushed = YES;
        [self.tzm_navigationController pushViewController:vc animated:YES];
    }
}
@end

@interface GSHHomeRoomVCBannerCell()<SDCycleScrollViewDelegate>
@property(nonatomic,strong)NSArray *list;
@property(nonatomic,strong)SDCycleScrollView *cycleScrollView;
@end
@implementation GSHHomeRoomVCBannerCell
-(instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        // 网络加载 --- 创建自定义图片的pageControlDot的图片轮播器
        self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:nil];
        self.cycleScrollView.autoScroll = NO;
        [self.contentView addSubview:self.cycleScrollView];
        __weak typeof(self)weakSelf = self;
        [self.cycleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.contentView);
        }];
    }
    return self;
}
-(void)setList:(NSArray *)list{
    _list = list;
    if ([list.firstObject isKindOfClass:GSHSceneM.class]) {
        NSMutableArray *imageList = [NSMutableArray array];
        NSMutableArray *titleList = [NSMutableArray array];
        NSMutableArray *imageUrlList = [NSMutableArray array];
        for (GSHSceneM *s in list) {
            UIImage *image = [GSHSceneM getHomeSceneBackgroundImageWithId:s.backgroundId.intValue];
            if (!image) {
                image = [UIImage imageWithColor:[UIColor clearColor]];
            }
            [imageList addObject:image];
            
            NSString *imageUrl = s.picUrl;
            if (!imageUrl) {
                imageUrl = @"";
            }
            [imageUrlList addObject:imageUrl];
            
            if (s.scenarioName) {
                [titleList addObject:s.scenarioName];
            }else{
                [titleList addObject:@""];
            }
        }
        self.cycleScrollView.localizationImageNamesGroup = imageList;
        self.cycleScrollView.titlesGroup = titleList;
        self.cycleScrollView.imageURLStringsGroup = imageUrlList;
    }else if ([list.firstObject isKindOfClass:GSHBannerM.class]){
        NSMutableArray *imageList = [NSMutableArray array];
        NSMutableArray *titleList = [NSMutableArray array];
        for (GSHBannerM *s in list) {
            NSString *imageUrl = s.picUrl;
            if (!imageUrl) {
                imageUrl = @"";
            }
            [imageList addObject:imageUrl];
            [titleList addObject:@""];
        }
        self.cycleScrollView.imageURLStringsGroup = imageList;
        self.cycleScrollView.titlesGroup = titleList;
    }
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    if (index < self.list.count) {
        id model = self.list[index];
        if ([model isKindOfClass:GSHSceneM.class]) {
            GSHSceneM *sceneM = model;
            [TZMProgressHUDManager showWithStatus:@"执行中" inView:self.viewController.view];
            __weak typeof(self) weakSelf = self;
            [GSHSceneManager executeSceneWithFamilyId:sceneM.familyId.stringValue gateWayId:[GSHOpenSDKShare share].currentFamily.gatewayId scenarioId:sceneM.scenarioId.stringValue block:^(NSError * _Nonnull error) {
                if (error) {
                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.viewController.view];
                } else {
                    [TZMProgressHUDManager showSuccessWithStatus:@"执行成功" inView:weakSelf.viewController.view];
                }
            }];
            return;
        }
        if ([model isKindOfClass:GSHBannerM.class]) {
            GSHBannerM *banner = model;
            if (banner.content && [banner.content rangeOfString:@"http"].location != NSNotFound) {
                GSHWebViewController *vc = [[GSHWebViewController alloc] initWithURL:[NSURL URLWithString:banner.content]];
                vc.hidesBottomBarWhenPushed = YES;
                [self.viewController.navigationController pushViewController:vc animated:YES];
            }
            return;
        }
    }
}

- (Class)customCollectionViewCellClassForCycleScrollView:(SDCycleScrollView *)view{
    return UICollectionViewCell.class;
}

- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index cycleScrollView:(SDCycleScrollView *)view{
    UIImageView *imageView = [cell.contentView viewWithTag:1001];
    UILabel *lable = [cell.contentView viewWithTag:1002];
    if (!imageView) {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, cell.contentView.size.width, cell.contentView.size.height)];
        imageView.tag = 1001;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imageView];
    }
    if (!lable) {
        lable = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, cell.contentView.size.width - 32, cell.contentView.size.height)];
        lable.tag = 1002;
        lable.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        lable.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:lable];
    }
    if (view.imageURLStringsGroup.count > index && [view.imageURLStringsGroup[index] length] > 0) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:view.imageURLStringsGroup[index]] placeholderImage:nil];
    }else{
        if (view.localizationImageNamesGroup.count > index) {
            imageView.image = view.localizationImageNamesGroup[index];
        }
    }
    if (view.titlesGroup.count > index) {
        lable.text = view.titlesGroup[index];
    }
}
@end

@interface GSHHomeRoomVCDeviceCell()
@property(nonatomic,strong)GSHDeviceM *model;
@property (weak, nonatomic) IBOutlet UIView *viewDot;
@property (weak, nonatomic) IBOutlet UIImageView *imageDeviceIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *roomName;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@end
@implementation GSHHomeRoomVCDeviceCell
-(void)setModel:(GSHDeviceM *)model{
    _model = model;
    self.lblName.text = model.deviceName;
    self.roomName.text = [NSString stringWithFormat:@" %@ ",model.roomName.length > 0 ? model.roomName : @""];
    [self.imageDeviceIcon sd_setImageWithURL:[NSURL URLWithString:model.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
    if ([model.deviceType isEqualToNumber:GSHYingShiSheXiangTou1DeviceType] || [model.deviceType isEqualToNumber:GSHYingShiSheXiangTou2DeviceType] || [model.deviceType isEqualToNumber:GSHYingShiMaoYanDeviceType]) {
        if (model.onlineStatus.integerValue != 1) {
            self.lblValue.text = @"离线";
            self.viewDot.backgroundColor = [UIColor colorWithRGB:0xF64A4A];
            self.contentView.alpha = 0.4;
        }else{
            if (model.defence.integerValue == 1) {
                self.lblValue.text = @"活动监测中";
            }else{
                self.lblValue.text = @"在线";
            }
            self.viewDot.backgroundColor = [UIColor colorWithRGB:0x07D18A];
            self.contentView.alpha = 1;
        }
    }else if ([model.deviceType isEqualToNumber:GSHShengBiKeDeviceType]) {
        self.lblValue.text = @"";
        self.viewDot.backgroundColor = [UIColor clearColor];
        self.contentView.alpha = 1;
    } else {
        if ([GSHOpenSDKShare share].currentFamily.onlineStatus == GSHFamilyMGWStatusOffLine) {
            // 网关离线 -- 所有设备离线
            self.lblValue.text = @"离线";
            model.onlineStatus = @(0);
            self.viewDot.backgroundColor = [UIColor colorWithRGB:0xF64A4A];
            self.contentView.alpha = 0.4;
        } else {
            // 网关在线
            NSDictionary *dic = [model realTimeDic];
            NSString *onLineValue = [dic objectForKey:GSHDeviceOnLineStateMeteId];
            if (onLineValue && onLineValue.integerValue == 0) {
                // 设备离线
                self.lblValue.text = @"离线";
                model.onlineStatus = @(0);
                self.viewDot.backgroundColor = [UIColor colorWithRGB:0xF64A4A];
                self.contentView.alpha = 0.4;
            } else {
                // 设备在线
                self.viewDot.backgroundColor = [UIColor colorWithRGB:0x07D18A];
                NSString *text = [GSHDeviceMachineViewModel getDeviceRealTimeStateStrWithDeviceType:self.model.deviceType.stringValue RealTimeDict:dic];
                self.lblValue.text = text.length > 0 ? text : @"在线";
                model.onlineStatus = @(1);
                self.contentView.alpha = 1;
            }
        }
    }
}
@end

@interface GSHHomeRoomVCCellModel : NSObject
@property(nonatomic,copy)NSString *cellName;
@property(nonatomic,strong)NSArray *data;
@property(nonatomic,assign)CGSize size;
@end
@implementation GSHHomeRoomVCCellModel
@end

@interface GSHHomeRoomVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (copy,nonatomic)NSString *familyId;
@property (strong,nonatomic)GSHRoomM *room;
@property (strong,nonatomic)GSHFloorM *floor;
@property (assign,nonatomic)NSArray *adList;
@property (strong,nonatomic)NSError *error;
@property (assign,nonatomic)BOOL loading;
@property (assign,nonatomic)NSInteger devicePageIndex;
@property (strong,nonatomic)NSMutableArray<GSHHomeRoomVCCellModel*> *cellList;
@property (assign, nonatomic)BOOL didLoad;
@end

@implementation GSHHomeRoomVC

+(instancetype)homeRoomVCWithFamilyId:(NSString*)familyId room:(GSHRoomM*)room floor:(GSHFloorM*)floor{
    GSHHomeRoomVC *vc = [GSHPageManager viewControllerWithSB:@"HomeSB" andID:@"GSHHomeRoomVC"];
    vc.room = room;
    if (!vc.room) {
        vc.room = [GSHRoomM new];
        vc.room.roomId = @(-1);
        vc.room.roomName = @"全部";
        vc.floor = floor;
    }
    vc.familyId = familyId;
    return vc;
}

-(void)dealloc{
    [self removeNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.didLoad = YES;
    // Do any additional setup after loading the view.
    self.tzm_prefersNavigationBarHidden = YES;
    self.cellList = [NSMutableArray array];
    self.collectionView.tzm_loadMoreControl.enabled = NO;
    [self refreshData];
    [self observerNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)observerNotifications{
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];     // websocket 实时数据更新
    [self observerNotification:GSHChangeNetworkManagerWebSocketOpenNotification];               // websocket 连接成功通知
    [self observerNotification:GSHChangeNetworkManagerWebSocketCloseNotification];              // websocket 连接失败
    [self observerNotification:GSHOpenSDKFamilyGatewayChangeNotification];                      // 网关替换中
    [self observerNotification:GSHOpenSDKDeviceUpdataNotification];                             // 设备更新（会带上一个数组，改动相关房间的roomId）
    [self observerNotification:GSHOpenSDKSceneUpdataNotification];                              // 场景更新（会带上一个数组，改动相关房间的roomId）
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification] ||
        [notification.name isEqualToString:GSHChangeNetworkManagerWebSocketOpenNotification] ||
        [notification.name isEqualToString:GSHChangeNetworkManagerWebSocketCloseNotification] ||
        [notification.name isEqualToString:GSHOpenSDKFamilyGatewayChangeNotification]) {
        [self.collectionView reloadData];
    }
    
    if ([notification.name isEqualToString:GSHOpenSDKDeviceUpdataNotification]) {
        if (self.room.roomId.intValue == -1) {
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN){
                self.devicePageIndex = 1;
            }
            [self refreshData];
        }else{
            NSArray *arr = notification.object;
            if ([arr isKindOfClass:NSArray.class]) {
                for (NSString *roomId in arr) {
                    if ([roomId isKindOfClass:NSString.class]) {
                        if ([self.room.roomId.stringValue isEqualToString:roomId]) {
                            [self refreshData];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    if ([notification.name isEqualToString:GSHOpenSDKSceneUpdataNotification]) {
        NSArray *arr = notification.object;
        if ([arr isKindOfClass:NSArray.class]) {
            for (NSString *roomId in arr) {
                if ([roomId isKindOfClass:NSString.class]) {
                    if ([self.room.roomId.stringValue isEqualToString:roomId]) {
                        [self refreshData];
                        break;
                    }
                }
            }
        }
    }
}

-(void)refreshData{
    __weak typeof(self)weakSelf = self;
    self.loading = YES;
    if (self.room) {
        [GSHDeviceManager getFamilyDeviceAndScenariosWithFamilyId:weakSelf.familyId roomId:weakSelf.room.roomId floorId:self.floor.floorId block:^(NSArray<GSHDeviceM *> *devices, NSArray<GSHSceneM *> *scenarios, NSError *error) {
            weakSelf.loading = NO;
            if (error) {
                weakSelf.error = error;
            }else{
                weakSelf.room.devices = [NSMutableArray arrayWithArray:devices];
                if ([scenarios.firstObject isKindOfClass:[GSHOssSceneM class]]) {
                    weakSelf.room.scenarios = [NSMutableArray array];
                    for (GSHOssSceneM *oss in scenarios) {
                        GSHSceneM *scene = [GSHSceneM new];
                        scene.scenarioName = oss.scenarioName;
                        scene.scenarioId = oss.scenarioId;
                        scene.picUrl = oss.backgroundUrl;
                        [weakSelf.room.scenarios addObject:scene];
                    }
                }else{
                    weakSelf.room.scenarios = [NSMutableArray arrayWithArray:scenarios];
                }
            }
            [weakSelf refreshCellList];
        }];
    }
}

-(void)refreshYingShiDeviceOnlineStatus{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
        __weak typeof(self)weakSelf = self;
        NSNumber *roomId = self.room.roomId;
        if (roomId.intValue == -1) {
            roomId = self.floor.floorId;
        }
        [GSHYingShiManager getDeviceOnlineStatusByRoom:roomId block:^(NSArray<NSDictionary*> *data, NSError *error) {
            BOOL change = NO;
            for (NSDictionary *dic in data) {
                for (GSHDeviceM *device in weakSelf.room.devices) {
                    if ([device.deviceType isEqualToNumber:GSHYingShiSheXiangTou1DeviceType] || [device.deviceType isEqualToNumber:GSHYingShiSheXiangTou2DeviceType] || [device.deviceType isEqualToNumber:GSHYingShiMaoYanDeviceType]) {
                        if ([device.deviceSn isEqualToString:[dic stringValueForKey:@"deviceSerial" default:@""]]) {
                            NSNumber *onlineStatus = [dic numverValueForKey:@"onlineStatus" default:nil];
                            NSNumber *defence = [dic numverValueForKey:@"defence" default:nil];
                            if (onlineStatus) {
                                if (![device.onlineStatus isEqualToNumber:onlineStatus]) {
                                    device.onlineStatus = onlineStatus;
                                    device.defence = defence;
                                    change = YES;
                                }
                            }
                        }
                    }
                }
            }
            [weakSelf.collectionView reloadData];
        }];
    }
}

-(void)refreshAdList:(NSArray<GSHBannerM*>*)adList{
    self.adList = adList;
    [self refreshCellList];
}

-(void)refreshCellList{
    if (!self.didLoad) {
        return;
    }
    [self.cellList removeAllObjects];
    if (self.adList.count > 0 && [GSHOpenSDKShare share].currentFamily.familyDevcieCount && [GSHOpenSDKShare share].currentFamily.familyDevcieCount.integerValue == 0) {
        GSHHomeRoomVCCellModel *model = [GSHHomeRoomVCCellModel new];
        model.cellName = @"bannerCell";
        model.data = self.adList;
        model.size = CGSizeMake(self.view.size.width - 32, (self.view.size.width - 32) / 343 * 150);
        [self.cellList addObject:model];
    }
    if (self.loading) {
        return;
    }
    if (self.room.scenarios.count > 0) {
        GSHHomeRoomVCCellModel *model = [GSHHomeRoomVCCellModel new];
        model.cellName = @"bannerCell";
        model.data = self.room.scenarios;
        model.size = CGSizeMake(self.view.size.width - 32, (self.view.size.width - 32) / 343 * 80);
        [self.cellList addObject:model];
    }
    if (self.room.devices.count > 0) {
        GSHHomeRoomVCCellModel *model = [GSHHomeRoomVCCellModel new];
        model.cellName = @"deviceCell";
        model.data = self.room.devices;
        model.size = CGSizeMake((self.view.size.width - 14) / 2, 135 + 10);
        [self.cellList addObject:model];
    }else{
        if (self.error) {
            GSHHomeRoomVCCellModel *model = [GSHHomeRoomVCCellModel new];
            model.cellName = @"errorCell";
            model.size = CGSizeMake(self.view.size.width - 32, 257);
            [self.cellList addObject:model];
        }else{
            if (self.room.roomId.integerValue != -1) {
                GSHHomeRoomVCCellModel *model = [GSHHomeRoomVCCellModel new];
                model.cellName = @"addDeviceCell2";
                model.size = CGSizeMake(self.view.size.width - 32, 358);
                [self.cellList addObject:model];
            }else{
                GSHHomeRoomVCCellModel *model = [GSHHomeRoomVCCellModel new];
                model.cellName = @"addDeviceCell1";
                model.size = CGSizeMake(self.view.size.width - 32, 200);
                [self.cellList addObject:model];
            }
        }
    }
    [self.collectionView reloadData];
}

#pragma mark - Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.cellList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.cellList.count > section && [self.cellList[section].cellName isEqualToString:@"deviceCell"]) {
        return self.cellList[section].data.count;
    }
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.cellList.count > indexPath.section) {
        __weak typeof(self)weakSelf = self;
        GSHHomeRoomVCCellModel *model = self.cellList[indexPath.section];
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:model.cellName forIndexPath:indexPath];
        if ([cell isKindOfClass:GSHHomeRoomVCDeviceCell.class]) {
            if (model.data.count > indexPath.row && [model.data[indexPath.row] isKindOfClass:GSHDeviceM.class]) {
                ((GSHHomeRoomVCDeviceCell*)cell).model = model.data[indexPath.row];
                ((GSHHomeRoomVCDeviceCell*)cell).roomName.hidden = self.room.roomId.integerValue != -1;
            }
        }else if ([cell isKindOfClass:GSHHomeRoomVCBannerCell.class]){
            ((GSHHomeRoomVCBannerCell*)cell).list = model.data;
        }else if ([cell isKindOfClass:GSHHomeRoomVCErrorCell.class]){
            ((GSHHomeRoomVCErrorCell*)cell).refreshView.block = ^{
                [weakSelf refreshData];
            };
            if (self.loading) {
                [((GSHHomeRoomVCErrorCell*)cell).refreshView startRefrsh];
            }else{
                [((GSHHomeRoomVCErrorCell*)cell).refreshView endRefrsh];
            }
            ((GSHHomeRoomVCErrorCell*)cell).refreshView.text = @"设备居然偷懒了";
        }else if ([cell isKindOfClass:GSHHomeRoomVCAddDeviceCell1.class]){
            ((GSHHomeRoomVCAddDeviceCell1*)cell).lblAdd.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember;
            ((GSHHomeRoomVCAddDeviceCell1*)cell).imageAdd.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember;
        }else if ([cell isKindOfClass:GSHHomeRoomVCAddDeviceCell2.class]){
            ((GSHHomeRoomVCAddDeviceCell2*)cell).btnAdd.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember;
        }
        return cell;
    }
    return [UICollectionViewCell new];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.cellList.count > indexPath.section) {
        GSHHomeRoomVCCellModel *model = self.cellList[indexPath.section];
        return model.size;
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    UIEdgeInsets insets = UIEdgeInsetsMake(8,16,8,16);
    if (self.cellList.count > section) {
        GSHHomeRoomVCCellModel *model = self.cellList[section];
        if ([model.cellName isEqualToString:@"deviceCell"]) {
            insets = UIEdgeInsetsMake(4,7,2,7);
        }
    }
    if (section == 0) {
        insets.top = insets.top + 8;
    }
    return insets;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:GSHHomeRoomVCDeviceCell.class]) {
        if (self.room.devices.count > indexPath.row) {
            GSHDeviceM *model = self.room.devices[indexPath.row];
            if ([model.deviceType isEqualToNumber:GSHYingShiMaoYanDeviceType] ||
                [model.deviceType isEqualToNumber:GSHYingShiSheXiangTou1DeviceType] ||
                [model.deviceType isEqualToNumber:GSHYingShiSheXiangTou2DeviceType]) {
                
                GSHYingShiCameraVC *vc = [GSHYingShiCameraVC yingShiCameraVCWithDevice:model];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [GSHDeviceMachineViewModel jumpToDeviceHandleVCWithVC:self deviceM:model deviceEditType:GSHDeviceVCTypeControl deviceSetCompleteBlock:NULL];
            }
        }
    }else if ([cell isKindOfClass:GSHHomeRoomVCBannerCell.class]){
    }else if ([cell isKindOfClass:GSHHomeRoomVCErrorCell.class]){
    }else if ([cell isKindOfClass:GSHHomeRoomVCAddDeviceCell1.class]){
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            // 离线模式
            [TZMProgressHUDManager showErrorWithStatus:@"离线模式无法添加设备" inView:self.view];
            return NO;
        }
        if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsManager) {
            GSHDeviceCategoryVC *vc = [GSHDeviceCategoryVC deviceCategoryVC];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if ([cell isKindOfClass:GSHHomeRoomVCAddDeviceCell2.class]){
    }
    return NO;
}

-(BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.room.roomId.intValue == -1 || [GSHOpenSDKShare share].currentFamily.permissions != GSHFamilyMPermissionsManager || [GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        return NO;
    }
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:GSHHomeRoomVCDeviceCell.class]) {
        return YES;
    }
    return NO;
}

- (NSIndexPath *)collectionView:(UICollectionView *)collectionView targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)originalIndexPath toProposedIndexPath:(NSIndexPath *)proposedIndexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:proposedIndexPath];
    if ([cell isKindOfClass:GSHHomeRoomVCDeviceCell.class]) {
        return proposedIndexPath;
    }
    return originalIndexPath;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath{
    GSHDeviceM *sourceDevice;
    GSHDeviceM *destinationDevice;
    if (self.cellList.count > sourceIndexPath.section) {
        GSHHomeRoomVCCellModel *model = self.cellList[sourceIndexPath.section];
        if ([model.cellName isEqualToString:@"deviceCell"]) {
            if (model.data.count > sourceIndexPath.row && [model.data[sourceIndexPath.row] isKindOfClass:GSHDeviceM.class]) {
                sourceDevice = model.data[sourceIndexPath.row];
            }
        }
    }
    if (self.cellList.count > destinationIndexPath.section) {
        GSHHomeRoomVCCellModel *model = self.cellList[destinationIndexPath.section];
        if ([model.cellName isEqualToString:@"deviceCell"]) {
            if (model.data.count > destinationIndexPath.row && [model.data[destinationIndexPath.row] isKindOfClass:GSHDeviceM.class]) {
                destinationDevice = model.data[destinationIndexPath.row];
            }
        }
    }
    if (sourceDevice && destinationDevice) {
        [self.room.devices removeObject:sourceDevice];
        [self.room.devices insertObject:sourceDevice atIndex:destinationIndexPath.row > self.room.devices.count ? self.room.devices.count : destinationIndexPath.row];
    }
    
    NSMutableArray *list = [NSMutableArray array];
    for (GSHDeviceM *device in self.room.devices) {
        if (device.globalId) {
            [list addObject:device.globalId];
        }
    }
    [GSHDeviceManager postHomeVCSortDeviceRoomId:self.room.roomId globalIdList:list block:^(NSError *error) {
        
    }];
}
@end
