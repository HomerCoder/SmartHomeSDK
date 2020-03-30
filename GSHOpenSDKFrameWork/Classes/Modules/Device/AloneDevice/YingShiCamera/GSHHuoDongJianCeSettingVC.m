//
//  GSHHuoDongJianCeSettingVC.m
//  SmartHome
//
//  Created by gemdale on 2018/8/10.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHHuoDongJianCeSettingVC.h"
#import "GSHPickerView.h"

@interface GSHHuoDongJianCeSettingVC ()
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)touchSave:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;
@property (weak, nonatomic) IBOutlet UISwitch *switchOpen;
@property (weak, nonatomic) IBOutlet UISwitch *switchTime;
@property (weak, nonatomic) IBOutlet UIView *viewSetting;
@property (weak, nonatomic) IBOutlet UIView *viewTime;
- (IBAction)touchEndTime:(UIButton *)sender;
- (IBAction)touchStartTime:(UIButton *)sender;
- (IBAction)touchWeek:(UIButton *)sender;
- (IBAction)touchSwitch:(UISwitch *)sender;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *weekBtnList;

@property(nonatomic,strong)GSHDeviceM *device;
@property(nonatomic,strong)NSMutableDictionary *ipc;
@property(nonatomic,strong)GSHYingShiCameraDefenceM *defenceM;
@property(nonatomic,strong)NSMutableArray<NSDictionary<NSString*,NSArray<NSString*>*>*> *changeStartTimeArray;
@property(nonatomic,strong)NSMutableArray<NSDictionary<NSString*,NSArray<NSString*>*>*> *changeEndTimeArray;
@property(nonatomic,strong)NSMutableArray *mArrry;
@property(nonatomic,assign)NSInteger cameraNo;
@property(nonatomic,copy)NSString *startTime;
@property(nonatomic,copy)NSString *endTime;
@end

@implementation GSHHuoDongJianCeSettingVC

+(instancetype)huoDongJianCeSettingVCWithDevice:(GSHDeviceM*)device ipc:(NSMutableDictionary*)ipc{
    GSHHuoDongJianCeSettingVC *vc = [GSHPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHHuoDongJianCeSettingVC"];
    vc.device = device;
    vc.ipc = ipc;
    return vc;
}

-(void)setDefenceM:(GSHYingShiCameraDefenceM *)defenceM{
    _defenceM = defenceM;
    if (defenceM) {
        NSRange nRange = [defenceM.stopTime rangeOfString:@"n"];
        if (nRange.location == NSNotFound) {
            self.lblEndTime.text = [NSString stringWithFormat:@"%@",defenceM.stopTime.length > 0 ? defenceM.stopTime : @"请设置"];
        }else{
            self.lblEndTime.text = [NSString stringWithFormat:@"%@(第二天)",[defenceM.stopTime substringFromIndex:nRange.location + nRange.length]];
        }
        self.endTime = defenceM.stopTime;
        self.lblStartTime.text = defenceM.startTime.length > 0 ? defenceM.startTime : @"请设置";
        self.startTime = defenceM.startTime;
        
        NSArray *startArray = [self.startTime componentsSeparatedByString:@":"];
        if (startArray.count > 1) {
            NSString *hItem = startArray[0];
            NSString *mItem = startArray[1];
            [self updateChangeEndTimeArrayWithHour:hItem.intValue minute:mItem.intValue];
        }
        
        for (UIButton *but in self.weekBtnList) {
            NSString *tag = [NSString stringWithFormat:@"%d",(int)but.tag];
            if ([defenceM.period rangeOfString:tag].location == NSNotFound) {
                but.selected = NO;
            }else{
                but.selected = YES;
            }
        }
        
        self.viewTime.hidden = NO;
        if (defenceM.defenceEnable.integerValue == 0) {
            self.switchTime.on = NO;
            self.viewSetting.hidden = YES;
        }else{
            self.switchTime.on = YES;
            self.viewSetting.hidden = NO;
        }
    }else{
        self.viewSetting.hidden = YES;
        self.viewTime.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.changeStartTimeArray = [NSMutableArray array];
    self.changeEndTimeArray = [NSMutableArray array];
    self.mArrry = [NSMutableArray array];
    for (int i = 0; i < 60; i++) {
        [self.mArrry addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    for (int i = 0; i < 24; i++) {
        [self.changeStartTimeArray addObject:@{[NSString stringWithFormat:@"%02d",i] : self.mArrry}];
    }
    
    self.cameraNo = 1;
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refreshData{
    NSNumber *isDefence = [self.ipc numverValueForKey:@"isDefence" default:nil];
    if (isDefence.intValue == 0) {
        self.switchOpen.on = NO;
    }else{
        self.switchOpen.on = YES;
    }
    [TZMProgressHUDManager showWithStatus:@"请稍候" inView:self.view];
    __weak typeof(self) weakSelf = self;
    [GSHYingShiManager getDefencePlanWithDeviceSerial:self.device.deviceSn channelNo:self.cameraNo block:^(GSHYingShiCameraDefenceM *model, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.defenceM = model;
        }
    }];
}

- (IBAction)touchSave:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    NSNumber *isDefence = [self.ipc numverValueForKey:@"isDefence" default:nil];
    if (self.switchOpen.on != (isDefence.intValue != 0)) {
        [TZMProgressHUDManager showWithStatus:@"请稍候" inView:self.view];
        [GSHYingShiManager postDefenceWithDeviceSerial:self.device.deviceSn on:self.switchOpen.on block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:@"保存失败，请重试" inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [weakSelf.ipc setValue:@(weakSelf.switchOpen.on ? 1 : 0) forKey:@"isDefence"];
                [weakSelf saveDefencePlan];
            }
        }];
    }else{
        [self saveDefencePlan];
    }
}

-(void)saveDefencePlan{
    NSString *startTime = self.startTime;
    NSString *endTime = self.endTime;
    NSMutableString *period = [NSMutableString string];
    for (UIButton *btn in self.weekBtnList) {
        if (btn.selected) {
            [period appendString:[NSString stringWithFormat:@"%d,",(int)btn.tag]];
        }
    }
    NSString *periodStr;
    if (period.length > 1) {
        periodStr = [period substringToIndex:period.length - 1];
    }
    
    if (self.switchTime.on) {
        if (startTime.length < 4) {
            [TZMProgressHUDManager showErrorWithStatus:@"请输入开始时间" inView:self.view];
            return;
        }
        if (endTime.length < 4) {
            [TZMProgressHUDManager showErrorWithStatus:@"请输入结束时间" inView:self.view];
            return;
        }
        if ([startTime compare:endTime] != NSOrderedAscending) {
            [TZMProgressHUDManager showErrorWithStatus:@"结束时间必须大于开始时间" inView:self.view];
            return;
        }
        if (periodStr.length == 0) {
            [TZMProgressHUDManager showErrorWithStatus:@"请选择重复时间" inView:self.view];
            return;
        }
    }
    
    [TZMProgressHUDManager showWithStatus:@"请稍候" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHYingShiManager postDefencePlanWithDeviceSerial:self.device.deviceSn startTime:startTime stopTime:endTime period:periodStr channelNo:self.cameraNo defenceEnable:self.switchTime.on block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:@"保存失败，请重试" inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"保存成功" inView:weakSelf.view];
            weakSelf.defenceM.startTime = startTime;
            weakSelf.defenceM.stopTime = endTime;
            weakSelf.defenceM.period = periodStr;
            [weakSelf.navigationController popViewControllerAnimated:YES];
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
    for (int i = 0; i <= minute; i++) {
        [array addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    [self.changeEndTimeArray addObject:@{[NSString stringWithFormat:@"%02d(第二天)",hour] : array}];
}

- (IBAction)touchEndTime:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    if (weakSelf.startTime.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请先选择开始时间" inView:weakSelf.view];
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
    
    [GSHPickerView showPickerViewWithDataArray:self.changeEndTimeArray selectContent:selectContent completion:^(NSString *selectContent , NSArray *selectRowArray) {
        if (selectRowArray.count > 1) {
            id hItem = selectRowArray[0];
            id mItem = selectRowArray[1];
            if ([hItem isKindOfClass:NSNumber.class] && [mItem isKindOfClass:NSNumber.class]) {
                int h = ((NSNumber*)hItem).intValue;
                int m = ((NSNumber*)mItem).intValue;
                if (h < weakSelf.changeEndTimeArray.count) {
                    NSDictionary<NSString*,NSArray*> *dic = weakSelf.changeEndTimeArray[h];
                    NSString *hString = [dic.allKeys firstObject];
                    NSArray<NSString*> *value = [dic valueForKey:hString];
                    if (m < value.count) {
                        NSString *mString = value[m];
                        NSRange range = [hString rangeOfString:@"(第二天)"];
                        if (range.location == NSNotFound) {
                            weakSelf.endTime = [NSString stringWithFormat:@"%@:%@",hString,mString];
                        }else{
                            weakSelf.endTime = [NSString stringWithFormat:@"n%@:%@",[hString substringToIndex:range.location],mString];
                        }
                        NSRange nRange = [weakSelf.endTime rangeOfString:@"n"];
                        if (nRange.location == NSNotFound) {
                            weakSelf.lblEndTime.text = [NSString stringWithFormat:@"%@",weakSelf.endTime];
                        }else{
                            weakSelf.lblEndTime.text = [NSString stringWithFormat:@"%@(第二天)",[weakSelf.endTime substringFromIndex:nRange.location + nRange.length]];
                        }
                    }
                }
            }
        }
    }];
}

- (IBAction)touchStartTime:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    
    NSArray *startArray = [self.startTime componentsSeparatedByString:@":"];
    NSString *selectContent;
    if (startArray.count > 1) {
        NSString *hItem = startArray[0];
        NSString *mItem = startArray[1];
        selectContent = [NSString stringWithFormat:@"%@,%@",hItem,mItem];
    }
    
    [GSHPickerView showPickerViewWithDataArray:self.changeStartTimeArray selectContent:(NSString*)selectContent completion:^(NSString *selectContent , NSArray *selectRowArray) {
        if (selectRowArray.count > 1) {
            id hItem = selectRowArray[0];
            id mItem = selectRowArray[1];
            if ([hItem isKindOfClass:NSNumber.class] && [mItem isKindOfClass:NSNumber.class]) {
                int h = ((NSNumber*)hItem).intValue;
                int m = ((NSNumber*)mItem).intValue;
                weakSelf.startTime = [NSString stringWithFormat:@"%02d:%02d",h,m];
                weakSelf.lblStartTime.text = weakSelf.startTime;
                weakSelf.endTime = nil;
                weakSelf.lblEndTime.text = nil;
                [weakSelf updateChangeEndTimeArrayWithHour:h minute:m];
            }
        }
    }];
}

- (IBAction)touchWeek:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)touchSwitch:(UISwitch *)sender {
    self.viewSetting.hidden = !sender.on;
}
@end
