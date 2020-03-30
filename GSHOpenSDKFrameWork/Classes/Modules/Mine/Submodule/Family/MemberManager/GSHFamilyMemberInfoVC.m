//
//  GSHFamilyMemberInfoVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/23.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFamilyMemberInfoVC.h"
#import "UIImageView+WebCache.h"
#import "GSHFamilyMemberFloorAuthorityVC.h"
#import "GSHFamilyMemberAuthorityVC.h"

@interface GSHFamilyMemberInfoVC ()
@property (strong, nonatomic)GSHFamilyM *family;
@property (strong, nonatomic)GSHFamilyMemberM *member;
@property (assign, nonatomic)BOOL creation;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcLabelHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblShuoMing;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewHead;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
- (IBAction)touchSettingAuthority:(UIButton *)sender;
- (IBAction)touchSave:(UIButton *)sender;
- (IBAction)touchAdd:(UIButton *)sender;
- (IBAction)touchDelete:(UIButton *)sender;

@end

@implementation GSHFamilyMemberInfoVC

+(instancetype)familyMemberInfoVCWithFamily:(GSHFamilyM*)family member:(GSHFamilyMemberM*)member creation:(BOOL)creation{
    GSHFamilyMemberInfoVC *vc = [GSHPageManager viewControllerWithSB:@"GSHMemberManagerSB" andID:@"GSHFamilyMemberInfoVC"];
    vc.family = family;
    vc.member = member;
    vc.creation = creation;
    return vc;
}

-(void)setMember:(GSHFamilyMemberM *)member{
    _member = member;
    if (!_member.familyId) {
        _member.familyId = _family.familyId;
    }
    if (member) {
        self.lblName.text = member.childUserName;
        self.lblPhone.text = member.childUserPhone;
        [self.imageViewHead sd_setImageWithURL:[NSURL URLWithString:member.childUserPicPath] placeholderImage:[UIImage ZHImageNamed:@"app_headImage_default_icon"]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.member = self.member;
    if (self.creation) {
        self.title = @"添加成员";
        self.btnAdd.hidden = NO;
        self.btnSave.hidden = YES;
        self.btnDelete.hidden = YES;
        self.lblShuoMing.hidden = NO;
        self.lcLabelHeight.constant = 20;
    }else{
        self.title = @"成员设置";
        self.btnAdd.hidden = YES;
        self.btnSave.hidden = NO;
        self.btnDelete.hidden = NO;
        self.lblShuoMing.hidden = YES;
        self.lcLabelHeight.constant = 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    self.member.floor = nil;
}

- (IBAction)touchSettingAuthority:(UIButton *)sender {
    if (self.family.permissions == GSHFamilyMPermissionsManager) {
        GSHFamilyMemberFloorAuthorityVC *vc = [GSHFamilyMemberFloorAuthorityVC familyMemberFloorAuthorityVCWithMember:self.member];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        GSHFamilyMemberAuthorityVC *vc = [GSHFamilyMemberAuthorityVC familyMemberAuthorityVCWithMember:self.member];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)touchSave:(UIButton *)sender{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"编辑中" inView:self.view];
    [GSHFamilyMemberManager postUpdateFamilyMemberWithFamilyId:weakSelf.family.familyId childUserId:weakSelf.member.childUserId floorList:self.member.floor block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"编辑成功" inView:weakSelf.view];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}
- (IBAction)touchAdd:(UIButton *)sender{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"添加中" inView:self.view];
    [GSHFamilyMemberManager postAddFamilyMemberWithFamilyId:weakSelf.family.familyId userId:weakSelf.member.childUserId floorList:self.member.floor block:^(GSHFamilyMemberM *member, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"添加成功" inView:weakSelf.view];
            [weakSelf.family.members addObject:weakSelf.member];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}
- (IBAction)touchDelete:(UIButton *)sender{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
    [GSHFamilyMemberManager postDeleteFamilyMemberWithFamilyId:weakSelf.family.familyId childUserId:weakSelf.member.childUserId block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"删除成功" inView:weakSelf.view];
            [weakSelf.family.members removeObject:weakSelf.member];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}
@end
