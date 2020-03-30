//
//  GSHCreateFamilyVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHCreateFamilyVC.h"
#import "GSHAlertManager.h"
#import "GSHPickerViewManager.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+TZM.h"
#import "NSObject+TZM.h"

@interface GSHCreateFamilyVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak)GSHFamilyListVC *familyListVC;
@property(nonatomic,strong)NSArray<GSHPrecinctM *> *precinctList;
@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,strong)GSHPrecinctM *selePrecinctM;

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UIButton *btnCreate;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
- (IBAction)touchCreate:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;

@property (copy, nonatomic) void (^completeBlock)(void);

@end

@implementation GSHCreateFamilyVC
+(instancetype)createFamilyVCWithFamilyListVC:(GSHFamilyListVC*)familyListVC completeBlock:(void(^)(void))completeBlock {
    GSHCreateFamilyVC *vc = [GSHPageManager viewControllerWithSB:@"GSHFamilySB" andID:@"GSHCreateFamilyVC"];
    vc.familyListVC = familyListVC;
    vc.completeBlock = completeBlock;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self observerNotifications];
    self.btnCreate.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
}

-(void)handleNotifications:(NSNotification *)notification{
}

-(void)refreshCreateBut{
    self.btnCreate.enabled = self.tfName.text.length > 0 && self.tfAddress.text.length > 0 && self.lblCity.text.length > 0;
}

-(void)seleAddress{
    __weak typeof(self)weakSelf = self;
    if (self.precinctList) {
        [self showPickerView];
    }else{
        [TZMProgressHUDManager showWithStatus:@"获取辖区列表中" inView:self.view];
        [GSHFamilyManager getPrecinctListWithblock:^(NSArray<GSHPrecinctM *> *precinctList, NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                weakSelf.precinctList = precinctList;
                [weakSelf showPickerView];
            }
        }];
    }
}

-(void)showPickerView{
    __weak typeof(self)weakSelf = self;
    [GSHPickerViewManager showPrecinctPickerViewWithPrecinctList:self.precinctList completion:^(GSHPrecinctM *districtModel, NSString *address) {
        weakSelf.selePrecinctM = districtModel;
        weakSelf.lblCity.text = address;
        [weakSelf refreshCreateBut];
    }];
}

- (IBAction)touchCreate:(UIButton *)sender {
    [self.view endEditing:YES];
    if (self.tfName.text.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入家庭名称" inView:self.view];
        return;
    }
    if (self.tfAddress.text.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入详细地址" inView:self.view];
        return;
    }
    if (self.tfName.text.length > 16) {
        [TZMProgressHUDManager showErrorWithStatus:@"家庭名称不能超过16位" inView:self.view];
        return;
    }
    if (self.tfAddress.text.length > 50) {
        [TZMProgressHUDManager showErrorWithStatus:@"详细地址不得超过50个字" inView:self.view];
        return;
    }
    if ([self.tfAddress.text tzm_judgeTheillegalCharacter]) {
        [TZMProgressHUDManager showErrorWithStatus:@"详细地址不能输入特殊字符" inView:self.view];
        return;
    }
    if ([self.tfName.text tzm_judgeTheillegalCharacter]) {
        [TZMProgressHUDManager showErrorWithStatus:@"家庭名不能输入特殊字符" inView:self.view];
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"创建中" inView:self.view];
    __weak typeof(self) weakSelf = self;
    [GSHFamilyManager postSetFamilyWithFamilyName:self.tfName.text familyPic:nil project:self.selePrecinctM.precinctId.stringValue address:self.tfAddress.text block:^(GSHFamilyM *family, NSError *error) {
        if (family) {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            family.projectName = weakSelf.lblCity.text;
            [weakSelf.familyListVC.list addObject:family];
            if (weakSelf.completeBlock) {
                weakSelf.completeBlock();
            }
        }else{
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self refreshCreateBut];
}
#pragma --mark tableView

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 || (indexPath.section == 2 && indexPath.row == 1)) {
        return NO;
    }
    return YES;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self seleAddress];
    }
    return nil;
}
@end
