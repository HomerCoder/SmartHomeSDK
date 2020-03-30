//
//  GSHDoorLackOpenListVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDoorLackOpenListVC.h"
#import "GSHDoorLockManager.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "UIScrollView+TZMRefreshAndLoadMore.h"

@interface GSHDoorLackOpenListVCCell()
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblname;
@property (weak, nonatomic) IBOutlet UILabel *lblStutes;
@property (strong, nonatomic) GSHDoorLockRecordM *model;
@end

@implementation GSHDoorLackOpenListVCCell
-(void)setModel:(GSHDoorLockRecordM *)model{
    _model = model;
    self.lblTime.text = [model.date stringWithFormat:@"HH:mm"];
    self.lblname.text = model.secretName;
    self.lblStutes.text = model.logTypeName;
}
@end

@interface GSHDoorLackOpenListVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)GSHDeviceM *device;
@property (strong, nonatomic)NSMutableArray<GSHDoorLockRecordListM*> *list;
@property (assign, nonatomic)NSInteger pageIndex;
@end

@implementation GSHDoorLackOpenListVC
+(instancetype)doorLackOpenListVCWithDevice:(GSHDeviceM*)device{
    GSHDoorLackOpenListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoorLackSB" andID:@"GSHDoorLackOpenListVC"];
    vc.device = device;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.list = [NSMutableArray array];
    self.pageIndex = 1;
    [self reloadData];
}

-(void)reloadData{
    __weak typeof(self)weakSelf = self;
    if (self.pageIndex == 1) {
        [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.tableView];
    }
    [self.tableView dismissPageStatusView];
    if (self.pageIndex == 1) {
        [self.list removeAllObjects];
    }
    [GSHDoorLockManager getLockRecordListWithDeviceSn:self.device.deviceSn pageIndex:self.pageIndex block:^(NSError * _Nonnull error, NSArray<GSHDoorLockRecordM *> * _Nonnull list) {
        [TZMProgressHUDManager dismissInView:weakSelf.tableView];
        if (error) {
            if (weakSelf.list.count == 0) {
                [weakSelf.tableView showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_equipment"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                    [weakSelf reloadData];
                }];
            }
        }else{
            if (list.count == 0) {
                if (weakSelf.pageIndex == 1) {
                    [weakSelf.tableView showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_equipment"] title:@"暂无门锁动态" desc:nil buttonText:nil didClickButtonCallback:NULL].backgroundColor = [UIColor whiteColor];
                }
                weakSelf.tableView.tzm_loadMoreControl.enabled = NO;
            }else{
                GSHDoorLockRecordListM *listModel = weakSelf.list.firstObject;
                for (GSHDoorLockRecordM *model in list) {
                    if (model.dateString) {
                        if (![listModel.dateString isEqualToString:model.dateString]) {
                            listModel = [GSHDoorLockRecordListM new];
                            listModel.date = model.date;
                            listModel.list = [NSMutableArray array];
                            [weakSelf.list addObject:listModel];
                        }
                        [listModel.list addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
                weakSelf.pageIndex++;
                weakSelf.tableView.tzm_loadMoreControl.enabled = YES;
            }
        }
        [weakSelf.tableView.tzm_loadMoreControl endRefreshing];
        [weakSelf.tableView.tzm_refreshControl stopIndicatorAnimation];
    }];
}

- (void)tzm_scrollViewRefresh:(UIScrollView *)scrollView refreshControl:(TZMPullToRefresh *)refreshControl{
    self.pageIndex = 1;
    [self reloadData];
}
- (void)tzm_scrollViewLoadMore:(UIScrollView *)scrollView LoadMoreControl:(TZMLoadMoreRefreshControl *)loadMoreControl{
    scrollView.tzm_loadMoreControl.enabled = NO;
    [self reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.list.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.list.count > section) {
        return self.list[section].list.count;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 17.5, tableView.width, 20)];
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    label.textColor = [UIColor colorWithRGB:0x282828];
    if (self.list.count > section) {
        GSHDoorLockRecordListM *list = self.list[section];
        label.text = [GSHDoorLockManager dateDay:list.date];;
    }
    [view addSubview:label];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHDoorLackOpenListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.list.count > indexPath.section) {
        GSHDoorLockRecordListM *list = self.list[indexPath.section];
        if (list.list.count > indexPath.row) {
            GSHDoorLockRecordM *model = list.list[indexPath.row];
            cell.model = model;
        }
        cell.line1.hidden = indexPath.row == 0;
        cell.line2.hidden = indexPath.row == list.list.count - 1;
    }
    return cell;
}

@end
