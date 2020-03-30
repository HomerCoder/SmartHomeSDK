//
//  GSHYingShiVideoListVC.m
//  SmartHome
//
//  Created by gemdale on 2019/5/10.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHYingShiVideoListVC.h"
#import "PGDatePickManager.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "GSHYingShiVideoVC.h"
#import "GSHAlertManager.h"

@interface GSHYingShiVideoListVCCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;
@end
@implementation GSHYingShiVideoListVCCell
-(void)setFile:(EZDeviceRecordFile *)file{
    _file = file;
    self.lblStartTime.text = [file.startTime stringWithFormat:@"HH:mm:ss"];
    self.lblEndTime.text = [file.stopTime stringWithFormat:@"HH:mm:ss"];
}
@end

@interface GSHYingShiVideoListVC ()<UITableViewDelegate,UITableViewDataSource,PGDatePickerDelegate>
@property(nonatomic, strong)EZDeviceInfo *deviceInfo;
@property(nonatomic, strong)NSString *verifyCode;
- (IBAction)touchDate:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISwitch *switchFullDay;
- (IBAction)touchFullDay:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcFullDayHeight;
@property (strong, nonatomic) NSArray<EZDeviceRecordFile*> *list;
@property (strong, nonatomic) NSDate *beginTime;
@property (strong, nonatomic) NSDate *endTime;
@end

@implementation GSHYingShiVideoListVC

+(instancetype)yingShiVideoListVCWithDeviceInfo:(EZDeviceInfo*)deviceInfo verifyCode:(NSString*)verifyCode{
    GSHYingShiVideoListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingShiVideoListVC"];
    vc.deviceInfo = deviceInfo;
    vc.verifyCode = verifyCode;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *todaty = [[NSDate new] stringWithFormat:@"yyyyMMdd" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [self updateDate:todaty];
    [self refreshIPC];
}

-(void)refreshIPC{
    __weak typeof(self)weakSelf = self;
    [GSHYingShiManager getIPCStatusWithDeviceSerial:self.deviceInfo.deviceSerial block:^(NSDictionary *data, NSError *error) {
        if (data) {
            NSNumber *fulldaySwitchStatus = [data numverValueForKey:@"fulldaySwitchStatus" default:@(0)];
            if (fulldaySwitchStatus.intValue == 0) {
                weakSelf.switchFullDay.on = NO;
                weakSelf.lcFullDayHeight.constant = 83.5;
            }else{
                weakSelf.lcFullDayHeight.constant = 50;
                weakSelf.switchFullDay.on = YES;
            }
        }else{
            weakSelf.lcFullDayHeight.constant = 0;
        }
    }];
}

-(void)showDateSele{
    PGDatePickManager *datePickManager = [[PGDatePickManager alloc]init];
    PGDatePicker *datePicker = datePickManager.datePicker;
    __weak typeof(self)weakSelf = self;
    datePickManager.cancelButtonMonitor = ^{
        NSString *todaty = [[NSDate new] stringWithFormat:@"yyyyMMdd" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [weakSelf updateDate:todaty];
    };
    
    datePicker.delegate = self;
    datePicker.datePickerMode = PGDatePickerModeDate;
    datePicker.isHiddenMiddleText = NO;
    datePicker.middleTextColor = [UIColor clearColor];
    datePicker.maximumDate = [NSDate date];
    datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-365*24*60*60];
    //设置线条的颜色
    datePicker.lineBackgroundColor = [UIColor colorWithHexString:@"#eaeaea"];
    //设置选中行的字体颜色
    datePicker.textColorOfSelectedRow = [UIColor colorWithHexString:@"#222222"];
    //设置未选中行的字体颜色
    datePicker.textColorOfOtherRow = [UIColor colorWithHexString:@"#999999"];
    //设置半透明的背景颜色
    datePickManager.isShadeBackgroud = YES;
    datePickManager.style = PGDatePickerType1;
    //设置头部的背景颜色
    datePickManager.headerViewBackgroundColor = [UIColor whiteColor];
    datePickManager.headerHeight = 45;
    //设置取消按钮的字体颜色
    datePickManager.cancelButtonTextColor = [UIColor colorWithHexString:@"#999999"];
    //设置取消按钮的字
    datePickManager.cancelButtonText = @"重置";
    //设置取消按钮的字体大小
    datePickManager.cancelButtonFont = [UIFont systemFontOfSize:17];
    //设置确定按钮的字体颜色
    datePickManager.confirmButtonTextColor = [UIColor colorWithHexString:@"#2EB0FF"];
    //设置确定按钮的字
    datePickManager.confirmButtonText = @"完成";
    //设置确定按钮的字体大小
    datePickManager.confirmButtonFont = [UIFont systemFontOfSize:17];
    [self presentViewController:datePickManager animated:NO completion:nil];
}

- (void)updateDate:(NSString*)date{
    self.beginTime  = [NSDate dateWithString:[NSString stringWithFormat:@"%@000000",date] format:@"yyyyMMddHHmmss"];
    self.endTime = [NSDate dateWithString:[NSString stringWithFormat:@"%@235959",date] format:@"yyyyMMddHHmmss"];
    [self refreshVideoList];
}

- (void)refreshVideoList{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [EZOpenSDK searchRecordFileFromDevice:self.deviceInfo.deviceSerial cameraNo:self.deviceInfo.cameraNum beginTime:self.beginTime endTime:self.endTime completion:^(NSArray *deviceRecords, NSError *error) {
        [TZMProgressHUDManager dismissInView:weakSelf.view];
        weakSelf.list = [weakSelf splitRecords:deviceRecords];
        [weakSelf.tableView reloadData];
        if (weakSelf.list.count > 0) {
            [weakSelf.tableView dismissPageStatusView];
        }else{
            [weakSelf.tableView showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_nodata"] title:error.code == 1153445 ? @"当前时间暂无录像" : error.localizedDescription desc:nil buttonText:[weakSelf.beginTime isToday] ? nil : @"重置筛选" didClickButtonCallback:^(TZMPageStatus status) {
                NSString *todaty = [[NSDate new] stringWithFormat:@"yyyyMMdd" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
                [weakSelf updateDate:todaty];
            }];
        }
    }] ;
}

-(NSArray<EZDeviceRecordFile*>*)splitRecords:(NSArray<EZDeviceRecordFile*>*)deviceRecords{
    NSMutableArray<EZDeviceRecordFile*> *list = [NSMutableArray array];
    for (EZDeviceRecordFile *file in deviceRecords) {
        if([file.startTime timeIntervalSinceDate:self.beginTime] < 0){
            file.startTime = self.beginTime;
        }
        if([file.stopTime timeIntervalSinceDate:self.endTime] > 0){
            file.stopTime = self.endTime;
        }
        if([file.startTime timeIntervalSinceDate:file.stopTime] > -3){
            continue;
        }
        if ([file.startTime timeIntervalSinceDate:file.stopTime] < -60 * 60) {
            NSDate *startTime = file.startTime;
            while ([startTime timeIntervalSinceDate:file.stopTime] < -60 * 60) {
                EZDeviceRecordFile *newFile = [EZDeviceRecordFile new];
                newFile.startTime = startTime;
                startTime = [NSDate dateWithTimeInterval:60 * 60 sinceDate:startTime];
                newFile.stopTime = startTime;
                [list addObject:newFile];
            }
            EZDeviceRecordFile *newFile = [EZDeviceRecordFile new];
            newFile.startTime = startTime;
            newFile.stopTime = file.stopTime;
            [list addObject:newFile];
            continue;
        }
        [list addObject:file];
    }
    return list;
}

- (IBAction)touchDate:(UIButton *)sender {
    [self showDateSele];
}

- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents{
    NSString *dayString = [NSString stringWithFormat:@"%04d%02d%02d",(int)(dateComponents.year),(int)(dateComponents.month),(int)(dateComponents.day)];
    [self updateDate:dayString];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHYingShiVideoListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.list.count - indexPath.row - 1 >= 0) {
        cell.file = self.list[self.list.count - indexPath.row - 1];
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.list.count - indexPath.row - 1 >= 0) {
        GSHYingShiVideoVC *vc = [GSHYingShiVideoVC yingShiCameraVCWithDeviceSerial:self.deviceInfo.deviceSerial cameraNo:self.deviceInfo.cameraNum recordFileList:self.list seleIndex:self.list.count - indexPath.row - 1 verifyCode:self.verifyCode];
        vc.title = @"内存卡录像";
        [self.navigationController pushViewController:vc animated:YES];
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 42.5;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 42.5)];
    view.backgroundColor = self.view.backgroundColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 300, 22.5)];
    label.textColor = [UIColor colorWithRGB:0x222222];
    label.font = [UIFont systemFontOfSize:16];
    if ([self.beginTime isToday]) {
        label.text = @"今天";
    }else if ([[self.beginTime dateByAddingDays:1] isToday]){
        label.text = @"昨天";
    }else if ([[self.beginTime dateByAddingDays:2] isToday]){
        label.text = @"前天";
    }else{
        label.text = [self.beginTime stringWithFormat:@"yyyy年M月d日" timeZone:nil locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    }
    [view addSubview:label];
    return view;
}

- (IBAction)touchFullDay:(UISwitch*)sender {
    BOOL on = sender.on;
    if (on) {
        __weak typeof(self)weakSelf = self;
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 1) {
                [weakSelf settingFullDay:on];
            }else{
                weakSelf.switchFullDay.on = !on;
            }
        } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"开启全天录像后，会极大占用内存，同时由于读取次数增加也会增加内存卡损坏的几率，确认开启吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    }else{
        [self settingFullDay:on];
    }
}

-(void)settingFullDay:(BOOL)on{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"设置中" inView:self.view];
    [GSHYingShiManager postFulldaySwitchStatusWithDeviceSerial:self.deviceInfo.deviceSerial on:on block:^(NSError *error) {
        if (error) {
            weakSelf.switchFullDay.on = !on;
            [TZMProgressHUDManager showErrorWithStatus:@"设置失败" inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"设置成功" inView:weakSelf.view];
            if (weakSelf.switchFullDay.on) {
                weakSelf.lcFullDayHeight.constant = 50;
            }else{
                weakSelf.lcFullDayHeight.constant = 83.5;
            }
        }
    }];
}

@end
