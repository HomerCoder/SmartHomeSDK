//
//  GSHDefenseMeteChooseVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/6/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDefenseMeteChooseVC.h"

@interface GSHDefenseMeteChooseVC () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *chooseTableView;
@property (strong, nonatomic) NSArray *dataSourceArray;
@property (strong, nonatomic) NSArray *valueSourceArray;
@property (strong, nonatomic) NSIndexPath *selectIndexPath;
@property (assign, nonatomic) int flag;
@property (strong, nonatomic) NSString *selectValue;

@end

@implementation GSHDefenseMeteChooseVC

+(instancetype)defenseMeteChooseVCWithTitle:(NSString *)title flag:(int)flag selectValue:(NSString *)selectValue {
    GSHDefenseMeteChooseVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDefenseSB" andID:@"GSHDefenseMeteChooseVC"];
    vc.title = title;
    vc.flag = flag;
    if (flag == 1) {
        vc.selectValue = selectValue.integerValue == 0 ? @"撤防" : @"布防";
    } else {
        vc.selectValue = selectValue;
    }
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.flag == 1) {
        self.dataSourceArray = @[@"布防",@"撤防"];
        self.valueSourceArray = @[@"1",@"0"];
    } else {
        self.dataSourceArray = @[@"一般",@"重要",@"紧急",@"严重"];
        self.valueSourceArray = @[@"1",@"2",@"3",@"4"];
    }
    if (self.selectValue) {
        int index = (int)[self.dataSourceArray indexOfObject:self.selectValue];
        self.selectIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    }
    [self.chooseTableView reloadData];
}

#pragma mark - Action

- (IBAction)sureButtonClick:(id)sender {
    if (self.selectValue.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请选择一项" inView:self.view];
        return;
    }
    NSString *reportLevel = self.valueSourceArray[self.selectIndexPath.row];
    NSString *reportName = self.dataSourceArray[self.selectIndexPath.row];
    if (self.chooseBlock) {
        self.chooseBlock(reportLevel, reportName);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHDefenseMeteChooseCell *chooseCell = [tableView dequeueReusableCellWithIdentifier:@"chooseCell" forIndexPath:indexPath];
    chooseCell.nameLabel.text = self.dataSourceArray[indexPath.row];
    NSLog(@"selectValue : %@",self.selectValue);
    chooseCell.chooseImageView.hidden = [self.selectValue isEqualToString:self.dataSourceArray[indexPath.row]] ? NO : YES;
    chooseCell.nameLabel.textColor = [self.selectValue isEqualToString:self.dataSourceArray[indexPath.row]] ? [UIColor colorWithHexString:@"#2EB0FF"] : [UIColor colorWithHexString:@"#222222"];
    chooseCell.selected = [self.selectValue isEqualToString:self.dataSourceArray[indexPath.row]];
    return chooseCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (int i = 0; i < self.dataSourceArray.count; i ++) {
        GSHDefenseMeteChooseCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.chooseImageView.hidden = YES;
        cell.nameLabel.textColor = [UIColor colorWithHexString:@"#222222"];
    }
    GSHDefenseMeteChooseCell *tmpCell = [tableView cellForRowAtIndexPath:indexPath];
    tmpCell.chooseImageView.hidden = NO;
    tmpCell.nameLabel.textColor = [UIColor colorWithHexString:@"#2EB0FF"];
    self.selectIndexPath = indexPath;
    self.selectValue = self.dataSourceArray[indexPath.row];
}


@end

@implementation GSHDefenseMeteChooseCell



@end
