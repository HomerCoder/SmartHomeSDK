//
//  GSHAirConditionerSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/10/30.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHAirConditionerSetVC.h"
#import "UINavigationController+TZM.h"

@interface GSHAirConditionerSetVC () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *operatorPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *temPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *tmpSwitch;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *temPickerViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *operatorPickerViewLeading;

@property (nonatomic,strong) NSArray *exts;

@property (nonatomic,strong) NSArray *leftPickDataArr;
@property (nonatomic,strong) NSMutableArray *rightPickDataArr;
@property (nonatomic,strong) NSString *leftPickSelectStr;
@property (nonatomic,strong) NSString *rightPickSelectStr;

@property (nonatomic,assign) NSInteger leftDefaultIndex;
@property (nonatomic,assign) NSInteger rightDefaultIndex;

@end

@implementation GSHAirConditionerSetVC

+ (instancetype)airConditionerSetVCWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHAirConditionerSetVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAirConditionerSetSB" andID:@"GSHAirConditionerSetVC"];
    vc.deviceM = deviceM;
    vc.exts = deviceM.exts;
    vc.deviceEditType = deviceEditType;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    self.leftPickDataArr = @[@"高于",@"等于",@"低于"];
    for (int i = 16; i < 33; i ++) {
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [self.rightPickDataArr addObject:str];
    }
    self.operatorPickerView.dataSource = self;
    self.operatorPickerView.delegate = self;
    self.temPickerView.dataSource = self;
    self.temPickerView.delegate = self;
    self.operatorPickerViewLeading.constant = self.view.frame.size.width / 3 - 30;
    self.temPickerViewLeading.constant = self.view.frame.size.width / 3 - 60;
    
    self.leftPickSelectStr = @"高于";
    self.rightPickSelectStr = @"16";
    
    if (self.exts.count > 0) {
        [self layoutUI];
    }
}

- (void)layoutUI {
    
    NSString *switchValue = @"";
    for (GSHDeviceExtM *extM in self.exts) {
        if ([extM.basMeteId isEqualToString:GSHAirConditioner_SwitchMeteId]) {
            switchValue = extM.rightValue;
        }
    }
    // v3.1.1 空调选了模式或温度,开关不作为条件 因此判断有开关属性且为0即表示关的状态,反之则为开的状态
    if (switchValue.length > 0 && switchValue.integerValue == 0) {
        // 有开关属性 , 表示是关的状态
        self.switchButton.selected = YES;
        [self showCloseUI];
    } else {
        // 开的状态
        NSString *modelValue = @"";
        for (GSHDeviceExtM *extM in self.exts) {
            if ([extM.basMeteId isEqualToString:GSHAirConditioner_ModelMeteId]) {
                modelValue = extM.rightValue;
            }
        }
        if (modelValue.length > 0) {
            int index;
            if (modelValue.intValue==3) {
                index = 1;
            } else if (modelValue.intValue==4) {
                index = 2;
            } else if (modelValue.intValue==8) {
                index = 3;
            } else {
                index = 4;
            }
            UIButton *modelButton = [self.view viewWithTag:index];
            modelButton.selected = YES;
        }
        
        NSString *temValue = @"";
        NSString *operator = @"等于";
        for (GSHDeviceExtM *extM in self.exts) {
            if ([extM.basMeteId isEqualToString:GSHAirConditioner_TemperatureMeteId]) {
                temValue = extM.rightValue;
                if ([extM.conditionOperator isEqualToString:@"=="]) {
                    operator = @"等于";
                } else if ([extM.conditionOperator isEqualToString:@">"]) {
                    operator = @"高于";
                } else {
                    operator = @"低于";
                }
            }
        }
        if (temValue.length > 0) {
            self.tmpSwitch.on = YES;
            self.operatorPickerView.hidden = NO;
            self.temPickerView.hidden = NO;
            
            NSInteger operatorIndex = [self.leftPickDataArr containsObject:operator] ? [self.leftPickDataArr indexOfObject:operator] : 0;
            self.leftDefaultIndex = operatorIndex;
            self.leftPickSelectStr = operator;
            NSInteger temIndex = [self.rightPickDataArr containsObject:temValue] ? [self.rightPickDataArr indexOfObject:temValue] : 0;
            self.rightDefaultIndex = temIndex;
            self.rightPickSelectStr = temValue;
        } else {
            self.tmpSwitch.on = NO;
            self.operatorPickerView.hidden = YES;
            self.temPickerView.hidden = YES;
        }
    }
}

- (void)viewWillLayoutSubviews {
    
    [self.operatorPickerView selectRow:self.leftDefaultIndex inComponent:0 animated:NO];
    [self.temPickerView selectRow:self.rightDefaultIndex inComponent:0 animated:NO];
}

#pragma mark - Lazy
- (NSMutableArray *)rightPickDataArr {
    if (!_rightPickDataArr) {
        _rightPickDataArr = [NSMutableArray array];
    }
    return _rightPickDataArr;
}

#pragma mark - method

- (IBAction)sureButtonClick:(id)sender {
    NSLog(@"%@%@",self.leftPickSelectStr,self.rightPickSelectStr);
    NSMutableArray *exts = [NSMutableArray array];
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = GSHAirConditioner_SwitchMeteId;
    extM.conditionOperator = @"==";
    if (self.switchButton.selected) {
        // 关
        extM.rightValue = @"0";
        [exts addObject:extM];
    } else {
        // 开
        extM.rightValue = @"10";
        [exts addObject:extM];
        
        for (int i = 1; i < 5; i ++) {
            UIButton *tmpButton = [self.view viewWithTag:i];
            if (tmpButton.selected) {
                // 有模式按钮选中
                GSHDeviceExtM *modelExtM = [[GSHDeviceExtM alloc] init];
                modelExtM.basMeteId = GSHAirConditioner_ModelMeteId;
                modelExtM.conditionOperator = @"==";
                if (i==1) {
                    modelExtM.rightValue = @"3";
                } else if (i==2) {
                    modelExtM.rightValue = @"4";
                } else if (i==3) {
                    modelExtM.rightValue = @"8";
                } else if (i==4) {
                    modelExtM.rightValue = @"7";
                }
                [exts addObject:modelExtM];
                break;
            }
        }
        
        if (self.tmpSwitch.on) {
            GSHDeviceExtM *temExtM = [[GSHDeviceExtM alloc] init];
            temExtM.basMeteId = GSHAirConditioner_TemperatureMeteId;
            NSString *operatore = @"";
            if ([self.leftPickSelectStr isEqualToString:@"高于"]){
                operatore = @">";
            } else if ([self.leftPickSelectStr isEqualToString:@"等于"]){
                operatore = @"==";
            } else {
                operatore = @"<";
            }
            temExtM.conditionOperator = operatore;
            temExtM.rightValue = self.rightPickSelectStr;
            [exts addObject:temExtM];
        }
    }
    if (exts.count > 1) {
        // v3.1.1 选择了模式,温度 , 删除开关条件属性
        [exts removeObjectAtIndex:0];
    }
    if (self.deviceSetCompleteBlock) {
        self.deviceSetCompleteBlock(exts);
    }
    [self closeWithComplete:^{
        
    }];
}

- (IBAction)switchButtonClick:(UIButton *)switchButton {
    switchButton.selected = !switchButton.selected;
    if (switchButton.selected) {
        [self showCloseUI];
    }
}

- (void)showCloseUI {
    for (int i = 1; i < 5; i ++) {
        UIButton *tmpButton = [self.view viewWithTag:i];
        tmpButton.selected = NO;
    }
    self.tmpSwitch.on = NO;
    self.operatorPickerView.hidden = YES;
    self.temPickerView.hidden = YES;
}

- (IBAction)handleButtonClick:(UIButton *)handleButton {
    if (self.switchButton.selected) {
        return;
    }
    for (int i = 1; i < 5; i ++) {
        UIButton *tmpButton = [self.view viewWithTag:i];
        tmpButton.selected = NO;
    }
    handleButton.selected = YES;
}

- (IBAction)triggerSwitchTouch:(UISwitch *)sender {
    if (self.switchButton.selected) {
        sender.on = NO;
        return;
    }
    self.operatorPickerView.hidden = !sender.on;
    self.temPickerView.hidden = !sender.on;
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.operatorPickerView) {
        return self.leftPickDataArr.count;
    } else {
        return self.rightPickDataArr.count;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //获取选中的文字，以便于在别的地方使用
    if (pickerView == self.operatorPickerView) {
        self.leftPickSelectStr = self.leftPickDataArr[row];
    } else {
        self.rightPickSelectStr = self.rightPickDataArr[row];
    }
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews) {
        if (singleLine.frame.size.height < 1) {
            singleLine.backgroundColor = [UIColor blackColor];
        }
    }
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.text = pickerView == self.operatorPickerView ? self.leftPickDataArr[row] : [NSString stringWithFormat:@"%@˚C",self.rightPickDataArr[row]];
    genderLabel.textColor = [UIColor colorWithHexString:@"#222222"];
    return genderLabel;
    
}



@end
