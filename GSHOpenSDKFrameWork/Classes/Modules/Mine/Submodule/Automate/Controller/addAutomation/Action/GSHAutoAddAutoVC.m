//
//  GSHAutoAddAutoVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutoAddAutoVC.h"
#import "GSHAutoCreateVC.h"

@interface GSHAutoAddAutoVC ()

@property (nonatomic , strong) NSMutableArray *autoListArray;
@property (nonatomic , strong) NSMutableArray *choosedArray;
@property (nonatomic , strong) NSMutableArray *noChoosedArray;
@property (nonatomic , strong) NSMutableDictionary *selectDic;

@end

@implementation GSHAutoAddAutoVC

+ (instancetype)autoAddAutoVC {
    GSHAutoAddAutoVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddAutoAction" andID:@"GSHAutoAddAutoVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self getAutoList]; // 获取联动列表
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Lazy
- (NSMutableArray *)autoListArray {
    if (!_autoListArray) {
        _autoListArray = [NSMutableArray array];
    }
    return _autoListArray;
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

- (NSMutableDictionary *)selectDic {
    if (!_selectDic) {
        _selectDic = [NSMutableDictionary dictionary];
    }
    return _selectDic;
}

#pragma mark - method

- (IBAction)sureButtonClick:(id)sender {
    for (int i = 0; i < self.autoListArray.count; i ++) {
        GSHOssAutoM *ossAutoM = self.autoListArray[i];
        GSHAutoActionListM *actionListM = [[GSHAutoActionListM alloc] init];
        actionListM.ruleId = ossAutoM.ruleId;
        actionListM.ruleName = ossAutoM.name;
        if ([self.selectDic objectForKey:ossAutoM.ruleId]) {
            if (![self isAddInArrayWithOssAutoM:ossAutoM]) {
                [self.choosedArray addObject:actionListM];
            }
        } else {
            [self.noChoosedArray addObject:actionListM];
        }
    }
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[GSHAutoCreateVC class]]) {
            if (self.chooseAutoBlock) {
                self.chooseAutoBlock(self.choosedArray , self.noChoosedArray);
            }
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (BOOL)isAddInArrayWithOssAutoM:(GSHOssAutoM *)ossAutoM {
    BOOL isIn = NO;
    for (GSHAutoActionListM *selectActionListM in self.choosedActionArray) {
        if ([selectActionListM.ruleId isKindOfClass:NSNumber.class]) {
            if ([ossAutoM.ruleId isEqualToNumber:selectActionListM.ruleId]) {
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
    return self.autoListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHAutoAddAutoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"autoAddAutoCell" forIndexPath:indexPath];
    GSHOssAutoM *ossAutoM = self.autoListArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.autoNameLabel.text = ossAutoM.name;
    cell.checkButton.selected = [self.selectDic objectForKey:ossAutoM.ruleId] ? YES : NO;
    //ossAutoM.isSelected;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHAutoAddAutoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    GSHOssAutoM *ossAutoM = self.autoListArray[indexPath.row];
    cell.checkButton.selected = !cell.checkButton.selected;
    if (cell.checkButton.selected) {
        // 选中
        [self.selectDic setObject:ossAutoM forKey:ossAutoM.ruleId];
    } else {
        // 取消选中
        if ([self.selectDic objectForKey:ossAutoM.ruleId]) {
            [self.selectDic removeObjectForKey:ossAutoM.ruleId];
        }
    }
    
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
    view.backgroundColor = [UIColor colorWithHexString:@"#F5F5F7"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
    label.textColor = [UIColor colorWithHexString:@"#3C4366"];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = @"请选择满足条件后要执行的自动化";
    [view addSubview:label];
    return view;
}

#pragma mark - request
// 获取联动列表
- (void)getAutoList {
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHAutoManager getAutoListNewWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId lastAutoId:@(-1) block:^(NSArray<GSHOssAutoM *> *list, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (self.autoListArray.count > 0) {
                [self.autoListArray removeAllObjects];
            }
            [self.autoListArray addObjectsFromArray:list];
            if (self.currentAutoId.length > 0 && [self deleteCurrentAutoFromAutoListArray:self.autoListArray]) {
                [self.autoListArray removeObject:[self deleteCurrentAutoFromAutoListArray:self.autoListArray]];
            }
            if (self.choosedActionArray) {
                [self alertAutoIsSelectedWithSelectedArray];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)alertAutoIsSelectedWithSelectedArray {
    for (GSHAutoActionListM *autoActionListM in self.choosedActionArray) {
        for (GSHOssAutoM *ossAutoM in self.autoListArray) {
            if ([ossAutoM.ruleId isKindOfClass:NSNumber.class]) {
                if ([autoActionListM.ruleId isEqualToNumber:ossAutoM.ruleId]) {
                    [self.selectDic setObject:autoActionListM forKey:autoActionListM.ruleId];
                }
            }
        }
    }
}

// 编辑模式 -- 过滤当前联动
- (GSHOssAutoM *)deleteCurrentAutoFromAutoListArray:(NSArray <GSHOssAutoM *>*)autoListArray {
    GSHOssAutoM *ossAutoM = nil;
    for (int i = 0; i < autoListArray.count; i ++) {
        GSHOssAutoM *tmpOssAutoM = autoListArray[i];
        if ([self.currentAutoId isEqualToString:tmpOssAutoM.ruleId.stringValue]) {
            ossAutoM = tmpOssAutoM;
            break;
        }
    }
    return ossAutoM;
}

@end

@implementation GSHAutoAddAutoCell


@end
