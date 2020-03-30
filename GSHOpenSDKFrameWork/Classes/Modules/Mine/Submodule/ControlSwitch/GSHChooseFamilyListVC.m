//
//  GSHChooseFamilyListVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/2/19.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHChooseFamilyListVC.h"
#import "GSHConfigLocalControlVC.h"
#import "UIView+TZMPageStatusViewEx.h"


@interface GSHChooseFamilyListVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) NSMutableArray *familyListArray;
@property (weak, nonatomic) IBOutlet UITableView *familyTableView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (nonatomic , assign) int chooseRow;

@end

@implementation GSHChooseFamilyListVC

+ (instancetype)chooseFamilyListVC {
    GSHChooseFamilyListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHControlSwitchSB" andID:@"GSHChooseFamilyListVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getFamilyList];   // 获取家庭列表
}

#pragma mark - Lazy
- (NSMutableArray *)familyListArray {
    if (!_familyListArray) {
        _familyListArray = [NSMutableArray array];
    }
    return _familyListArray;
}

#pragma mark - method

- (IBAction)nextButtonClick:(id)sender {
    if (self.familyListArray.count > self.chooseRow) {
        GSHFamilyM *familyM = self.familyListArray[self.chooseRow];
        if (familyM.gatewayId.length == 0) {
            [TZMProgressHUDManager showErrorWithStatus:@"无法切换，请添加网关！" inView:self.view];
            return;
        }
        if (self.controlType == 0) {
            [self getFamilyInfoWithFamilyM:familyM];
        } else {
            // 外网控制
            [TZMProgressHUDManager showWithStatus:@"切换中" inView:self.view];
            @weakify(self)
            [[GSHWebSocketClient shared] changType:GSHNetworkTypeWAN gatewayId:familyM.gatewayId block:^(NSError * _Nonnull error) {
                @strongify(self)
                if (error) {
                    // 失败
                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
                } else {
                    // 切换成功
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [TZMProgressHUDManager showSuccessWithStatus:@"切换成功" inView:self.view];
                        [self.navigationController popToRootViewControllerAnimated:NO];
                        [self postNotification:GSHControlSwitchSuccess object:familyM];
                    });
                }
            }];
        }
    }
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.familyListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseFamilyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHChooseFamilyCell" forIndexPath:indexPath];
    if (self.familyListArray.count > indexPath.row) {
        GSHFamilyM *familyM = self.familyListArray[indexPath.row];
        cell.familyNameLabel.text = familyM.familyName;
        if (indexPath.row == self.chooseRow) {
            cell.chooseButton.selected = YES;
        } else {
            cell.chooseButton.selected = NO;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.chooseRow = (int)indexPath.row;
    [self.familyTableView reloadData];
}

#pragma mark - request
- (void)getFamilyList {
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    [GSHFamilyManager getHomeVCFamilyListWithblock:^(NSArray<GSHFamilyM *> *familyList, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager dismissInView:self.view];
            self.actionButton.hidden = YES;
            [self.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [self getFamilyList];
            }];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (self.familyListArray.count > 0) {
                [self.familyListArray removeAllObjects];
            }
            [self.familyListArray addObjectsFromArray:familyList];
            [self.familyTableView reloadData];
            [self.view dismissPageStatusView];
            self.actionButton.hidden = NO;
        }
    }];
}

// 拉取家庭下所有信息
- (void)getFamilyInfoWithFamilyM:(GSHFamilyM *)familyM {
    [TZMProgressHUDManager showWithStatus:@"数据拉取中" inView:self.view];
    @weakify(self)
    [GSHFamilyManager getAllInfoFromFamilyWithFamilyId:familyM.familyId block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            GSHConfigLocalControlVC *configLocalControlVC = [GSHConfigLocalControlVC configLocalControlVC];
            configLocalControlVC.familyM = familyM;
            configLocalControlVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:configLocalControlVC animated:YES];
        }
    }];
    
}

@end

@implementation GSHChooseFamilyCell

@end
