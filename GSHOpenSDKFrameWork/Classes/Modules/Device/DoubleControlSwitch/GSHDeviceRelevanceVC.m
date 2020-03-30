//
//  GSHDeviceRelevanceVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDeviceRelevanceVC.h"
#import "GSHChooseSwitchListVC.h"

@interface GSHDeviceRelevanceVC () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) GSHSwitchBindM *switchBindM;
@property (strong, nonatomic) NSArray *sectionNameArray;

@end

@implementation GSHDeviceRelevanceVC

+ (instancetype)deviceRelevanceVCWithDeviceId:(NSString *)deviceId {
    GSHDeviceRelevanceVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoubleControlSwitchSB" andID:@"GSHDeviceRelevanceVC"];
    vc.deviceId = deviceId;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sectionNameArray = @[@"第一路",@"第二路",@"第三路"];
    
    [self getDeviceBindInfo];
    
}

#pragma mark - Lazy

#pragma mark - method

- (void)unBindWithBasMeteId:(NSString *)basMeteId meteBindedInfoListM:(GSHMeteBindedInfoListM *)listM indexPath:(NSIndexPath *)indexPath{
    
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"解绑中" inView:self.view];
    [GSHDeviceManager unBindMultiControlWithDeviceId:self.switchBindM.deviceId deviceSn:self.switchBindM.deviceSn basMeteId:basMeteId relDeviceId:listM.deviceId relDeviceSn:listM.deviceSn relBasMeteId:listM.basMeteId block:^(NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"解绑成功" inView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getDeviceBindInfo];
            });
        }
    }];
}

#pragma mark - request
- (void)getDeviceBindInfo {
    
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    [GSHDeviceManager getDeviceBIndInfoWithDeviceId:self.deviceId block:^(GSHSwitchBindM *switchBindM, NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            self.switchBindM = switchBindM;
            [self.mainTableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.switchBindM.switchMeteBindInfoModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.switchBindM.switchMeteBindInfoModels.count > section) {
        GSHSwitchMeteBindInfoModelM *switchMeteBindInfoModelM = self.switchBindM.switchMeteBindInfoModels[section];
        return 1 + switchMeteBindInfoModelM.meteBindedInfoList.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHSwitchMeteBindInfoModelM *switchMeteBindInfoModelM = self.switchBindM.switchMeteBindInfoModels[indexPath.section];
    if (switchMeteBindInfoModelM.meteBindedInfoList.count == indexPath.row) {
        GSHDeviceRelevanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceRelevanceCell" forIndexPath:indexPath];
        if (switchMeteBindInfoModelM.meteBindedInfoList.count >= 4) {
            cell.relevanceTypeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            cell.contentView.alpha = 0.3;
        } else {
            cell.relevanceTypeLabel.textColor = [UIColor colorWithHexString:@"#2EB0FF"];
            cell.contentView.alpha = 1;
        }
        return cell;
    } else {
        GSHMeteBindedInfoListM *listM = switchMeteBindInfoModelM.meteBindedInfoList[indexPath.row];
        GSHDeviceRelevanceSecondCell *secondCell = [tableView dequeueReusableCellWithIdentifier:@"deviceRelevanceSecondCell" forIndexPath:indexPath];
        secondCell.deviceNameLabel.text = listM.deviceName;
        secondCell.deviceMeteNameLabel.text = listM.meteName;
        @weakify(self)
        secondCell.bindBtnClickBlock = ^{
            @strongify(self)
            [self unBindWithBasMeteId:switchMeteBindInfoModelM.basMeteId meteBindedInfoListM:listM indexPath:indexPath];
        };
        return secondCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 0, SCREEN_WIDTH - 17.5, 50)];
    label.text = [NSString stringWithFormat:@"%@ - %@",self.switchBindM.deviceName,self.sectionNameArray[section]];
    label.textColor = [UIColor colorWithHexString:@"#999999"];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHSwitchMeteBindInfoModelM *switchMeteBindInfoModelM = self.switchBindM.switchMeteBindInfoModels[indexPath.section];
    if (switchMeteBindInfoModelM.meteBindedInfoList.count == indexPath.row) {
        // 关联按钮点击
        if (switchMeteBindInfoModelM.meteBindedInfoList.count >= 4) {
            [TZMProgressHUDManager showErrorWithStatus:@"最多只能关联4个开关" inView:self.view];
            return nil;
        }
        
        GSHChooseSwitchListVC *chooseSwitchListVC = [GSHChooseSwitchListVC chooseSwitchListVCWithSwitchBindM:self.switchBindM switchMeteBindInfoModelM:switchMeteBindInfoModelM];
        chooseSwitchListVC.hidesBottomBarWhenPushed = YES;
        @weakify(self)
        chooseSwitchListVC.bindSuccessBlock = ^{
            @strongify(self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getDeviceBindInfo];
            });
            
        };
        [self.navigationController pushViewController:chooseSwitchListVC animated:YES];
    }
    return nil;
}

@end


@implementation GSHDeviceRelevanceCell

@end


@implementation GSHDeviceRelevanceSecondCell

- (IBAction)bindBtnClick:(id)sender {
    if (self.bindBtnClickBlock) {
        self.bindBtnClickBlock();
    }
}


@end
