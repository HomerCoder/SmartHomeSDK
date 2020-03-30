//
//  GSHAutoAddActionSceneVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutoAddActionSceneVC.h"
#import "GSHAutoCreateVC.h"

@interface GSHAutoAddActionSceneVC ()

@property (nonatomic , strong) NSMutableArray *sceneArray;
@property (nonatomic , strong) NSMutableArray *choosedArray;
@property (nonatomic , strong) NSMutableArray *noChoosedArray;

@end

@implementation GSHAutoAddActionSceneVC

+ (instancetype)autoAddActionSceneVC {
    GSHAutoAddActionSceneVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddAutoAction" andID:@"GSHAutoAddActionSceneVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
    [self querySceneModeList];  // 查询 情景模式列表
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy
- (NSMutableArray *)sceneArray {
    if (!_sceneArray) {
        _sceneArray = [NSMutableArray array];
    }
    return _sceneArray;
}

- (NSMutableArray *)choosedArray {
    if (!_choosedArray) {
        _choosedArray = [NSMutableArray array];
    }
    return _choosedArray;
}

- (NSMutableArray *)noChoosedArray {
    if (!_noChoosedArray) {
        _noChoosedArray = [NSMutableArray array];
    }
    return _noChoosedArray;
}

#pragma mark - method

- (IBAction)sureButtonClick:(id)sender {
    for (int i = 0; i < self.sceneArray.count; i ++) {
        GSHOssSceneM *ossSceneM = self.sceneArray[i];
        GSHAutoActionListM *actionListM = [[GSHAutoActionListM alloc] init];
        actionListM.scenarioId = ossSceneM.scenarioId;
        actionListM.scenarioName = ossSceneM.scenarioName;
        actionListM.businessId = ossSceneM.businessId;
        if (ossSceneM.isSelected) {
            if (![self isAddInArrayWithOssSceneM:ossSceneM]) {
                [self.choosedArray addObject:actionListM];
            }
        } else {
            [self.noChoosedArray addObject:actionListM];
        }
    }
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[GSHAutoCreateVC class]]) {
            if (self.chooseSceneBlock) {
                self.chooseSceneBlock(self.choosedArray , self.noChoosedArray);
            }
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (BOOL)isAddInArrayWithOssSceneM:(GSHOssSceneM *)ossSceneM {
    BOOL isIn = NO;
    for (GSHAutoActionListM *selectActionListM in self.choosedActionArray) {
        if ([selectActionListM.scenarioId isKindOfClass:NSNumber.class]) {
            if ([ossSceneM.scenarioId isEqualToNumber:selectActionListM.scenarioId]) {
                isIn = YES;
                break;
            }
        }
    }
    return isIn;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sceneArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHAutoAddActionSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addActionCell" forIndexPath:indexPath];
    GSHOssSceneM *ossSceneM = self.sceneArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.sceneNameLabel.text = ossSceneM.scenarioName;
    cell.checkButton.selected = ossSceneM.isSelected;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHAutoAddActionSceneCell *sceneCell = [tableView cellForRowAtIndexPath:indexPath];
    GSHOssSceneM *ossSceneM = self.sceneArray[indexPath.row];
    sceneCell.checkButton.selected = !sceneCell.checkButton.selected;
    [ossSceneM setIsSelected:sceneCell.checkButton.selected];
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
    view.backgroundColor = [UIColor colorWithHexString:@"#F5F5F7"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexString:@"#3C4366"];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = @"请选择满足条件后要执行的场景模式";
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - request
// 查询情景模式列表
- (void)querySceneModeList {
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHSceneManager getSceneListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId currPage:nil block:^(GSHSceneListM *sceneListM,NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (self.sceneArray.count > 0) {
                [self.sceneArray removeAllObjects];
            }
            [self.sceneArray addObjectsFromArray:sceneListM.scenarios];
            if (self.choosedActionArray.count > 0) {
                [self alertSceneIsSelectedWithSelectedArray];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)alertSceneIsSelectedWithSelectedArray { 
    for (GSHAutoActionListM *autoActionListM in self.choosedActionArray) {
        for (GSHOssSceneM *ossSceneM in self.sceneArray) {
            if ([ossSceneM.scenarioId isKindOfClass:NSNumber.class]) {
                if ([autoActionListM.scenarioId isEqualToNumber:ossSceneM.scenarioId]) {
                    [ossSceneM setIsSelected:YES];
                }
            }
        }
    }
}

@end

@implementation GSHAutoAddActionSceneCell


@end
