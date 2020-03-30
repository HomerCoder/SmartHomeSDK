//
//  GSHAutoEffectTimeSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/10/29.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHAutoEffectTimeSetVC.h"

#import "GSHPickerView.h"
#import "GSHWeekChooseView.h"

@interface GSHAutoEffectTimeSetVC ()

@property (weak, nonatomic) IBOutlet UIView *timeSetView;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *allDaySwitch;
@property (weak, nonatomic) IBOutlet UIView *weekView;
@property (strong, nonatomic) GSHWeekChooseView *weekChooseView;

@property (strong, nonatomic) NSMutableIndexSet *repeatCountIndexSet;

@property(nonatomic,strong)NSMutableArray<NSDictionary<NSString*,NSArray<NSString*>*>*> *changeStartTimeArray;
@property(nonatomic,strong)NSMutableArray<NSDictionary<NSString*,NSArray<NSString*>*>*> *changeEndTimeArray;
@property(nonatomic,strong)NSMutableArray *mArrry;

@property(nonatomic,copy)NSString *startTime;
@property(nonatomic,copy)NSString *endTime;

@end

@implementation GSHAutoEffectTimeSetVC

+(instancetype)autoEffectTimeSetVCWithStartTime:(NSString *)startTime
                                        endTime:(NSString *)endTime
                                   weekIndexSet:(NSIndexSet *)weekIndexSet
                                  timeSetVCType:(GSHEffectTimeSetVCType)timeSetVCType {
    
    GSHAutoEffectTimeSetVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddAutomationSB" andID:@"GSHAutoEffectTimeSetVC"];
    vc.startTime = startTime;
    vc.endTime = endTime;
    vc.repeatCountIndexSet = [weekIndexSet mutableCopy];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.weekChooseView = [[NSBundle mainBundle] loadNibNamed:@"GSHWeekChooseView" owner:self options:nil][0];
    self.weekChooseView.frame = self.weekView.bounds;
    [self.weekView addSubview:self.weekChooseView];
    
    self.changeStartTimeArray = [NSMutableArray array];
    self.changeEndTimeArray = [NSMutableArray array];
    self.mArrry = [NSMutableArray array];
    for (int i = 0; i < 60; i++) {
        [self.mArrry addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    for (int i = 0; i < 24; i++) {
        [self.changeStartTimeArray addObject:@{[NSString stringWithFormat:@"%02d",i] : self.mArrry}];
    }
    if (self.startTime && self.endTime && self.repeatCountIndexSet) {
        // 已选时间，编辑
        
        for (int i = 0; i < 7; i ++) {
            if ([self.repeatCountIndexSet containsIndex:i]) {
                UIButton *btn = [self.weekChooseView.weekButtonArray objectAtIndex:i];
                btn.selected = YES;
            }
        }
        
        if ([self.startTime isEqualToString:self.endTime]) {
            // 全天
            self.allDaySwitch.on = YES;
            self.timeSetView.hidden = YES;
        } else {
            self.startTimeLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            self.endTimeLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            self.allDaySwitch.on = NO;
            self.startTimeLabel.text = self.startTime;
            NSArray *startTimeArr = [self.startTime componentsSeparatedByString:@":"];
            if (startTimeArr.count > 1) {
                id hItem = startTimeArr[0];
                id mItem = startTimeArr[1];
                int h = ((NSString*)hItem).intValue;
                int m = ((NSString*)mItem).intValue;
                [self updateChangeEndTimeArrayWithHour:h minute:m];
            }
            NSRange nRange = [self.endTime rangeOfString:@"n"];
            if (nRange.location == NSNotFound) {
                self.endTimeLabel.text = [NSString stringWithFormat:@"%@",self.endTime];
            } else {
                self.endTimeLabel.text = [NSString stringWithFormat:@"%@(第二天)",[self.endTime substringFromIndex:nRange.location + nRange.length]];
            }
        }
    } else {
        self.startTime = @"00:00";
    }
}

#pragma mark - Lazy
- (NSMutableIndexSet *)repeatCountIndexSet {
    if (!_repeatCountIndexSet) {
        _repeatCountIndexSet = [NSMutableIndexSet indexSet];
    }
    return _repeatCountIndexSet;
}

#pragma mark - method

- (IBAction)touchSwitch:(UISwitch *)sender {
    self.timeSetView.hidden = sender.on;
}

- (IBAction)touchSure:(id)sender {
    
    NSString *startTime = self.startTimeLabel.text;
    NSString *endTime = self.endTimeLabel.text;
    
    [self.repeatCountIndexSet removeAllIndexes];
    for (UIButton *btn in self.weekChooseView.weekButtonArray) {
        if (btn.selected) {
            [self.repeatCountIndexSet addIndex:btn.tag-1];
        }
    }
    
    if (!self.allDaySwitch.on) {
        if (startTime.length < 4) {
            [TZMProgressHUDManager showErrorWithStatus:@"请输入开始时间" inView:self.view];
            return;
        }
        if (endTime.length < 4) {
            [TZMProgressHUDManager showErrorWithStatus:@"请输入结束时间" inView:self.view];
            return;
        }
    } 
    if (self.saveBlock) {
        self.saveBlock(self.allDaySwitch.on,self.repeatCountIndexSet,self.startTime, self.endTime);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnStartTimeClick:(id)sender {
    
    NSArray *startArray = [self.startTime componentsSeparatedByString:@":"];
    NSString *selectContent;
    if (startArray.count > 1) {
        NSString *hItem = startArray[0];
        NSString *mItem = startArray[1];
        selectContent = [NSString stringWithFormat:@"%@,%@",hItem,mItem];
    }
    @weakify(self)
    [GSHPickerView showPickerViewWithDataArray:self.changeStartTimeArray selectContent:(NSString*)selectContent completion:^(NSString *selectContent , NSArray *selectRowArray) {
        @strongify(self)
        if (selectRowArray.count > 1) {
            id hItem = selectRowArray[0];
            id mItem = selectRowArray[1];
            if ([hItem isKindOfClass:NSNumber.class] && [mItem isKindOfClass:NSNumber.class]) {
                int h = ((NSNumber*)hItem).intValue;
                int m = ((NSNumber*)mItem).intValue;
                self.startTime = [NSString stringWithFormat:@"%02d:%02d",h,m];
                self.startTimeLabel.textColor = [UIColor colorWithHexString:@"#222222"];
                self.startTimeLabel.text = self.startTime;
                self.endTimeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
                self.endTimeLabel.text = @"请选择";
                self.endTime = nil;
                [self updateChangeEndTimeArrayWithHour:h minute:m];
            }
        }
    }];
}

- (IBAction)btnEndTimeClick:(id)sender {
    
    if ([self.startTimeLabel.text isEqualToString:@"请选择"]) {
        [TZMProgressHUDManager showErrorWithStatus:@"请先选择开始时间" inView:self.view];
        return;
    }
    
    NSArray *endArray = [self.endTime componentsSeparatedByString:@":"];
    NSString *selectContent = @"";
    if (endArray.count > 1) {
        NSString *hItem = endArray[0];
        NSString *mItem = endArray[1];
        NSRange nRange = [hItem rangeOfString:@"n"];
        if (nRange.location == NSNotFound) {
            selectContent = [NSString stringWithFormat:@"%@,%@",hItem,mItem];
        }else{
            selectContent = [NSString stringWithFormat:@"%@(第二天),%@",[hItem substringFromIndex:nRange.location + nRange.length],mItem];
        }
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
                        NSRange range = [hString rangeOfString:@"(第二天)"];
                        if (range.location == NSNotFound) {
                            self.endTime = [NSString stringWithFormat:@"%@:%@",hString,mString];
                        }else{
                            self.endTime = [NSString stringWithFormat:@"n%@:%@",[hString substringToIndex:range.location],mString];
                        }
                        NSRange nRange = [self.endTime rangeOfString:@"n"];
                        if (nRange.location == NSNotFound) {
                            self.endTimeLabel.text = [NSString stringWithFormat:@"%@",self.endTime];
                        }else{
                            self.endTimeLabel.text = [NSString stringWithFormat:@"%@(第二天)",[self.endTime substringFromIndex:nRange.location + nRange.length]];
                        }
                        self.endTimeLabel.textColor = [UIColor colorWithHexString:@"#222222"];
                    }
                }
            }
        }
    }];
}

-(void)updateChangeEndTimeArrayWithHour:(int)hour minute:(int)minute{
    [self.changeEndTimeArray removeAllObjects];
    if (minute < 59) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = minute + 1; i < 60; i++) {
            [array addObject:[NSString stringWithFormat:@"%02d",i]];
        }
        [self.changeEndTimeArray addObject:@{[NSString stringWithFormat:@"%02d",hour] : array}];
    }
    for (int i = 1; i < 24; i++) {
        if (hour + i < 24) {
            [self.changeEndTimeArray addObject:@{[NSString stringWithFormat:@"%02d",(hour + i)] : self.mArrry}];
        }else{
            [self.changeEndTimeArray addObject:@{[NSString stringWithFormat:@"%02d(第二天)",(hour + i) % 24] : self.mArrry}];
        }
    }
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < minute; i++) {
        [array addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    if (array.count > 0) {
        [self.changeEndTimeArray addObject:@{[NSString stringWithFormat:@"%02d(第二天)",hour] : array}];
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
