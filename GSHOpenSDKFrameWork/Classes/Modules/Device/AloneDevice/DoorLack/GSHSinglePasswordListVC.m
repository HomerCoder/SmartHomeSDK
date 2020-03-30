//
//  GSHSinglePasswordListVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHSinglePasswordListVC.h"
#import "GSHDoorLockManager.h"
#import "GSHSinglePasswordVC.h"

@interface GSHSinglePasswordListVCCell()
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lblStutes;
@property (strong, nonatomic) GSHDoorLockPassWordM *model;
@end
@implementation GSHSinglePasswordListVCCell
-(void)setModel:(GSHDoorLockPassWordM *)model{
    _model = model;
    self.lbTime.text = [model.createDate stringWithFormat:@"HH:mm"];
    self.lblStutes.text = model.status == GSHDoorLockSinglePasswordStatusUnvalid ? @"已失效" : @"生效中";
    self.lblStutes.backgroundColor = model.status == GSHDoorLockSinglePasswordStatusUnvalid ? [UIColor colorWithRGB:0x999999] : [UIColor colorWithRGB:0x07C683];
}
@end

@interface GSHSinglePasswordListVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)GSHDeviceM *device;
@property (strong, nonatomic)NSArray<GSHDoorLockPassWordListM*> *list;
@end

@implementation GSHSinglePasswordListVC
+(instancetype)singlePasswordListVCWithDevice:(GSHDeviceM*)device{
    GSHSinglePasswordListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoorLackSB" andID:@"GSHSinglePasswordListVC"];
    vc.device = device;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadDate];
    [self observerNotifications];
}

-(void)observerNotifications{
    [self observerNotification:GSHDoorLockManagerPassWordChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHDoorLockManagerPassWordChangeNotification]) {
        [self reloadDate];
    }
}

-(void)reloadDate{
    [TZMProgressHUDManager showErrorWithStatus:@"加载中" inView:self.view];
    __weak typeof(self) weakSelf = self;
    [GSHDoorLockManager getSingleLockSecretWithDeviceSn:self.device.deviceSn secretType:GSHDoorLockSecretTypePassword usedType:GSHDoorLockUsedTypeSingle block:^(NSError * _Nonnull error, NSArray<GSHDoorLockPassWordListM *> * _Nonnull list) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.list = list;
            [weakSelf.tableView reloadData];
        }
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, tableView.width, 20)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorWithRGB:0x999999];
    if (self.list.count > section) {
        GSHDoorLockPassWordListM *list = self.list[section];
        label.text = [GSHDoorLockManager dateDay:list.date];
    }
    [view addSubview:label];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHSinglePasswordListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.list.count > indexPath.section) {
        GSHDoorLockPassWordListM *list = self.list[indexPath.section];
        if (list.list.count > indexPath.row) {
            GSHDoorLockPassWordM *model = list.list[indexPath.row];
            cell.model = model;
        }
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.list.count > indexPath.section) {
        GSHDoorLockPassWordListM *list = self.list[indexPath.section];
        if (list.list.count > indexPath.row) {
            GSHDoorLockPassWordM *model = list.list[indexPath.row];
            [self.navigationController pushViewController:[GSHSinglePasswordVC singlePasswordVCWithPassword:model device:self.device] animated:YES];
        }
    }
    return NO;
}


@end
