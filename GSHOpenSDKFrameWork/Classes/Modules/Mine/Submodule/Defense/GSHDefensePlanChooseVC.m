//
//  GSHDefensePlanChooseVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/6/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDefensePlanChooseVC.h"
#import "GSHDefensePlanListVC.h"

@interface GSHDefensePlanChooseVC () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *defensePlanChooseTableView;
@property (strong, nonatomic) NSMutableArray *planArray;
@property (strong, nonatomic) NSString *selectTemplateId;

@end

@implementation GSHDefensePlanChooseVC

+(instancetype)defensePlanChooseVCWithSelectTemplateId:(NSString *)templateId {
    GSHDefensePlanChooseVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDefenseSB" andID:@"GSHDefensePlanChooseVC"];
    if (templateId) {
        vc.selectTemplateId = templateId;
    }
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

- (IBAction)editButtonClick:(id)sender {
    
    @weakify(self)
    GSHDefensePlanListVC *listVC = [GSHDefensePlanListVC defensePlanListVC];
    listVC.updateSuccessBlock = ^(GSHDefensePlanM * _Nonnull planM) {
        @strongify(self)
        int indexI = 0,indexJ = 0;
        for (int i = 0 ; i < self.planArray.count ; i ++) {
            NSArray *arr = (NSArray *)self.planArray[i];
            for (int j = 0 ; j < arr.count ; j ++) {
                GSHDefensePlanM *tmpPlanM = arr[j];
                if ([tmpPlanM.templateId isEqualToString:planM.templateId]) {
                    indexI = i;
                    indexJ = j;
                }
            }
        }
        NSMutableArray *tmpArr = self.planArray[indexI];
        if (tmpArr.count > indexJ) {
            [tmpArr removeObjectAtIndex:indexJ];
            [tmpArr insertObject:planM atIndex:indexJ];
        }
        [self.defensePlanChooseTableView reloadData];
        if (self.updateSuccessBlock) {
            self.updateSuccessBlock(planM);
        }
    };
    listVC.deleteButtonClickBlock = ^(NSString *templateId){
        @strongify(self)
        NSNumber *indexI , *indexJ;
        for (int i = 0 ; i < self.planArray.count ; i ++) {
            NSArray *arr = (NSArray *)self.planArray[i];
            for (int j = 0 ; j < arr.count ; j ++) {
                GSHDefensePlanM *tmpPlanM = arr[j];
                if ([tmpPlanM.templateId isEqualToString:templateId]) {
                    indexI = @(i);
                    indexJ = @(j);
                }
            }
        }
        if (indexI && indexJ) {
            NSMutableArray *tmpArr = self.planArray[indexI.integerValue];
            if (tmpArr.count > indexJ.integerValue) {
                [tmpArr removeObjectAtIndex:indexJ.integerValue];
            }
        }
        [self.defensePlanChooseTableView reloadData];
    };
    listVC.addButtonClickBlock = ^{
        @strongify(self)
        [self getDefensePlanList];
    };
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark - Request
// 请求防御计划列表
- (void)getDefensePlanList {
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHDefensePlanManager getDefensePlanListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSArray<GSHDefensePlanM *> * _Nonnull list, NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (self.planArray.count > 0) {
                [self.planArray removeAllObjects];
            }
            [self handlePlanListDataWithList:list];
            [self.defensePlanChooseTableView reloadData];
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
    GSHDefensePlanChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chooseCell" forIndexPath:indexPath];
    NSArray *arr = self.planArray[indexPath.section];
    if (arr.count > indexPath.row) {
        GSHDefensePlanM *planM = arr[indexPath.row];
        cell.defensePlanNameLabel.text = planM.templateName;
        cell.checkImageView.hidden = [planM.templateId isEqualToString:self.selectTemplateId] ? NO : YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 12.f;
    }
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < self.planArray.count; i ++) {
        NSArray *arr = self.planArray[i];
        for (int j = 0; j < arr.count; j ++) {
            GSHDefensePlanChooseCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            cell.checkImageView.hidden = YES;
        }
    }
    NSArray *tmpArr = self.planArray[indexPath.section];
    GSHDefensePlanM *planM = tmpArr[indexPath.row];
    GSHDefensePlanChooseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checkImageView.hidden = NO;
    if (self.chooseBlock) {
        self.chooseBlock(planM);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

@end


@implementation GSHDefensePlanChooseCell

@end
