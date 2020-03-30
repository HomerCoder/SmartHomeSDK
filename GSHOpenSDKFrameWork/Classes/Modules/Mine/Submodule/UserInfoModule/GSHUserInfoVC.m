//
//  GSHUserInfoVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/11.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHUserInfoVC.h"
#import "UIButton+WebCache.h"
#import "GSHAlertManager.h"
#import "GSHInputTextVC.h"
#import "GSHQRCodeVC.h"
#import "GSHPhoneInfoVC.h"
#import "NSString+TZM.h"
#import <AVFoundation/AVFoundation.h>
#import "GSHPickerViewManager.h"

@interface GSHUserInfoVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,PGDatePickerDelegate>
@property(nonatomic,strong)GSHUserInfoM *userInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *lblNick;
@property (weak, nonatomic) IBOutlet UILabel *lblSex;
@property (weak, nonatomic) IBOutlet UILabel *lblBirthday;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblWechat;
@end

@implementation GSHUserInfoVC

+(instancetype)newWithUserInfo:(GSHUserInfoM*)userInfo{
    GSHUserInfoVC *vc = [GSHPageManager viewControllerWithSB:@"GSHUserInfoSB" andID:@"GSHUserInfoVC"];
    vc.userInfo = userInfo;
    return vc;
}

-(void)setUserInfo:(GSHUserInfoM *)userInfo {
    _userInfo = userInfo;
    [self.btnHeadImage sd_setBackgroundImageWithURL:[NSURL URLWithString:userInfo.picPath] forState:UIControlStateNormal placeholderImage:[UIImage ZHImageNamed:@"app_headImage_default_icon"]];
    self.lblNick.text = userInfo.nick;
    self.lblSex.text = userInfo.sex.intValue == 1 ? @"男" : (userInfo.sex.intValue == 2 ? @"女" : @"");
    if (userInfo.phone.length == 11) {
        self.lblPhoneNumber.text = [NSString stringWithFormat:@"%@ %@ %@",[userInfo.phone substringToIndex:3],[userInfo.phone substringWithRange:NSMakeRange(3, 4)],[userInfo.phone substringFromIndex:7]];
    }
    if (userInfo.birth.length == 8) {
        self.lblBirthday.text = [NSString stringWithFormat:@"%@-%@-%@",[userInfo.birth substringToIndex:4],[userInfo.birth substringWithRange:NSMakeRange(4, 2)],[userInfo.birth substringFromIndex:6]];
    }
    if (userInfo.thirdPartyUserList.count == 0) {
        self.lblWechat.text = @"暂无";
    } else {
        for (GSHThirdPartyUserM *m in userInfo.thirdPartyUserList) {
            if (m.userType == GSHUserMThirdPartyLoginTypeWechat) {
                self.lblWechat.text = m.userName.length>0?m.userName:@"暂无";
            }
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.userInfo) {
        [self reloadUserInfo];
    }
}

- (void)reloadUserInfo{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"加载用户信息中" inView:self.view];
    [GSHUserManager getUserInfoWithBlock:^(GSHUserInfoM *userInfo, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            weakSelf.userInfo = [GSHUserManager currentUserInfo];
        }else{
            if (userInfo) {
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                weakSelf.userInfo = userInfo;
            }else{
                [TZMProgressHUDManager showErrorWithStatus:@"用户信息为空" inView:weakSelf.view];
                weakSelf.userInfo = [GSHUserManager currentUserInfo];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.userInfo = self.userInfo;
}

-(void)viewWillLayoutSubviews {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        for (UIView *view in self.tableView.subviews) {
            if ([view isKindOfClass:[UITableViewCell class]]) {
                ((UITableViewCell *)view).contentView.alpha = 0.2;
            }
        }
    }
}

- (void)changeHeadImage{
    @weakify(self)
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        @strongify(self)
        if (buttonIndex == 1 || buttonIndex == 2) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = YES;
            picker.delegate = self;
            if (buttonIndex == 1) {
                // 拍照
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
                    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    } textFieldsSetupHandler:NULL andTitle:@"没有相机权限" andMessage:@"请到系统设置里设置，设置->隐私->相机，打开应用权限" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"已经打开",@"取消",nil];
                    return;
                }
            } else if (buttonIndex == 2) {
                // 从相册选择
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            [self presentViewController:picker animated:YES completion:^{
            }];
        }
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
        
    } andTitle:@"" andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:@"" cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择",nil];
    
}

-(void)changeNick{
    __weak typeof(self)weakSelf = self;
    GSHInputTextVC *vc = [GSHInputTextVC inputTextVCWithOldText:self.userInfo.nick block:^(NSString *text, GSHInputTextVC *inputTextVC) {
        if (text.length == 0) {
            [TZMProgressHUDManager showErrorWithStatus:@"请输入昵称" inView:inputTextVC.view];
            return;
        }
        if ([text tzm_judgeTheillegalCharacter]) {
            [TZMProgressHUDManager showErrorWithStatus:@"昵称不能含特殊字符" inView:inputTextVC.view];
            return;
        }
        [TZMProgressHUDManager showWithStatus:@"更新昵称中" inView:inputTextVC.view];
        __weak GSHInputTextVC *weakInputVC = inputTextVC;
        [GSHUserManager postUpdateUserInfoWithParameter:@{@"nick":text} block:^(GSHUserInfoM *userInfo, NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakInputVC.view];
            }else{
                [TZMProgressHUDManager dismissInView:weakInputVC.view];
                weakSelf.userInfo.nick = userInfo.nick;
                [weakInputVC.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
    vc.title = @"昵称";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)changeSex{
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1 || buttonIndex == 2) {
            NSNumber *sex = @(buttonIndex);
            [GSHUserManager postUpdateUserInfoWithParameter:@{@"sex":sex} block:^(GSHUserInfoM *userInfo, NSError *error) {
                if (error) {
                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                }else{
                    [TZMProgressHUDManager dismissInView:weakSelf.view];
                    weakSelf.userInfo.sex = sex;
                    weakSelf.lblSex.text = sex.intValue == 1 ? @"男" : (sex.intValue == 2 ? @"女" : @"");
                }
            }];
        }
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
    } andTitle:@"" andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:@"" cancelButtonTitle:@"取消" otherButtonTitles:@"男",@"女",nil];
}

-(void)changeBirthday{
    [GSHPickerViewManager showDatePickerViewWithDelegate:self mode:PGDatePickerModeDate maximumDate:[NSDate date] minimumDate:nil cancelButtonMonitor:^{
    }];
}

-(void)showQRCode{
    [self.navigationController pushViewController:[GSHQRCodeVC qrCodeVCWithUserInfo:self.userInfo] animated:YES];
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        return nil;
    }
    if(indexPath.section == 0 && indexPath.row == 0){
        [self changeHeadImage];
    }else if (indexPath.section == 1 && indexPath.row == 0){
        [self changeNick];
    }else if (indexPath.section == 1 && indexPath.row == 1){
        [self changeSex];
    }else if (indexPath.section == 1 && indexPath.row == 2){
        [self changeBirthday];
    }else if (indexPath.section == 2 && indexPath.row == 0){
    }else if (indexPath.section == 2 && indexPath.row == 1){
    }else if (indexPath.section == 2 && indexPath.row == 2){
        [self showQRCode];
    }else{
    }
    return nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __weak typeof(self)weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 从info中将图片取出，并加载到imageView当中
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [TZMProgressHUDManager showWithStatus:@"上传中" inView:self.view];
    [GSHUserManager postUpdateHeadImageWithImage:image progress:^(NSProgress * _Nonnull progress) {
        [TZMProgressHUDManager showProgress:(90.0 * progress.completedUnitCount) / (100.0 * progress.totalUnitCount) status:@"请稍候" inView:weakSelf.view];
    } block:^(GSHUserInfoM *userInfo, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"更新成功" inView:weakSelf.view];
            weakSelf.userInfo = userInfo;
        }
    }];
}

// 取消选取调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents{
    NSString *dayString = [NSString stringWithFormat:@"%04d%02d%02d",(int)(dateComponents.year),(int)(dateComponents.month),(int)(dateComponents.day)];
    __weak typeof(self)weakSelf = self;
    [GSHUserManager postUpdateUserInfoWithParameter:@{@"birth":dayString} block:^(GSHUserInfoM *userInfo, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.userInfo.birth = dayString;
            if (userInfo.birth.length == 8) {
                weakSelf.lblBirthday.text = [NSString stringWithFormat:@"%@-%@-%@",[userInfo.birth substringToIndex:4],[userInfo.birth substringWithRange:NSMakeRange(4, 2)],[userInfo.birth substringFromIndex:6]];
            }
        }
    }];
}

@end
