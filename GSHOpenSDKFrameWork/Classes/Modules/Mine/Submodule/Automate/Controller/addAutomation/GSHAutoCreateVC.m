//
//  GSHAutoCreateVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/11/13.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAutoCreateVC.h"
#import "GSHAddTriggerConditionVC.h"
#import "GSHAutoEffectTimeSetVC.h"
#import "GSHAutoAddActionVC.h"
#import "GSHAutoTimeSetVC.h"
#import <TZMButton.h>
#import "GSHAlertManager.h"
#import "GSHDeviceMachineViewModel.h"
#import "NSString+TZM.h"
#import "GSHChooseDeviceListCell.h"

@implementation GSHAutoCreateTimeCell

@end

@implementation GSHAutoCreateDeviceCell

@end

@interface GSHAutoCreateVC () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (assign, nonatomic) AddAutoVCType addAutoVCType;

@property (strong, nonatomic) NSArray *sectionHeadTitleArray;

@property (weak, nonatomic) IBOutlet UITableView *addTableView;
@property (weak, nonatomic) IBOutlet UITextField *autoNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *effectTimeLabel;

// 定时条件
@property (strong, nonatomic) NSString *requiredCondition_time; // 必选
@property (strong, nonatomic) NSString *requiredCondition_repeatCount;
@property (strong, nonatomic) NSMutableIndexSet *requiredCondition_weekIndexSet;
@property (strong, nonatomic) NSMutableArray *requiredCondition_deviceArray;
@property (strong, nonatomic) NSString *optionalCondition_time; // 可选
@property (strong, nonatomic) NSString *optionalCondition_repeatCount;
@property (strong, nonatomic) NSMutableIndexSet *optionalCondition_weekIndexSet;
@property (strong, nonatomic) NSMutableArray *optionalCondition_deviceArray;

@property (strong, nonatomic) NSMutableArray *action_deviceArray;

// 生效时间段
@property (strong, nonatomic) NSMutableIndexSet *effectTimeWeekIndexSet;
@property (strong, nonatomic) NSString *effectStartTime;
@property (strong, nonatomic) NSString *effectEndTime;

@property (strong, nonatomic) GSHOssAutoM *ossSetAutoM;
@property (strong, nonatomic) GSHOssAutoM *oldOssAutoM;
@property (strong, nonatomic) GSHAutoM *setAutoM;
@property (strong, nonatomic) GSHAutoM *oldAutoM;
@property (strong, nonatomic) GSHAutoTriggerM *triggerM;

@property (nonatomic , strong) NSMutableArray *action_deviceTypeArray; // 执行动作 - 存储无设备的设备类型
@property (nonatomic , strong) NSMutableArray *requeiredTrigger_deviceTypeArray; // 必选条件 - 存储无设备的设备类型
@property (nonatomic , strong) NSMutableArray *optionalTrigger_deviceTypeArray; // 可选条件 - 存储无设备的设备类型

@end

@implementation GSHAutoCreateVC

+ (instancetype)autoCreateVCWithAutoVCType:(AddAutoVCType)addAutoVCType
                                  oldAutoM:(GSHAutoM *)oldAutoM
                               oldOssAutoM:(GSHOssAutoM *)oldOssAutoM  {
    GSHAutoCreateVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddAutomationSB" andID:@"GSHAutoCreateVC"];
    vc.addAutoVCType = addAutoVCType;
    if (oldAutoM) {
        vc.oldAutoM = [oldAutoM yy_modelCopy];
    }
    if (oldOssAutoM) {
        vc.oldOssAutoM = [oldOssAutoM yy_modelCopy];
    }
    return vc;
}

// 玩转 -- 领走 调用
+ (instancetype)autoCreateVCWithAutoListDataDictionary:(NSDictionary *)dataDictionary {
    GSHAutoCreateVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddAutomationSB" andID:@"GSHAutoCreateVC"];
    vc.addAutoVCType = AddAutoVCTypeTemplate;
    vc.oldAutoM = [GSHAutoM yy_modelWithDictionary:dataDictionary];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.requiredCondition_deviceArray = [NSMutableArray array];
    self.requiredCondition_weekIndexSet = [NSMutableIndexSet indexSet];
    self.optionalCondition_deviceArray = [NSMutableArray array];
    self.optionalCondition_weekIndexSet = [NSMutableIndexSet indexSet];
    self.action_deviceArray = [NSMutableArray array];
    self.effectTimeWeekIndexSet = [NSMutableIndexSet indexSet];
    self.action_deviceTypeArray = [NSMutableArray array];
    self.optionalTrigger_deviceTypeArray = [NSMutableArray array];
    self.requeiredTrigger_deviceTypeArray = [NSMutableArray array];
    
    [self.addTableView registerNib:[UINib nibWithNibName:@"GSHChooseDeviceListCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"chooseDeviceListCell"];
    
    self.sectionHeadTitleArray = @[@"如果满足以下任一条件（必选）",@"并且执行以下全部条件（可选）",@"就执行以下操作"];
    
    if (self.addAutoVCType == AddAutoVCTypeEdit) {
        // 编辑联动
        self.navigationItem.title = @"编辑联动";
        [self initEditData];
    } else if (self.addAutoVCType == AddAutoVCTypeTemplate) {
        // 模版创建联动
        self.navigationItem.title = @"激活联动";
        [self initEditData];
        // 请求联动模版设备
        [self getTemplateDetailInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId.numberValue templateId:self.setAutoM.tplId];
    } else {
        // 添加联动
        self.navigationItem.title = @"自定义联动";
        self.effectTimeLabel.text = @"全天";
        self.effectStartTime = @"00:00";
        self.effectEndTime = @"00:00";
        self.effectTimeWeekIndexSet = [[self getWeekIndexSetWithWeek:127] mutableCopy];
    }
}

- (void)initEditData {
    if (self.addAutoVCType == AddAutoVCTypeTemplate) {
        // 来源于联动模版
        self.autoNameTextField.text = self.oldAutoM.tplName.length > 0 ? self.oldAutoM.tplName : @"";
        self.oldAutoM.automationName = self.oldAutoM.tplName;
    } else {
        self.autoNameTextField.text = self.oldAutoM.automationName.length > 0 ? self.oldAutoM.automationName : @"";
    }

    self.setAutoM = [self.oldAutoM yy_modelCopy];
    if (self.oldOssAutoM) {
        self.ossSetAutoM = [self.oldOssAutoM yy_modelCopy];
    }
    self.triggerM = self.oldAutoM.trigger;
    
    if (self.setAutoM.trigger.isSetRequiredTime) {
        // 必选条件 -- 有定时条件
        GSHAutoTriggerConditionListM *conditionListM = self.setAutoM.trigger.conditionList[0];
        self.requiredCondition_time = conditionListM.getDateTimer;
        self.requiredCondition_weekIndexSet = [[self getWeekIndexSetWithWeek:conditionListM.week] mutableCopy];
        self.requiredCondition_repeatCount = [conditionListM getWeekStrWithIndexSet:self.requiredCondition_weekIndexSet];
    } else if (self.setAutoM.trigger.isSetOptionalTime) {
        // 可选条件 -- 有定时条件
        GSHAutoTriggerConditionListM *conditionListM = self.setAutoM.trigger.optionalConditionList[0];
        self.optionalCondition_time = conditionListM.getDateTimer;
        self.optionalCondition_weekIndexSet = [[self getWeekIndexSetWithWeek:conditionListM.week] mutableCopy];
        self.optionalCondition_repeatCount = [conditionListM getWeekStrWithIndexSet:self.optionalCondition_weekIndexSet];
    }
    
    if (self.action_deviceArray.count > 0) {
        [self.action_deviceArray removeAllObjects];
    }
    if (self.setAutoM.actionList.count > 0) {
        for (GSHAutoActionListM *autoActionListM in self.setAutoM.actionList) {
            [self.action_deviceArray addObject:autoActionListM];
        }
    }
    
    if (self.requiredCondition_deviceArray.count > 0) {
        [self.requiredCondition_deviceArray removeAllObjects];
    }
    
    if (self.triggerM.conditionList.count > 0) {
        for (GSHAutoTriggerConditionListM *conditionListM in self.triggerM.conditionList) {
            if (conditionListM.device) {
                [self.requiredCondition_deviceArray addObject:conditionListM];
            }
        }
    }
    
    if (self.optionalCondition_deviceArray.count > 0) {
        [self.optionalCondition_deviceArray removeAllObjects];
    }
    
    if (self.triggerM.optionalConditionList.count > 0) {
        for (GSHAutoTriggerConditionListM *conditionListM in self.triggerM.optionalConditionList) {
            if (conditionListM.device) {
                [self.optionalCondition_deviceArray addObject:conditionListM];
            }
        }
    }
    
    // 生效时间段
    self.effectTimeWeekIndexSet = [[self getWeekIndexSetWithWeek:self.setAutoM.week] mutableCopy];
    if (self.setAutoM.getStartTime && self.setAutoM.getEndTime) {
        self.effectStartTime = self.setAutoM.getStartTime;
        if ([self.setAutoM.getStartTime isEqualToString:self.setAutoM.getEndTime]) {
            self.effectTimeLabel.text = @"全天";
            self.effectEndTime = self.setAutoM.getEndTime;
        } else {
            NSDate *tmpStartTime = [NSDate dateWithString:self.setAutoM.getStartTime format:@"HH:mm"];
            NSDate *tmpEndTime = [NSDate dateWithString:self.setAutoM.getEndTime format:@"HH:mm"];
            if (tmpEndTime.timeIntervalSinceReferenceDate < tmpStartTime.timeIntervalSinceReferenceDate) {
                self.effectEndTime = [NSString stringWithFormat:@"n%@",self.setAutoM.getEndTime];
            } else {
                self.effectEndTime = self.setAutoM.getEndTime;
            }
            if ([self.effectEndTime containsString:@"n"]) {
                self.effectTimeLabel.text = [NSString stringWithFormat:@"%@ - %@(第二天)",self.effectStartTime,[self.effectEndTime substringFromIndex:1]];
            } else {
                self.effectTimeLabel.text = [NSString stringWithFormat:@"%@ - %@",self.effectStartTime,self.effectEndTime];
            }
        }
    } else {
        self.effectTimeLabel.text = @"";
    }
}

#pragma mark - Lazy
- (GSHAutoM *)setAutoM {
    if (!_setAutoM) {
        _setAutoM = [[GSHAutoM alloc] init];
        _setAutoM.trigger = self.triggerM;
    }
    return _setAutoM;
}

- (GSHAutoTriggerM *)triggerM {
    if (!_triggerM) {
        _triggerM = [[GSHAutoTriggerM alloc] init];
        _triggerM.name = @"测试";
    }
    return _triggerM;
}

- (GSHOssAutoM *)ossSetAutoM {
    if (!_ossSetAutoM) {
        _ossSetAutoM = [[GSHOssAutoM alloc] init];
    }
    return _ossSetAutoM;
}

- (NSMutableIndexSet *)effectTimeWeekIndexSet {
    if (!_effectTimeWeekIndexSet) {
        _effectTimeWeekIndexSet = [NSMutableIndexSet indexSet];
    }
    return _effectTimeWeekIndexSet;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionHeadTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.requiredCondition_time.length > 0 ? self.requeiredTrigger_deviceTypeArray.count + self.requiredCondition_deviceArray.count + 1 : self.requeiredTrigger_deviceTypeArray.count + self.requiredCondition_deviceArray.count;
    } else if (section == 1) {
        return self.optionalCondition_time.length > 0 ? self.optionalTrigger_deviceTypeArray.count + self.optionalCondition_deviceArray.count + 1 : self.optionalTrigger_deviceTypeArray.count + self.optionalCondition_deviceArray.count;
    } else {
        return self.action_deviceTypeArray.count + self.action_deviceArray.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return self.requiredCondition_time.length > 0 ? 70.0 : 60.0;
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        return self.optionalCondition_time.length > 0 ? 70.0 : 60.0;
    }
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSInteger deviceTypeBeginIndex = self.requiredCondition_time.length > 0 ? 1 : 0;
        NSInteger deviceBeginIndex = deviceTypeBeginIndex+self.requeiredTrigger_deviceTypeArray.count;
        if (indexPath.row == 0 && self.requiredCondition_time.length > 0) {
            // 有必选时间条件
            GSHAutoCreateTimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"timeCell" forIndexPath:indexPath];
            timeCell.timeLabel.text = self.requiredCondition_time;
            timeCell.weekLabel.text = self.requiredCondition_repeatCount;
            return timeCell;
        } else if (self.requeiredTrigger_deviceTypeArray.count > 0 &&
                   indexPath.row >= deviceTypeBeginIndex &&
                   indexPath.row < deviceTypeBeginIndex+self.requeiredTrigger_deviceTypeArray.count) {
            
            GSHChooseDeviceListCell *chooseDeviceListCell = [tableView dequeueReusableCellWithIdentifier:@"chooseDeviceListCell" forIndexPath:indexPath];
            GSHDeviceTypeM *deviceTypeM = self.requeiredTrigger_deviceTypeArray[indexPath.row-deviceTypeBeginIndex];
            chooseDeviceListCell.checkButton.hidden = YES;
            chooseDeviceListCell.deviceActionLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            chooseDeviceListCell.deviceActionLabel.text = @"暂无设备";
            [chooseDeviceListCell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:deviceTypeM.picPath]];
            chooseDeviceListCell.deviceNameLabel.text = deviceTypeM.deviceTypeStr;
            return chooseDeviceListCell;
        } else {
            GSHAutoCreateDeviceCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
            GSHAutoTriggerConditionListM *triggerConditionM = self.requiredCondition_deviceArray[indexPath.row-deviceBeginIndex];
            [deviceCell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:triggerConditionM.device.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
            deviceCell.deviceNameLabel.text = triggerConditionM.device.deviceName;
            if (triggerConditionM.device.exts.count > 0) {
                deviceCell.deviceExtLabel.text = [GSHDeviceMachineViewModel getDeviceShowStrWithDeviceM:triggerConditionM.device];
            } else {
                deviceCell.deviceExtLabel.text = @"";
            }
            return deviceCell;
        }
    } if (indexPath.section == 1) {
        
        NSInteger deviceTypeBeginIndex = self.optionalCondition_time.length > 0 ? 1 : 0;
        NSInteger deviceBeginIndex = deviceTypeBeginIndex+self.optionalTrigger_deviceTypeArray.count;
        
        if (indexPath.row == 0 && self.optionalCondition_time.length > 0) {
            // 有可选时间条件
            GSHAutoCreateTimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"timeCell" forIndexPath:indexPath];
            timeCell.timeLabel.text = self.optionalCondition_time;
            timeCell.weekLabel.text = self.optionalCondition_repeatCount;
            return timeCell;
        } else if (self.optionalTrigger_deviceTypeArray.count > 0 &&
                   indexPath.row >= deviceTypeBeginIndex &&
                   indexPath.row < deviceTypeBeginIndex+self.optionalTrigger_deviceTypeArray.count) {
            
            GSHChooseDeviceListCell *chooseDeviceListCell = [tableView dequeueReusableCellWithIdentifier:@"chooseDeviceListCell" forIndexPath:indexPath];
            GSHDeviceTypeM *deviceTypeM = self.optionalTrigger_deviceTypeArray[indexPath.row-deviceTypeBeginIndex];;
            chooseDeviceListCell.checkButton.hidden = YES;
            chooseDeviceListCell.deviceActionLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            chooseDeviceListCell.deviceActionLabel.text = @"暂无设备";
            [chooseDeviceListCell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:deviceTypeM.picPath]];
            chooseDeviceListCell.deviceNameLabel.text = deviceTypeM.deviceTypeStr;
            return chooseDeviceListCell;
            
        } else {
            GSHAutoCreateDeviceCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
            GSHAutoTriggerConditionListM *triggerConditionM = self.optionalCondition_deviceArray[indexPath.row-deviceBeginIndex];;
            [deviceCell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:triggerConditionM.device.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
            deviceCell.deviceNameLabel.text = triggerConditionM.device.deviceName;
            if (triggerConditionM.device.exts.count > 0) {
                deviceCell.deviceExtLabel.text = [GSHDeviceMachineViewModel getDeviceShowStrWithDeviceM:triggerConditionM.device];
            } else {
                deviceCell.deviceExtLabel.text = @"";
            }
            return deviceCell;
        }
    } else {
        // 执行动作
        NSInteger deviceBeginIndex = self.action_deviceTypeArray.count > 0 ? self.action_deviceTypeArray.count : 0;
        
        if (self.action_deviceTypeArray.count > 0 && indexPath.row < self.action_deviceTypeArray.count) {
            GSHChooseDeviceListCell *chooseDeviceListCell = [tableView dequeueReusableCellWithIdentifier:@"chooseDeviceListCell" forIndexPath:indexPath];
            GSHDeviceTypeM *deviceTypeM = self.action_deviceTypeArray[indexPath.row];;
            chooseDeviceListCell.checkButton.hidden = YES;
            chooseDeviceListCell.deviceActionLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            chooseDeviceListCell.deviceActionLabel.text = @"暂无设备";
            [chooseDeviceListCell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:deviceTypeM.picPath]];
            chooseDeviceListCell.deviceNameLabel.text = deviceTypeM.deviceTypeStr;
            return chooseDeviceListCell;
        } else {
            GSHAutoCreateDeviceCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
            GSHAutoActionListM *autoActionListM = self.action_deviceArray[indexPath.row-deviceBeginIndex];
            deviceCell.deviceNameLabel.text = autoActionListM.getActionName;
            if (autoActionListM.scenarioId) {
                deviceCell.deviceIconImageView.image = [UIImage ZHImageNamed:@"automation_icon_scenario"];
            } else if (autoActionListM.ruleId) {
                deviceCell.deviceIconImageView.image = [UIImage ZHImageNamed:@"automation_icon_automation"];
            } else {
                if (autoActionListM.device.homePageIcon) {
                    [deviceCell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:autoActionListM.device.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
                } else {
                    [deviceCell.deviceIconImageView sd_setImageWithURL:[GSHDeviceMachineViewModel deviceModelImageUrlWithDevice:autoActionListM.device] placeholderImage:DeviceIconPlaceHoldImage];
                }
            }
            if (autoActionListM.device.exts.count > 0) {
                deviceCell.deviceExtLabel.text = [GSHDeviceMachineViewModel getDeviceShowStrWithDeviceM:autoActionListM.device];
            } else {
                deviceCell.deviceExtLabel.text = @"";
            }
            return deviceCell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.view endEditing:YES];
    if (indexPath.section == 0) {
        NSInteger deviceTypeBeginIndex = self.requiredCondition_time.length > 0 ? 1 : 0;
        NSInteger deviceBeginIndex = deviceTypeBeginIndex+self.requeiredTrigger_deviceTypeArray.count;
        // 必选条件
        if (self.requiredCondition_time.length > 0 && indexPath.row == 0) {
            // 有必选条件 -- 定时条件
            GSHAutoTimeSetVC *timeSetVC = [GSHAutoTimeSetVC autoTimeSetVCWithOldTime:self.requiredCondition_time choosedIndexSet:self.requiredCondition_weekIndexSet];
            @weakify(self)
            timeSetVC.compeleteSetTimeBlock = ^(NSString *time, NSString *repeatCount,NSIndexSet *repeatCountIndexSet) {
                @strongify(self)
                self.requiredCondition_time = time;
                self.requiredCondition_repeatCount = repeatCount;
                self.requiredCondition_weekIndexSet = [repeatCountIndexSet mutableCopy];
                // 选择了定时条件 -- 生效时间段默认为全天
                self.effectTimeLabel.text = @"全天";
                self.effectStartTime = @"00:00";
                self.effectEndTime = @"00:00";
                [self.effectTimeWeekIndexSet removeAllIndexes];
                [self.addTableView reloadData];
            };
            [self.navigationController pushViewController:timeSetVC animated:YES];
            return;
        } else if (self.requeiredTrigger_deviceTypeArray.count > 0 &&
                    indexPath.row >= deviceTypeBeginIndex &&
                    indexPath.row < deviceTypeBeginIndex+self.requeiredTrigger_deviceTypeArray.count) {
            // 设备品类点击不响应
            return;
        } else {
            GSHAutoTriggerConditionListM *triggerConditionListM = self.requiredCondition_deviceArray[indexPath.row-deviceBeginIndex];
            if ([triggerConditionListM.device.deviceType isEqual:GSHSOSSensorDeviceType]) {
                [TZMProgressHUDManager showErrorWithStatus:@"紧急按钮不可再选" inView:self.view];
                return;
            }
            GSHAutoCreateDeviceCell *deviceCell = (GSHAutoCreateDeviceCell *)[tableView cellForRowAtIndexPath:indexPath];
            __weak typeof(triggerConditionListM.device) weakDeviceM = triggerConditionListM.device;
            __weak typeof(deviceCell) weakDeviceCell = deviceCell;
            [GSHDeviceMachineViewModel jumpToDeviceHandleVCWithVC:self
                                                      deviceM:triggerConditionListM.device
                                               deviceEditType:GSHDeviceVCTypeAutoTriggerSet
                                       deviceSetCompleteBlock:^(NSArray * _Nonnull exts) {
                                           __strong typeof(weakDeviceM) strongDeviceM = weakDeviceM;
                                           __strong typeof(weakDeviceCell) strongDeviceCell = weakDeviceCell;
                                           [strongDeviceM.exts removeAllObjects];
                                           [strongDeviceM.exts addObjectsFromArray:exts];
                                           strongDeviceCell.deviceExtLabel.text = [GSHDeviceMachineViewModel getDeviceShowStrWithDeviceM:strongDeviceM];
                                       }];
        }
    } else if (indexPath.section == 1) {
        // 可选条件
        NSInteger deviceTypeBeginIndex = self.optionalCondition_time.length > 0 ? 1 : 0;
        NSInteger deviceBeginIndex = deviceTypeBeginIndex+self.optionalTrigger_deviceTypeArray.count;
        
        // 必选条件
        if (self.optionalCondition_time.length > 0 && indexPath.row == 0) {
            // 有可选条件 -- 定时条件
            GSHAutoTimeSetVC *timeSetVC = [GSHAutoTimeSetVC autoTimeSetVCWithOldTime:self.optionalCondition_time choosedIndexSet:self.optionalCondition_weekIndexSet];
            @weakify(self)
            timeSetVC.compeleteSetTimeBlock = ^(NSString *time, NSString *repeatCount,NSIndexSet *repeatCountIndexSet) {
                @strongify(self)
                self.optionalCondition_time = time;
                self.optionalCondition_repeatCount = repeatCount;
                self.optionalCondition_weekIndexSet = [repeatCountIndexSet mutableCopy];
                // 选择了定时条件 -- 生效时间段默认为全天
                self.effectTimeLabel.text = @"全天";
                self.effectStartTime = @"00:00";
                self.effectEndTime = @"00:00";
                [self.effectTimeWeekIndexSet removeAllIndexes];
                [self.addTableView reloadData];
            };
            [self.navigationController pushViewController:timeSetVC animated:YES];
            return;
        } else if (self.optionalTrigger_deviceTypeArray.count > 0 &&
                   indexPath.row >= deviceTypeBeginIndex &&
                   indexPath.row < deviceTypeBeginIndex+self.optionalTrigger_deviceTypeArray.count) {
            
            return;
            
        } else {
            GSHAutoTriggerConditionListM *triggerConditionListM = self.optionalCondition_deviceArray[indexPath.row-deviceBeginIndex];
            if ([triggerConditionListM.device.deviceType isEqual:GSHSOSSensorDeviceType]) {
                [TZMProgressHUDManager showErrorWithStatus:@"紧急按钮不可再选" inView:self.view];
                return;
            }
            GSHAutoCreateDeviceCell *deviceCell = (GSHAutoCreateDeviceCell *)[tableView cellForRowAtIndexPath:indexPath];
            __weak typeof(triggerConditionListM.device) weakDeviceM = triggerConditionListM.device;
            __weak typeof(deviceCell) weakDeviceCell = deviceCell;
            [GSHDeviceMachineViewModel jumpToDeviceHandleVCWithVC:self
                                                      deviceM:triggerConditionListM.device
                                               deviceEditType:GSHDeviceVCTypeAutoTriggerSet
                                       deviceSetCompleteBlock:^(NSArray * _Nonnull exts) {
                                           __strong typeof(weakDeviceM) strongDeviceM = weakDeviceM;
                                           __strong typeof(weakDeviceCell) strongDeviceCell = weakDeviceCell;
                                           [strongDeviceM.exts removeAllObjects];
                                           [strongDeviceM.exts addObjectsFromArray:exts];
                                           strongDeviceCell.deviceExtLabel.text = [GSHDeviceMachineViewModel getDeviceShowStrWithDeviceM:strongDeviceM];
                                       }];
        }
    } else {
        // 执行动作
        if (self.action_deviceTypeArray.count > 0 && indexPath.row < self.action_deviceTypeArray.count) {
            return;
        }
        GSHAutoCreateDeviceCell *deviceCell = (GSHAutoCreateDeviceCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (self.action_deviceArray.count > indexPath.row-self.action_deviceTypeArray.count) {
            GSHAutoActionListM *autoActionListM = self.action_deviceArray[indexPath.row-self.action_deviceTypeArray.count];
            if (autoActionListM.device) {
                // 设备
                __weak typeof(autoActionListM.device) weakDeviceM = autoActionListM.device;
                __weak typeof(deviceCell) weakDeviceCell = deviceCell;
                [GSHDeviceMachineViewModel jumpToDeviceHandleVCWithVC:self
                                                          deviceM:autoActionListM.device
                                                   deviceEditType:GSHDeviceVCTypeAutoActionSet
                                           deviceSetCompleteBlock:^(NSArray * _Nonnull exts) {
                                               __strong typeof(weakDeviceM) strongDeviceM = weakDeviceM;
                                               __strong typeof(weakDeviceCell) strongDeviceCell = weakDeviceCell;
                                               [strongDeviceM.exts removeAllObjects];
                                               [strongDeviceM.exts addObjectsFromArray:exts];
                                               strongDeviceCell.deviceExtLabel.text = [GSHDeviceMachineViewModel getDeviceShowStrWithDeviceM:strongDeviceM];
                                           }];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isCanEdit = YES;
    if (indexPath.section == 0) {
        NSInteger deviceTypeBeginIndex = self.requiredCondition_time.length > 0 ? 1 : 0;
        if (self.requeiredTrigger_deviceTypeArray.count > 0 &&
                   indexPath.row >= deviceTypeBeginIndex &&
                   indexPath.row < deviceTypeBeginIndex+self.requeiredTrigger_deviceTypeArray.count) {
            isCanEdit = NO;
        }
    } else if (indexPath.section == 1) {
        NSInteger deviceTypeBeginIndex = self.optionalCondition_time.length > 0 ? 1 : 0;
        if (self.optionalTrigger_deviceTypeArray.count > 0 &&
                   indexPath.row >= deviceTypeBeginIndex &&
                   indexPath.row < deviceTypeBeginIndex+self.optionalTrigger_deviceTypeArray.count) {
            isCanEdit = NO;
        }
    } else {
        if (self.action_deviceTypeArray.count > 0 && indexPath.row < self.action_deviceTypeArray.count) {
            isCanEdit = NO;
        }
    }
    return isCanEdit;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            // 必选条件
            NSInteger deviceTypeBeginIndex = self.requiredCondition_time.length > 0 ? 1 : 0;
            NSInteger deviceBeginIndex = deviceTypeBeginIndex+self.requeiredTrigger_deviceTypeArray.count;
            if (self.requiredCondition_time.length > 0 && indexPath.row == 0) {
                // 删除必选定时条件
                self.requiredCondition_time = nil;
                self.requiredCondition_repeatCount = nil;
            } else {
                if (self.requiredCondition_deviceArray.count > indexPath.row-deviceBeginIndex) {
                    [self.requiredCondition_deviceArray removeObjectAtIndex:indexPath.row-deviceBeginIndex];
                }
            }
        } else if (indexPath.section == 1) {
            // 可选条件
            NSInteger deviceTypeBeginIndex = self.optionalCondition_time.length > 0 ? 1 : 0;
            NSInteger deviceBeginIndex = deviceTypeBeginIndex+self.optionalTrigger_deviceTypeArray.count;
            if (self.optionalCondition_time.length > 0 && indexPath.row == 0) {
                // 删除可选定时条件
                self.optionalCondition_time = nil;
                self.optionalCondition_repeatCount = nil;
            } else {
                if (self.optionalCondition_deviceArray.count > indexPath.row - deviceBeginIndex) {
                    [self.optionalCondition_deviceArray removeObjectAtIndex:indexPath.row - deviceBeginIndex];
                }
            }
        } else if (indexPath.section == 2) {
            // 执行动作
            if (self.action_deviceArray.count > indexPath.row-self.action_deviceTypeArray.count) {
                [self.action_deviceArray removeObjectAtIndex:indexPath.row-self.action_deviceTypeArray.count];
            }
        }
        [self.addTableView reloadData];
    }
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 56.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 56)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 24, 200, 20)];
    label.textColor = [UIColor colorWithHexString:@"#999999"];
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    label.text = self.sectionHeadTitleArray[section];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 55.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    TZMButton *button = [TZMButton buttonWithType:UIButtonTypeCustom];
    button.tag = section;
    button.backgroundColor = [UIColor whiteColor];
    button.frame = CGRectMake(0, 0, SCREEN_WIDTH, 55.0);
    [button setTitleColor:[UIColor colorWithHexString:@"#2EB0FF"] forState:UIControlStateNormal];
    [button setTitle:section==2 ? @"添加动作" : @"添加条件" forState:UIControlStateNormal];
    [button setImage:[UIImage ZHImageNamed:@"scene_device_add_icon"] forState:UIControlStateNormal];
    [button setImage:[UIImage ZHImageNamed:@"scene_device_add_icon"] forState:UIControlStateHighlighted];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    [button setImageDirection:TZMButtonImageDirectionLeft];
    [button addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (section == 1 && self.requiredCondition_time.length > 0) {
        // v3.1.1 必选条件 选择了定时条件 可选条件不可再选
        button.alpha = 0.3;
        button.enabled = NO;
    } else {
        button.alpha = 1;
        button.enabled = YES;
    }
    return button;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.autoNameTextField) {
        self.setAutoM.automationName = textField.text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length > 0 && textField == self.autoNameTextField) {
        NSString *str =@"^[A-Za-z0-9➋➌➍➎➏➐➑➒\\u4e00-\u9fa5]+$";
        NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
        if (![emailTest evaluateWithObject:string]) {
            return NO;
        }
    }
    return YES;
}


#pragma mark - method
- (void)addButtonClick:(UIButton *)button {
    [self.view endEditing:YES];
    NSInteger tag = button.tag;
    if (tag == 0) {
        // 添加条件 -- 必选条件
        BOOL isShowTimeCondition = YES;
        if (self.optionalCondition_deviceArray.count > 0) {
            // 可选条件选择了,必选也无法选择定时条件
            isShowTimeCondition = NO;
        }
        GSHAddTriggerConditionVC *addTriggerConditionVC = [GSHAddTriggerConditionVC addTriggerConditionVCWhitIsShowTimeCondition:isShowTimeCondition];
        addTriggerConditionVC.selectedDeviceArray = [self.requiredCondition_deviceArray mutableCopy];
        @weakify(self)
        addTriggerConditionVC.compeleteSetTimeBlock = ^(NSString *time, NSString *repeatCount,NSIndexSet *repeatCountIndexSet) {
            @strongify(self)
            self.requiredCondition_time = time;
            self.requiredCondition_repeatCount = repeatCount;
            self.requiredCondition_weekIndexSet = [repeatCountIndexSet mutableCopy];
            // 选择定时条件后 -- 生效时间段为全天
            self.effectTimeLabel.text = @"全天";
            self.effectStartTime = @"00:00";
            self.effectEndTime = @"00:00";
            [self.effectTimeWeekIndexSet removeAllIndexes];
            [self.addTableView reloadData];
        };
        addTriggerConditionVC.selectDeviceBlock = ^(NSArray *selectedDeviceArray) {
            @strongify(self)
            [self refreshTriggerConditionArrayWithDeviceArray:selectedDeviceArray selectedDeviceArray:self.requiredCondition_deviceArray];
            [self.addTableView reloadData];
        };
        [self.navigationController pushViewController:addTriggerConditionVC animated:YES];
    } else if (tag == 1) {
        // 添加条件 -- 可选条件
        GSHAddTriggerConditionVC *addTriggerConditionVC = [GSHAddTriggerConditionVC addTriggerConditionVCWhitIsShowTimeCondition:NO];
        addTriggerConditionVC.selectedDeviceArray = [self.optionalCondition_deviceArray mutableCopy];
        @weakify(self)
        addTriggerConditionVC.compeleteSetTimeBlock = ^(NSString *time, NSString *repeatCount,NSIndexSet *repeatCountIndexSet) {
            @strongify(self)
            self.optionalCondition_time = time;
            self.optionalCondition_repeatCount = repeatCount;
            self.optionalCondition_weekIndexSet = [repeatCountIndexSet mutableCopy];
            // 选择定时条件后 -- 生效时间段为全天
            self.effectTimeLabel.text = @"全天";
            self.effectStartTime = @"00:00";
            self.effectEndTime = @"00:00";
            [self.effectTimeWeekIndexSet removeAllIndexes];
            [self.addTableView reloadData];
        };
        addTriggerConditionVC.selectDeviceBlock = ^(NSArray *selectedDeviceArray) {
            @strongify(self)
            [self refreshTriggerConditionArrayWithDeviceArray:selectedDeviceArray selectedDeviceArray:self.optionalCondition_deviceArray];
            [self.addTableView reloadData];
        };
        [self.navigationController pushViewController:addTriggerConditionVC animated:YES];
    } else if (tag == 2) {
        // 添加动作
        GSHAutoAddActionVC *autoAddActionVC = [GSHAutoAddActionVC autoAddActionVC];
        autoAddActionVC.currentAutoId = self.addAutoVCType == AddAutoVCTypeEdit ? self.ossSetAutoM.ruleId.stringValue : @"";
        autoAddActionVC.choosedActionArray = [self.action_deviceArray copy];
        @weakify(self)
        autoAddActionVC.chooseSceneBlock = ^(NSArray *choosedArray , NSArray *noChoosedArray) {
            @strongify(self)
            for (GSHAutoActionListM *actionListM in noChoosedArray) {
                [self removeFromActionArrayWithActionListM:actionListM type:0];
            }
            if (choosedArray.count > 0) {
                [self.action_deviceArray addObjectsFromArray:choosedArray];
            }
            [self.addTableView reloadData];
        };
        autoAddActionVC.chooseAutoBlock = ^(NSArray *choosedArray, NSArray *noChoosedArray) {
            @strongify(self)
            for (GSHAutoActionListM *actionListM in noChoosedArray) {
                [self removeFromActionArrayWithActionListM:actionListM type:1];
            }
            if (choosedArray.count > 0) {
                [self.action_deviceArray addObjectsFromArray:choosedArray];
            }
            [self.addTableView reloadData];
        };
        autoAddActionVC.chooseDeviceBlock = ^(NSArray *selectedDeviceArray) {
            @strongify(self)
            [self refreshActionArrayWithDeviceArray:selectedDeviceArray];
            [self.addTableView reloadData];
        };
        [self.navigationController pushViewController:autoAddActionVC animated:YES];
    }
}

// 触发条件 -- 设备选择完成之后，刷新已选择设备情况
- (void)refreshTriggerConditionArrayWithDeviceArray:(NSArray *)deviceArray
                                selectedDeviceArray:(NSMutableArray *)selectedDeviceArray {
    NSMutableArray *shouldBeAddedArray = [NSMutableArray array];
    for (GSHDeviceM *deviceM in deviceArray) {
        BOOL isIn = NO;
        for (GSHAutoTriggerConditionListM *tmpTriggerConditionListM in selectedDeviceArray) {
            if ([deviceM.deviceId isKindOfClass:NSNumber.class]) {
                if (tmpTriggerConditionListM.device && [tmpTriggerConditionListM.device.deviceId isEqualToNumber:deviceM.deviceId]) {
                    isIn = YES;
                }
            }
        }
        if (!isIn) {
            GSHAutoTriggerConditionListM *triggerConditionListM = [[GSHAutoTriggerConditionListM alloc] init];
            triggerConditionListM.device = deviceM;
            [shouldBeAddedArray addObject:triggerConditionListM];
        }
    }
    
    NSMutableArray *shouldBeDeleteArray = [NSMutableArray array];
    for (GSHAutoTriggerConditionListM *tmpTriggerConditionListM in selectedDeviceArray) {
        BOOL isIn = NO;
        for (GSHDeviceM *deviceM in deviceArray) {
            if (tmpTriggerConditionListM.device) {
                if ([tmpTriggerConditionListM.device.deviceId isKindOfClass:NSNumber.class]) {
                    if ([deviceM.deviceId isEqualToNumber:tmpTriggerConditionListM.device.deviceId]) {
                        isIn = YES;
                    }
                }
            } else {
                isIn = YES;
            }
        }
        if (!isIn) {
            [shouldBeDeleteArray addObject:tmpTriggerConditionListM];
        }
    }
    if (shouldBeAddedArray.count > 0) {
        [selectedDeviceArray addObjectsFromArray:shouldBeAddedArray];
    }
    if (shouldBeDeleteArray.count > 0) {
        [selectedDeviceArray removeObjectsInArray:shouldBeDeleteArray];
    }
    for (GSHAutoTriggerConditionListM *conditionListM in selectedDeviceArray) {
        if (conditionListM.device.exts.count == 0) {
            [conditionListM.device.exts addObjectsFromArray:[GSHDeviceMachineViewModel getInitExtsWithDeviceM:conditionListM.device deviceEditType:GSHDeviceVCTypeAutoTriggerSet]];
        }
    }
}

- (void)removeFromActionArrayWithActionListM:(GSHAutoActionListM *)actionListM type:(int)type {
    for (GSHAutoActionListM *selectActionListM in self.action_deviceArray) {
        if (type == 0) {
            // 情景
            if ([actionListM.scenarioId isKindOfClass:NSNumber.class]) {
                if ([selectActionListM.scenarioId isEqualToNumber:actionListM.scenarioId]) {
                    [self.action_deviceArray removeObject:selectActionListM];
                    break;
                }
            }
        } else if (type == 1){
            // 联动
            if ([actionListM.ruleId isKindOfClass:NSNumber.class]) {
                if ([selectActionListM.ruleId isEqualToNumber:actionListM.ruleId]) {
                    [self.action_deviceArray removeObject:selectActionListM];
                    break;
                }
            }
        } else {
            // 设备
            if ([actionListM.device.deviceId isKindOfClass:NSNumber.class]) {
                if ([selectActionListM.device.deviceId isEqualToNumber:actionListM.device.deviceId]) {
                    [self.action_deviceArray removeObject:selectActionListM];
                    break;
                }
            }
        }
    }
}

// 执行动作 -- 设备选择完成之后，刷新已选择设备情况
- (void)refreshActionArrayWithDeviceArray:(NSArray *)deviceArray {
    NSMutableArray *shouldBeAddedArray = [NSMutableArray array];
    for (GSHDeviceM *deviceM in deviceArray) {
        BOOL isIn = NO;
        for (GSHAutoActionListM *selectedAutoActionListM in self.action_deviceArray) {
            if (selectedAutoActionListM.device && [deviceM.deviceId isKindOfClass:NSNumber.class]) {
                if ([selectedAutoActionListM.device.deviceId isEqualToNumber:deviceM.deviceId]) {
                    isIn = YES;
                }
            }
        }
        if (!isIn) {
            GSHAutoActionListM *autoActionListM = [[GSHAutoActionListM alloc] init];
            autoActionListM.device = deviceM;
            [shouldBeAddedArray addObject:autoActionListM];
        }
    }
    
    NSMutableArray *shouldBeDeleteArray = [NSMutableArray array];
    for (GSHAutoActionListM *selectedAutoActionListM in self.action_deviceArray) {
        BOOL isIn = NO;
        if (selectedAutoActionListM.device) {
            for (GSHDeviceM *deviceM in deviceArray) {
                if ([selectedAutoActionListM.device.deviceId isKindOfClass:NSNumber.class]) {
                    if ([deviceM.deviceId isEqualToNumber:selectedAutoActionListM.device.deviceId]) {
                        isIn = YES;
                    }
                }
            }
        } else {
            isIn = YES;
        }
        if (!isIn) {
            [shouldBeDeleteArray addObject:selectedAutoActionListM];
        }
    }
    if (shouldBeAddedArray.count > 0) {
        [self.action_deviceArray addObjectsFromArray:shouldBeAddedArray];
    }
    if (shouldBeDeleteArray.count > 0) {
        [self.action_deviceArray removeObjectsInArray:shouldBeDeleteArray];
    }
    for (GSHAutoActionListM *actionListM in self.action_deviceArray) {
        if (actionListM.device.exts.count == 0) {
            [actionListM.device.exts addObjectsFromArray:[GSHDeviceMachineViewModel getInitExtsWithDeviceM:actionListM.device deviceEditType:GSHDeviceVCTypeAutoActionSet]];
        }
    }
}

// 生效时间段选择
- (IBAction)effectTimeButtonClick:(id)sender {
    if (self.requiredCondition_time || self.optionalCondition_time) {
        // 已设置定时条件
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            
        } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"已设置定时条件，生效时间默认全天" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"知道了",nil];
    } else {
        GSHAutoEffectTimeSetVC *effectTimeSetVC = [GSHAutoEffectTimeSetVC autoEffectTimeSetVCWithStartTime:self.effectStartTime endTime:self.effectEndTime weekIndexSet:self.effectTimeWeekIndexSet timeSetVCType:GSHEffectTimeSetTypeVCAuto];
        @weakify(self)
        effectTimeSetVC.saveBlock = ^(BOOL isAllDay,NSIndexSet *repeatCountIndexSet, NSString * _Nonnull startTime, NSString * _Nonnull endTime) {
            @strongify(self)
            self.effectTimeWeekIndexSet = [repeatCountIndexSet mutableCopy];
            if (isAllDay) {
                self.effectTimeLabel.text = @"全天";
                self.effectStartTime = @"00:00";
                self.effectEndTime = @"00:00";
            } else {
                if ([endTime containsString:@"n"]) {
                    self.effectTimeLabel.text = [NSString stringWithFormat:@"%@ - %@(第二天)",startTime,[endTime substringFromIndex:1]];
                    self.effectEndTime = [endTime substringFromIndex:1];
                } else {
                    self.effectTimeLabel.text = [NSString stringWithFormat:@"%@ - %@",startTime,endTime];
                    self.effectEndTime = endTime;
                }
                self.effectStartTime = startTime;
            }
        };
        [self.navigationController pushViewController:effectTimeSetVC animated:YES];
    }
}

// 将星期字符串转成星期集合
- (NSIndexSet *)getWeekIndexSetWithWeek:(NSInteger)week {
    if (week > 127) {
        week = 127;
    }
    NSString *weekStr = [self getBinaryByDecimal:week];
    for (NSInteger i = 7 - weekStr.length; i > 0; i --) {
        weekStr = [NSString stringWithFormat:@"0%@",weekStr];
    }
    NSMutableIndexSet *weekIndexSet = [NSMutableIndexSet indexSet];
    for (NSInteger i = weekStr.length-1; i >= 0; i--) {
        NSString *str = [weekStr substringWithRange:NSMakeRange(i, 1)];
        if ([str isEqualToString:@"1"]) {
            if (i == weekStr.length-1) {
                [weekIndexSet addIndex:6];
            } else {
                [weekIndexSet addIndex:5-i];
            }
        }
    }
    return weekIndexSet;
}

- (NSNumber *)changeStringToTimerWithStr:(NSString *)dateStr {
    NSArray *dataArr = [dateStr componentsSeparatedByString:@":"];
    int hour = ((NSString *)dataArr.firstObject).intValue;
    int minute = ((NSString *)dataArr.lastObject).intValue;
    return @(hour * 3600 + minute * 60);
}


/**
 二进制转换为十进制
 
 @param binary 二进制数
 @return 十进制数
 */
- (NSInteger)getDecimalByBinary:(NSString *)binary {
    
    NSInteger decimal = 0;
    for (int i=0; i<binary.length; i++) {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            
            decimal += pow(2, i);
        }
    }
    return decimal;
}

/**
 十进制转换为二进制
 
 @param decimal 十进制数
 @return 二进制数
 */
- (NSString *)getBinaryByDecimal:(NSInteger)decimal {
    
    NSString *binary = @"";
    while (decimal) {
        binary = [[NSString stringWithFormat:@"%ld", decimal%2] stringByAppendingString:binary];
        if (decimal / 2 < 1) {
            break;
        }
        decimal = decimal / 2 ;
    }
    return binary;
}


// 完成
- (IBAction)completeButtonClick:(UIButton *)button {
    [self.view endEditing:YES];
    if (!self.setAutoM.automationName || [self.setAutoM.automationName tzm_checkStringIsEmpty]) {
        [TZMProgressHUDManager showErrorWithStatus:@"联动名称不能为空" inView:self.view];
        return;
    }
    if ([self.setAutoM.automationName tzm_judgeTheillegalCharacter]) {
        [TZMProgressHUDManager showErrorWithStatus:@"名字不能含特殊字符" inView:self.view];
        return;
    }
    
    if (!self.requiredCondition_time && self.requiredCondition_deviceArray.count == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"必选条件不能为空" inView:self.view];
        return;
    }
    
    if (!self.requiredCondition_time &&
        self.requiredCondition_deviceArray.count == 0 &&
        !self.optionalCondition_time &&
        self.optionalCondition_deviceArray.count == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"无联动条件" inView:self.view];
        return;
    }
    for (GSHAutoTriggerConditionListM *tmpConditionListM in self.requiredCondition_deviceArray) {
        if (tmpConditionListM.device.exts.count == 0) {
            [TZMProgressHUDManager showErrorWithStatus:[NSString stringWithFormat:@"必选条件栏目中 %@ 未设置执行动作",tmpConditionListM.device.deviceName] inView:self.view];
            return;
        }
    }
    
    for (GSHAutoTriggerConditionListM *tmpConditionListM in self.optionalCondition_deviceArray) {
        if (tmpConditionListM.device.exts.count == 0) {
            [TZMProgressHUDManager showErrorWithStatus:[NSString stringWithFormat:@"可选条件栏目中 %@ 未设置执行动作",tmpConditionListM.device.deviceName] inView:self.view];
            return;
        }
    }
    
    if (self.action_deviceArray.count == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请添加执行动作" inView:self.view];
        return;
    }
    for (GSHAutoActionListM *actionListM in self.action_deviceArray) {
        if (actionListM.device && actionListM.device.exts.count == 0) {
            [TZMProgressHUDManager showErrorWithStatus:[NSString stringWithFormat:@"执行动作栏目中 %@ 未设置执行动作",actionListM.device.deviceName] inView:self.view];
            return;
        }
    }
    if (self.triggerM.conditionList.count > 0) {
        [self.triggerM.conditionList removeAllObjects];
    }
    // 必选条件
    if (self.requiredCondition_time.length > 0) {
        GSHAutoTriggerConditionListM *conditionListM = [[GSHAutoTriggerConditionListM alloc] init];
        conditionListM.datetimer = [self changeStringToTimerWithStr:self.requiredCondition_time];
        conditionListM.week = [self getDecimalByBinary:[self getWeekWithWeekIndexSet:self.requiredCondition_weekIndexSet]];
        [self.triggerM.conditionList insertObject:conditionListM atIndex:0];
    }
    if (self.requiredCondition_deviceArray.count > 0) {
        for (GSHAutoTriggerConditionListM *triggerConditionListM in self.requiredCondition_deviceArray) {
            [self.triggerM.conditionList addObject:triggerConditionListM];
        }
    }
    
    if (self.triggerM.optionalConditionList.count > 0) {
        [self.triggerM.optionalConditionList removeAllObjects];
    }
    // 可选条件
    if (self.optionalCondition_time.length > 0) {
        GSHAutoTriggerConditionListM *conditionListM = [[GSHAutoTriggerConditionListM alloc] init];
        conditionListM.datetimer = [self changeStringToTimerWithStr:self.optionalCondition_time];
        conditionListM.week = [self getDecimalByBinary:[self getWeekWithWeekIndexSet:self.optionalCondition_weekIndexSet]];
        [self.triggerM.optionalConditionList insertObject:conditionListM atIndex:0];
    }
    if (self.optionalCondition_deviceArray.count > 0) {
        for (GSHAutoTriggerConditionListM *triggerConditionListM in self.optionalCondition_deviceArray) {
            [self.triggerM.optionalConditionList addObject:triggerConditionListM];
        }
    }
    self.setAutoM.trigger = self.triggerM;
    self.setAutoM.status = @(1);
    self.setAutoM.type = [self getTypeValue];
    self.setAutoM.familyId = [GSHOpenSDKShare share].currentFamily.familyId.numberValue;
    self.setAutoM.trigger.relationType = @1;
    
    if ([self.effectEndTime containsString:@"n"]) {
        self.setAutoM.endTime = [self changeStringToTimerWithStr:[self.effectEndTime substringFromIndex:1]];
    } else {
        self.setAutoM.endTime = [self changeStringToTimerWithStr:self.effectEndTime];
    }
    self.setAutoM.startTime = [self changeStringToTimerWithStr:self.effectStartTime];
    self.setAutoM.week = [self getDecimalByBinary:[self getWeekWithWeekIndexSet:self.effectTimeWeekIndexSet]];
    
    if (self.setAutoM.actionList.count > 0) {
        [self.setAutoM.actionList removeAllObjects];
    }
    if (self.action_deviceArray.count > 0) {
        [self.setAutoM.actionList addObjectsFromArray:self.action_deviceArray];
    }
    
    self.ossSetAutoM.familyId = [GSHOpenSDKShare share].currentFamily.familyId.numberValue;
    self.ossSetAutoM.name = self.setAutoM.automationName;
    self.ossSetAutoM.type = self.setAutoM.type;
    self.ossSetAutoM.status = self.setAutoM.status;
    self.ossSetAutoM.md5 = [[self.setAutoM yy_modelToJSONString] md5String];
    self.ossSetAutoM.relationType = @1;
    if (self.setAutoM.tplId) {
        self.ossSetAutoM.autoTplId = self.setAutoM.tplId;
    }
    
    NSLog(@"保存的联动 json : %@",[self.setAutoM yy_modelToJSONString]);
    if (self.addAutoVCType == AddAutoVCTypeEdit) {
        // 编辑模式
        if (button) {
            [TZMProgressHUDManager showWithStatus:@"修改中" inView:self.view];
        }
        NSString *volumeId = [self.ossSetAutoM.fid componentsSeparatedByString:@","].firstObject;
        __weak typeof(self)weakSelf = self;
        [GSHAutoManager updateAutoWithVolumeId:volumeId ossAutoM:self.ossSetAutoM autoM:self.setAutoM block:^(NSError *error) {
            if (error) {
                if (button) {
                    if (error.code == 71) {
                        // 情景名称已存在
                        [TZMProgressHUDManager showErrorWithStatus:@"联动名称已存在" inView:weakSelf.view];
                    } else {
                        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                    }
                }
            } else {
                if (weakSelf.updateAutoSuccessBlock) {
                    weakSelf.updateAutoSuccessBlock(weakSelf.ossSetAutoM);
                }
                // 更新本地文件
                if (button) {
                    [TZMProgressHUDManager showSuccessWithStatus:@"修改成功" inView:weakSelf.view];
                    for (UIViewController *vc in self.navigationController.viewControllers) {
                        if ([vc isKindOfClass:NSClassFromString(@"GSHAutomateVC")]) {
                            [weakSelf.navigationController popToViewController:vc animated:YES];
                        }
                    }
                }
            }
        }];
    } else {
        // 添加联动
        @weakify(self)
        [TZMProgressHUDManager showWithStatus:@"添加中" inView:self.view];
        [GSHAutoManager addAutoWithOssAutoM:self.ossSetAutoM autoM:self.setAutoM block:^(NSString *ruleId, NSError *error) {
            @strongify(self)
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            } else {
                self.ossSetAutoM.ruleId = ruleId.numberValue;
                [TZMProgressHUDManager showSuccessWithStatus:@"添加成功" inView:self.view];
                if (self.addAutoSuccessBlock) {
                    self.addAutoSuccessBlock(self.ossSetAutoM);
                }
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:NSClassFromString(@"GSHAutomateVC")] || [vc isKindOfClass:NSClassFromString(@"GSHPlayVC")]) {
                        [self.navigationController popToViewController:vc animated:YES];
                    }
                }
            }
        }];
    }
}

// 将星期集合转成星期字符串
- (NSString *)getWeekWithWeekIndexSet:(NSIndexSet *)weekIndexSet {
    NSMutableString *str = [NSMutableString stringWithString:@"0000000"];
    for (int i = 6; i >= 0; i --) {
        if (i == 6) {
            if ([weekIndexSet containsIndex:6]) {
                [str replaceCharactersInRange:NSMakeRange(6, 1) withString:@"1"];
            }
        } else {
            if ([weekIndexSet containsIndex:i]) {
                [str replaceCharactersInRange:NSMakeRange(5-i, 1) withString:@"1"];
            }
        }
    }
    return str;
}

- (NSNumber *)getTypeValue {
    NSNumber *type = @0;
    if (!self.requiredCondition_time && self.requiredCondition_deviceArray.count > 0 && !self.optionalCondition_time && self.optionalCondition_deviceArray.count == 0) {
        type = @0;
    } else if (self.requiredCondition_time && self.requiredCondition_deviceArray.count == 0 && !self.optionalCondition_time && self.optionalCondition_deviceArray.count == 0) {
        type = @1;
    } else if (self.requiredCondition_time && self.requiredCondition_deviceArray.count > 0 && !self.optionalCondition_time && self.optionalCondition_deviceArray.count == 0) {
        type = @2;
    } else if (!self.requiredCondition_time && self.requiredCondition_deviceArray.count > 0 && !self.optionalCondition_time && self.optionalCondition_deviceArray.count > 0) {
        type = @3;
    } else if (!self.requiredCondition_time && self.requiredCondition_deviceArray.count > 0 && self.optionalCondition_time && self.optionalCondition_deviceArray.count == 0) {
        type = @4;
    } else if (!self.requiredCondition_time && self.requiredCondition_deviceArray.count > 0 && self.optionalCondition_time && self.optionalCondition_deviceArray.count > 0) {
        type = @5;
    } else if (self.requiredCondition_time && self.requiredCondition_deviceArray.count == 0 && !self.optionalCondition_time && self.optionalCondition_deviceArray.count > 0) {
        type = @6;
    } else if (self.requiredCondition_time && self.requiredCondition_deviceArray.count > 0 && !self.optionalCondition_time && self.optionalCondition_deviceArray.count > 0) {
        type = @7;
    }
    return type;
}

#pragma mark - request
// 请求模版详情
- (void)getTemplateDetailInfoWithFamilyId:(NSNumber *)familyId templateId:(NSNumber *)templateId {
    
    [TZMProgressHUDManager showWithStatus:@"获取模版详情中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHAutoManager getAutoTemplateDeviceListWithFamilyId:familyId.stringValue templateId:templateId block:^(NSArray<GSHDeviceM *> *actionDeviceList, NSArray<GSHDeviceM *> *optTriggerDeviceList, NSArray<GSHDeviceM *> *reqTriggerDeviceList, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [weakSelf handleDataWithActionDeviceList:actionDeviceList optTriggerDeviceList:optTriggerDeviceList reqTriggerDeviceList:reqTriggerDeviceList];
            [weakSelf.addTableView reloadData];
        }
    }];
}

- (void)handleDataWithActionDeviceList:(NSArray*)actionDeviceList
                  optTriggerDeviceList:(NSArray*)optTriggerDeviceList
                  reqTriggerDeviceList:(NSArray*)reqTriggerDeviceList {
    
    if (self.action_deviceArray.count > 0) {
        [self.action_deviceArray removeAllObjects];
    }
    if (actionDeviceList.count > 0) {
        
        for (GSHAutoActionListM *actionListM in self.setAutoM.actionList) {
            if (actionListM.deviceTypes.count > 0) {
                for (GSHDeviceTypeM *deviceTypeM in actionListM.deviceTypes) {
                    if (deviceTypeM.devices.count > 0) {
                        [deviceTypeM.devices removeAllObjects];
                    }
                    for (GSHDeviceM *deviceM in actionDeviceList) {
                        if ([deviceTypeM.deviceType isEqualToNumber:deviceM.deviceType]) {
                            deviceM.exts = [deviceTypeM.exts mutableCopy];
                            [deviceTypeM.devices addObject:deviceM];
                        }
                    }
                    if (deviceTypeM.devices.count == 0) {
                        [self.action_deviceTypeArray addObject:deviceTypeM];
                    } else {
                        for (GSHDeviceM *deviceM in deviceTypeM.devices) {
                            GSHAutoActionListM *autoActionListM = [[GSHAutoActionListM alloc] init];
                            autoActionListM.device = deviceM;
                            [self.action_deviceArray addObject:autoActionListM];
                        }
                    }
                }
            }
        }
    } else {
        for (GSHAutoActionListM *actionListM in self.setAutoM.actionList) {
            if (actionListM.deviceTypes.count > 0) {
                for (GSHDeviceTypeM *deviceTypeM in actionListM.deviceTypes) {
                    if (deviceTypeM.devices.count == 0) {
                        [self.action_deviceTypeArray addObject:deviceTypeM];
                    }
                }
            }
        }
    }
    
    if (self.optionalCondition_deviceArray.count > 0) {
        [self.optionalCondition_deviceArray removeAllObjects];
    }
    if (optTriggerDeviceList.count > 0) {
        
        for (GSHAutoTriggerConditionListM *autoTriggerConditionM in self.setAutoM.trigger.optionalConditionList) {
            if (autoTriggerConditionM.deviceTypeModel) {
                if (autoTriggerConditionM.deviceTypeModel.devices.count > 0) {
                    [autoTriggerConditionM.deviceTypeModel.devices removeAllObjects];
                }
                for (GSHDeviceM *deviceM in optTriggerDeviceList) {
                    if ([autoTriggerConditionM.deviceTypeModel.deviceType isEqualToNumber:deviceM.deviceType]) {
                        if ([deviceM.deviceSn containsString:@"_"]) {
                            // 虚拟传感器
                            GSHDeviceExtM *deviceExtM = [autoTriggerConditionM.deviceTypeModel.exts.firstObject yy_modelCopy];
                            deviceExtM.basMeteId = [deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn];
                            deviceM.exts = [@[deviceExtM] mutableCopy];
                        } else {
                            deviceM.exts = [autoTriggerConditionM.deviceTypeModel.exts mutableCopy];
                        }
                        [autoTriggerConditionM.deviceTypeModel.devices addObject:deviceM];
                    }
                }
                if (autoTriggerConditionM.deviceTypeModel.devices.count == 0) {
                    [self.optionalTrigger_deviceTypeArray addObject:autoTriggerConditionM.deviceTypeModel];
                } else {
                    for (GSHDeviceM *deviceM in autoTriggerConditionM.deviceTypeModel.devices) {
                        GSHAutoTriggerConditionListM *conditionListM = [[GSHAutoTriggerConditionListM alloc] init];
                        conditionListM.device = deviceM;
                        [self.optionalCondition_deviceArray addObject:conditionListM];
                    }
                }
            }
        }
    } else {
        for (GSHAutoTriggerConditionListM *autoTriggerConditionM in self.setAutoM.trigger.optionalConditionList) {
            if (autoTriggerConditionM.deviceTypeModel) {
                if (autoTriggerConditionM.deviceTypeModel.devices.count == 0) {
                    [self.optionalTrigger_deviceTypeArray addObject:autoTriggerConditionM.deviceTypeModel];
                }
            }
        }
    }
    
    if (self.requiredCondition_deviceArray.count > 0) {
        [self.requiredCondition_deviceArray removeAllObjects];
    }
    if (reqTriggerDeviceList.count > 0) {
        
        for (GSHAutoTriggerConditionListM *autoTriggerConditionM in self.setAutoM.trigger.conditionList) {
            if (autoTriggerConditionM.deviceTypeModel) {
                if (autoTriggerConditionM.deviceTypeModel.devices.count > 0) {
                    [autoTriggerConditionM.deviceTypeModel.devices removeAllObjects];
                }
                for (GSHDeviceM *deviceM in reqTriggerDeviceList) {
                    if ([autoTriggerConditionM.deviceTypeModel.deviceType isEqualToNumber:deviceM.deviceType]) {
                        if ([deviceM.deviceSn containsString:@"_"]) {
                            // 虚拟传感器
                            GSHDeviceExtM *deviceExtM = [autoTriggerConditionM.deviceTypeModel.exts.firstObject yy_modelCopy];
                            deviceExtM.basMeteId = [deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn];
                            deviceM.exts = [@[deviceExtM] mutableCopy];
                        } else {
                            deviceM.exts = [autoTriggerConditionM.deviceTypeModel.exts mutableCopy];
                        }
                        [autoTriggerConditionM.deviceTypeModel.devices addObject:deviceM];
                    }
                }
                if (autoTriggerConditionM.deviceTypeModel.devices.count == 0) {
                    [self.requeiredTrigger_deviceTypeArray addObject:autoTriggerConditionM.deviceTypeModel];
                } else {
                    for (GSHDeviceM *deviceM in autoTriggerConditionM.deviceTypeModel.devices) {
                        GSHAutoTriggerConditionListM *conditionListM = [[GSHAutoTriggerConditionListM alloc] init];
                        conditionListM.device = deviceM;
                        [self.requiredCondition_deviceArray addObject:conditionListM];
                    }
                }
            }
        }
    } else {
        for (GSHAutoTriggerConditionListM *autoTriggerConditionM in self.setAutoM.trigger.conditionList) {
            if (autoTriggerConditionM.deviceTypeModel) {
                if (autoTriggerConditionM.deviceTypeModel.devices.count == 0) {
                    [self.requeiredTrigger_deviceTypeArray addObject:autoTriggerConditionM.deviceTypeModel];
                }
            }
        }
    }
}


@end
