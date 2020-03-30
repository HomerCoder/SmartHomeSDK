//
//  GSHDeviceCategoryVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/9/17.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDeviceCategoryVC.h"
#import "UIView+TZMPageStatusViewEx.h"

#import "GSHBlueRoundButton.h"

#import "GSHAddGWGuideVC.h"
#import "GSHDeviceCategoryGuideVC.h"
#import "GSHYingShiDeviceDetailVC.h"
#import "GSHQRCodeScanningVC.h"
#import "GSHDeviceModelListVC.h"
#import "GSHShengBiKeGuideVC.h"
#import "GSHAddGWApIntroVC.h"

#import "NSString+TZM.h"

@implementation GSHDeviceCategoryHeadView

@end

@implementation GSHDeviceSearchCell

@end

@implementation GSHDeviceCategoryCell

@end

@implementation GSHDeviceCategoryNameCell

@end

@interface GSHDeviceCategoryVC ()
<UITableViewDelegate,
UITableViewDataSource,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *leftTableView;
@property (strong, nonatomic) NSMutableArray *deviceKindArray;
@property (weak, nonatomic) IBOutlet UICollectionView *rightCollectionView;

@property (strong, nonatomic) NSMutableArray *searchDataArray;

@property (assign, nonatomic) NSInteger leftSelectIndex;
@property (strong, nonatomic) NSMutableArray *stateArray;

@property (weak, nonatomic) IBOutlet UIView *viewError;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet GSHBlueRoundButton *btnScanAgain;
@property (weak, nonatomic) IBOutlet UIButton *btnSele;

@property (strong, nonatomic) GSHDeviceModelM *seleDeviceModelM;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;

@end

@implementation GSHDeviceCategoryVC

+(instancetype)deviceCategoryVC {
    GSHDeviceCategoryVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddDeviceSB" andID:@"GSHDeviceCategoryVC"];
    return vc;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIButton *cancelBtn = [self.searchBar valueForKey:@"cancelButton"];
    cancelBtn.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.leftTableView.delegate = self;
    self.leftTableView.dataSource = self;
    
    self.rightCollectionView.delegate = self;
    self.rightCollectionView.dataSource = self;
        
    self.definesPresentationContext=YES;
    
    self.leftSelectIndex = 0;
    [self getDeviceTypes];
    
    self.searchBar.backgroundImage = [UIImage imageWithColor:[UIColor colorWithHexString:@"#ffffff"]];
    self.searchBar.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
}

#pragma mark - Lazy

- (NSMutableArray *)deviceKindArray {
    if (!_deviceKindArray) {
        _deviceKindArray = [NSMutableArray array];
    }
    return _deviceKindArray;
}

- (NSMutableArray *)searchDataArray {
    if (!_searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}

- (NSMutableArray *)stateArray {
    if (!_stateArray) {
        _stateArray = [NSMutableArray array];
    }
    return _stateArray;
}

// 扫码添加设备
- (IBAction)scanButtonClick:(id)sender {
    __weak typeof(self)weakSelf = self;
    self.seleDeviceModelM = nil;
    UINavigationController *nav = [GSHQRCodeScanningVC qrCodeScanningNavWithText:@"请扫描设备机身或说明书上的二维码添加设备" title:@"扫描设备二维码" block:^BOOL(NSString *code, GSHQRCodeScanningVC *vc) {
        [weakSelf scanQRCode:code];
        [weakSelf dismissViewControllerAnimated:NO completion:NULL];
        return NO;
    }];
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)scanQRCode:(NSString*)qrCode{
    if (qrCode.length > 0) {
        NSArray<NSString *> *items = [qrCode componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
        if (items.count > 1) {
            if ([items[0] rangeOfString:@"ys7"].location != NSNotFound) {
                [self pushYingShiWithQRCode:qrCode deviceModelM:nil];
                return;
            }
        }
        
        if (qrCode.length > 3) {
            NSString *flagStr = [qrCode substringToIndex:2];
            if ([flagStr isEqualToString:@"GD"]) {
                __weak typeof(self)weakSelf = self;
                [TZMProgressHUDManager showWithStatus:@"解析二维码中" inView:self.view];
                [GSHDeviceManager postDeviceModelListWithQRCode:qrCode block:^(NSArray<GSHDeviceModelM *> *list, NSString *sn, NSError *error) {
                    if (error) {
                        if (error.code == 205) {
                            [TZMProgressHUDManager dismissInView:weakSelf.view];
                            if (qrCode.length > 15) {
                                GSHAddGWApIntroVC *vc = [GSHAddGWApIntroVC addGWApIntroVCWithSn:[qrCode substringFromIndex:15] deviceModel:nil bind:YES];
                                [weakSelf.navigationController pushViewController:vc animated:YES];
                            }
                        }else{
                            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                        }
                    }else{
                        if (![GSHOpenSDKShare share].currentFamily) {
                            [TZMProgressHUDManager showErrorWithStatus:@"请先添加家庭" inView:weakSelf.view];
                            return;
                        }
                        GSHDeviceModelM *modelM = list.firstObject;
                        if (modelM == nil) {
                            [TZMProgressHUDManager showErrorWithStatus:@"无对应设备" inView:weakSelf.view];
                            return;
                        }
                        if (modelM.deviceType.integerValue == GateWayDeviceType || modelM.deviceType.integerValue == GateWayDeviceType2) {
                            if ([GSHOpenSDKShare share].currentFamily.gatewayId.length > 0) {
                                [TZMProgressHUDManager showErrorWithStatus:@"家庭下已添加网关" inView:weakSelf.view];
                                return;
                            }
                        }else{
                            if ([GSHOpenSDKShare share].currentFamily.gatewayId.length == 0) {
                                [TZMProgressHUDManager showErrorWithStatus:@"请添加智能网关" inView:weakSelf.view];
                                return;
                            }
                        }
                        [TZMProgressHUDManager dismissInView:weakSelf.view];
                        GSHDeviceModelListVC *vc = [GSHDeviceModelListVC deviceModelListVCWithList:list sn:sn];
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    }
                }];
                return;
            }
        }
        
        self.title = @"二维码扫描失败";
        self.viewError.hidden = NO;
        self.lblError.text = @"二维码信息错误，请扫描正确的二维码";
    } else {
        [TZMProgressHUDManager showErrorWithStatus:@"无效二维码" inView:self.view];
    }
}

- (void)pushYingShiWithQRCode:(NSString*)qrCode deviceModelM:(GSHDeviceModelM*)deviceModelM{
    //这个是萤石设备
    NSString *errorString;
    GSHDeviceM *deviceM = [GSHDeviceM new];
    NSArray<NSString *> *items = [qrCode componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];;
    if (items.count > 1) {
        deviceM.deviceSn = items[1];
    }
    if (items.count > 2) {
        deviceM.validateCode = items[2];
    }
    if (items.count > 3) {
        NSString *item3 = items[3];
        deviceM.deviceModelStr = item3;
        GSHYingShiDeviceDetailVC *vc = [GSHYingShiDeviceDetailVC yingShiDeviceDetailVCWithDevice:deviceM model:deviceModelM];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }else{
        errorString = @"二维码信息错误，请扫描正确的二维码";
    }
    
    if(errorString.length > 0){
        self.title = @"二维码扫描失败";
        self.viewError.hidden = NO;
        self.lblError.text = errorString;
        if (deviceModelM.deviceTypeStr.length > 0) {
            self.btnSele.hidden = YES;
            [self.btnScanAgain setTitle:@"重新扫描" forState:UIControlStateNormal];
        }else{
            [self.btnScanAgain setTitle:@"重试" forState:UIControlStateNormal];
            self.btnSele.hidden = NO;
        }
    }
}

// 重试
- (IBAction)btnScanAgain:(id)sender {
    self.viewError.hidden = YES;
    self.title = @"添加设备";
    if (self.seleDeviceModelM) {
        NSString *text;
        if (self.seleDeviceModelM.deviceType.integerValue == 17 || self.seleDeviceModelM.deviceType.integerValue == 16) {
            text = @"请扫描设备机身或说明书上的二维码添加设备";
        }else if (self.seleDeviceModelM.deviceType.integerValue == 15){
            text = @"请扫描设备“固件信息”或说明书上的二维码添加设备";
        }
        __weak typeof(self)weakSelf = self;
        UINavigationController *nav = [GSHQRCodeScanningVC qrCodeScanningNavWithText:text title:@"扫描设备二维码" block:^BOOL(NSString *code, GSHQRCodeScanningVC *vc) {
            [weakSelf pushYingShiWithQRCode:code deviceModelM:weakSelf.seleDeviceModelM];
            [weakSelf dismissViewControllerAnimated:NO completion:NULL];
            return NO;
        }];
        [self presentViewController:nav animated:YES completion:NULL];
    } else {
        [self scanButtonClick:nil];
    }
}

- (IBAction)touchSele:(id)sender {
    self.viewError.hidden = YES;
    self.title = @"添加设备";
}

#pragma mark - request
- (void)getDeviceTypes {
    [TZMProgressHUDManager showWithStatus:@"获取设备品类中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHDeviceManager getSystemDeviceTemplateWithBlock:^(NSArray<GSHDeviceKindM *> *list, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        } else {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [weakSelf.deviceKindArray addObjectsFromArray:list];
            for (GSHDeviceKindM *kindM in weakSelf.deviceKindArray) {
                NSMutableArray *arr = [NSMutableArray array];
                for (int i = 0;i < kindM.deviceTypeList.count;i++) {
                    [arr addObject:@(1)];
                }
                [weakSelf.stateArray addObject:arr];
            }
            [weakSelf.leftTableView reloadData];
            [weakSelf.rightCollectionView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchTableView) {
        return self.searchDataArray.count;
    }
    return self.deviceKindArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchTableView) {
        GSHDeviceSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
        if (self.searchDataArray.count > indexPath.row) {
            GSHDeviceModelM *modelM = self.searchDataArray[indexPath.row];
            [cell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:modelM.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
            cell.deviceTypeNameLabel.text = modelM.modelNameDesc;
        }
        return cell;
    } else {
        GSHDeviceCategoryNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
        GSHDeviceKindM *kindM = self.deviceKindArray[indexPath.row];
        cell.nameLabel.text = kindM.kindName;
        if (indexPath.row == self.leftSelectIndex) {
            // 选中
            cell.leftFlagLabel.hidden = NO;
            cell.nameLabel.textColor = [UIColor colorWithHexString:@"#2EB0FF"];
            cell.nameLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        } else {
            // 未选中
            cell.leftFlagLabel.hidden = YES;
            cell.nameLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            cell.nameLabel.font = [UIFont systemFontOfSize:14.0];
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchTableView) {
        if (self.searchDataArray.count > indexPath.row) {
            GSHDeviceModelM *modelM = self.searchDataArray[indexPath.row];
            [self pushToDeviceGuideVCWithDeviceModelM:modelM];
        }
    } else {
        for (int i = 0; i < self.deviceKindArray.count; i ++) {
            GSHDeviceCategoryNameCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.leftFlagLabel.hidden = YES;
            cell.nameLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            cell.nameLabel.font = [UIFont systemFontOfSize:14.0];
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
        }
        GSHDeviceCategoryNameCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
        selectCell.leftFlagLabel.hidden = NO;
        selectCell.nameLabel.textColor = [UIColor colorWithHexString:@"#2EB0FF"];
        selectCell.nameLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        selectCell.contentView.backgroundColor = [UIColor whiteColor];
        self.leftSelectIndex = indexPath.row;
        [self.rightCollectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.deviceKindArray.count > 0) {
        GSHDeviceKindM *kindM = self.deviceKindArray[self.leftSelectIndex];
        return kindM.deviceTypeList.count;
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.deviceKindArray.count > 0) {
        NSArray *arr = self.stateArray[self.leftSelectIndex];
        BOOL state = ((NSNumber *)arr[section]).boolValue;
        GSHDeviceKindM *kindM = self.deviceKindArray[self.leftSelectIndex];
        GSHDeviceTypeM *typeM = kindM.deviceTypeList[section];
        return state ? typeM.deviceModelList.count : 0;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GSHDeviceCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoryCell" forIndexPath:indexPath];
    if (self.deviceKindArray.count > 0) {
        GSHDeviceKindM *kindM = self.deviceKindArray[self.leftSelectIndex];
        GSHDeviceTypeM *typeM = kindM.deviceTypeList[indexPath.section];
        GSHDeviceModelM *modelM = typeM.deviceModelList[indexPath.row];
        cell.deviceModelNameLabel.text = modelM.modelNameDesc;
        [cell.deviceModelImageView sd_setImageWithURL:[NSURL URLWithString:modelM.homePageIcon] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#F6F7FA"]]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH - 100) / 3.0, 114);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        GSHDeviceCategoryHeadView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
        header.tag = indexPath.section;
        NSArray *arr = self.stateArray[self.leftSelectIndex];
        BOOL state = ((NSNumber *)arr[indexPath.section]).boolValue;
        header.arrowButton.selected = !state;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headViewClick:)];
        [header addGestureRecognizer:tap];
        
        GSHDeviceKindM *kindM = self.deviceKindArray[self.leftSelectIndex];
        GSHDeviceTypeM *typeM = kindM.deviceTypeList[indexPath.section];
        header.typeNameLabel.text = typeM.deviceTypeStr;
        
        reusableView = header;
    }
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.deviceKindArray.count > 0) {
        GSHDeviceKindM *kindM = self.deviceKindArray[self.leftSelectIndex];
        GSHDeviceTypeM *typeM = kindM.deviceTypeList[indexPath.section];
        GSHDeviceModelM *modelM = typeM.deviceModelList[indexPath.row];
        [self pushToDeviceGuideVCWithDeviceModelM:modelM];
    }
}

- (void)pushToDeviceGuideVCWithDeviceModelM:(GSHDeviceModelM *)modelM {
    __weak typeof(self)weakSelf = self;
    if (modelM.deviceType.integerValue == 18) {
        GSHShengBiKeGuideVC *vc = [GSHShengBiKeGuideVC shengBiKeGuideVCWithGategory:modelM];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (modelM.deviceType.integerValue == 17 || modelM.deviceType.integerValue == 16 ||
        modelM.deviceType.integerValue == 15) {
        self.seleDeviceModelM = modelM;
        NSString *text;
        if (modelM.deviceType.integerValue == 17 || self.seleDeviceModelM.deviceType.integerValue == 16) {
            text = @"请扫描设备机身或说明书上的二维码添加设备";
        }else if (self.seleDeviceModelM.deviceType.integerValue == 15){
            text = @"请扫描设备“固件信息”或说明书上的二维码添加设备";
        }
        UINavigationController *nav = [GSHQRCodeScanningVC qrCodeScanningNavWithText:text title:@"扫描设备二维码" block:^BOOL(NSString *code, GSHQRCodeScanningVC *vc) {
            [weakSelf pushYingShiWithQRCode:code deviceModelM:weakSelf.seleDeviceModelM];
            [weakSelf dismissViewControllerAnimated:NO completion:NULL];
            return NO;
        }];
        [self presentViewController:nav animated:YES completion:NULL];
    } else if (modelM.deviceType.integerValue == GateWayDeviceType || modelM.deviceType.integerValue == GateWayDeviceType2) {
        // 添加网关
        if (![GSHOpenSDKShare share].currentFamily) {
            [TZMProgressHUDManager showErrorWithStatus:@"请先添加家庭" inView:weakSelf.view];
            return;
        }
        if ([GSHOpenSDKShare share].currentFamily.gatewayId.length > 0) {
            // 有网关id
            [TZMProgressHUDManager showErrorWithStatus:@"家庭下已添加网关" inView:weakSelf.view];
            return;
        }
        [self.navigationController pushViewController:[GSHAddGWGuideVC addGWGuideVCWithFamily:[GSHOpenSDKShare share].currentFamily deviceModel:modelM sn:nil] animated:YES];
    } else {
        if ([GSHOpenSDKShare share].currentFamily.gatewayId.length == 0) {
            // 无网关id
            [TZMProgressHUDManager showErrorWithStatus:@"暂不能添加该设备，请添加智能网关" inView:weakSelf.view];
            return;
        }
        GSHDeviceCategoryGuideVC *vc = [GSHDeviceCategoryGuideVC deviceCategoryGuideVCWithGategory:modelM deviceSn:@""];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)headViewClick:(UITapGestureRecognizer *)tap {
    ((GSHDeviceCategoryHeadView *)tap.view).arrowButton.selected = !((GSHDeviceCategoryHeadView *)tap.view).arrowButton.selected;
    NSInteger tag = tap.view.tag;
    NSMutableArray *arr = self.stateArray[self.leftSelectIndex];
    BOOL state = ((NSNumber *)arr[tag]).boolValue;
    state = !state;
    [arr replaceObjectAtIndex:tag withObject:[NSNumber numberWithBool:state]];
    [self.rightCollectionView reloadData];
}

#pragma mark - UISearchBarDelegate
// return NO to not become first responder
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}
// called when text starts editing
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.leftTableView.hidden = YES;
    self.rightCollectionView.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.tzm_prefersNavigationBarHidden = YES;
    searchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText tzm_checkStringIsEmpty]) {
        if (self.searchDataArray.count > 0) {
            [self.searchDataArray removeAllObjects];
            [self.searchTableView reloadData];
        }
    } else {
        if (self.searchDataArray.count > 0) {
            [self.searchDataArray removeAllObjects];
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"modelNameDesc like '*%@*'",searchText]];
        for (GSHDeviceKindM *kindM in self.deviceKindArray) {
            for (GSHDeviceTypeM *typeM in kindM.deviceTypeList) {
                NSArray *resultArray = [typeM.deviceModelList filteredArrayUsingPredicate:predicate];
                if (resultArray.count > 0) {
                    [self.searchDataArray addObjectsFromArray:resultArray];
                }
            }
        }
        [self.searchTableView reloadData];
    }
}

// return NO to not resign first responder
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}
// called when text ends editing
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (self.searchDataArray.count > 0) {
        [self.searchDataArray removeAllObjects];
        [self.searchTableView reloadData];
    }
    searchBar.text = @"";
    [self.view endEditing:YES];
    self.leftTableView.hidden = NO;
    self.rightCollectionView.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tzm_prefersNavigationBarHidden = NO;
    searchBar.showsCancelButton = NO;
}

@end
