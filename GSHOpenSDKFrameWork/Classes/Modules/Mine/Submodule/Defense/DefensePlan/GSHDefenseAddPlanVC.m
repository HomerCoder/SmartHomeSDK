//
//  GSHDefenseAddPlanVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/6/3.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDefenseAddPlanVC.h"
#import "GSHDefensePlanTimeSetVC.h"
#import "UITextField+TZM.h"
#import "NSString+TZM.h"

@implementation GSHDefenseAddPlanOneCell

@end

@implementation GSHDefenseAddPlanTwoCell

@end

@interface GSHDefenseAddPlanVC () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *addPlanTableView;
@property (assign, nonatomic) GSHDefensePlanSetType planSetType;
@property (strong, nonatomic) NSArray *weekArray;
@property (weak, nonatomic) UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) GSHDefensePlanM *defensePlanSetM;

@end

@implementation GSHDefenseAddPlanVC

+(instancetype)defenseAddPlanVCWithPlanSetType:(GSHDefensePlanSetType)planSetType defensePlanM:(GSHDefensePlanM *)defensePlanM {
    GSHDefenseAddPlanVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDefensePlanSB" andID:@"GSHDefenseAddPlanVC"];
    vc.planSetType = planSetType;
    if (planSetType == GSHDefensePlanSetEdit) {
        vc.defensePlanSetM = defensePlanM;
    }
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.weekArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    if (self.planSetType == GSHDefensePlanSetAdd) {
        self.defensePlanSetM = [[GSHDefensePlanM alloc] init];
        self.defensePlanSetM.monTime = [self allDayOpenTimeStr];
        self.defensePlanSetM.tueTime = [self allDayOpenTimeStr];
        self.defensePlanSetM.wedTime = [self allDayOpenTimeStr];
        self.defensePlanSetM.thuTime = [self allDayOpenTimeStr];
        self.defensePlanSetM.friTime = [self allDayOpenTimeStr];
        self.defensePlanSetM.sauTime = [self allDayOpenTimeStr];
        self.defensePlanSetM.sunTime = [self allDayOpenTimeStr];
    }
    self.deleteButton.hidden = (self.planSetType == GSHDefensePlanSetAdd || [self.defensePlanSetM.templateType isEqualToString:@"0"]) ? YES : NO;
    self.saveButton.hidden = [self.defensePlanSetM.templateType isEqualToString:@"0"] ? YES : NO;
    self.title = self.planSetType == GSHDefensePlanSetAdd ? @"新增计划" : @"编辑计划";
    
    [self observerNotifications];
    
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
}

-(void)handleNotifications:(NSNotification *)notification{
}

#pragma mark - Action

- (IBAction)saveButtonClick:(id)sender {
    self.defensePlanSetM.templateName = self.nameTextField.text;
    if(self.defensePlanSetM.templateName.length == 0){
        [TZMProgressHUDManager showErrorWithStatus:@"请输入计划名称" inView:self.view];
        return;
    }
    if ([self.defensePlanSetM.templateName tzm_judgeTheillegalCharacter]) {
        [TZMProgressHUDManager showErrorWithStatus:@"名字不能含特殊字符" inView:self.view];
        return;
    }
    
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"保存中" inView:self.view];
    [GSHDefensePlanManager addDefensePlanWithPlanSetM:self.defensePlanSetM familyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"添加成功" inView:self.view];
            if (self.planSetType == GSHDefensePlanSetAdd) {
                if (self.addButtonClickBlock) {
                    self.addButtonClickBlock();
                }
            } else {
                if (self.updateSuccessBlock) {
                    self.updateSuccessBlock(self.defensePlanSetM);
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

// 删除计划
- (IBAction)deleteButtonClick:(id)sender {
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
    [GSHDefensePlanManager deleteDefensePlanWithPlanTemplateId:self.defensePlanSetM.templateId block:^(NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"删除成功" inView:self.view];
            if (self.deleteButtonClickBlock) {
                self.deleteButtonClickBlock(self.defensePlanSetM.templateId);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.defensePlanSetM.templateName = self.nameTextField.text;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 7;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.0001f;
    }
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GSHDefenseAddPlanOneCell *oneCell = [tableView dequeueReusableCellWithIdentifier:@"oneCell" forIndexPath:indexPath];
        if (self.defensePlanSetM) {
            oneCell.planNameTextField.enabled = [self.defensePlanSetM.templateType isEqualToString:@"0"] ? NO : YES; 
        } else {
            oneCell.planNameTextField.enabled = YES;
        }
        oneCell.planNameTextField.text = self.defensePlanSetM.templateName.length>0?self.defensePlanSetM.templateName:@"";
        self.nameTextField = oneCell.planNameTextField;
        self.nameTextField.delegate = self;
        return oneCell;
    } else {
        GSHDefenseAddPlanTwoCell *twoCell = [tableView dequeueReusableCellWithIdentifier:@"twoCell" forIndexPath:indexPath];
        twoCell.typeNameLabel.text = self.weekArray[indexPath.row];
        twoCell.timeLabel.text = [self getShowStrWithIndexRow:(int)indexPath.row];
        return twoCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.defensePlanSetM.templateType isEqualToString:@"0"] && indexPath.section == 1) {
        // 选择时间
        NSString *timeStr = @"";
        if (indexPath.row == 0) {
            timeStr = self.defensePlanSetM.monTime;
        } else if (indexPath.row == 1) {
            timeStr = self.defensePlanSetM.tueTime;
        } else if (indexPath.row == 2) {
            timeStr = self.defensePlanSetM.wedTime;
        } else if (indexPath.row == 3) {
            timeStr = self.defensePlanSetM.thuTime;
        } else if (indexPath.row == 4) {
            timeStr = self.defensePlanSetM.friTime;
        } else if (indexPath.row == 5) {
            timeStr = self.defensePlanSetM.sauTime;
        } else if (indexPath.row == 6) {
            timeStr = self.defensePlanSetM.sunTime;
        }
        GSHDefenseAddPlanTwoCell *twoCell = (GSHDefenseAddPlanTwoCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSString *title = self.weekArray[indexPath.row];
        GSHDefensePlanTimeSetVC *defensePlanTimeSetVC = [GSHDefensePlanTimeSetVC defensePlanTimeSetVCWithTitle:title timeStr:timeStr];
        __weak typeof(twoCell) weakTwoCell = twoCell;
        @weakify(self)
        defensePlanTimeSetVC.sureButtonClickBlock = ^(NSString * _Nonnull showStr, NSString * _Nonnull timeStr) {
            __strong typeof(weakTwoCell) strongTwoCell = weakTwoCell;
            @strongify(self)
            strongTwoCell.timeLabel.text = showStr;
            if (indexPath.row == 0) {
                self.defensePlanSetM.monTime = timeStr;
            } else if (indexPath.row == 1) {
                self.defensePlanSetM.tueTime = timeStr;
            } else if (indexPath.row == 2) {
                self.defensePlanSetM.wedTime = timeStr;
            } else if (indexPath.row == 3) {
                self.defensePlanSetM.thuTime = timeStr;
            } else if (indexPath.row == 4) {
                self.defensePlanSetM.friTime = timeStr;
            } else if (indexPath.row == 5) {
                self.defensePlanSetM.sauTime = timeStr;
            } else if (indexPath.row == 6) {
                self.defensePlanSetM.sunTime = timeStr;
            }
        };
        [self.navigationController pushViewController:defensePlanTimeSetVC animated:YES];
    }
}

// 没选时间时，默认全天，字符串为48位1
- (NSString *)allDayOpenTimeStr {
    NSMutableString *str = [NSMutableString string];
    for (int i = 0 ; i < 48; i ++) {
        [str appendString:@"1"];
    }
    return str;
}

- (NSString *)getShowStrWithIndexRow:(int)row {
    if (row == 0) {
        return [self getShowStrWithBinaryTimeStr:self.defensePlanSetM.monTime];
    } else if (row == 1) {
        return [self getShowStrWithBinaryTimeStr:self.defensePlanSetM.tueTime];
    } else if (row == 2) {
        return [self getShowStrWithBinaryTimeStr:self.defensePlanSetM.wedTime];
    } else if (row == 3) {
        return [self getShowStrWithBinaryTimeStr:self.defensePlanSetM.thuTime];
    } else if (row == 4) {
        return [self getShowStrWithBinaryTimeStr:self.defensePlanSetM.friTime];
    } else if (row == 5) {
        return [self getShowStrWithBinaryTimeStr:self.defensePlanSetM.sauTime];
    } else {
        return [self getShowStrWithBinaryTimeStr:self.defensePlanSetM.sunTime];
    }
}

- (NSString *)getShowStrWithBinaryTimeStr:(NSString *)binaryTimeStr {
    NSString *showStr = @"";
    if (binaryTimeStr.intValue == 0) {
        showStr = @"关闭";
    } else {
        NSRange startRange = [binaryTimeStr rangeOfString:@"1"];
        if (startRange.location != NSNotFound) {
            NSRange endRange = [binaryTimeStr rangeOfString:@"1" options:NSBackwardsSearch];
            if (startRange.location == 0 && endRange.location == 47) {
                // 全天
                showStr = @"全天";
            } else {
                int startLocation = (int)startRange.location;
                int startHour = startLocation / 2;
                int startMinute = startLocation % 2 == 0 ? 0 : 30;
                int endLocation = (int)endRange.location;
                int endHour = (endLocation+1) / 2;
                int endMinute = endLocation % 2 - 1 == 0 ? 0 : 30;
                
                NSString *startTime = [NSString stringWithFormat:@"%02d:%02d",startHour,startMinute];
                NSString *endTime = [NSString stringWithFormat:@"%02d:%02d",endHour,endMinute];
                showStr = [NSString stringWithFormat:@"开启 (%@ -- %@)",startTime,endTime];
            }
        }
    }
    return showStr;
}

@end
