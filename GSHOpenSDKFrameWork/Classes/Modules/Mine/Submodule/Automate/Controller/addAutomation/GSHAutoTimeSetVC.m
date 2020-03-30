//
//  GSHAutoTimeSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutoTimeSetVC.h"
#import "GSHAutoCreateVC.h"
#import "GSHWeekChooseView.h"

@interface GSHAutoTimeSetVC ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *showTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *weekView;
@property (strong, nonatomic) GSHWeekChooseView *weekChooseView;

@property (strong, nonatomic) NSString *oldTime;
@property (strong, nonatomic) NSMutableIndexSet *repeatCountIndexSet;

@end

@implementation GSHAutoTimeSetVC

+ (instancetype)autoTimeSetVCWithOldTime:(NSString *)oldTime choosedIndexSet:(NSIndexSet *)choosedIndexSet {
    GSHAutoTimeSetVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddAutomationSB" andID:@"GSHAutoTimeSetVC"];
    vc.oldTime = oldTime;
    vc.repeatCountIndexSet = [choosedIndexSet mutableCopy];
    return vc;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.weekChooseView = [[NSBundle mainBundle] loadNibNamed:@"GSHWeekChooseView" owner:self options:nil][0];
    self.weekChooseView.frame = self.weekView.bounds;
    [self.weekView addSubview:self.weekChooseView];
    
    self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [self.datePicker addTarget:self action:@selector(datePickerChange:) forControlEvents:UIControlEventValueChanged];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [dateFormatter dateFromString:self.oldTime];
    if (!self.oldTime) {
        date = [NSDate date];
    }
    [self.datePicker setDate:date];
    [self setShowTimeLabelTextWithDate:date];
    
    if (self.repeatCountIndexSet.count > 0) {
        for (int i = 0; i < 7; i ++) {
            if ([self.repeatCountIndexSet containsIndex:i]) {
                UIButton *btn = [self.weekChooseView.weekButtonArray objectAtIndex:i];
                btn.selected = YES;
            }
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy
- (NSMutableIndexSet *)repeatCountIndexSet {
    if (!_repeatCountIndexSet) {
        _repeatCountIndexSet = [NSMutableIndexSet indexSet];
    }
    return _repeatCountIndexSet;
}

#pragma mark - method
- (void)datePickerChange:(UIDatePicker *)datePicker {
    [self setShowTimeLabelTextWithDate:datePicker.date];
}

- (void)setShowTimeLabelTextWithDate:(NSDate *)date {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    self.showTimeLabel.text = dateStr;
}

- (IBAction)saveButtonClick:(id)sender {
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[GSHAutoCreateVC class]]) {
            
            [self.repeatCountIndexSet removeAllIndexes];
            for (UIButton *btn in self.weekChooseView.weekButtonArray) {
                if (btn.selected) {
                    [self.repeatCountIndexSet addIndex:btn.tag-1];
                }
            }
            NSString *str = [self showRepeatCountStringWithIndexSet:self.repeatCountIndexSet];
            if (self.compeleteSetTimeBlock) {
                self.compeleteSetTimeBlock(self.showTimeLabel.text,str,self.repeatCountIndexSet);
            }
            [self.navigationController popToViewController:vc animated:YES];
        }
        
    }
}

- (NSString *)showRepeatCountStringWithIndexSet:(NSIndexSet *)indexSet {
    __block NSMutableString *showStr = [NSMutableString stringWithFormat:@""];
    if (indexSet.count == 7) {
        [showStr appendString:@"每天执行"];
    } else if (indexSet.count == 2 && [indexSet containsIndex:5] && [indexSet containsIndex:6]){
        [showStr appendString:@"周末执行"];
    } else if (indexSet.count == 5 && ![indexSet containsIndex:5] && ![indexSet containsIndex:6]) {
        [showStr appendString:@"工作日执行"];
    } else if (indexSet.count == 0) {
        [showStr appendString:@"仅一次"];
    } else {
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                [showStr appendString:@"周一、"];
            } else if (idx == 1) {
                [showStr appendString:@"周二、"];
            } else if (idx == 2) {
                [showStr appendString:@"周三、"];
            } else if (idx == 3) {
                [showStr appendString:@"周四、"];
            } else if (idx == 4) {
                [showStr appendString:@"周五、"];
            } else if (idx == 5) {
                [showStr appendString:@"周六、"];
            } else if (idx == 6) {
                [showStr appendString:@"周日、"];
            }
        }];
        showStr = [[showStr substringToIndex:(showStr.length - 1)] mutableCopy];
    }
    return showStr;
}


@end
