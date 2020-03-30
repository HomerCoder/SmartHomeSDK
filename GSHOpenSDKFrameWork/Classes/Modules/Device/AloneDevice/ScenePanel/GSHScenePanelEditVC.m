//
//  GSHScenePanelEditVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHScenePanelEditVC.h"
#import "GSHPickerView.h"
#import "GSHChooseSceneListVC.h"
#import "GSHAlertManager.h"
#import "GSHDeviceCategoryVC.h"
#import "NSString+TZM.h"
#import "GSHDeviceManagerVC.h"
#import "NSObject+TZM.h"

@interface GSHScenePanelEditVC () <UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *editTableView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceSnLabel;
@property (weak, nonatomic) IBOutlet UILabel *protocolTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstBindLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondBindLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdBindLabel;
@property (weak, nonatomic) IBOutlet UILabel *fourthBindLabel;
@property (weak, nonatomic) IBOutlet UILabel *fifthBindLabel;
@property (weak, nonatomic) IBOutlet UILabel *sixthBindLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstBindButton;
@property (weak, nonatomic) IBOutlet UIButton *secondBindButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdBindButton;
@property (weak, nonatomic) IBOutlet UIButton *fourthBindButton;
@property (weak, nonatomic) IBOutlet UIButton *fifthBindButton;
@property (weak, nonatomic) IBOutlet UIButton *sixthBindButton;

@property (nonatomic,strong) GSHDeviceM *deviceM;

@property (nonatomic,strong) GSHFloorM *floor;
@property (nonatomic,strong) GSHRoomM *room;

@property(nonatomic,assign) GSHScenePanelEditType scenePanelEditType;   // 添加或编辑的标识

@end

@implementation GSHScenePanelEditVC

+ (instancetype)scenePanelEditVCWithDeviceM:(GSHDeviceM*)deviceM type:(GSHScenePanelEditType)type {
    GSHScenePanelEditVC *vc = [GSHPageManager viewControllerWithSB:@"GSHScenePanelEditSB" andID:@"GSHScenePanelEditVC"];
    vc.deviceM = deviceM;
    vc.scenePanelEditType = type;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.editTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
    
    if (self.scenePanelEditType == GSHScenePanelEditTypeEdit) {
        [self getDeviceDetailInfo];
    }
    
    [self observerNotifications];
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
}

-(void)handleNotifications:(NSNotification *)notification{
}

- (void)refreshUI {
    
    self.nameTextField.text = self.deviceM.deviceName.length > 0 ? self.deviceM.deviceName : @"";
    
    if ([GSHOpenSDKShare share].currentFamily.floor.count > 1) {
        self.roomLabel.text = [NSString stringWithFormat:@"%@%@",self.deviceM.floorName.length>0?self.deviceM.floorName:@"",self.deviceM.roomName.length>0?self.deviceM.roomName:@""];
    } else {
        self.roomLabel.text = self.deviceM.roomName.length>0?self.deviceM.roomName:@"";
    }
    
    self.deviceTypeLabel.text = self.deviceM.deviceModelStr.length>0?self.deviceM.deviceModelStr:@"";
    self.deviceVersionLabel.text = self.deviceM.firmwareVersion.length>0?self.deviceM.firmwareVersion:@"";
    self.deviceSnLabel.text = self.deviceM.deviceSn.length>0?self.deviceM.deviceSn:@"";
    self.protocolTypeLabel.text = self.deviceM.agreementType.length>0?self.deviceM.agreementType:@"";
    self.companyLabel.text = self.deviceM.manufacturer.length>0?self.deviceM.manufacturer:@"";
    
    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
        if ([attributeM.basMeteId isEqualToString:GSHScenePanel_FirstMeteId] && attributeM.scenarioName.length > 0) {
            self.firstBindLabel.text = attributeM.scenarioName;
            self.firstBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            self.firstBindButton.selected = YES;
            self.firstBindButton.layer.borderColor = [UIColor colorWithHexString:@"#E62E30"].CGColor;
        } else if ([attributeM.basMeteId isEqualToString:GSHScenePanel_SecondMeteId] && attributeM.scenarioName.length > 0) {
            self.secondBindLabel.text = attributeM.scenarioName;
            self.secondBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            self.secondBindButton.selected = YES;
            self.secondBindButton.layer.borderColor = [UIColor colorWithHexString:@"#E62E30"].CGColor;
        } else if ([attributeM.basMeteId isEqualToString:GSHScenePanel_ThirdMeteId] && attributeM.scenarioName.length > 0) {
            self.thirdBindLabel.text = attributeM.scenarioName;
            self.thirdBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            self.thirdBindButton.selected = YES;
            self.thirdBindButton.layer.borderColor = [UIColor colorWithHexString:@"#E62E30"].CGColor;
        } else if ([attributeM.basMeteId isEqualToString:GSHScenePanel_FourthMeteId] && attributeM.scenarioName.length > 0) {
            self.fourthBindLabel.text = attributeM.scenarioName;
            self.fourthBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            self.fourthBindButton.selected = YES;
            self.fourthBindButton.layer.borderColor = [UIColor colorWithHexString:@"#E62E30"].CGColor;
        } else if ([attributeM.basMeteId isEqualToString:GSHScenePanel_FifthMeteId] && attributeM.scenarioName.length > 0) {
            self.fifthBindLabel.text = attributeM.scenarioName;
            self.fifthBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            self.fifthBindButton.selected = YES;
            self.fifthBindButton.layer.borderColor = [UIColor colorWithHexString:@"#E62E30"].CGColor;
        } else if ([attributeM.basMeteId isEqualToString:GSHScenePanel_SixthMeteId] && attributeM.scenarioName.length > 0) {
            self.sixthBindLabel.text = attributeM.scenarioName;
            self.sixthBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            self.sixthBindButton.selected = YES;
            self.sixthBindButton.layer.borderColor = [UIColor colorWithHexString:@"#E62E30"].CGColor;
        }
    }
    
}

#pragma mark - method
- (IBAction)bindBtnClick:(UIButton *)button {
    int tag = (int)button.tag;
    NSString *basMeteId = @"";
    for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
        if (attributeM.meteIndex.intValue == tag) {
            basMeteId = attributeM.basMeteId;
        }
    }
    if (basMeteId.length == 0) {
        return;
    }
    __weak typeof(button) weakButton = button;
    if (button.selected) {
        // 解绑
        @weakify(self)
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            __strong typeof(weakButton) strongButton = weakButton;
            @strongify(self)
            if (buttonIndex == 1) {
                [self unBindClickWithButtonTag:tag button:strongButton basMeteId:basMeteId];
            }
        } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确认解除绑定吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    } else {
        // 绑定
        GSHChooseSceneListVC *chooseSceneListVC = [GSHChooseSceneListVC chooseSceneListVCWithDeviceM:self.deviceM indexValue:tag basMeteId:basMeteId];
        chooseSceneListVC.hidesBottomBarWhenPushed = YES;
        @weakify(self)
        chooseSceneListVC.bindSceneSuccessBlock = ^(GSHOssSceneM *ossSceneM){
            @strongify(self)
            __strong typeof(weakButton) strongButton = weakButton;
            for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                if (attributeM.meteIndex.intValue == tag) {
                    attributeM.scenarioName = ossSceneM.scenarioName;
                    break;
                }
            }
            if (tag == 1) {
                self.firstBindLabel.text = ossSceneM.scenarioName;
                self.firstBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            } else if (tag == 2) {
                self.secondBindLabel.text = ossSceneM.scenarioName;
                self.secondBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            } else if (tag == 3) {
                self.thirdBindLabel.text = ossSceneM.scenarioName;
                self.thirdBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            } else if (tag == 4) {
                self.fourthBindLabel.text = ossSceneM.scenarioName;
                self.fourthBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            } else if (tag == 5) {
                self.fifthBindLabel.text = ossSceneM.scenarioName;
                self.fifthBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            } else if (tag == 6) {
                self.sixthBindLabel.text = ossSceneM.scenarioName;
                self.sixthBindLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            }
            if (self.bindSceneSuccessBlock) {
                self.bindSceneSuccessBlock(ossSceneM,tag);
            }
            strongButton.selected = YES;
            strongButton.layer.borderColor = [UIColor colorWithHexString:@"#E62E30"].CGColor;
        };
        [self.navigationController pushViewController:chooseSceneListVC animated:YES];
    }
}

// 保存
- (IBAction)saveButtonClick:(id)sender {
    [self.view endEditing:YES];
    self.deviceM.deviceName = self.nameTextField.text;
    NSString *name = self.deviceM.deviceName;
    if(name.length == 0){
        [TZMProgressHUDManager showErrorWithStatus:@"请输入设备名" inView:self.view];
        return;
    }
    if ([name tzm_judgeTheillegalCharacter]) {
        [TZMProgressHUDManager showErrorWithStatus:@"名字不能含特殊字符" inView:self.view];
        return;
    }
    
    NSString *roomId = nil;
    if(self.room.roomId.stringValue.length > 0) {
        roomId = self.room.roomId.stringValue;
    } else {
        roomId = self.deviceM.roomId.stringValue;
    }
    if(roomId.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请选择所属房间" inView:self.view];
        return;
    }
    
//    NSMutableArray *attributeArray = [NSMutableArray array];
//    for (GSHDeviceAttributeM *deviceAttributeM in self.deviceM.attribute) {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setObject:deviceAttributeM.meteKind forKey:@"meteKind"];
//        [dic setObject:deviceAttributeM.basMeteId forKey:@"basMeteId"];
//        [attributeArray addObject:dic];
//    }
    
    @weakify(self)
    if (self.scenePanelEditType == GSHScenePanelEditTypeAdd) {
        // 添加
        [TZMProgressHUDManager showWithStatus:@"保存中" inView:self.view];
        [GSHDeviceManager postAddDeviceWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceType:self.deviceM.deviceType.stringValue roomId:roomId deviceName:name attribute:@[] block:^(GSHDeviceM *device, NSError *error) {
            @strongify(self)
            if (error) {
                [TZMProgressHUDManager dismissInView:self.view];
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        [self saveButtonClick:nil];
                    }
                } textFieldsSetupHandler:NULL andTitle:@"设备添加失败" andMessage:nil image:[UIImage ZHImageNamed:@"app_icon_error_red"] preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"重试",nil];
            }else{
                [TZMProgressHUDManager dismissInView:self.view];
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        if (self.isLastDevice) {
                            // 最后一个设备，返回跳转到设备品类页面
                            for (UIViewController *vc in self.navigationController.viewControllers) {
                                if ([vc isKindOfClass:GSHDeviceCategoryVC.class]) {
                                    [self.navigationController popToViewController:vc animated:NO];
                                }
                            }
                        } else {
                            if (self.deviceAddSuccessBlock) {
                                self.deviceAddSuccessBlock(self.deviceM.deviceId.stringValue);
                            }
                            [self.navigationController popViewControllerAnimated:NO];
                        }
                    } else {
                        [self.navigationController popToRootViewControllerAnimated:NO];
                    }
                } textFieldsSetupHandler:NULL andTitle:@"设备添加成功" andMessage:nil image:[UIImage ZHImageNamed:@"app_icon_susess"] preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"完成" otherButtonTitles:@"继续添加设备",nil];
            }
        }];
    } else {
        // 编辑
        [TZMProgressHUDManager showWithStatus:@"修改中" inView:self.view];
        [GSHDeviceManager postUpdateDeviceWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceSn:self.deviceM.deviceSn deviceType:self.deviceM.deviceType.stringValue roomId:self.deviceM.roomId.stringValue newRoomId:self.room.roomId.stringValue deviceName:name attribute:@[] block:^(GSHDeviceM *device, NSError *error) {
            @strongify(self)
            if (error) {
               [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            } else {
               [TZMProgressHUDManager showSuccessWithStatus:@"修改成功" inView:self.view];
               self.deviceM.deviceName = name;
               if (self.floor.floorName.length > 0) {
                   self.deviceM.floorName = self.floor.floorName;
               }
               if (self.room.roomName.length > 0) {
                   self.deviceM.roomName = self.room.roomName;
               }
//               if (attributeArray.count > 0) {
//                   for (int i = 0; i < attributeArray.count; i ++) {
//                       NSDictionary *dic = attributeArray[i];
//                       GSHDeviceAttributeM *attributeM = self.deviceM.attribute[i];
//                       attributeM.meteName = [dic objectForKey:@"meteName"];
//                   }
//               }
               if (self.deviceEditSuccessBlock) {
                   self.deviceEditSuccessBlock(self.deviceM);
               }
               [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

// 删除设备
- (IBAction)btnDeleteClick:(id)sender {
    @weakify(self)
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        @strongify(self)
        if (buttonIndex == 0) {
            [self deleteDevice];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确认删除此设备吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"删除" cancelButtonTitle:@"取消" otherButtonTitles:nil];
}

// 解除绑定
- (void)unBindClickWithButtonTag:(int)tag button:(UIButton *)button basMeteId:(NSString *)basMeteId {

    [TZMProgressHUDManager showWithStatus:@"解绑中" inView:self.view];
    __weak typeof(button) weakButton = button;
    __weak typeof(self) weakSelf = self;
    [GSHDeviceManager unbindScenarioBoardWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId basMeteId:basMeteId deviceId:self.deviceM.deviceId.stringValue block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"解绑成功" inView:weakSelf.view];
            __strong typeof(weakButton) strongButton = weakButton;
            if (tag == 1) {
                weakSelf.firstBindLabel.text = @"未绑定";
                weakSelf.firstBindLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            } else if (tag == 2) {
                weakSelf.secondBindLabel.text = @"未绑定";
                weakSelf.secondBindLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            } else if (tag == 3) {
                weakSelf.thirdBindLabel.text = @"未绑定";
                weakSelf.thirdBindLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            } else if (tag == 4) {
                weakSelf.fourthBindLabel.text = @"未绑定";
                weakSelf.fourthBindLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            } else if (tag == 5) {
                weakSelf.fifthBindLabel.text = @"未绑定";
                weakSelf.fifthBindLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            } else if (tag == 6) {
                weakSelf.sixthBindLabel.text = @"未绑定";
                weakSelf.sixthBindLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            }
            if (weakSelf.unbindSceneSuccessBlock) {
                weakSelf.unbindSceneSuccessBlock(tag);
            }
            strongButton.selected = NO;
            strongButton.layer.borderColor = [UIColor colorWithHexString:@"#2EB0FF"].CGColor;
        }
    }];
}


#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceSign:nil block:^(GSHDeviceM *device, NSError *error) {
        @strongify(self)
        if (error) {
            if (error.code == 92) {
                @weakify(self)
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    @strongify(self)
                    for (UIViewController *vc in self.navigationController.viewControllers) {
                        if ([vc isKindOfClass:GSHDeviceCategoryVC.class]) {
                            [self.navigationController popToViewController:vc animated:YES];
                        }
                    }
                } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"该设备已被重置，请重新搜索后再次添加" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了",nil];
            }
        } else {
            self.deviceM = device;
            [self refreshUI];
        }
    }];
}

-(void)deleteDevice{
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
    [GSHDeviceManager deleteDeviceWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId roomId:self.deviceM.roomId.stringValue deviceId:self.deviceM.deviceId.stringValue deviceSn:self.deviceM.deviceSn deviceModel:self.deviceM.deviceModel.stringValue deviceType:self.deviceM.deviceType.stringValue block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"删除成功" inView:self.view];
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:GSHDeviceManagerVC.class]) {
                    [self.navigationController popToViewController:vc animated:YES];
                    return;
                }
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.scenePanelEditType == GSHScenePanelEditTypeAdd && indexPath.section == 0 && indexPath.row != 0) {
        return 0.f;
    } else {
        return 50.f;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        // 选择所属房间
        [self.view endEditing:NO];
        NSArray <GSHFloorM*> *floors = [[GSHOpenSDKShare share].currentFamily filterFloor];
        NSMutableArray *array = [NSMutableArray array];
        if (floors.count > 1) {
            for (GSHFloorM *floor in floors) {
                NSMutableArray<NSString*> *roomArr = [NSMutableArray array];
                for (GSHRoomM *room in floor.rooms) {
                    [roomArr addObject:room.roomName];
                }
                if (floor.floorName) {
                    [array addObject:@{floor.floorName:roomArr}];
                }
            }
        } else {
            for (GSHRoomM *room in floors.firstObject.rooms) {
                [array addObject:room.roomName];
            }
        }
        @weakify(self)
        [GSHPickerView showPickerViewWithDataArray:array completion:^(NSString *selectContent , NSArray *selectRowArray) {
            @strongify(self)
            
            self.roomLabel.text = selectContent;
            if (selectRowArray.count == 2) {
                id floorItem = selectRowArray[0];
                if ([floorItem isKindOfClass:NSNumber.class]) {
                    NSInteger floorRow = ((NSNumber*)floorItem).integerValue;
                    if (floors.count > floorRow) {
                        self.floor = floors[floorRow];
                        id roomItem = selectRowArray[1];
                        if ([roomItem isKindOfClass:NSNumber.class]) {
                            NSInteger roomRow = ((NSNumber*)roomItem).integerValue;
                            if (self.floor.rooms.count > roomRow) {
                                self.room = self.floor.rooms[roomRow];
                            }
                        }
                    }
                }
            }
            if (selectRowArray.count == 1) {
                self.floor = floors.firstObject;
                id roomItem = selectRowArray[0];
                if ([roomItem isKindOfClass:NSNumber.class]) {
                    NSInteger roomRow = ((NSNumber*)roomItem).integerValue;
                    if (self.floor.rooms.count > roomRow) {
                        self.room = self.floor.rooms[roomRow];
                    }
                }
            }
        }];
    }
    return nil;
}

@end
