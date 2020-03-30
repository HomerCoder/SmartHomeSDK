//
//  GSHControlSwitchVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/2/19.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHControlSwitchVC.h"
#import "GSHNetworkSetNotiVC.h"

@interface GSHControlSwitchVC ()

@property (weak, nonatomic) IBOutlet UIImageView *localControlCheckImageView;
@property (weak, nonatomic) IBOutlet UIImageView *netControlCheckImageView;

@end

@implementation GSHControlSwitchVC

+ (instancetype)controlSwitchVC {
    GSHControlSwitchVC *vc = [GSHPageManager viewControllerWithSB:@"GSHControlSwitchSB" andID:@"GSHControlSwitchVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
    self.localControlCheckImageView.hidden = [GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN ? NO : YES;
    self.netControlCheckImageView.hidden = [GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN ? NO : YES;
    
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && [GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        [TZMProgressHUDManager showInfoWithStatus:@"您已处于局域网控制模式" inView:self.view];
        return nil;
    }
    if (indexPath.row == 1 && [GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
        [TZMProgressHUDManager showInfoWithStatus:@"您已处于外网控制模式" inView:self.view];
        return nil;
    }
    if (indexPath.row == 1) {
        // 切换到外网
        [TZMProgressHUDManager showWithStatus:@"切换中" inView:self.view];
        @weakify(self)
        [[GSHWebSocketClient shared] changType:GSHNetworkTypeWAN gatewayId:[GSHOpenSDKShare share].currentFamily.gatewayId block:^(NSError * _Nonnull error) {
            @strongify(self)
            if (error) {
                // 失败
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            } else {
                // 切换成功
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TZMProgressHUDManager showSuccessWithStatus:@"切换成功" inView:self.view];
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    [self postNotification:GSHControlSwitchSuccess object:[GSHOpenSDKShare share].currentFamily];
                });
            }
        }];
    } else {
        // 切换到局域网
        GSHNetworkSetNotiVC *networkSetNotiVC = [GSHNetworkSetNotiVC networkSetNotiVC];
        networkSetNotiVC.controlType = indexPath.row;
        networkSetNotiVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:networkSetNotiVC animated:YES];
    }
    return nil;
}



@end
