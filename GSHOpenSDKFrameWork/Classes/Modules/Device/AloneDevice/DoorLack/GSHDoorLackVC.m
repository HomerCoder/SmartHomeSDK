//
//  GSHDoorLackVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDoorLackVC.h"
#import "GSHDoorLockManager.h"
#import "GSHDoorLackOpenListVC.h"
#import "GSHDoorLackSettingVC.h"
#import "UIViewController+TZMPageStatusViewEx.h"

@interface GSHDoorLackVCCell()
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) GSHDoorLockRecordM *model;
@end

@implementation GSHDoorLackVCCell
-(void)setModel:(GSHDoorLockRecordM *)model{
    _model = model;
    self.lblTime.text = [model.date stringWithFormat:@"HH:mm"];
    self.lblName.text = model.secretName;
    self.lblStatus.text = model.logTypeName;
}
@end

@interface GSHDoorLackVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblElectric;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIView *viewNodata;

- (IBAction)touchSetting:(UIButton *)sender;
- (IBAction)touchMore:(UIButton *)sender;

@property (strong, nonatomic)NSArray<GSHDoorLockRecordListM*> *list;
@end

@implementation GSHDoorLackVC
+(instancetype)doorLackVCWithDevice:(GSHDeviceM*)device;{
    GSHDoorLackVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoorLackSB" andID:@"GSHDoorLackVC"];
    vc.deviceM = device;
    vc.deviceEditType = GSHDeviceVCTypeControl;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self refreshUI];
    [self reloadData];
}

-(void)reloadData{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.tableView];
    [self.viewNodata dismissPageStatusView];
    [GSHDoorLockManager getLockRecordListWithDeviceSn:self.deviceM.deviceSn pageIndex:1 block:^(NSError * _Nonnull error, NSArray<GSHDoorLockRecordM *> * _Nonnull list) {
        [TZMProgressHUDManager dismissInView:weakSelf.tableView];
        
        if (error) {
            [weakSelf.viewNodata showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_equipment"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [weakSelf reloadData];
            }].backgroundColor = [UIColor whiteColor];
        }else{
            if (list.count == 0) {
                [weakSelf.viewNodata showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_equipment"] title:@"最近7天暂无门锁动态" desc:nil buttonText:nil didClickButtonCallback:NULL].backgroundColor = [UIColor whiteColor];
            }else{
                list = [list subarrayWithRange:NSMakeRange(0,3)];
                NSMutableArray<GSHDoorLockRecordListM*> *arr = [NSMutableArray array];
                GSHDoorLockRecordListM *listModel;
                for (GSHDoorLockRecordM *model in list) {
                    if (model.dateString) {
                        if (![listModel.dateString isEqualToString:model.dateString]) {
                            listModel = [GSHDoorLockRecordListM new];
                            listModel.date = model.date;
                            listModel.list = [NSMutableArray array];
                            [arr addObject:listModel];
                        }
                        [listModel.list addObject:model];
                    }
                }
                weakSelf.list = arr;
                [weakSelf.tableView reloadData];
            }
        }
    }];
}

-(void)refreshUI{
    self.lblTitle.text = self.deviceM.deviceName;
    NSDictionary *realTimeDict = [self.deviceM realTimeDic];
    NSString *status = [realTimeDict objectForKey:GSHDoorLack_status];
    NSString *electric = [realTimeDict objectForKey:GSHDoorLack_electric];
    
    if (electric.intValue < 20) {
        self.lblElectric.textColor = [UIColor redColor];
    }else{
        self.lblElectric.textColor = [UIColor colorWithRGB:0x636985];
    }
    self.lblElectric.text = [NSString stringWithFormat:@"电量：%@%%",electric];
    
    switch (status.intValue) {
        case 0:
            //未锁好
            self.lblStatus.text = @"未锁好";
            self.imageViewStatus.image = [UIImage ZHImageNamed:@"doorLackVC_status_unlock"];
            break;
        case 1:
            //外反锁
            self.lblStatus.text = @"已反锁";
            self.imageViewStatus.image = [UIImage ZHImageNamed:@"doorLackVC_status_backLock"];
            break;
        case 2:
            //开锁
            self.lblStatus.text = @"已开锁";
            self.imageViewStatus.image = [UIImage ZHImageNamed:@"doorLackVC_status_open"];
            break;
        case 3:
            //内反锁
            self.lblStatus.text = @"已反锁";
            self.imageViewStatus.image = [UIImage ZHImageNamed:@"doorLackVC_status_backLock"];
            break;
        default:
            self.lblStatus.text = @"已上锁";
            self.imageViewStatus.image = [UIImage ZHImageNamed:@"doorLackVC_status_lock"];
            break;
    }
    
}

- (IBAction)touchSetting:(UIButton *)sender {
    GSHDoorLackSettingVC *VC = [GSHDoorLackSettingVC doorLackSettingVCWithDevice:self.deviceM];
    [self closeWithComplete:^{
        [[UIViewController visibleTopViewController].navigationController pushViewController:VC animated:YES];
    }];
}

- (IBAction)touchMore:(UIButton *)sender {
    GSHDoorLackOpenListVC *VC = [GSHDoorLackOpenListVC doorLackOpenListVCWithDevice:self.deviceM];
    [self closeWithComplete:^{
        [[UIViewController visibleTopViewController].navigationController pushViewController:VC animated:YES];
    }];
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 34)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 11.5, tableView.width, 20)];
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    label.textColor = [UIColor colorWithRGB:0x282828];
    if (self.list.count > section) {
        GSHDoorLockRecordListM *list = self.list[section];
        label.text = [GSHDoorLockManager dateDay:list.date];
    }
    [view addSubview:label];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHDoorLackVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
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
