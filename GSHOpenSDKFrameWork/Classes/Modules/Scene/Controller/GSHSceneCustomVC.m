//
//  GSHSceneCustomVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/11/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHSceneCustomVC.h"
#import "GSHChooseDeviceVC.h"
#import "GSHSceneInfoVC.h"

#import "GSHDeviceMachineViewModel.h"

#import "GSHChooseDeviceListCell.h"
#import "NSString+TZM.h"

@implementation GSHSceneCustomOneCell

@end

@implementation GSHSceneCustomDeviceCell

@end


@interface GSHSceneCustomVC ()


@property (nonatomic , strong) NSMutableArray *selectDeviceArray;
@property (nonatomic , strong) NSMutableArray *floorListArray;
@property (nonatomic , strong) NSMutableArray *deviceTypeArray; // 存储无设备的设备类型

@property (nonatomic , strong) GSHSceneM *oldSceneM;
@property (nonatomic , strong) GSHSceneM *sceneSetM;
@property (nonatomic , strong) GSHOssSceneM *sceneListSetM;

@property (nonatomic , strong) NSNumber *lastRank;
@property (nonatomic , strong) NSNumber *templateId;
@property (nonatomic , assign) BOOL isEditScene;    // 标识是否是编辑场景

@property (nonatomic , assign) SceneCustomType sceneCustomType;
@property (nonatomic , strong) GSHSceneTemplateDetailInfoM *templateDetailInfoM;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;

@end

@implementation GSHSceneCustomVC

+ (instancetype)sceneCustomVCWithSceneM:(GSHSceneM *)sceneM
                             sceneListM:(GSHOssSceneM *)sceneListM
                               lastRank:(NSNumber *)lastRank
                             templateId:(NSNumber *)templateId
                        sceneCustomType:(SceneCustomType)sceneCustomType {
    
    GSHSceneCustomVC *vc = [GSHPageManager viewControllerWithSB:@"GSHSceneSB" andID:@"GSHSceneCustomVC"];
    vc.lastRank = lastRank;
    vc.sceneCustomType = sceneCustomType;
    if (sceneCustomType == SceneCustomTypeEdit) {
        // 编辑场景
        vc.oldSceneM = [sceneM yy_modelCopy];
        vc.sceneSetM = [sceneM yy_modelCopy];
        vc.sceneListSetM = [sceneListM yy_modelCopy];
        vc.selectDeviceArray = [sceneM.devices mutableCopy];
        vc.navigationItem.title = @"编辑场景";
        vc.isEditScene = YES;
    } else {
        // 添加场景
        vc.sceneSetM = [[GSHSceneM alloc] init];
        vc.sceneListSetM = [[GSHOssSceneM alloc] init];
        vc.navigationItem.title = @"自定义场景";
        vc.isEditScene = NO;
        if (sceneCustomType == SceneCustomTypeTemplate) {
            vc.navigationItem.title = @"激活场景";
            [vc.completeButton setTitle:@"激活" forState:UIControlStateNormal];
            vc.templateId = templateId;
        }
    }
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GSHChooseDeviceListCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"chooseDeviceListCell"];
    
    if (self.sceneCustomType == SceneCustomTypeTemplate) {
        // 从场景模版进来 请求模版详情
        [self getSceneTemplateDetailWithTemplateId:self.templateId];
    }
    
}

#pragma mark - Lazy
- (NSMutableArray *)deviceTypeArray {
    if (!_deviceTypeArray) {
        _deviceTypeArray = [NSMutableArray array];
    }
    return _deviceTypeArray;
}

- (NSMutableArray *)selectDeviceArray {
    if (!_selectDeviceArray) {
        _selectDeviceArray = [NSMutableArray array];
    }
    return _selectDeviceArray;
}

- (NSMutableArray *)floorListArray {
    if (!_floorListArray) {
        _floorListArray = [NSMutableArray array];
    }
    return _floorListArray;
}

#pragma mark - method
// 添加设备
- (IBAction)addDeviceButtonClick:(id)sender {
    GSHFloorM *floorM;
    GSHRoomM *roomM;
    if (self.floorListArray.count > 0) {
        floorM = self.floorListArray[0];
        if (floorM.rooms.count > 0) {
            roomM = floorM.rooms[0];
        }
    }
    GSHChooseDeviceVC *chooseDeviceVC = [[GSHChooseDeviceVC alloc] initWithSelectDeviceArray:self.selectDeviceArray floorM:floorM roomM:roomM floorArray:self.floorListArray];
    chooseDeviceVC.fromFlag = ChooseDeviceFromAddScene;
    @weakify(self)
    chooseDeviceVC.selectDeviceBlock = ^(NSArray *selectedDeviceArray) {
        @strongify(self)
        [self refreshSelectedDeviceArrayWithDeviceArray:selectedDeviceArray];
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:chooseDeviceVC animated:YES];
}

// 设备选择完成之后，刷新已选择设备情况
- (void)refreshSelectedDeviceArrayWithDeviceArray:(NSArray *)deviceArray {
    NSMutableArray *shouldBeAddedArray = [NSMutableArray array];
    for (GSHDeviceM *deviceM in deviceArray) {
        BOOL isIn = NO;
        for (GSHDeviceM *selectedDeviceM in self.selectDeviceArray) {
            if ([deviceM.deviceId isKindOfClass:NSNumber.class]) {
                if ([selectedDeviceM.deviceId isEqualToNumber:deviceM.deviceId]) {
                    isIn = YES;
                }
            }
        }
        if (!isIn) {
            [shouldBeAddedArray addObject:deviceM];
        }
    }
    
    NSMutableArray *shouldBeDeleteArray = [NSMutableArray array];
    for (GSHDeviceM *selectedDeviceM in self.selectDeviceArray) {
        BOOL isIn = NO;
        for (GSHDeviceM *deviceM in deviceArray) {
            if ([selectedDeviceM.deviceId isKindOfClass:NSNumber.class]) {
                if ([deviceM.deviceId isEqualToNumber:selectedDeviceM.deviceId]) {
                    isIn = YES;
                }
            }
        }
        if (!isIn) {
            [shouldBeDeleteArray addObject:selectedDeviceM];
        }
    }
    if (shouldBeAddedArray.count > 0) {
        [self.selectDeviceArray addObjectsFromArray:shouldBeAddedArray];
    }
    if (shouldBeDeleteArray.count > 0) {
        [self.selectDeviceArray removeObjectsInArray:shouldBeDeleteArray];
    }
    for (GSHDeviceM *deviceM in self.selectDeviceArray) {
        if (deviceM.exts.count == 0) {
            [deviceM.exts addObjectsFromArray:[GSHDeviceMachineViewModel getInitExtsWithDeviceM:deviceM deviceEditType:GSHDeviceVCTypeSceneSet]];
        }
    }
}

// 跳转场景信息页面
- (void)jumpToSceneInfoVC {
    GSHSceneInfoVC *sceneInfoVC = [GSHSceneInfoVC sceneInfoVCWithSceneSetM:self.sceneSetM];
    @weakify(self)
    sceneInfoVC.saveButtonClickBlock = ^(GSHSceneM * _Nonnull sceneM) {
        @strongify(self)
        self.sceneSetM.scenarioName = sceneM.scenarioName;
        self.sceneSetM.backgroundId = sceneM.backgroundId;
        self.sceneSetM.floorId = sceneM.floorId;
        self.sceneSetM.floorName = sceneM.floorName;
        self.sceneSetM.roomId = sceneM.roomId;
        self.sceneSetM.roomName = sceneM.roomName;
        self.sceneSetM.voiceKeyword = sceneM.voiceKeyword;
        self.sceneSetM.picUrl = sceneM.picUrl;
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:sceneInfoVC animated:YES];
}

// 完成按钮点击
- (IBAction)completeButtonClick:(UIButton *)button {
    [self.view endEditing:YES];
    if (!self.sceneSetM.scenarioName || [self.sceneSetM.scenarioName tzm_checkStringIsEmpty]) {
        [TZMProgressHUDManager showErrorWithStatus:@"请先设置场景信息" inView:self.view];
        return;
    }
    if (self.selectDeviceArray.count == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请添加执行动作" inView:self.view];
        return;
    }
    self.sceneSetM.familyId = [GSHOpenSDKShare share].currentFamily.familyId.numberValue;
    if (self.sceneSetM.devices.count > 0) {
        [self.sceneSetM.devices removeAllObjects];
    }
    [self.sceneSetM.devices addObjectsFromArray:self.selectDeviceArray];
    
    for (GSHDeviceM *deviceM in self.sceneSetM.devices) {
        if (deviceM.exts.count == 0) {
            [TZMProgressHUDManager showErrorWithStatus:[NSString stringWithFormat:@"%@ 未设置执行动作",deviceM.deviceName] inView:self.view];
            return;
        }
    }
    self.sceneListSetM.md5 = [[self.sceneSetM yy_modelToJSONString] md5String];
    self.sceneListSetM.familyId = [GSHOpenSDKShare share].currentFamily.familyId.numberValue;
    self.sceneListSetM.scenarioName = self.sceneSetM.scenarioName;
    self.sceneListSetM.rank = self.lastRank?self.lastRank:@(0);
    self.sceneListSetM.backgroundId = self.sceneSetM.backgroundId;
    self.sceneListSetM.backgroundUrl = self.sceneSetM.picUrl;
    self.sceneListSetM.roomId = self.sceneSetM.roomId;
    self.sceneListSetM.roomName = self.sceneSetM.roomName?self.sceneSetM.roomName:@"";
    self.sceneListSetM.floorName = self.sceneSetM.floorName?self.sceneSetM.floorName:@"";
    self.sceneListSetM.voiceKeyword = self.sceneSetM.voiceKeyword?self.sceneSetM.voiceKeyword:@"";
    if (self.templateId) {
        self.sceneListSetM.scenarioTplId = self.templateId;
    }
    
    if (self.sceneCustomType == SceneCustomTypeEdit) {
        if (button) {
            [TZMProgressHUDManager showWithStatus:@"修改中" inView:self.view];
        }
        @weakify(self)
        NSString *volumeId = [self.sceneListSetM.fid componentsSeparatedByString:@","].firstObject;
        [GSHSceneManager alertSceneWithVolumeId:volumeId
                                      oldRoomId:self.oldSceneM.roomId.stringValue
                                         sceneM:self.sceneSetM
                                      ossSceneM:self.sceneListSetM
                                          block:^(NSError *error) {
            @strongify(self)
            if (error) {
                if (button) {
                    if (error.code == 71) {
                        // 情景名称已存在
                        [TZMProgressHUDManager showErrorWithStatus:@"情景名称已存在" inView:self.view];
                    } else {
                        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
                    }
                }
            } else {
                if (self.updateSceneBlock) {
                    self.updateSceneBlock(self.sceneListSetM);
                }
                if (button) {
                    [TZMProgressHUDManager showSuccessWithStatus:@"修改成功" inView:self.view];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }];
    } else {
        [TZMProgressHUDManager showWithStatus:@"添加中" inView:self.view];
        @weakify(self)
        [GSHSceneManager addSceneWithSceneM:self.sceneSetM ossSceneM:self.sceneListSetM block:^(NSString *scenarionId, NSError *error) {
            @strongify(self)
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
            } else {
                self.sceneListSetM.scenarioId = scenarionId.numberValue;
                if (self.saveSceneBlock) {
                    self.saveSceneBlock(self.sceneListSetM);
                }
                [TZMProgressHUDManager showSuccessWithStatus:@"添加成功" inView:self.view];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

#pragma mark - request
// 获取场景模版详情数据
- (void)getSceneTemplateDetailWithTemplateId:(NSNumber *)templateId {
    [TZMProgressHUDManager showWithStatus:@"获取场景模板详情" inView:self.view];
    @weakify(self)
    [GSHSceneManager getSceneTemplateDetailWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId sceneTemplateId:templateId block:^(GSHSceneTemplateDetailInfoM *sceneTemplateDetailInfoM, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            self.templateDetailInfoM = sceneTemplateDetailInfoM;
            [self handleTemplateDetailData];
            [self.tableView reloadData];
        }
    }];
}

// 模版详情 -- 组装数据
- (void)handleTemplateDetailData {
    self.sceneSetM.scenarioName = self.templateDetailInfoM.name;
    self.sceneSetM.backgroundId = self.templateDetailInfoM.bgImgId;
    self.sceneSetM.picUrl = self.templateDetailInfoM.bgImgUrl;
    for (GSHDeviceTypeM *deviceTypeM in self.templateDetailInfoM.deviceTypes) {
        if (deviceTypeM.devices.count == 0) {
            [self.deviceTypeArray addObject:deviceTypeM];
        } else {
            for (GSHDeviceM *deviceM in deviceTypeM.devices) {
                deviceM.deviceType = deviceTypeM.deviceType;
                deviceM.exts = [deviceTypeM.exts mutableCopy];
                [self.selectDeviceArray addObject:deviceM];
            }
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return self.deviceTypeArray.count + self.selectDeviceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 55.0f;
    }
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GSHSceneCustomOneCell *oneCell = [tableView dequeueReusableCellWithIdentifier:@"oneCell" forIndexPath:indexPath];
        oneCell.sceneNameLabel.text = self.sceneSetM.scenarioName.length > 0 ? self.sceneSetM.scenarioName : @"";
        [oneCell.sceneBackImageView sd_setImageWithURL:[NSURL URLWithString:self.sceneSetM.picUrl] placeholderImage:GlobalPlaceHoldImage];
        return oneCell;
    } else {
        GSHChooseDeviceListCell *chooseDeviceListCell = [tableView dequeueReusableCellWithIdentifier:@"chooseDeviceListCell" forIndexPath:indexPath];
        
        if (self.deviceTypeArray.count > 0 && indexPath.row < self.deviceTypeArray.count) {
            // 有设备类型 无设备
            GSHDeviceTypeM *deviceTypeM = self.deviceTypeArray[indexPath.row];
            chooseDeviceListCell.checkButton.hidden = YES;
            chooseDeviceListCell.deviceActionLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            chooseDeviceListCell.deviceActionLabel.text = @"暂无设备";
            [chooseDeviceListCell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:deviceTypeM.picPath]];
            chooseDeviceListCell.deviceNameLabel.text = deviceTypeM.deviceTypeStr;
        } else {
            [chooseDeviceListCell.checkButton setImage:[UIImage ZHImageNamed:@"list_icon_arrow_right"] forState:UIControlStateNormal];
            chooseDeviceListCell.checkButton.enabled = NO;
            chooseDeviceListCell.deviceActionLabel.textColor = [UIColor colorWithHexString:@"#222222"];
            NSInteger deviceIndex = indexPath.row - self.deviceTypeArray.count;
            if (self.selectDeviceArray.count > deviceIndex) {
                GSHDeviceM *deviceM = self.selectDeviceArray[deviceIndex];
                chooseDeviceListCell.deviceNameLabel.text = deviceM.deviceName;
                
                if (deviceM.homePageIcon) {
                    [chooseDeviceListCell.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:deviceM.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
                } else {
                    [chooseDeviceListCell.deviceIconImageView sd_setImageWithURL:[GSHDeviceMachineViewModel deviceModelImageUrlWithDevice:deviceM] placeholderImage:DeviceIconPlaceHoldImage];
                }
                
                if (deviceM.exts.count > 0) {
                    chooseDeviceListCell.deviceActionLabel.text = [GSHDeviceMachineViewModel getDeviceShowStrWithDeviceM:deviceM];
                } else {
                    chooseDeviceListCell.deviceActionLabel.text = @"";
                }
            }
        }
        return chooseDeviceListCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 16.0f;
    }
    return 56.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [[UIView alloc] init];
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 56)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 24, 200, 20)];
        label.textColor = [UIColor colorWithHexString:@"#999999"];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"场景执行以下操作";
        [view addSubview:label];
        
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // 场景信息
        [self jumpToSceneInfoVC];
    } else {
        // 执行动作
        if (self.deviceTypeArray.count > 0 && indexPath.row < self.deviceTypeArray.count) {
            return;
        } else {
            NSInteger deviceIndex ;
            if (self.deviceTypeArray.count > 0) {
                deviceIndex = indexPath.row - self.deviceTypeArray.count;
            } else {
                deviceIndex = indexPath.row;
            }
            GSHDeviceM *deviceM = self.selectDeviceArray[deviceIndex];
            GSHChooseDeviceListCell *deviceCell = (GSHChooseDeviceListCell *)[tableView cellForRowAtIndexPath:indexPath];
            __weak typeof(deviceM) weakDeviceM = deviceM;
            __weak typeof(deviceCell) weakDeviceCell = deviceCell;
            [GSHDeviceMachineViewModel jumpToDeviceHandleVCWithVC:self deviceM:deviceM deviceEditType:GSHDeviceVCTypeSceneSet deviceSetCompleteBlock:^(NSArray * _Nonnull exts) {
                __strong typeof(weakDeviceM) strongDeviceM = weakDeviceM;
                __strong typeof(weakDeviceCell) strongDeviceCell = weakDeviceCell;
                [strongDeviceM.exts removeAllObjects];
                [strongDeviceM.exts addObjectsFromArray:exts];
                strongDeviceCell.deviceActionLabel.text = [GSHDeviceMachineViewModel getDeviceShowStrWithDeviceM:strongDeviceM];
            }];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (self.deviceTypeArray.count > 0 && indexPath.row < self.deviceTypeArray.count) {
            return NO;
        }
        return YES;
    }
    return NO;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger deviceIndex ;
        if (self.deviceTypeArray.count > 0) {
            deviceIndex = indexPath.row - self.deviceTypeArray.count;
        } else {
            deviceIndex = indexPath.row;
        }
        if (self.selectDeviceArray.count > deviceIndex) {
            [self.selectDeviceArray removeObjectAtIndex:deviceIndex];
            [self.tableView reloadData];
        }
    }
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}



@end
