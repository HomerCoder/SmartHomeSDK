//
//  GSHRoomEditVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/22.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHRoomEditVC.h"
#import "GSHAlertManager.h"
#import "NSString+TZM.h"

@interface GSHRoomEditVC () <UITextFieldDelegate>
@property (nonatomic,strong)GSHFamilyM *family;
@property (nonatomic,strong)GSHFloorM *oldFloor;
@property (nonatomic,strong)GSHFloorM *changeFloor;
@property (nonatomic,strong)GSHRoomM *room;

@property (nonatomic,copy)NSString *bgId;

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UIView *viewFloor;
@property (weak, nonatomic) IBOutlet UIView *viewDelete;
@property (weak, nonatomic) IBOutlet UILabel *lblFloor;
@property (weak, nonatomic) IBOutlet UIView *viewSeleName;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerViewName;
- (IBAction)hideSeleNameView:(id)sender;
- (IBAction)seleName:(id)sender;
- (IBAction)touchChangeFloor:(UIButton *)sender;
- (IBAction)touchQuickBut:(UIButton *)sender;
- (IBAction)touchSave:(UIButton *)sender;
- (IBAction)touchDelete:(UIButton *)sender;
@end

@implementation GSHRoomEditVC
+(instancetype)roomEditVCWithFamily:(GSHFamilyM*)family floor:(GSHFloorM*)floor room:(GSHRoomM*)room{
    GSHRoomEditVC *vc = [GSHPageManager viewControllerWithSB:@"GSHRoomManagerSB" andID:@"GSHRoomEditVC"];
    vc.family = family;
    vc.oldFloor = floor;
    vc.room = room;
    return vc;
}

-(void)setRoom:(GSHRoomM *)room{
    _room = room;
    if (room) {
        self.title = @"编辑房间";
        self.tfName.text = room.roomName;
        self.bgId = room.backgroundId;
        self.viewDelete.hidden = NO;
    }else{
        self.title = @"添加房间";
        self.bgId = @"0";
        self.viewDelete.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tfName.delegate = self;
    self.room = self.room;
    if (self.family.floor.count > 1 && self.room) {
        self.viewFloor.hidden = NO;
        self.lblFloor.text = self.oldFloor.floorName;
    }else{
        self.viewFloor.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deleteRoom{
    [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHRoomManager postDeleteRoomWithFamilyId:weakSelf.family.familyId floorId:weakSelf.oldFloor.floorId roomId:weakSelf.room.roomId block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if (weakSelf.room) {
                [weakSelf.oldFloor.rooms removeObject:weakSelf.room];
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)hideSeleNameView:(id)sender{
    self.viewSeleName.hidden = YES;
}

- (IBAction)seleName:(id)sender{
    self.viewSeleName.hidden = YES;
    NSInteger row = [self.pickerViewName selectedRowInComponent:0];
    if (self.family.floor.count > row) {
        self.changeFloor = self.family.floor[row];
        self.lblFloor.text = self.changeFloor.floorName;
    }
}

- (IBAction)touchDelete:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 0) {
            [weakSelf deleteRoom];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:[NSString stringWithFormat:@"确认删除%@吗？",self.room.roomName] image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"确认" cancelButtonTitle:@"取消" otherButtonTitles:nil];
}

- (IBAction)touchChangeFloor:(UIButton *)sender {
    self.viewSeleName.hidden = NO;
}

- (IBAction)touchQuickBut:(UIButton *)sender {
    self.tfName.text = sender.titleLabel.text;
}

- (IBAction)touchSave:(UIButton *)sender {
    NSString *roomName = self.tfName.text;
    NSString *bgId = self.bgId;
    __weak typeof(self)weakSelf = self;
    if (roomName.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入房间名" inView:weakSelf.view];
        return;
    }
    if (bgId.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请选择房间背景" inView:weakSelf.view];
        return;
    }
    if (self.room.roomId) {
        [TZMProgressHUDManager showWithStatus:@"更新中" inView:self.view];
        
        [GSHRoomManager postUpdateRoomWithFamilyId:weakSelf.family.familyId floorId:self.changeFloor.floorId?self.changeFloor.floorId:self.oldFloor.floorId roomId:weakSelf.room.roomId roomName:roomName roomBg:bgId block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                weakSelf.room.roomName = roomName;
                weakSelf.room.backgroundId = bgId;
                if (weakSelf.changeFloor) {
                    if (weakSelf.oldFloor.floorId.integerValue != weakSelf.changeFloor.floorId.integerValue) {
                        [weakSelf.oldFloor.rooms removeObject:weakSelf.room];
                        [weakSelf.changeFloor.rooms addObject:weakSelf.room];
                        weakSelf.oldFloor = weakSelf.changeFloor;
                        weakSelf.changeFloor = nil;
                    }
                }
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }else{
        [TZMProgressHUDManager showWithStatus:@"新建中" inView:self.view];
        [GSHRoomManager postAddRoomWithFamilyId:weakSelf.family.familyId floorId:weakSelf.oldFloor.floorId roomName:roomName roomBg:bgId block:^(GSHRoomM *room, NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager showSuccessWithStatus:@"成功" inView:weakSelf.view];
                if (room) {
                    [weakSelf.oldFloor.rooms addObject:room];
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.family.floor.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (self.family.floor.count > row) {
        return self.family.floor[row].floorName;
    }
    return @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length > 0 && textField == self.tfName) {
        NSString *str =@"^[A-Za-z0-9➋➌➍➎➏➐➑➒\\u4e00-\u9fa5]+$";
        NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
        if (![emailTest evaluateWithObject:string]) {
            return NO;
        }
    }
    return YES;
}

@end
