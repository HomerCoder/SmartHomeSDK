//
//  GSHYingShiGaoJingListVC.m
//  SmartHome
//
//  Created by gemdale on 2018/8/20.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiGaoJingListVC.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "UIScrollView+TZMRefreshAndLoadMore.h"
#import "Masonry.h"
#import "GSHGaoJingDetailVC.h"
#import "PGDatePickManager.h"
#import "GSHAlertManager.h"
#import "NSObject+TZM.h"
#import "UIImageView+WebCache.h"

NSString * const GSHYingShiGaoJingDeleteNotification = @"GSHYingShiGaoJingDeleteNotification";

@interface GSHYingShiGaoJingListVCHeader()
@property (nonatomic,strong) UILabel *label;
@property (strong, nonatomic) NSLayoutConstraint *lcLeading;
@property (strong, nonatomic) UIButton *btnSele;
- (void)touchSele:(UIButton *)sender;
@property (strong, nonatomic)GSHYingShiGaoJingGroupM *model;
@end

@implementation GSHYingShiGaoJingListVCHeader
- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.label = [[UILabel alloc]initWithFrame:CGRectZero];
        self.label.font = [UIFont systemFontOfSize:16];
        self.label.textColor = [UIColor colorWithHexString:@"#222222"];
        [self addSubview:self.label];
        __weak typeof(self)weakSelf = self;
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(weakSelf).offset(15);
            make.top.equalTo(weakSelf).offset(15);
            make.height.equalTo(@(22.5));
        }];
        
        // 2.1左边约束
        self.lcLeading = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:50];
        [self addConstraint:self.lcLeading];
        
        self.btnSele = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.btnSele setImage:[UIImage ZHImageNamed:@"yingShiGaoJingListVC_xuanZhong_n"] forState:UIControlStateNormal];
        [self.btnSele setImage:[UIImage ZHImageNamed:@"yingShiGaoJingListVC_xuanZhong_s"] forState:UIControlStateSelected];
        [self.btnSele addTarget:self action:@selector(touchSele:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnSele];
        [self.btnSele mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(weakSelf).offset(5);
            make.height.equalTo(@(44));
            make.width.equalTo(@(44));
            make.centerY.equalTo(weakSelf.label);
        }];
        self.btnSele.hidden = YES;
    }
    return self;
}

-(void)setModel:(GSHYingShiGaoJingGroupM *)model{
    _model = model;
    self.label.text = model.dateDay;
    self.btnSele.selected = model.isSele;
}

-(void)touchSele:(UIButton *)sender{
    self.model.isSele = !sender.selected;
    for (GSHYingShiGaoJingM *model in self.model.list) {
        model.isSele = !sender.selected;
    }
    if ([self.viewController isKindOfClass:GSHYingShiGaoJingListVC.class]) {
        [((GSHYingShiGaoJingListVC*)self.viewController) refreshSeleAll];
    }
    if ([self.superview isKindOfClass:UITableView.class]) {
        [((UITableView*)self.superview) reloadData];
    }
}
@end

@interface GSHYingShiGaoJingListVCCell()
@property (weak, nonatomic) IBOutlet UILabel *lblWeiJie;
@property (weak, nonatomic) IBOutlet UIButton *btnSele;
- (IBAction)touchSele:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewContent;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewUnread;
@property (weak, nonatomic) IBOutlet UIImageView *imageShouCang;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcLeading;

@property (assign,nonatomic)GSHYingShiGaoJingListVCType type;
@property (strong,nonatomic)GSHYingShiGaoJingM *model;
@property (strong,nonatomic)GSHYingShiGaoJingGroupM *group;
@property (weak,nonatomic)UITableView *tableView;

@end
@implementation GSHYingShiGaoJingListVCCell
- (IBAction)touchSele:(UIButton *)sender {
    self.model.isSele = !sender.selected;
    BOOL allSele = YES;
    for (GSHYingShiGaoJingM *model in self.group.list) {
        if (!model.isSele) {
            allSele = NO;
        }
    }
    self.group.isSele = allSele;
    if ([self.viewController isKindOfClass:GSHYingShiGaoJingListVC.class]) {
        [((GSHYingShiGaoJingListVC*)self.viewController) refreshSeleAll];
    }
    [self.tableView reloadData];
}

-(void)setModel:(GSHYingShiGaoJingM *)model{
    _model = model;
    self.lblName.text = model.alarmName;
    [self.imageViewContent sd_setImageWithURL:[NSURL URLWithString:model.alarmPicUrl]];
    self.imageViewUnread.hidden = model.isChecked == 1;
    self.imageShouCang.hidden = model.collectState == 0;
    self.lblContent.text = model.roomName;
    self.lblTime.text = model.startTime;
    self.btnSele.selected = model.isSele;
    
    if ([model.alarmType isEqualToString:@"motiondetect"]) {
        self.lblWeiJie.hidden = YES;
        self.lblContent.hidden = NO;
    } else {
        self.lblContent.hidden = YES;
        if ([model.alarmType isEqualToString:@"calling"]) {
            self.lblName.text = @"有人按门铃";
            self.lblWeiJie.hidden = NO;
            if (model.isPicked) {
                self.lblWeiJie.backgroundColor = [UIColor colorWithRGB:0x4CD664];
                self.lblWeiJie.text = @"已接";
            }else{
                self.lblWeiJie.backgroundColor = [UIColor colorWithRGB:0xE64430];
                self.lblWeiJie.text = @"未接";
            }
        } else {
            self.lblWeiJie.hidden = YES;
        }
    }
}

-(void)setType:(GSHYingShiGaoJingListVCType)type{
    _type = type;
    if (type == GSHYingShiGaoJingListVCTypeCollect) {
        self.imageViewUnread.hidden = YES;
        self.imageShouCang.hidden = YES;
    }
}
@end


@interface GSHYingShiGaoJingListVC ()<UITableViewDelegate,UITableViewDataSource,PGDatePickerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnBianJi;
- (IBAction)touchBianJi:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnShaiXuan;
- (IBAction)touchShaiXuan:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *headView;
- (IBAction)touchHeadView:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIButton *btnSeleAll;
- (IBAction)touchSeleAll:(UIButton *)sender;
- (IBAction)touchRead:(UIButton *)sender;
- (IBAction)touchDelete:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcFootViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcHeadViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnRead;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;


@property(nonatomic,strong)GSHDeviceM *device;
@property(nonatomic,assign)GSHYingShiGaoJingListVCType type;
@property(nonatomic,assign)GSHYingShiGaoJingMAlarmType alarmType;
@property(nonatomic,assign)BOOL isEdit;
@property(nonatomic,strong)NSNumber *startTime;
@property(nonatomic,strong)NSNumber *endTime;
@property(nonatomic,strong)NSMutableArray<GSHYingShiGaoJingGroupM*> *list;
@property(nonatomic,strong)NSMutableArray<GSHYingShiGaoJingM*> *gaoJinglist;
@property(nonatomic,strong)NSMutableDictionary<NSString*,GSHYingShiGaoJingGroupM*> *dic;
@end

@implementation GSHYingShiGaoJingListVC

+(instancetype)yingShiGaoJingListVCWithtype:(GSHYingShiGaoJingListVCType)type device:(GSHDeviceM*)device alarmType:(GSHYingShiGaoJingMAlarmType)alarmType{
    GSHYingShiGaoJingListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHYingShiGaoJingListVC"];
    vc.type = type;
    vc.device = device;
    vc.alarmType = alarmType;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.alarmType == GSHYingShiGaoJingMAlarmTypeDoorbell) {
        self.title = @"门铃呼叫记录";
    }else{
        self.title = @"告警记录";
    }
    self.list = [NSMutableArray array];
    self.dic = [NSMutableDictionary dictionary];
    self.gaoJinglist = [NSMutableArray array];
    [self.tableView registerClass:GSHYingShiGaoJingListVCHeader.class forHeaderFooterViewReuseIdentifier:@"header"];
    [self initUI];
    [self refreshDataWithAlarmTime:nil];
    [self observerNotifications];
}

-(void)observerNotifications{
    [self observerNotification:GSHYingShiGaoJingCollectChangeNotification];
    [self observerNotification:GSHYingShiGaoJingDeleteNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHYingShiGaoJingCollectChangeNotification] || [notification.name isEqualToString:GSHYingShiGaoJingDeleteNotification]) {
        if (self.type == GSHYingShiGaoJingListVCTypeAll) {
            NSDictionary *dic = notification.object;
            NSString *collect = [dic objectForKey:@"collect"];
            NSString *alarmId = [dic objectForKey:@"alarmId"];
            NSString *dateDay = [dic objectForKey:@"dateDay"];
            GSHYingShiGaoJingGroupM *group = [self.dic objectForKey:dateDay];
            if ([notification.name isEqualToString:GSHYingShiGaoJingCollectChangeNotification]) {
                for (GSHYingShiGaoJingM *m in group.list) {
                    if ([m.alarmId isEqualToString:alarmId]) {
                        m.collectState = collect.integerValue;
                    }
                }
            }else{
                for (NSUInteger i = group.list.count; i > 0; i--) {
                    GSHYingShiGaoJingM *m = group.list[i - 1];
                    if ([m.alarmId isEqualToString:alarmId]) {
                        [group.list removeObject:m];
                        [self.gaoJinglist removeObject:m];
                        return;
                    }
                }
            }
        }else{
            [self.tableView dismissPageStatusView];
            __weak typeof(self)weakSelf = self;
            [GSHYingShiManager getCollectAlarmListWithDeviceSerial:self.device.deviceSn alarmType:self.alarmType alarmTime:nil block:^(NSArray<GSHYingShiGaoJingM *> *list, NSError *error) {
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [weakSelf reloadDataWithList:list error:error alarmTime:nil];
            }];
        }
    }
}

-(void)dealloc{
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)initUI{
    self.tableView.tzm_refreshControl.textColor = [UIColor colorWithRGB:0x222222];
    self.tableView.tzm_refreshControl.activityIndicatorView.color = [UIColor colorWithRGB:0x222222];

    if (self.type == GSHYingShiGaoJingListVCTypeAll) {
        self.btnBianJi.hidden = NO;
        self.btnShaiXuan.hidden = NO;
        self.headView.hidden = NO;
        self.lcHeadViewHeight.constant = 50;
    }else{
        self.title = @"我的收藏";
        self.headView.hidden = YES;
        self.btnBianJi.hidden = YES;
        self.btnShaiXuan.hidden = YES;
        self.lcHeadViewHeight.constant = 0;
    }
}

-(void)refreshSeleAll{
    BOOL seleAll = YES;
    for (GSHYingShiGaoJingGroupM *group in self.list) {
        if (!group.isSele) {
            seleAll = NO;
            break;
        }
    }
    self.btnSeleAll.selected = seleAll;
    
    BOOL isSele = NO;
    for (GSHYingShiGaoJingGroupM *group in self.list) {
        for (GSHYingShiGaoJingM *model in group.list) {
            if (model.isSele) {
                isSele = YES;
                break;
            }
        }
    }
    self.btnRead.enabled = isSele;
    self.btnDelete.enabled = isSele;
}

-(void)showDateSele{
    PGDatePickManager *datePickManager = [[PGDatePickManager alloc]init];
    PGDatePicker *datePicker = datePickManager.datePicker;
    __weak typeof(self)weakSelf = self;
    datePickManager.cancelButtonMonitor = ^{
        weakSelf.startTime = nil;
        weakSelf.endTime = nil;
        [weakSelf refreshDataWithAlarmTime:nil];
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

-(void)refreshDataWithAlarmTime:(NSNumber*)alarmTime{
    if (self.list.count == 0) {
        [self.tableView dismissPageStatusView];
        [TZMProgressHUDManager showWithStatus:@"加载告警中" inView:self.view];
    }
    __weak typeof(self)weakSelf = self;
    if (self.type == GSHYingShiGaoJingListVCTypeAll) {
        [GSHYingShiManager getAlarmListWithDeviceSerial:self.device.deviceSn alarmType:self.alarmType alarmTime:alarmTime startTime:self.startTime.doubleValue > 0 ? self.startTime : nil  endTime:self.endTime.doubleValue > 0 ? self.endTime : nil block:^(NSArray<GSHYingShiGaoJingM *> *list, NSError *error) {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [weakSelf reloadDataWithList:list error:error alarmTime:alarmTime];
        }];
    }else{
        [GSHYingShiManager getCollectAlarmListWithDeviceSerial:self.device.deviceSn  alarmType:self.alarmType alarmTime:alarmTime block:^(NSArray<GSHYingShiGaoJingM *> *list, NSError *error) {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [weakSelf reloadDataWithList:list error:error alarmTime:alarmTime];
        }];
    }
}

-(void)reloadDataWithList:(NSArray<GSHYingShiGaoJingM *> *)list error:(NSError*)error alarmTime:(NSNumber*)alarmTime{
    __weak typeof(self)weakSelf = self;
    if (error) {
        if (self.list.count == 0) {
            [self.tableView showPageStatus:TZMPageStatusNormal image:nil title:@"加载失败，请重试" desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [weakSelf refreshDataWithAlarmTime:nil];
            }];
        }else{
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }
    }else{
        if (!alarmTime) {
            //刷新，拉取第一页
            [self.list removeAllObjects];
            [self.dic removeAllObjects];
            [self.gaoJinglist removeAllObjects];
            self.tableView.tzm_loadMoreControl.enabled = YES;
        }else{
            if (list.count > 0) {
                self.tableView.tzm_loadMoreControl.enabled = YES;
            }
        }
        [self addDataWithList:list];
        if (self.list.count == 0) {
            [self.tableView showPageStatus:TZMPageStatusNormal image:self.type == GSHYingShiGaoJingListVCTypeAll ? [UIImage ZHImageNamed:@"yingShiGaoJingListVC_all_nodata_icon"] : [UIImage ZHImageNamed:@"yingShiGaoJingListVC_shoucang_nodata_icon"] title:self.type == GSHYingShiGaoJingListVCTypeAll ? (self.startTime == nil ? @"最近7天暂无告警记录" : @"暂无告警记录") : @"当前尚未收藏任何告警记录" desc:nil buttonText:self.type == GSHYingShiGaoJingListVCTypeAll ? (self.startTime == nil ? nil : @"重置筛选") : nil didClickButtonCallback:^(TZMPageStatus status) {
                weakSelf.startTime = nil;
                weakSelf.endTime = nil;
                [weakSelf refreshDataWithAlarmTime:nil];
            }];
        }else{
            [self.tableView reloadData];
        }
    }
    [self.tableView.tzm_loadMoreControl endRefreshing];
    [self.tableView.tzm_refreshControl stopIndicatorAnimation];
}

- (void)addDataWithList:(NSArray<GSHYingShiGaoJingM*>*)list{
    if (list.count > 0) {
        for (GSHYingShiGaoJingM *model in list) {
            NSString *date = model.dateDay;
            GSHYingShiGaoJingGroupM *group = [self.dic objectForKey:date];
            if (!group) {
                group = [GSHYingShiGaoJingGroupM new];
                group.dateDay = date;
                group.list = [NSMutableArray array];
                [self.dic setObject:group forKey:date];
                [self.list addObject:group];
            }
            group.isSele = NO;
            [group.list addObject:model];
            [self.gaoJinglist addObject:model];
        }
        [self refreshSeleAll];
    }
}

- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents{
    NSString *dayString = [NSString stringWithFormat:@"%04d%02d%02d",(int)(dateComponents.year),(int)(dateComponents.month),(int)(dateComponents.day)];
    NSDate *startDate = [NSDate dateWithString:[NSString stringWithFormat:@"%@000000",dayString] format:@"yyyyMMddHHmmss"];
    NSDate *endDate = [NSDate dateWithString:[NSString stringWithFormat:@"%@235959",dayString] format:@"yyyyMMddHHmmss"];
    self.startTime = @(startDate.timeIntervalSince1970 * 1000);
    self.endTime = @(endDate.timeIntervalSince1970 * 1000);
    [self refreshDataWithAlarmTime:nil];
}

- (void)tzm_scrollViewRefresh:(UIScrollView *)scrollView refreshControl:(TZMPullToRefresh *)refreshControl{
    [self refreshDataWithAlarmTime:nil];
}
- (void)tzm_scrollViewLoadMore:(UIScrollView *)scrollView LoadMoreControl:(TZMLoadMoreRefreshControl *)loadMoreControl{
    scrollView.tzm_loadMoreControl.enabled = NO;
    [self refreshDataWithAlarmTime:@(self.list.lastObject.list.lastObject.alarmTime)];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.list.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section < self.list.count) {
        return self.list[section].list.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHYingShiGaoJingListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.tableView = tableView;
    if (indexPath.section < self.list.count) {
        GSHYingShiGaoJingGroupM *group = self.list[indexPath.section];
        if (indexPath.row < group.list.count) {
            cell.model = group.list[indexPath.row];
            cell.type = self.type;
            cell.group = group;
        }
        if (self.isEdit) {
            cell.lcLeading.constant = 50;
            cell.btnSele.hidden = NO;
        }else{
            cell.lcLeading.constant = 15;
            cell.btnSele.hidden = YES;
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 47.5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    GSHYingShiGaoJingListVCHeader *head = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (section < self.list.count) {
        head.model = self.list[section];
    }
    if (self.isEdit) {
        head.lcLeading.constant = 50;
        head.btnSele.hidden = NO;
    }else{
        head.lcLeading.constant = 15;
        head.btnSele.hidden = YES;
    }
    return head;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type == GSHYingShiGaoJingListVCTypeAll) {
        return @[];
    }
    __weak typeof(self)weakSelf = self;
    GSHYingShiGaoJingM *model;
    GSHYingShiGaoJingGroupM *group;
    if (indexPath.section < self.list.count) {
        group = self.list[indexPath.section];
        if (indexPath.row < group.list.count) {
            model = group.list[indexPath.row];
        }
    }
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [TZMProgressHUDManager showWithStatus:@"删除中" inView:weakSelf.view];
        [GSHYingShiManager postDeleteAlarmWithAlarmIdList:@[model.alarmId] deleteFlag:@(0) block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager showSuccessWithStatus:@"删除成功" inView:weakSelf.view];
                [group.list removeObject:model];
                [weakSelf.gaoJinglist removeObject:model];
                if (group.list.count == 0) {
                    [weakSelf.list removeObject:group];
                    [weakSelf.dic removeObjectForKey:group.dateDay];
                }
                [weakSelf.tableView reloadData];
                [NSObject postNotification:GSHYingShiGaoJingDeleteNotification object:@{@"alarmId":model.alarmId,@"dateDay":model.dateDay}];
            }
        }];
    }];
    action1.backgroundColor = [UIColor colorWithHexString:@"#E64430"];
    return @[action1];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHYingShiGaoJingListVCCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    GSHGaoJingDetailVC *vc = [GSHGaoJingDetailVC gaoJingDetailVCWithModel:cell.model verifyCode:nil deviceSerial:self.device.deviceSn modelList:self.gaoJinglist];
    [self.navigationController pushViewController:vc animated:YES];
    return nil;
}

- (IBAction)touchBianJi:(UIButton *)sender {

    self.isEdit = !self.isEdit;
    if (self.isEdit) {
        self.headView.hidden = YES;
        self.btnShaiXuan.hidden = YES;
        self.lcHeadViewHeight.constant = 0;
        [self.btnBianJi setImage:nil forState:UIControlStateNormal];
        [self.btnBianJi setTitle:@"取消" forState:UIControlStateNormal];
        self.navigationItem.hidesBackButton = YES;
        
        self.footView.hidden = NO;
        self.lcFootViewHeight.constant = 55;
    }else{
        self.btnShaiXuan.hidden = NO;
        self.headView.hidden = NO;
        self.lcHeadViewHeight.constant = 50;
        [self.btnBianJi setImage:[UIImage ZHImageNamed:@"yingShiGaoJingListVC_bianji_icon"] forState:UIControlStateNormal];
        [self.btnBianJi setTitle:nil forState:UIControlStateNormal];
        self.navigationItem.hidesBackButton = NO;
        
        self.footView.hidden = YES;
        self.lcFootViewHeight.constant = NO;
        self.btnSeleAll.selected = NO;
        for (GSHYingShiGaoJingGroupM *group in self.list) {
            group.isSele = NO;
            for (GSHYingShiGaoJingM *model in group.list) {
                model.isSele = NO;
            }
        }
    }
    [self.tableView reloadData];
}

- (IBAction)touchHeadView:(UIButton *)sender {
    GSHYingShiGaoJingListVC *vc = [GSHYingShiGaoJingListVC yingShiGaoJingListVCWithtype:GSHYingShiGaoJingListVCTypeCollect device:self.device alarmType:self.alarmType];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)touchShaiXuan:(UIButton *)sender {
    [self showDateSele];
}

- (IBAction)touchSeleAll:(UIButton *)sender {
    sender.selected = !sender.selected;
    for (GSHYingShiGaoJingGroupM *group in self.list) {
        group.isSele = sender.selected;
        for (GSHYingShiGaoJingM *model in group.list) {
            model.isSele = sender.selected;
        }
    }
    [self refreshSeleAll];
    [self.tableView reloadData];
}

- (IBAction)touchRead:(UIButton *)sender {
    NSMutableArray<NSString *> *idList = [NSMutableArray array];
    for (GSHYingShiGaoJingGroupM *group in self.list) {
        for (GSHYingShiGaoJingM *model in group.list) {
            if (model.isSele) {
                [idList addObject:model.alarmId];
            }
        }
    }
    if (idList.count == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"未选择告警" inView:self.view];
        return;
    }
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"标记已读中" inView:self.view];
    [GSHYingShiManager postAlarmReadWithAlarmIdList:idList block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            for (GSHYingShiGaoJingGroupM *group in weakSelf.list) {
                for (GSHYingShiGaoJingM *model in group.list) {
                    if (model.isSele) {
                        model.isChecked = 1;
                        model.isSele = NO;
                    }
                }
                group.isSele = NO;
            }
            [weakSelf.tableView reloadData];
            [weakSelf refreshSeleAll];
        }
    }];
}

- (IBAction)touchDelete:(UIButton *)sender {
    NSMutableArray<NSString *> *idList = [NSMutableArray array];//不含收藏的id列表
    BOOL haveShouCang = NO;
    for (GSHYingShiGaoJingGroupM *group in self.list) {
        for (GSHYingShiGaoJingM *model in group.list) {
            if (model.isSele) {
                [idList addObject:model.alarmId];
                if (model.collectState == 0) {
                }else{
                    haveShouCang = YES;
                }
            }
        }
    }
//    if (idList.count == 0) {
//        [TZMProgressHUDManager showErrorWithStatus:@"未选择告警或选择的是已收藏告警" inView:weakSelf.view];
//        return;
//    }
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 0) {
            [weakSelf deleteWithList:idList];
        }
    } textFieldsSetupHandler:NULL andTitle:@"确认删除所选告警记录？" andMessage:haveShouCang ? @"（收藏状态下的告警记录将不会被删除）" : nil image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"删除" cancelButtonTitle:@"取消" otherButtonTitles:nil];
}

-(void)deleteWithList:(NSArray<NSString*>*)idList{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
    [GSHYingShiManager postDeleteAlarmWithAlarmIdList:idList deleteFlag:self.type == GSHYingShiGaoJingListVCTypeAll ? @(1) : @(0) block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            for (NSUInteger i = weakSelf.list.count; i > 0; i--) {
                GSHYingShiGaoJingGroupM *group = weakSelf.list[i - 1];
                for (NSUInteger i = group.list.count; i > 0; i--) {
                    GSHYingShiGaoJingM *model = group.list[i - 1];
                    if (model.isSele && model.collectState == 0) {
                        [group.list removeObject:model];
                        [weakSelf.gaoJinglist removeObject:model];
                    }
                }
                if (group.list.count == 0) {
                    [weakSelf.list removeObject:group];
                    [weakSelf.dic removeObjectForKey:group.dateDay];
                }
            }
            if (weakSelf.list.count == 0) {
                [weakSelf refreshDataWithAlarmTime:nil];
                weakSelf.btnSeleAll.selected = NO;
            }else{
                [weakSelf refreshDataWithAlarmTime:@(weakSelf.list.lastObject.list.lastObject.alarmTime)];
            }
        }
    }];
}

@end
