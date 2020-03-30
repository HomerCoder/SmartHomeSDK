//
//  GSHFamilyListVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFamilyListVC.h"
#import "GSHCreateFamilyVC.h"
#import "GSHFamilyManagerVC.h"
#import "UIViewController+TZMPageStatusViewEx.h"

@interface GSHFamilyListCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblDeviceCount;
@property (weak, nonatomic) IBOutlet UILabel *lblPermissions;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrent;

@end

@implementation GSHFamilyListCell
-(void)setFamily:(GSHFamilyM *)family{
    _family = family;
    self.lblUserName.text = family.familyName;
    self.lblDeviceCount.text = [NSString stringWithFormat:@"%d个设备",family.deviceCount.intValue];
    self.lblPermissions.text = family.permissions == GSHFamilyMPermissionsManager ? @"管理员" : @"成员";
    self.lblCurrent.hidden = family.familyId != [GSHOpenSDKShare share].currentFamily.familyId;
}
@end

@interface GSHFamilyListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchNewFamily:(UIButton *)sender;
@end

@implementation GSHFamilyListVC

+(instancetype)familyListVC{
    GSHFamilyListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHFamilySB" andID:@"GSHFamilyListVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.list.count > 0) {
        [self dismissPageStatusView];
    }
    [self.tableView reloadData];
}

-(void)reloadList{
    __weak typeof(self)weakSelf = self;
    [self dismissPageStatusView];
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [GSHFamilyManager getFamilyListWithblock:^(NSArray<GSHFamilyM *> *familyList, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if (familyList.count == 0) {
                [weakSelf showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_home"] title:@"暂无家庭" desc:nil buttonText:@"新建家庭" didClickButtonCallback:^(TZMPageStatus status) {
                    [weakSelf touchNewFamily:nil];
                }];
            }else{
                weakSelf.list = [NSMutableArray arrayWithArray:familyList];
                [weakSelf.tableView reloadData];
            }
        }
    }];
}

- (IBAction)touchNewFamily:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    GSHCreateFamilyVC *vc = [GSHCreateFamilyVC createFamilyVCWithFamilyListVC:self completeBlock:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark --tableView dele
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHFamilyListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.list.count > indexPath.row) {
        cell.family = self.list[indexPath.row];
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.list.count > indexPath.row) {
        GSHFamilyManagerVC *vc = [GSHFamilyManagerVC familyManagerVCWithFamily:self.list[indexPath.row] familyListVC:self];
        @weakify(self)
        vc.refreshFamilyListBlock = ^{
            // 刷新家庭列表
            @strongify(self)
            [self reloadList];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    return nil;
}

@end
