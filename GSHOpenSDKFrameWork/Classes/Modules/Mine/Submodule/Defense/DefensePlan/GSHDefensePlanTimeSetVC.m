//
//  GSHDefensePlanTimeSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/6/4.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDefensePlanTimeSetVC.h"
#import "GSHPickerView.h"

@interface GSHDefensePlanTimeSetVC ()

@property (weak, nonatomic) IBOutlet UIView *endTimeView;
@property (weak, nonatomic) IBOutlet UIView *startTimeView;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *allDayView;
@property (weak, nonatomic) IBOutlet UISwitch *timeSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *isCloseTimeSwitch;

@property (nonatomic,strong) NSMutableArray<NSDictionary<NSString*,NSArray<NSString*>*>*> *changeStartTimeArray;
@property (nonatomic,strong) NSMutableArray<NSDictionary<NSString*,NSArray<NSString*>*>*> *changeEndTimeArray;
@property (nonatomic,strong) NSMutableArray *mArrry;

@property (nonatomic,copy) NSString *binaryTimeStr;
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,copy) NSString *endTime;

@end

@implementation GSHDefensePlanTimeSetVC

+(instancetype)defensePlanTimeSetVCWithTitle:(NSString *)title timeStr:(NSString *)timeStr {
    GSHDefensePlanTimeSetVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDefensePlanSB" andID:@"GSHDefensePlanTimeSetVC"];
    vc.title = title;
    vc.binaryTimeStr = timeStr;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.changeStartTimeArray = [NSMutableArray array];
    self.changeEndTimeArray = [NSMutableArray array];
    self.mArrry = [NSMutableArray arrayWithObjects:@"00",@"30", nil];
    for (int i = 0; i < 24; i++) {
        [self.changeStartTimeArray addObject:@{[NSString stringWithFormat:@"%02d",i] : self.mArrry}];
    }
    
    if (self.binaryTimeStr.length > 0) {
        
        NSRange startRange = [self.binaryTimeStr rangeOfString:@"1"];
        if (startRange.location == NSNotFound) {
            // 关闭 , 全0
            self.isCloseTimeSwitch.on = YES;
            [self closeTimeViewChange];
        } else {
            self.isCloseTimeSwitch.on = NO;
            NSRange endRange = [self.binaryTimeStr rangeOfString:@"1" options:NSBackwardsSearch];
            if (endRange.location != NSNotFound) {
                if (startRange.location == 0 && endRange.location == 47) {
                    // 全天
                    self.timeSwitch.on = YES;
                    self.startTimeView.hidden = YES;
                    self.endTimeView.hidden = YES;
                } else {
                    self.timeSwitch.on = NO;
                    self.startTimeView.hidden = NO;
                    self.endTimeView.hidden = NO;
                    int startLocation = (int)startRange.location;
                    int startHour = startLocation / 2;
                    int startMinute = startLocation % 2 == 0 ? 0 : 30;
                    int endLocation = (int)endRange.location;
                    int endHour = (endLocation+1) / 2;
                    int endMinute = endLocation % 2 - 1 == 0 ? 0 : 30;
                    self.startTime = [NSString stringWithFormat:@"%02d:%02d",startHour,startMinute];
                    self.endTime = [NSString stringWithFormat:@"%02d:%02d",endHour,endMinute];
                    self.startTimeLabel.text = self.startTime;
                    self.endTimeLabel.text = self.endTime;
                    [self updateChangeEndTimeArrayWithHour:startHour minute:startMinute];
                }
            }
        }
    }
}

#pragma mark - Action

- (IBAction)isCloseTimeSwitchClick:(UISwitch *)sender {
    
    self.allDayView.hidden = sender.on;
    if (sender.on) {
        // 关闭时间
        [self closeTimeViewChange];
    } else {
        // 开启时间
        [self openTimeViewChange];
    }
}

// 关闭时间
- (void)closeTimeViewChange {
    self.allDayView.hidden = YES;
    self.startTimeView.hidden = YES;
    self.endTimeView.hidden = YES;
}

// 开启时间
- (void)openTimeViewChange {
    self.allDayView.hidden = NO;
    self.startTimeView.hidden = self.timeSwitch.on;
    self.endTimeView.hidden = self.timeSwitch.on;
}

- (IBAction)switchClick:(UISwitch *)sender {
    self.startTimeView.hidden = sender.on;
    self.endTimeView.hidden = sender.on;
}

- (IBAction)sureButtonClick:(id)sender {
    NSString *showStr = @"关闭";
    NSString *binaryStr = @"";
    if (self.isCloseTimeSwitch.on) {
        // 关闭时间
        showStr = @"关闭";
        binaryStr = @"000000000000000000000000000000000000000000000000";
    } else {
        // 未关闭时间
        if (self.timeSwitch.on) {
            // 全天
            showStr = @"全天";
            binaryStr = @"111111111111111111111111111111111111111111111111";
        } else {
            if (!self.startTime) {
                [TZMProgressHUDManager showErrorWithStatus:@"请选择开始时间" inView:self.view];
                return;
            }
            if (!self.endTime) {
                [TZMProgressHUDManager showErrorWithStatus:@"请选择结束时间" inView:self.view];
                return;
            }
            showStr = [NSString stringWithFormat:@"开启 (%@ -- %@)",self.startTime,self.endTime];
            binaryStr = [self convertTimeToBinaryStrWithStartTime:self.startTime endTime:self.endTime];
        }
    }
    
    NSLog(@"binaryStr : %@",binaryStr);
    if (self.sureButtonClickBlock) {
        self.sureButtonClickBlock(showStr, binaryStr);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startButtonClick:(id)sender {
    NSArray *startArray = [@"00:00" componentsSeparatedByString:@":"];
    NSString *selectContent;
    if (startArray.count > 1) {
        NSString *hItem = startArray[0];
        NSString *mItem = startArray[1];
        selectContent = [NSString stringWithFormat:@"%@,%@",hItem,mItem];
    }
    @weakify(self)
    [GSHPickerView showPickerViewWithDataArray:self.changeStartTimeArray selectContent:(NSString*)selectContent completion:^(NSString *selectContent , NSArray *selectRowArray) {
        @strongify(self)
        if (selectContent.length > 3) {
            id hItem = [selectContent substringWithRange:NSMakeRange(0, 2)];
            id mItem = [selectContent substringWithRange:NSMakeRange(2, 2)];
            int h = ((NSString*)hItem).intValue;
            int m = ((NSString*)mItem).intValue;
            self.startTime = [NSString stringWithFormat:@"%02d:%02d",h,m];
            self.startTimeLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            self.startTimeLabel.text = self.startTime;
            self.endTimeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            self.endTimeLabel.text = @"请选择";
            self.endTime = nil;
            [self updateChangeEndTimeArrayWithHour:h minute:m];
        }
    }];
}

- (IBAction)endTimeButtonClick:(id)sender {
    if ([self.startTimeLabel.text isEqualToString:@"请选择"]) {
        [TZMProgressHUDManager showErrorWithStatus:@"请先选择开始时间" inView:self.view];
        return;
    }
    NSArray *endArray = [self.endTime componentsSeparatedByString:@":"];
    NSString *selectContent = @"";
    if (endArray.count > 1) {
        NSString *hItem = endArray[0];
        NSString *mItem = endArray[1];
        selectContent = [NSString stringWithFormat:@"%@,%@",hItem,mItem];
    }
    @weakify(self)
    [GSHPickerView showPickerViewWithDataArray:self.changeEndTimeArray selectContent:selectContent completion:^(NSString *selectContent , NSArray *selectRowArray) {
        @strongify(self)
        if (selectRowArray.count > 1) {
            id hItem = selectRowArray[0];
            id mItem = selectRowArray[1];
            if ([hItem isKindOfClass:NSNumber.class] && [mItem isKindOfClass:NSNumber.class]) {
                int h = ((NSNumber*)hItem).intValue;
                int m = ((NSNumber*)mItem).intValue;
                if (h < self.changeEndTimeArray.count) {
                    NSDictionary<NSString*,NSArray*> *dic = self.changeEndTimeArray[h];
                    NSString *hString = [dic.allKeys firstObject];
                    NSArray<NSString*> *value = [dic valueForKey:hString];
                    if (m < value.count) {
                        NSString *mString = value[m];
                        self.endTime = [NSString stringWithFormat:@"%@:%@",hString,mString];
                        self.endTimeLabel.text = [NSString stringWithFormat:@"%@",self.endTime];
                        self.endTimeLabel.textColor = [UIColor colorWithHexString:@"#222222"];
                    }
                }
            }
        }
    }];
}

-(void)updateChangeEndTimeArrayWithHour:(int)hour minute:(int)minute{
    [self.changeEndTimeArray removeAllObjects];
    if (minute == 0) {
        [self.changeEndTimeArray addObject:@{[NSString stringWithFormat:@"%02d",hour] : @[@"30"]}];
    }
    for (int i = 1; i < 24; i++) {
        if (hour + i < 24) {
            [self.changeEndTimeArray addObject:@{[NSString stringWithFormat:@"%02d",(hour + i)] : self.mArrry}];
        }
    }
    [self.changeEndTimeArray addObject:@{@"24":@[@"00"]}];
}

- (NSString *)convertTimeToBinaryStrWithStartTime:(NSString *)startTime endTime:(NSString *)endTime {
    
    NSMutableString *binaryStr = [NSMutableString string];
    NSArray *startArr = [startTime componentsSeparatedByString:@":"];
    NSArray *endArr = [endTime componentsSeparatedByString:@":"];
    int startMin = ((NSString *)startArr[1]).intValue == 0 ? 0 : 1;
    int start = ((NSString *)startArr[0]).intValue * 2 + startMin;
    
    int endMin = ((NSString *)endArr[1]).intValue == 0 ? 0 : 1;
    int end = ((NSString *)endArr[0]).intValue * 2 + endMin - 1;

    for (int i = 0; i < 48; i ++) {
        if (i >= start && i <= end) {
            [binaryStr appendString:@"1"];
        } else {
            [binaryStr appendString:@"0"];
        }
    }
    return binaryStr;
    
}

@end
