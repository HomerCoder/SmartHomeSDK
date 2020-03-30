//
//  GSHAirBoxSensorSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/11/21.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHAirBoxSensorSetVC.h"
#import "UINavigationController+TZM.h"

@interface GSHAirBoxSensorSetVCModel : NSObject
@property (nonatomic , strong) NSArray <NSString*>*deviceLeftDataArr;
@property (nonatomic , strong) NSArray <NSString*>*deviceRightDataArr;
@property (nonatomic , assign) NSInteger deviceLeftIndex;
@property (nonatomic , assign) NSInteger deviceRightIndex;
@property (nonatomic , assign) BOOL deviceHidden;
@property (nonatomic , copy) NSString *name;
@property (nonatomic , copy) NSString *unit;
@end

@implementation GSHAirBoxSensorSetVCModel
-(void)setDeviceLeftIndex:(NSInteger)deviceLeftIndex{
    if (deviceLeftIndex == NSNotFound) {
        _deviceLeftIndex = 0;
    }else{
        _deviceLeftIndex = deviceLeftIndex;
    }
}

-(void)setDeviceRightIndex:(NSInteger)deviceRightIndex{
    if (deviceRightIndex == NSNotFound) {
        _deviceRightIndex = 0;
    }else{
        _deviceRightIndex = deviceRightIndex;
    }
}
@end

@interface GSHAirBoxSensorCell()
@property(nonatomic,strong)GSHAirBoxSensorSetVCModel *model;
@end

@implementation GSHAirBoxSensorCell
@end

@interface GSHAirBoxSensorSetVC () <UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong) NSArray *exts;
@property (weak, nonatomic) IBOutlet UITableView *airBoxTableView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (nonatomic , strong) NSArray <GSHAirBoxSensorSetVCModel*>*deviceDataArr;
@end

@implementation GSHAirBoxSensorSetVC

+ (instancetype)airBoxSensorSetVCWithDeviceM:(GSHDeviceM *)deviceM {
    GSHAirBoxSensorSetVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAirBoxSensorSetSB" andID:@"GSHAirBoxSensorSetVC"];
    vc.deviceM = deviceM;
    vc.exts = deviceM.exts;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    self.deviceNameLabel.text = self.deviceM.deviceName;
    self.airBoxTableView.sectionHeaderHeight = 70;
    self.airBoxTableView.sectionFooterHeight = 0;
    self.airBoxTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
    
    if ([self.deviceM.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]){
        NSMutableArray *list1 = [NSMutableArray array];
        for (int i = -40; i < 101; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d",i];
            [list1 addObject:str];
        }
        NSMutableArray *list2 = [NSMutableArray array];
        for (int i = 0; i < 101; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d",i];
            [list2 addObject:str];
        }
    
        GSHAirBoxSensorSetVCModel *model1 = [GSHAirBoxSensorSetVCModel new];
        model1.deviceRightDataArr = list1;
        model1.deviceLeftDataArr = @[@"高于",@"低于"];
        model1.deviceHidden = YES;
        model1.deviceLeftIndex = 0;
        model1.deviceRightIndex = 0;
        model1.name = @"设置触发阈值-温度";
        GSHAirBoxSensorSetVCModel *model2 = [GSHAirBoxSensorSetVCModel new];
        model2.deviceRightDataArr = list2;
        model2.deviceLeftDataArr = @[@"高于",@"低于"];
        model2.deviceHidden = YES;
        model2.deviceLeftIndex = 0;
        model2.deviceRightIndex = 0;
        model2.name = @"设置触发阈值-湿度";
        GSHAirBoxSensorSetVCModel *model3 = [GSHAirBoxSensorSetVCModel new];
        model3.deviceRightDataArr = @[@"严重污染",@"重度污染",@"中度污染",@"轻度污染",@"良",@"优"];
        model3.deviceLeftDataArr = @[];
        model3.deviceHidden = YES;
        model3.deviceLeftIndex = 0;
        model3.deviceRightIndex = 0;
        model3.name = @"设置触发阈值-空气质量";
        self.deviceDataArr = @[model1,model2,model3];
    }else if ([self.deviceM.deviceType isEqualToNumber:GSHHuanjingSensorDeviceType]){
        NSMutableArray *list2 = [NSMutableArray array];
        for (int i = -10; i < 81; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d",i];
            [list2 addObject:str];
        }
        NSMutableArray *list3 = [NSMutableArray array];
        for (int i = 0; i < 101; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d",i];
            [list3 addObject:str];
        }
        NSMutableArray *list4 = [NSMutableArray array];
        for (int i = 0; i < 11; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d",i * 50];
            [list4 addObject:str];
        }
        NSMutableArray *list5 = [NSMutableArray array];
        for (int i = 2; i < 11; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d",i * 200];
            [list5 addObject:str];
        }
        GSHAirBoxSensorSetVCModel *model1 = [GSHAirBoxSensorSetVCModel new];
        model1.deviceRightDataArr = @[@"优",@"良",@"中",@"差"];
        model1.deviceLeftDataArr = @[];
        model1.deviceHidden = YES;
        model1.deviceLeftIndex = 0;
        model1.deviceRightIndex = 0;
        model1.unit = @"";
        model1.name = @"设置触发阈值-空气质量";
        GSHAirBoxSensorSetVCModel *model2 = [GSHAirBoxSensorSetVCModel new];
        model2.deviceRightDataArr = list2;
        model2.deviceLeftDataArr = @[@"高于",@"低于"];
        model2.deviceHidden = YES;
        model2.deviceLeftIndex = 0;
        model2.deviceRightIndex = 0;
        model2.unit = @"℃";
        model2.name = @"设置触发阈值-温度";
        GSHAirBoxSensorSetVCModel *model3 = [GSHAirBoxSensorSetVCModel new];
        model3.deviceRightDataArr = list3;
        model3.deviceLeftDataArr = @[@"高于",@"低于"];;
        model3.deviceHidden = YES;
        model3.deviceLeftIndex = 0;
        model3.deviceRightIndex = 0;
        model3.unit = @"%";
        model3.name = @"设置触发阈值-湿度";
        GSHAirBoxSensorSetVCModel *model4 = [GSHAirBoxSensorSetVCModel new];
        model4.deviceRightDataArr = list4;
        model4.deviceLeftDataArr = @[@"高于",@"低于"];;
        model4.deviceHidden = YES;
        model4.deviceLeftIndex = 0;
        model4.deviceRightIndex = 0;
        model4.unit = @"ug/m3";
        model4.name = @"设置触发阈值-PM2.5";
        GSHAirBoxSensorSetVCModel *model5 = [GSHAirBoxSensorSetVCModel new];
        model5.deviceRightDataArr = list5;
        model5.deviceLeftDataArr = @[@"高于",@"低于"];;
        model5.deviceHidden = YES;
        model5.deviceLeftIndex = 0;
        model5.deviceRightIndex = 0;
        model5.unit = @"PPM";
        model5.name = @"设置触发阈值-CO2";
        self.deviceDataArr = @[model1,model2,model3,model4,model5];
    }
    [self layoutUI];
}

- (void)layoutUI {
    if ([self.deviceM.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
        for (GSHDeviceExtM *extM in self.exts) {
            if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_temMeteId]) {
                self.deviceDataArr[0].deviceHidden = NO;
                self.deviceDataArr[0].deviceLeftIndex = [extM.conditionOperator isEqualToString:@">"] ? 0 : 1;
                self.deviceDataArr[0].deviceRightIndex = [self.deviceDataArr[0].deviceRightDataArr indexOfObject:extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_humMeteId]) {
                self.deviceDataArr[1].deviceHidden = NO;
                self.deviceDataArr[1].deviceLeftIndex = [extM.conditionOperator isEqualToString:@">"] ? 0 : 1;
                self.deviceDataArr[1].deviceRightIndex = [self.deviceDataArr[1].deviceRightDataArr indexOfObject:extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_pmMeteId]) {
                self.deviceDataArr[2].deviceHidden = NO;
                NSString *str = @"轻度污染";
                if (extM.rightValue.integerValue == 35) {
                    str = @"优";
                } else if ([extM.conditionOperator isEqualToString:@"<"] && extM.rightValue.integerValue == 75) {
                    str = @"良";
                } else if ([extM.conditionOperator isEqualToString:@">"] && extM.rightValue.integerValue == 75) {
                    str = @"轻度污染";
                } else if (extM.rightValue.integerValue == 115) {
                    str = @"中度污染";
                } else if (extM.rightValue.integerValue == 150) {
                    str = @"重度污染";
                } else if (extM.rightValue.integerValue == 250) {
                    str = @"严重污染";
                }
                self.deviceDataArr[2].deviceRightIndex = [self.deviceDataArr[2].deviceRightDataArr indexOfObject:str];
            }
        }
    }else if ([self.deviceM.deviceType isEqualToNumber:GSHHuanjingSensorDeviceType]){
        for (GSHDeviceExtM *extM in self.exts) {
            if ([extM.basMeteId isEqualToString:GSHHuanjingSensor_youhaiMeteId]) {
                NSString *str = @"优";
                if ([extM.conditionOperator isEqualToString:@"<"] && extM.rightValue.integerValue == 120) {
                    str = @"优";
                } else if ([extM.conditionOperator isEqualToString:@"<"] && extM.rightValue.integerValue == 200) {
                    str = @"良";
                } else if ([extM.conditionOperator isEqualToString:@">"] && extM.rightValue.integerValue == 200) {
                    str = @"中";
                } else if ([extM.conditionOperator isEqualToString:@">"] && extM.rightValue.integerValue == 250) {
                    str = @"差";
                }
                self.deviceDataArr[0].deviceHidden = NO;
                self.deviceDataArr[0].deviceRightIndex = [self.deviceDataArr[0].deviceRightDataArr indexOfObject:str] ;
            } else if ([extM.basMeteId isEqualToString:GSHHuanjingSensor_wenduMeteId]) {
                self.deviceDataArr[1].deviceHidden = NO;
                self.deviceDataArr[1].deviceLeftIndex = [extM.conditionOperator isEqualToString:@">"] ? 0 : 1;
                self.deviceDataArr[1].deviceRightIndex = [self.deviceDataArr[1].deviceRightDataArr indexOfObject:extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHHuanjingSensor_shiduMeteId]) {
                self.deviceDataArr[2].deviceHidden = NO;
                self.deviceDataArr[2].deviceLeftIndex = [extM.conditionOperator isEqualToString:@">"] ? 0 : 1;
                self.deviceDataArr[2].deviceRightIndex = [self.deviceDataArr[2].deviceRightDataArr indexOfObject:extM.rightValue];
            }else if ([extM.basMeteId isEqualToString:GSHHuanjingSensor_pm25MeteId]) {
                self.deviceDataArr[3].deviceHidden = NO;
                self.deviceDataArr[3].deviceLeftIndex = [extM.conditionOperator isEqualToString:@">"] ? 0 : 1;
                self.deviceDataArr[3].deviceRightIndex = [self.deviceDataArr[3].deviceRightDataArr indexOfObject:extM.rightValue];
            }else if ([extM.basMeteId isEqualToString:GSHHuanjingSensor_co2MeteId]) {
                self.deviceDataArr[4].deviceHidden = NO;
                self.deviceDataArr[4].deviceLeftIndex = [extM.conditionOperator isEqualToString:@">"] ? 0 : 1;
                self.deviceDataArr[4].deviceRightIndex = [self.deviceDataArr[4].deviceRightDataArr indexOfObject:extM.rightValue];
            }
        }
    }
    [self.airBoxTableView reloadData];
}
#pragma mark - method
- (IBAction)sureButtonClick:(id)sender {
    BOOL on = NO;
    for (GSHAirBoxSensorSetVCModel *model in self.deviceDataArr) {
        if (model.deviceHidden == NO) {
            on = YES;
        }
    }
    if (!on) {
        [TZMProgressHUDManager showErrorWithStatus:@"请至少选择一项" inView:self.view];
        return;
    }
    
    NSMutableArray *exts = [NSMutableArray array];
    if ([self.deviceM.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
        GSHAirBoxSensorSetVCModel *model0 = self.deviceDataArr[0];
        if (!model0.deviceHidden) {
            GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
            temExtM.basMeteId = GSHAirBoxSensor_temMeteId;
            temExtM.conditionOperator = [model0.deviceLeftDataArr[model0.deviceLeftIndex] isEqualToString:@"高于"] ? @">" : @"<";
            temExtM.rightValue = model0.deviceRightDataArr[model0.deviceRightIndex];
            [exts addObject:temExtM];
        }
        GSHAirBoxSensorSetVCModel *model1 = self.deviceDataArr[1];
        if (!model1.deviceHidden) {
            GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
            temExtM.basMeteId = GSHAirBoxSensor_humMeteId;
            temExtM.conditionOperator = [model1.deviceLeftDataArr[model1.deviceLeftIndex] isEqualToString:@"高于"] ? @">" : @"<";
            temExtM.rightValue = model1.deviceRightDataArr[model1.deviceRightIndex];
            [exts addObject:temExtM];
        }
        GSHAirBoxSensorSetVCModel *model2 = self.deviceDataArr[2];
        if (!model2.deviceHidden) {
            GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
            temExtM.basMeteId = GSHAirBoxSensor_pmMeteId;
            NSString *rightValue = model2.deviceRightDataArr[model2.deviceRightIndex];
            if ([rightValue isEqualToString:@"优"]) {
                temExtM.conditionOperator = @"<";
                temExtM.rightValue = @"35";
            } else if ([rightValue isEqualToString:@"良"]) {
                temExtM.conditionOperator = @"<";
                temExtM.rightValue = @"75";
            } else if ([rightValue isEqualToString:@"轻度污染"]) {
                temExtM.conditionOperator = @">";
                temExtM.rightValue = @"75";
            } else if ([rightValue isEqualToString:@"中度污染"]) {
                temExtM.conditionOperator = @">";
                temExtM.rightValue = @"115";
            } else if ([rightValue isEqualToString:@"重度污染"]) {
                temExtM.conditionOperator = @">";
                temExtM.rightValue = @"150";
            } else if ([rightValue isEqualToString:@"严重污染"]) {
                temExtM.conditionOperator = @">";
                temExtM.rightValue = @"250";
            }
            [exts addObject:temExtM];
        }
    }else if ([self.deviceM.deviceType isEqualToNumber:GSHHuanjingSensorDeviceType]){
        GSHAirBoxSensorSetVCModel *model0 = self.deviceDataArr[0];
        if (!model0.deviceHidden) {
            GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
            temExtM.basMeteId = GSHHuanjingSensor_youhaiMeteId;
            NSString *rightValue = model0.deviceRightDataArr[model0.deviceRightIndex];
            if ([rightValue isEqualToString:@"优"]) {
                temExtM.conditionOperator = @"<";
                temExtM.rightValue = @"120";
            } else if ([rightValue isEqualToString:@"良"]) {
                temExtM.conditionOperator = @"<";
                temExtM.rightValue = @"200";
            } else if ([rightValue isEqualToString:@"中"]) {
                temExtM.conditionOperator = @">";
                temExtM.rightValue = @"200";
            } else if ([rightValue isEqualToString:@"差"]) {
                temExtM.conditionOperator = @">";
                temExtM.rightValue = @"250";
            }
            [exts addObject:temExtM];
        }
        GSHAirBoxSensorSetVCModel *model1 = self.deviceDataArr[1];
        if (!model1.deviceHidden) {
            GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
            temExtM.basMeteId = GSHHuanjingSensor_wenduMeteId;
            temExtM.conditionOperator = [model1.deviceLeftDataArr[model1.deviceLeftIndex] isEqualToString:@"高于"] ? @">" : @"<";
            temExtM.rightValue = model1.deviceRightDataArr[model1.deviceRightIndex];
            [exts addObject:temExtM];
        }
        GSHAirBoxSensorSetVCModel *model2 = self.deviceDataArr[2];
        if (!model2.deviceHidden) {
            GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
            temExtM.basMeteId = GSHHuanjingSensor_shiduMeteId;
            temExtM.conditionOperator = [model2.deviceLeftDataArr[model2.deviceLeftIndex] isEqualToString:@"高于"] ? @">" : @"<";
            temExtM.rightValue = model2.deviceRightDataArr[model2.deviceRightIndex];
            [exts addObject:temExtM];
        }
        GSHAirBoxSensorSetVCModel *model3 = self.deviceDataArr[3];
        if (!model3.deviceHidden) {
            GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
            temExtM.basMeteId = GSHHuanjingSensor_pm25MeteId;
            temExtM.conditionOperator = [model3.deviceLeftDataArr[model3.deviceLeftIndex] isEqualToString:@"高于"] ? @">" : @"<";
            temExtM.rightValue = model3.deviceRightDataArr[model3.deviceRightIndex];
            [exts addObject:temExtM];
        }
        GSHAirBoxSensorSetVCModel *model4 = self.deviceDataArr[4];
        if (!model4.deviceHidden) {
            GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
            temExtM.basMeteId = GSHHuanjingSensor_co2MeteId;
            temExtM.conditionOperator = [model4.deviceLeftDataArr[model4.deviceLeftIndex] isEqualToString:@"高于"] ? @">" : @"<";
            temExtM.rightValue = model4.deviceRightDataArr[model4.deviceRightIndex];
            [exts addObject:temExtM];
        }
    }

    if (self.deviceSetCompleteBlock) {
        self.deviceSetCompleteBlock(exts);
    }
    [self closeWithComplete:^{

    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.deviceDataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.deviceDataArr[indexPath.section].deviceHidden ? 0 : 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHAirBoxSensorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHAirBoxSensorCell" forIndexPath:indexPath];
    cell.contentView.tag = indexPath.section;
    cell.model = self.deviceDataArr[indexPath.section];
    if (cell.model.deviceLeftDataArr.count == 0) {
        cell.leftPickerView.hidden = YES;
        cell.rightPickerView.hidden = YES;
        cell.middlePickerView.hidden = NO;
        cell.middlePickerView.delegate = self;
        cell.middlePickerView.dataSource = self;
        cell.leftPickerView.delegate = nil;
        cell.leftPickerView.dataSource = nil;
        cell.rightPickerView.delegate = nil;
        cell.rightPickerView.dataSource = nil;
        [cell.middlePickerView selectRow:cell.model.deviceRightIndex inComponent:0 animated:NO];
    }else{
        cell.leftPickerView.hidden = NO;
        cell.rightPickerView.hidden = NO;
        cell.middlePickerView.hidden = YES;
        cell.middlePickerView.delegate = nil;
        cell.middlePickerView.dataSource = nil;
        cell.leftPickerView.delegate = self;
        cell.leftPickerView.dataSource = self;
        cell.rightPickerView.delegate = self;
        cell.rightPickerView.dataSource = self;
        [cell.rightPickerView selectRow:cell.model.deviceRightIndex inComponent:0 animated:NO];
        [cell.leftPickerView selectRow:cell.model.deviceLeftIndex inComponent:0 animated:NO];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, SCREEN_WIDTH - 34 - 34 - 50 - 10, 70)];
    label.textColor = [UIColor colorWithHexString:@"#3C4366"];
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.0];
    [view addSubview:label];
    
    UISwitch *sectionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 34 - 50, 20, 50, 30)];
    sectionSwitch.backgroundColor = [UIColor clearColor];
    sectionSwitch.onTintColor = [UIColor colorWithHexString:@"#2EB0FF"];
    sectionSwitch.tag = section;
    [sectionSwitch addTarget:self action:@selector(sectionSwitchClick:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:sectionSwitch];
    
    label.text = self.deviceDataArr[section].name;
    sectionSwitch.on = !self.deviceDataArr[section].deviceHidden;
    return view;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    GSHAirBoxSensorCell *cell = (GSHAirBoxSensorCell*)pickerView.superview.superview;
    if ([cell isKindOfClass:GSHAirBoxSensorCell.class]) {
        GSHAirBoxSensorSetVCModel *model = cell.model;
        if ([model isKindOfClass:GSHAirBoxSensorSetVCModel.class]) {
            if (model.deviceLeftDataArr.count > 0) {
                if (pickerView == cell.leftPickerView) {
                    return cell.model.deviceLeftDataArr.count;
                }
                if (pickerView == cell.rightPickerView) {
                    return cell.model.deviceRightDataArr.count;
                }
            }else{
                if (pickerView == cell.middlePickerView) {
                    return cell.model.deviceRightDataArr.count;
                }
            }
        }
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //获取选中的文字，以便于在别的地方使用
    GSHAirBoxSensorCell *cell = (GSHAirBoxSensorCell*)pickerView.superview.superview;
       if ([cell isKindOfClass:GSHAirBoxSensorCell.class]) {
           GSHAirBoxSensorSetVCModel *model = cell.model;
           if ([model isKindOfClass:GSHAirBoxSensorSetVCModel.class]) {
               if (model.deviceLeftDataArr.count > 0) {
                   if (pickerView == cell.leftPickerView) {
                       model.deviceLeftIndex = row;
                   }
                   if (pickerView == cell.rightPickerView) {
                       model.deviceRightIndex = row;
                   }
               }else{
                   if (pickerView == cell.middlePickerView) {
                       model.deviceRightIndex = row;
                   }
               }
           }
       }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews) {
        if (singleLine.frame.size.height < 1) {
            singleLine.backgroundColor = [UIColor blackColor];
        } else {
            singleLine.backgroundColor = [UIColor clearColor];
        }
    }
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.backgroundColor = [UIColor clearColor];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.textColor = [UIColor colorWithHexString:@"#222222"];
    
    GSHAirBoxSensorCell *cell = (GSHAirBoxSensorCell*)pickerView.superview.superview;
    if ([cell isKindOfClass:GSHAirBoxSensorCell.class]) {
        GSHAirBoxSensorSetVCModel *model = cell.model;
        if ([model isKindOfClass:GSHAirBoxSensorSetVCModel.class]) {
            if (model.deviceLeftDataArr.count > 0) {
                if (pickerView == cell.leftPickerView) {
                   genderLabel.text =  cell.model.deviceLeftDataArr[row];
                }
                if (pickerView == cell.rightPickerView) {
                    genderLabel.text =  [NSString stringWithFormat:@"%@%@",cell.model.deviceRightDataArr[row],cell.model.unit];
                }
            }else{
                if (pickerView == cell.middlePickerView) {
                    genderLabel.text =  cell.model.deviceRightDataArr[row];
                }
            }
        }
    }
    return genderLabel;
}

- (void)sectionSwitchClick:(UISwitch *)sectionSwitch {
    GSHAirBoxSensorSetVCModel *model = self.deviceDataArr[sectionSwitch.tag];
    model.deviceHidden = !sectionSwitch.on;
    [self.airBoxTableView reloadData];
    [self.airBoxTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionSwitch.tag] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


@end

