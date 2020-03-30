//
//  GSHPasswordListVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHPasswordListVC.h"
#import "GSHDoorLackPasswordVC.h"

@interface GSHPasswordListVCCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end
@implementation GSHPasswordListVCCell
@end

@interface GSHPasswordListVC ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewFingerprint;
@property (weak, nonatomic) IBOutlet UITableView *tableViewPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnFingerprint;
@property (weak, nonatomic) IBOutlet UIView *lineFingerprint;
@property (weak, nonatomic) IBOutlet UIView *linePassword;
@property (weak, nonatomic) IBOutlet UIButton *btnPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
- (IBAction)touchFingerprint:(UIButton *)sender;
- (IBAction)touchPassword:(id)sender;
- (IBAction)touchAdd:(UIButton *)sender;
@property (strong, nonatomic)GSHDeviceM *device;
@property (strong, nonatomic)NSArray<GSHDoorLockPassWordM*> *fingerprintList;
@property (strong, nonatomic)NSArray<GSHDoorLockPassWordM*> *passwordList;
@end

@implementation GSHPasswordListVC
+(instancetype)passwordListVCWithDevice:(GSHDeviceM*)device{
    GSHPasswordListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoorLackSB" andID:@"GSHPasswordListVC"];
    vc.device = device;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadPassword];
    [self reloadFingerprint];
    [self observerNotifications];
}

-(void)observerNotifications{
    [self observerNotification:GSHDoorLockManagerPassWordChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHDoorLockManagerPassWordChangeNotification]) {
        [self reloadPassword];
        [self reloadFingerprint];
    }
}
-(void)reloadPassword{
    [TZMProgressHUDManager showErrorWithStatus:@"加载中" inView:self.tableViewPassword];
    __weak typeof(self) weakSelf = self;
    [GSHDoorLockManager getLockSecretWithDeviceSn:self.device.deviceSn secretType:GSHDoorLockSecretTypePassword usedType:GSHDoorLockUsedTypePermanent block:^(NSError * _Nonnull error, NSArray<GSHDoorLockPassWordM *> * _Nonnull list) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.tableViewPassword];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.tableViewPassword];
            weakSelf.passwordList = list;
            [weakSelf.tableViewPassword reloadData];
        }
    }];
}

-(void)reloadFingerprint{
    [TZMProgressHUDManager showErrorWithStatus:@"加载中" inView:self.tableViewFingerprint];
    __weak typeof(self) weakSelf = self;
    [GSHDoorLockManager getLockSecretWithDeviceSn:self.device.deviceSn secretType:GSHDoorLockSecretTypeFingerprint usedType:GSHDoorLockUsedTypePermanent block:^(NSError * _Nonnull error, NSArray<GSHDoorLockPassWordM *> * _Nonnull list) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.tableViewFingerprint];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.tableViewFingerprint];
            weakSelf.fingerprintList = list;
            [weakSelf.tableViewFingerprint reloadData];
        }
    }];
}

- (IBAction)touchFingerprint:(UIButton *)sender {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)touchPassword:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.size.width, 0) animated:YES];
}

- (IBAction)touchAdd:(UIButton *)sender {
    [self.navigationController pushViewController:[GSHDoorLackPasswordVC doorLackPasswordVCWithPassword:nil device:self.device] animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableViewPassword) {
        return self.passwordList.count;
    }
    if (tableView == self.tableViewFingerprint) {
        return self.fingerprintList.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHPasswordListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (tableView == self.tableViewPassword) {
        if (self.passwordList.count > indexPath.row) {
            cell.lblName.text =self.passwordList[indexPath.row].secretName;
        }
    }
    if (tableView == self.tableViewFingerprint) {
        if (self.fingerprintList.count > indexPath.row) {
            cell.lblName.text =self.fingerprintList[indexPath.row].secretName;
        }
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableViewPassword) {
        if (self.passwordList.count > indexPath.row) {
            [self.navigationController pushViewController:[GSHDoorLackPasswordVC doorLackPasswordVCWithPassword:self.passwordList[indexPath.row] device:self.device] animated:YES];
        }
    }
    if (tableView == self.tableViewFingerprint) {
        if (self.fingerprintList.count > indexPath.row) {
            [self.navigationController pushViewController:[GSHDoorLackPasswordVC doorLackPasswordVCWithPassword:self.fingerprintList[indexPath.row] device:self.device] animated:YES];
        }
    }
    return NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView != self.scrollView) {
        return;
    }
    if (scrollView.contentOffset.x > self.scrollView.size.width / 2 && self.btnFingerprint.selected) {
        self.btnFingerprint.titleLabel.font = [UIFont systemFontOfSize:14];
        self.btnFingerprint.selected = NO;
        self.lineFingerprint.hidden = YES;
        self.btnPassword.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        self.btnPassword.selected = YES;
        self.linePassword.hidden = NO;
        self.btnAdd.hidden = NO;
    }
    if (scrollView.contentOffset.x < self.scrollView.size.width / 2 && self.btnPassword.selected) {
        self.btnFingerprint.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        self.btnFingerprint.selected = YES;
        self.lineFingerprint.hidden = NO;
        self.btnPassword.titleLabel.font = [UIFont systemFontOfSize:14];
        self.btnPassword.selected = NO;
        self.linePassword.hidden = YES;
        self.btnAdd.hidden = YES;
    }
}
@end
