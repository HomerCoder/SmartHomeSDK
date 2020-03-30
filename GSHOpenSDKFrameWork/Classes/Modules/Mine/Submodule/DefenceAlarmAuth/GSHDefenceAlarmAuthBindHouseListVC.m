//
//  GSHDefenceAlarmAuthBindFactoryList.m
//  SmartHome
//
//  Created by zhanghong on 2020/2/28.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDefenceAlarmAuthBindHouseListVC.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "UIView+TZMPageStatusViewEx.h"

@implementation GSHDefenceAlarmAuthBindHouseCell


@end

@interface GSHDefenceAlarmAuthBindHouseListVC ()

@property (weak, nonatomic) IBOutlet UITableView *houseTableView;
@property (strong , nonatomic) NSMutableArray *houseArray;
@property (strong , nonatomic) NSNumber *selectRow;
@property (strong , nonatomic) NSNumber *selectMhouseId;
@property (strong , nonatomic) NSNumber *smartHomeFamilyId;
@property (strong , nonatomic) GSHSDKEnjoyHomeHouseM *selectHouseM;

@end

@implementation GSHDefenceAlarmAuthBindHouseListVC

+(instancetype)defenceAlarmAuthBindHouseListVCWithSmartHomeFamilyId:(NSNumber *)smartHomeFamilyId SelectHouseId:(NSNumber *)mhouseId {
    
    GSHDefenceAlarmAuthBindHouseListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDefenceAlarmAuthSB" andID:@"GSHDefenceAlarmAuthBindHouseListVC"];
    vc.smartHomeFamilyId = smartHomeFamilyId;
    vc.selectMhouseId = mhouseId;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem.customView.hidden = YES;
    self.houseArray = [NSMutableArray array];
    // 请求享家房屋列表
    [self getEnjoyHomeHouseListWithToken:[GSHUserManager currentUser].accessToken isShowLoading:YES];
    
    [self observerNotifications];
}

-(void)dealloc {
    [self removeNotifications];
}

#pragma mark - 通知
-(void)observerNotifications{
    [self observerNotification:GSHSDKNotificationAccessToken];   // 获取享家授权结果及accessToken的通知
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHSDKNotificationAccessToken]) {
        // 获取新的token , 重新请求房屋列表
        NSDictionary *userInfo = notification.userInfo;
        NSString *result = [userInfo objectForKey:@"result"];
        if ([result isEqualToString:@"01"]) {
            // 新的accessToken
            NSString *token = [userInfo objectForKey:@"accessToken"];
            [GSHUserManager currentUser].accessToken = token;
            [self getEnjoyHomeHouseListWithToken:token isShowLoading:NO];
        } else {
            // 请求新token失败
            [TZMProgressHUDManager showErrorWithStatus:@"token失效,请求房屋失败" inView:self.view];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - method
// 保存 -- 调用绑定房屋接口
- (IBAction)saveButtonClick:(id)sender {
    if (!self.selectHouseM) {
        [TZMProgressHUDManager showErrorWithStatus:@"请选择要绑定的房屋" inView:self.view];
        return;
    }
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"绑定中" inView:self.view];
    [GSHSDKEnjoyHomeHouseManager bindEnjoyHomeHouseWithFamilyId:self.smartHomeFamilyId.stringValue mHouseId:self.selectHouseM.userHouseId.stringValue mHouseName:self.selectHouseM.houseName block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"绑定成功" inView:self.view];
            if (self.saveBlock) {
                self.saveBlock(self.selectHouseM);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - request
// 获取享家房屋列表
- (void)getEnjoyHomeHouseListWithToken:(NSString *)accessToken isShowLoading:(BOOL)isShowLoading {
    @weakify(self)
    if (isShowLoading) {
        [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    }
    [GSHSDKEnjoyHomeHouseManager getEnjoyHomeHouseListWithAccessToken:accessToken block:^(NSArray<GSHSDKEnjoyHomeHouseM *> *list, NSError *error) {
        @strongify(self)
        if (error) {
            if (error.code == 65) {
                // accessToken 失效,通知享家重新获取accessToken
                [self postNotification:GSHSDKNotificationAuth object:nil];
            } else {
                [TZMProgressHUDManager dismissInView:self.view];
                TZMPageStatusView *statusView = [self.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                    [self getEnjoyHomeHouseListWithToken:accessToken isShowLoading:YES];
                }];
                statusView.backgroundColor = [UIColor whiteColor];
                self.navigationItem.rightBarButtonItem.customView.hidden = YES;
            }
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            self.navigationItem.rightBarButtonItem.customView.hidden = NO;
            if (self.houseArray.count > 0) {
                [self.houseArray removeAllObjects];
            }
            [self.houseArray addObjectsFromArray:list];
            [self.houseTableView reloadData];
        }
    }];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.houseArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHDefenceAlarmAuthBindHouseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"houseCell" forIndexPath:indexPath];
    if (self.houseArray.count > indexPath.row) {
        GSHSDKEnjoyHomeHouseM *houseM = self.houseArray[indexPath.row];
        cell.houseNameLabel.text = houseM.houseName;
        if ([houseM.userHouseId isEqual:self.selectMhouseId]) {
            cell.checkButton.selected = YES;
            cell.houseNameLabel.textColor = [UIColor colorWithHexString:@"#2EB0FF"];
        } else {
            cell.checkButton.selected = NO;
            cell.houseNameLabel.textColor = [UIColor colorWithHexString:@"#222222"];
        }
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHDefenceAlarmAuthBindHouseCell *cell = (GSHDefenceAlarmAuthBindHouseCell *)[tableView cellForRowAtIndexPath:indexPath];
    for (int i = 0; i < self.houseArray.count; i ++) {
        GSHDefenceAlarmAuthBindHouseCell *tmpCell = (GSHDefenceAlarmAuthBindHouseCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        tmpCell.checkButton.selected = NO;
        tmpCell.houseNameLabel.textColor = [UIColor colorWithHexString:@"#222222"];
    }
    cell.checkButton.selected = YES;
    cell.houseNameLabel.textColor = [UIColor colorWithHexString:@"#2EB0FF"];
    if (self.houseArray.count > indexPath.row) {
        self.selectHouseM = self.houseArray[indexPath.row];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}


@end
