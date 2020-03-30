//
//  GSHAddTriggerConditionVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAddTriggerConditionVC.h"
#import "GSHAutoTimeSetVC.h"
#import "GSHChooseDeviceVC.h"

@interface GSHAddTriggerConditionVC ()

@property (nonatomic , strong) NSArray *conditionNameArray;
@property (nonatomic , strong) NSArray *detailTextArray;
@property (nonatomic , strong) NSArray *imageArray;
@property (nonatomic , assign) BOOL isShowTimeCondition;

@end

@implementation GSHAddTriggerConditionVC

+ (instancetype)addTriggerConditionVCWhitIsShowTimeCondition:(BOOL)isShowTimeCondition {
    GSHAddTriggerConditionVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddAutomationSB" andID:@"GSHAddTriggerConditionVC"];
    vc.isShowTimeCondition = isShowTimeCondition;
    return vc;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedDeviceArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.conditionNameArray = @[@"定时条件",@"设备受控时"];
    self.detailTextArray = @[@"如“每天早上八点”",@"如“灯打开”“门磁打开”"];
    self.imageArray = @[@"intelligent_icon_timing",@"intelligent_icon_equipment"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conditionNameArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isShowTimeCondition && indexPath.row == 0) {
        // 可选条件时隐藏定时条件
        return 0.0f;
    }
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHAddTriggerConditionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"triggerConditionCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.triggerConditionNameLabel.text = self.conditionNameArray[indexPath.row];
    cell.triggerDetailLabel.text = self.detailTextArray[indexPath.row];
    cell.cellImageView.image = [UIImage ZHImageNamed:self.imageArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //  定时条件
        GSHAutoTimeSetVC *timeSetVC = [GSHAutoTimeSetVC autoTimeSetVCWithOldTime:nil choosedIndexSet:nil];
        @weakify(self)
        timeSetVC.compeleteSetTimeBlock = ^(NSString *time, NSString *repeatCount,NSIndexSet *repeatCountIndexSet) {
            @strongify(self)
            if (self.compeleteSetTimeBlock) {
                self.compeleteSetTimeBlock(time, repeatCount,repeatCountIndexSet);
            }
        };
        [self.navigationController pushViewController:timeSetVC animated:YES];
    } else if (indexPath.row == 1) {
        // 设备受控
        NSMutableArray *deviceArray = [NSMutableArray array];
        for (GSHAutoTriggerConditionListM *triggerConditionListM in self.selectedDeviceArray) {
            if (triggerConditionListM.device) {
                [deviceArray addObject:triggerConditionListM.device];
            }
        }
        GSHChooseDeviceVC *chooseDeviceVC = [[GSHChooseDeviceVC alloc] initWithSelectDeviceArray:deviceArray];
        chooseDeviceVC.fromFlag = ChooseDeviceFromAddAutoAddCondition;
        @weakify(self)
        chooseDeviceVC.selectDeviceBlock = ^(NSArray *selectedDeviceArray) {
            @strongify(self)
            if (self.selectDeviceBlock) {
                self.selectDeviceBlock(selectedDeviceArray);
            }
        };
        [self.navigationController pushViewController:chooseDeviceVC animated:YES];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

@end

#pragma mark - GSHAddTriggerConditionCell
@interface GSHAddTriggerConditionCell ()

@end

@implementation GSHAddTriggerConditionCell

@end
