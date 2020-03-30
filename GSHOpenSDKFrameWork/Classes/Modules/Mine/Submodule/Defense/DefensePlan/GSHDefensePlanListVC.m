//
//  GSHDefensePlanListVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/5/31.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDefensePlanListVC.h"
#import "GSHDefenseAddPlanVC.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "UIViewController+TZMPageStatusViewEx.h"

@interface GSHDefensePlanListVC () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *planTableView;
@property (strong, nonatomic) NSMutableArray *planArray;

@end

@implementation GSHDefensePlanListVC

+(instancetype)defensePlanListVC {
    GSHDefensePlanListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDefensePlanSB" andID:@"GSHDefensePlanListVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self getDefensePlanList];
}

#pragma mark - Lazy
- (NSMutableArray *)planArray {
    if (!_planArray) {
        _planArray = [NSMutableArray array];
    }
    return _planArray;
}

#pragma mark - Action
// 自定义计划按钮点击
- (IBAction)addPlanButtonClick:(id)sender {
    GSHDefenseAddPlanVC *addPlanVC = [GSHDefenseAddPlanVC defenseAddPlanVCWithPlanSetType:GSHDefensePlanSetAdd defensePlanM:nil];
    @weakify(self)
    addPlanVC.addButtonClickBlock = ^{
        @strongify(self)
        [self getDefensePlanList];
        if (self.addButtonClickBlock) {
            self.addButtonClickBlock();
        }
    };
    [self.navigationController pushViewController:addPlanVC animated:YES];
}

#pragma mark - Request
// 请求防御计划列表
- (void)getDefensePlanList {
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHDefensePlanManager getDefensePlanListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSArray<GSHDefensePlanM *> * _Nonnull list, NSError * _Nonnull error) {
        @strongify(self)
        [TZMProgressHUDManager dismissInView:self.view];
        if (error) {
            [self.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [self getDefensePlanList];
            }];
        } else {
            [self.view dismissPageStatusView];
            if (self.planArray.count > 0) {
                [self.planArray removeAllObjects];
            }
            [self handlePlanListDataWithList:list];
            [self.planTableView reloadData];
        }
    }];
}

- (void)handlePlanListDataWithList:(NSArray *)list {
    NSMutableArray *generalArray = [NSMutableArray array];
    NSMutableArray *customArray = [NSMutableArray array];
    for (GSHDefensePlanM *tmpPlanM in list) {
        if (tmpPlanM.templateType.integerValue == 0) {
            // 通用模版
            [generalArray addObject:tmpPlanM];
        } else if (tmpPlanM.templateType.integerValue == 1) {
            // 自定义模版
            [customArray addObject:tmpPlanM];
        }
    }
    [self.planArray addObject:generalArray];
    [self.planArray addObject:customArray];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.planArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.planArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHDefensePlanListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHDefensePlanListCell" forIndexPath:indexPath];
    NSArray *arr = self.planArray[indexPath.section];
    if (arr.count > indexPath.row) {
        GSHDefensePlanM *planM = arr[indexPath.row];
        cell.defensePlanNameLabel.text = planM.templateName;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.f;
    }
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHDefensePlanListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSMutableArray *arr = self.planArray[indexPath.section];
    GSHDefensePlanM *planM = arr[indexPath.row];
    @weakify(self)
    __weak typeof(cell) weakCell = cell;
    GSHDefenseAddPlanVC *addPlanVC = [GSHDefenseAddPlanVC defenseAddPlanVCWithPlanSetType:GSHDefensePlanSetEdit defensePlanM:planM];
    addPlanVC.deleteButtonClickBlock = ^(NSString *templateId) {
        @strongify(self)
        if ([planM.templateId isEqualToString:templateId]) {
            [arr removeObject:planM];
        }
        [self.planTableView reloadData];
        if (self.deleteButtonClickBlock) {
            self.deleteButtonClickBlock(templateId);
        }
    };
    addPlanVC.updateSuccessBlock = ^(GSHDefensePlanM *planM) {
        __strong typeof(weakCell) strongCell = weakCell;
        @strongify(self)
        strongCell.defensePlanNameLabel.text = planM.templateName;
        planM.templateName = planM.templateName;
        if (self.updateSuccessBlock) {
            self.updateSuccessBlock(planM);
        }
    };
    [self.navigationController pushViewController:addPlanVC animated:YES];
}


@end


@implementation GSHDefensePlanListCell


@end
