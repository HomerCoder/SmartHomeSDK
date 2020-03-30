//
//  GSHSceneInfoVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/11/6.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHSceneInfoVC.h"
#import "GSHSceneBackgroundVC.h"
#import "GSHVoiceKeyWordVC.h"

#import "GSHPickerView.h"

#import "NSString+TZM.h"

@interface GSHSceneInfoVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *roomBackImageView;
@property (weak, nonatomic) IBOutlet UILabel *roomValueLabel;
@property (weak, nonatomic) IBOutlet UITextField *sceneNameTextField;

@property (nonatomic , strong) GSHSceneM *sceneSetM;
@property (nonatomic , strong) NSArray *voiceKeyWordArray;

@end

@implementation GSHSceneInfoVC

+ (instancetype)sceneInfoVCWithSceneSetM:(GSHSceneM *)sceneSetM {
    GSHSceneInfoVC *vc = [GSHPageManager viewControllerWithSB:@"GSHSceneSB" andID:@"GSHSceneInfoVC"];
    vc.sceneSetM = [sceneSetM yy_modelCopy];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.roomBackImageView sd_setImageWithURL:[NSURL URLWithString:self.sceneSetM.picUrl] placeholderImage:GlobalPlaceHoldImage];
    self.sceneNameTextField.text = self.sceneSetM.scenarioName.length > 0 ? self.sceneSetM.scenarioName : @"";
    NSString *roomStr = @"";
    if ([GSHOpenSDKShare share].currentFamily.floor.count == 1) {
        roomStr = self.sceneSetM.roomName?self.sceneSetM.roomName:@"";
    } else {
        roomStr = [NSString stringWithFormat:@"%@%@",self.sceneSetM.floorName?self.sceneSetM.floorName:@"",self.sceneSetM.roomName?self.sceneSetM.roomName:@""];
    }
    self.roomValueLabel.text = roomStr.length > 0 ? roomStr : @"选取房间";
    if (self.sceneSetM.voiceKeyword.length > 0) {
        self.voiceKeyWordArray = [self.sceneSetM.voiceKeyword componentsSeparatedByString:@","];
    }
    
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 16.0f;
    } else {
        return 10.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.view endEditing:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            // 选择背景图片
            GSHSceneBackgroundVC *sceneBackVC = [[GSHSceneBackgroundVC alloc] initWithBackImgId:self.sceneSetM.backgroundId];
            sceneBackVC.selectBackImage = ^(GSHSceneBackgroundImageM *sceneBackgroundImageM) {
                self.sceneSetM.backgroundId = sceneBackgroundImageM.scenarioBgImgId;
                self.sceneSetM.picUrl = sceneBackgroundImageM.picUrl;
                [self.roomBackImageView sd_setImageWithURL:[NSURL URLWithString:sceneBackgroundImageM.picUrl] placeholderImage:GlobalPlaceHoldImage];
            };
            [self.navigationController pushViewController:sceneBackVC animated:YES];
        } else if (indexPath.row == 2) {
            // 选择房间
            [self popupRoomViewToChooseRoom];
        }
    } else {
        // 语音关键词
        GSHVoiceKeyWordVC *voiceKeyWordVC = [[GSHVoiceKeyWordVC alloc] init];
        [voiceKeyWordVC.keyWordArray addObjectsFromArray:self.voiceKeyWordArray];
        @weakify(self)
        voiceKeyWordVC.setVoiceKeyWordBlock = ^(NSArray *voiceKeyWordArray) {
            @strongify(self)
            self.voiceKeyWordArray = voiceKeyWordArray;
            if (voiceKeyWordArray.count > 0) {
                NSMutableString *voiceKeyWordStr = [NSMutableString string];
                [voiceKeyWordArray enumerateObjectsUsingBlock:^(NSString*  _Nonnull voiceKeyWord, NSUInteger idx, BOOL * _Nonnull stop) {
                    [voiceKeyWordStr appendString:[NSString stringWithFormat:@"%@,",voiceKeyWord]];
                }];
                if (voiceKeyWordStr.length > 0) {
                    [voiceKeyWordStr deleteCharactersInRange:NSMakeRange(voiceKeyWordStr.length - 1, 1)];
                }
                self.sceneSetM.voiceKeyword = (NSString *)voiceKeyWordStr;
            } else {
                self.sceneSetM.voiceKeyword = @"";
            }
        };
        [self.navigationController pushViewController:voiceKeyWordVC animated:YES];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.sceneSetM.scenarioName = textField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length > 0) {
        NSString *str =@"^[A-Za-z0-9➋➌➍➎➏➐➑➒\\u4e00-\u9fa5]+$";
        NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
        if (![emailTest evaluateWithObject:string]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - method
// 弹出选择房间的弹框
- (void)popupRoomViewToChooseRoom {
    @weakify(self)
    [GSHPickerView
     showPickerViewContainResetButtonWithDataArray:[self handleRoomInfoWithFloorMList:[GSHOpenSDKShare share].currentFamily.floor]
     cancelBenTitle:@"重置"
     cancelBenTitleColor:[UIColor colorWithHexString:@"#2EB0FF"]
     sureBtnTitle:@"确定"
     cancelBlock:^{
        // 重置按钮点击
        NSLog(@"重置了");
        @strongify(self)
        self.sceneSetM.floorName = nil;
        self.sceneSetM.floorId = nil;
        self.sceneSetM.roomName = nil;
        self.sceneSetM.roomId = nil;
        self.roomValueLabel.text = @"选取房间";
     } completion:^(NSString *selectContent , NSArray *selectRowArray) {
         @strongify(self)
         self.roomValueLabel.text = selectContent;
         if ([GSHOpenSDKShare share].currentFamily.floor.count == 1) {
             // 只有一个楼层
             GSHFloorM *floorM = [GSHOpenSDKShare share].currentFamily.floor.firstObject;
             self.sceneSetM.floorName = floorM.floorName;
             self.sceneSetM.floorId = floorM.floorId;
             NSNumber *roomRow = selectRowArray[0];
             GSHRoomM *roomM = floorM.rooms[[roomRow intValue]];
             self.sceneSetM.roomName = roomM.roomName;
             self.sceneSetM.roomId = roomM.roomId;
         } else {
             // 有多个楼层
             if (selectRowArray.count == 2) {
                 NSNumber *floorRow = selectRowArray[0];
                 NSNumber *roomRow = selectRowArray[1];
                 if ([GSHOpenSDKShare share].currentFamily.floor.count > [floorRow intValue]) {
                     GSHFloorM *floorM = [GSHOpenSDKShare share].currentFamily.floor[[floorRow intValue]];
                     self.sceneSetM.floorName = floorM.floorName;
                     self.sceneSetM.floorId = floorM.floorId;
                     if (floorM.rooms.count > [roomRow intValue]) {
                         GSHRoomM *roomM = floorM.rooms[[roomRow intValue]];
                         self.sceneSetM.roomName = roomM.roomName;
                         self.sceneSetM.roomId = roomM.roomId;
                     }
                 }
             }
         }
     }];
}

- (NSArray *)handleRoomInfoWithFloorMList:(NSArray *)floorMList {
    if (floorMList.count == 1) {
        GSHFloorM *floorM = floorMList[0];
        NSMutableArray *roomNameArray = [NSMutableArray array];
        for (GSHRoomM *roomM in floorM.rooms) {
            [roomNameArray addObject:roomM.roomName];
        }
        return roomNameArray;
    } else {
        NSMutableArray *floorArray = [NSMutableArray array];
        for (GSHFloorM *floorM in floorMList) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSMutableArray *roomNameArray = [NSMutableArray array];
            for (GSHRoomM *roomM in floorM.rooms) {
                [roomNameArray addObject:roomM.roomName];
            }
            [dic setObject:roomNameArray forKey:floorM.floorName];
            [floorArray addObject:dic];
        }
        return floorArray;
    }
}

- (IBAction)saveButtonClick:(id)sender {
    
    [self.view endEditing:YES];
    if (!self.sceneSetM.scenarioName || [self.sceneSetM.scenarioName tzm_checkStringIsEmpty]) {
        [TZMProgressHUDManager showErrorWithStatus:@"场景名称不能为空" inView:self.view];
        return;
    }
    if ([self.sceneSetM.scenarioName tzm_judgeTheillegalCharacter]) {
        [TZMProgressHUDManager showErrorWithStatus:@"名字不能含特殊字符" inView:self.view];
        return;
    }
    if (!self.sceneSetM.backgroundId) {
        [TZMProgressHUDManager showErrorWithStatus:@"请选择背景图片" inView:self.view];
        return;
    }
    if (self.saveButtonClickBlock) {
        self.saveButtonClickBlock(self.sceneSetM);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}


@end
