//
//  GSHFamilyTransferVC.m
//  SmartHome
//
//  Created by gemdale on 2019/1/4.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHFamilyTransferVC.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "GSHAlertManager.h"
#import "UIImageView+WebCache.h"
#import "GSHFamilyListVC.h"

@interface GSHFamilyTransferVCCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnSele;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@end

@implementation GSHFamilyTransferVCCell
-(void)setMember:(GSHFamilyMemberM *)member{
    _member = member;
    [self.imageHeader sd_setImageWithURL:[NSURL URLWithString:member.childUserPicPath] placeholderImage:[UIImage ZHImageNamed:@"app_headImage_default_icon"]];
    self.lblName.text = member.childUserName;
    self.lblPhone.text = member.childUserPhone;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    self.btnSele.selected = selected;
}

@end

@interface GSHFamilyTransferVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchTransfer:(UIButton *)sender;
@property(nonatomic,strong)GSHFamilyM *family;
@property(nonatomic,strong)GSHFamilyMemberM *seleMember;
@end

@implementation GSHFamilyTransferVC

+(instancetype)familyTransferVCWithFamily:(GSHFamilyM*)family{
    GSHFamilyTransferVC *vc = [GSHPageManager viewControllerWithSB:@"GSHFamilySB" andID:@"GSHFamilyTransferVC"];
    vc.family = family;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadData];
}

- (void)reloadData{
    __weak typeof(self) weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [GSHFamilyMemberManager getFamilyMemberListWithFamilyId:self.family.familyId block:^(NSArray<GSHFamilyMemberM *> *list, NSError *error) {
        [weakSelf dismissPageStatusView];
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if (list.count == 0) {
                [weakSelf showPageStatus:TZMPageStatusNormal
                                   image:[UIImage ZHImageNamed:@"familyMemberListVC_nodata_icon"]
                                   title:@"暂无成员"
                                    desc:nil
                              buttonText:nil
                  didClickButtonCallback:nil];
            }
            weakSelf.family.members = [NSMutableArray arrayWithArray:list];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.family.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHFamilyTransferVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.family.members.count) {
        cell.member = self.family.members[indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.family.members.count) {
        self.seleMember = self.family.members[indexPath.row];
    }
}

- (IBAction)touchTransfer:(UIButton *)sender {
    if (!self.seleMember) {
        [TZMProgressHUDManager showErrorWithStatus:@"请选择转让成员" inView:self.view];
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"转让中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHFamilyManager postTransferFamilyWithFamilyId:self.family.familyId childUserId:self.seleMember.childUserId block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                if (buttonIndex == 1) {
                    // 通知首页刷新数据
                    [weakSelf postNotification:GSHRefreshHomeDataNotifacation object:nil];
                    if (weakSelf.refreshFamilyListBlock) {
                        weakSelf.refreshFamilyListBlock();
                    }
                    for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
                        if ([vc isKindOfClass:[GSHFamilyListVC class]]) {
                            [weakSelf.navigationController popToViewController:vc animated:YES];
                        }
                    }
                }
            } textFieldsSetupHandler:NULL andTitle:@"转让成功" andMessage:[NSString stringWithFormat:@"%@已经成为%@的管理员",weakSelf.seleMember.childUserName,weakSelf.family.familyName] image:[UIImage ZHImageNamed:@"app_icon_susess"] preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        }
    }];
}
@end
