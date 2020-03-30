//
//  GSHDefenseMessageVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/6/11.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDefenseMessageVC.h"
#import "GSHMessageCell.h"
#import "NSString+TZM.h"
#import "UIScrollView+TZMRefreshAndLoadMore.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "UIViewController+TZMPageStatusViewEx.h"

@interface GSHDefenseMessageVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView *messageTableView;
@property (nonatomic , strong) NSMutableArray *dataArray;
@property (nonatomic , strong) NSMutableArray *msgDateArray;
@property (nonatomic , strong) NSMutableArray *sourceArray;
@property (nonatomic , strong) NSString *deviceType;
@property (nonatomic , assign) int pageIndex;

@end

@implementation GSHDefenseMessageVC

- (instancetype)initWithTitle:(NSString *)title deviceType:(NSString *)deviceType {
    self = [super init];
    if (self) {
        self.title = title;
        self.deviceType = deviceType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.messageTableView];
    self.messageTableView.tzm_enabledRefreshControl = YES;
    self.messageTableView.tzm_enabledLoadMoreControl = YES;
    self.pageIndex = 0;
    [self getFamilyDefenseMsgWithCurrentPage:self.pageIndex];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.messageTableView.tzm_refreshControl.originalInsetTop = 40;
    self.messageTableView.tzm_refreshControl.textColor = [UIColor colorWithRGB:0x222222];
}


#pragma mark - Lazy
- (UITableView *)messageTableView {
    if (!_messageTableView) {
        _messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KNavigationBar_Height) style:UITableViewStyleGrouped];
        _messageTableView.dataSource = self;
        _messageTableView.delegate = self;
        _messageTableView.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
        _messageTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_messageTableView registerNib:[UINib nibWithNibName:@"GSHMessageCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"messageCell"];
    }
    return _messageTableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)msgDateArray {
    if (!_msgDateArray) {
        _msgDateArray = [NSMutableArray array];
    }
    return _msgDateArray;
}

- (NSMutableArray *)sourceArray {
    if (!_sourceArray) {
        _sourceArray = [NSMutableArray array];
    }
    return _sourceArray;
}

#pragma mark - 
- (void)tzm_scrollViewRefresh:(UIScrollView *)scrollView refreshControl:(TZMPullToRefresh *)refreshControl{
    self.pageIndex = 0;
    [self getFamilyDefenseMsgWithCurrentPage:0];
}

- (void)tzm_scrollViewLoadMore:(UIScrollView *)scrollView LoadMoreControl:(TZMLoadMoreRefreshControl *)loadMoreControl {
    self.pageIndex++;
    self.messageTableView.tzm_enabledLoadMoreControl = NO;
    [self getFamilyDefenseMsgWithCurrentPage:self.pageIndex];
}

#pragma mark - request
- (void)getFamilyDefenseMsgWithCurrentPage:(NSInteger)currentPage {
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHMessageManager getFamilyDefenseMsgWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceType:self.deviceType currPage:currentPage block:^(NSArray<GSHMessageM *> * _Nonnull list, NSError * _Nonnull error) {
        @strongify(self)
        [self.messageTableView.tzm_refreshControl stopIndicatorAnimation];
        [TZMProgressHUDManager dismissInView:self.view];
        if (error) {
            [self.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [self getFamilyDefenseMsgWithCurrentPage:currentPage];
            }];
        } else {
            if (currentPage == 0) {
                [self.dataArray removeAllObjects];
            }
            if (list.count == 10) {
                self.messageTableView.tzm_enabledLoadMoreControl = YES;
            }
            [self.dataArray addObjectsFromArray:list];
            if (self.dataArray.count == 0) {
                [self showBlankView];
            }
            [self handleDataWithArray:(NSArray *)self.dataArray];
            [self.messageTableView reloadData];
        }
    }];
}

- (void)showBlankView {
    [self showPageStatus:TZMPageStatusNormal
                   image:[UIImage ZHImageNamed:@"blankpage_icon_message"]
                   title:nil
                    desc:@"暂无消息记录哦"
              buttonText:nil
  didClickButtonCallback:nil];
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = self.sourceArray[section];
    NSArray *arr = [dic objectForKey:dic.allKeys[0]];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    NSDictionary *dic = self.sourceArray[indexPath.section];
    NSArray *arr = [dic objectForKey:dic.allKeys[0]];
    GSHMessageM *messageM = arr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
    cell.messageNameLabel.text = messageM.msgTitle;
    cell.messageLabel.text = messageM.msgBody;
    cell.timeLabel.text = [messageM.createTime substringWithRange:NSMakeRange(11, 5)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.sourceArray[indexPath.section];
    NSArray *arr = [dic objectForKey:dic.allKeys[0]];
    GSHMessageM *messageM = arr[indexPath.row];
    CGFloat labelHeight = [messageM.msgBody tzm_getStrHeightWithFontSize:16.0 labelWidth:SCREEN_WIDTH - 120] + 10;
    return labelHeight + 66.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 54.0f;
    }
    return 74.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    CGFloat dateViewY = 0;
    if (section == 0) {
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
        dateViewY = 20;
    } else {
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 70);
        dateViewY = 40;
    }
    UIView *dateView = [[UIView alloc] initWithFrame:CGRectMake(6, dateViewY, 80, 30)];
    dateView.backgroundColor = [UIColor whiteColor];
    dateView.layer.cornerRadius = 15.0f;
    [view addSubview:dateView];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateView.bounds];
    dateLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.textColor = [UIColor colorWithHexString:@"#585858"];
    NSDictionary *dic = self.sourceArray[section];
    NSString *dateStr = dic.allKeys[0];
    NSString *todayDateStr = [[NSDate date] stringWithFormat:@"yyyy-MM-dd"];
    dateLabel.text = [dateStr isEqualToString:todayDateStr] ? @"今天" : dateStr;
    [dateView addSubview:dateLabel];
    
    if (section != 0) {
        UIView *downLineView = [[UIView alloc] initWithFrame:CGRectMake(46, 0, 1, 36)];
        downLineView.backgroundColor = [UIColor colorWithHexString:@"#DEDEDE"];
        [view addSubview:downLineView];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    return view;
}

#pragma mark - method
// 处理消息数据，按日期分组
- (void)handleDataWithArray:(NSArray *)dataArray {
    
    if (self.sourceArray.count > 0) {
        [self.sourceArray removeAllObjects];
    }
    if (self.msgDateArray.count > 0) {
        [self.msgDateArray removeAllObjects];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    for (GSHMessageM *messageM in dataArray) {
        NSString *msgDateStr = [messageM.createTime substringToIndex:10];
        if (![self isAddedInMsgDateArrayWithDateStr:msgDateStr]) {
            [self.msgDateArray addObject:msgDateStr];
        }
    }
    for (NSString *dateStr in self.msgDateArray) {
        NSMutableArray *tmpDataArr = [NSMutableArray array];
        for (GSHMessageM *messageM in dataArray) {
            if ([messageM.createTime containsString:dateStr]) {
                [tmpDataArr addObject:messageM];
            }
        }
        NSDictionary *dic = @{dateStr:tmpDataArr};
        [self.sourceArray addObject:dic];
    }
}

- (BOOL)isAddedInMsgDateArrayWithDateStr:(NSString *)dateStr {
    BOOL isAddedIn = NO;
    for (NSString *tmpDateStr in self.msgDateArray) {
        if ([tmpDateStr isEqualToString:dateStr]) {
            isAddedIn = YES;
        }
    }
    return isAddedIn;
}


@end
