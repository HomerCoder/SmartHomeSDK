//
//  GSHDeviceEditVC.m
//  SmartHome
//
//  Created by gemdale on 2018/7/6.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDeviceEditVC.h"
#import "GSHPickerView.h"
#import "GSHAlertManager.h"
#import "GSHDeviceCategoryVC.h"
#import "NSString+TZM.h"

#import "GSHDeviceManagerVC.h"
#import "UITextField+TZM.h"
#import "GSHDeviceRelevanceVC.h"
#import "NSString+TZM.h"

@interface GSHDeviceEditVCCellModel()
@end
@implementation GSHDeviceEditVCCellModel
+(instancetype)modelWithTitle:(NSString*)title text:(NSString*)text placeholder:(NSString*)placeholder type:(GSHDeviceEditVCCellModelType)type{
    GSHDeviceEditVCCellModel *model = [GSHDeviceEditVCCellModel new];
    model.title = title;
    model.text = text;
    model.placeholder = placeholder;
    model.type = type;
    return model;
}
@end

@interface GSHDeviceEditVCInputCell()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@end

@implementation GSHDeviceEditVCInputCell

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self observerNotifications];
    return self;
}

-(void)setModel:(GSHDeviceEditVCCellModel *)model{
    _model = model;
    self.lblTitle.text = model.title;
    self.tfText.text = model.text;
    self.tfText.placeholder = model.placeholder;
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:UITextFieldTextDidChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if (notification.object == self.tfText){
        NSLog(@"%@",self.tfText.text);
        if (self.tfText.tzm_maxByteLen > 0) {
            self.model.text = self.tfText.text.tzm_textLength > self.tfText.tzm_maxByteLen ? [self.tfText.text tzm_substringToMaxByte:self.tfText.tzm_maxByteLen] : self.tfText.text;
        }else{
            self.model.text = self.tfText.text;
        }
    }
}
@end

@interface GSHDeviceEditVCChooseCell()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcTrailing;
@end
@implementation GSHDeviceEditVCChooseCell
-(void)setModel:(GSHDeviceEditVCCellModel *)model{
    _model = model;
    self.lblTitle.text = model.title;
    self.lblText.text = model.text;
    self.accessoryType = model.accessoryType;
    if (self.accessoryType == UITableViewCellAccessoryNone) {
        self.lcTrailing.constant = 15;
    }else{
        self.lcTrailing.constant = 0;
    }
}
@end

@interface GSHDeviceEditVCTextCell()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@end
@implementation GSHDeviceEditVCTextCell
-(void)setModel:(GSHDeviceEditVCCellModel *)model{
    _model = model;
    self.lblTitle.text = model.title;
    self.lblText.text = model.text; 
}
@end

@interface GSHDeviceEditVCSwitchCell()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@end
@implementation GSHDeviceEditVCSwitchCell

-(void)awakeFromNib {
    [super awakeFromNib];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self observerNotifications];
    return self;
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:UITextFieldTextDidChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if (notification.object == self.tfText){
        if (self.tfText.tzm_maxByteLen > 0) {
            self.model.text = self.tfText.text.tzm_textLength > self.tfText.tzm_maxByteLen ? [self.tfText.text tzm_substringToMaxByte:self.tfText.tzm_maxByteLen] : self.tfText.text;
        }else{
            self.model.text = self.tfText.text;
        }
    }
}

-(void)setModel:(GSHDeviceEditVCCellModel *)model{
    _model = model;
    self.lblTitle.text = model.title;
    self.tfText.text = model.text;
    self.tfText.placeholder = model.placeholder;
}

- (IBAction)switchButtonClick:(UISwitch *)deviceSwitch {
    if (self.switchButtonClickBlock) {
        self.switchButtonClickBlock(deviceSwitch);
    }
}
@end

@interface GSHDeviceEditVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchSave:(UIButton *)sender;
- (IBAction)touchDelete:(UIButton *)sender;
@property (strong, nonatomic) NSArray<NSArray<GSHDeviceEditVCCellModel*>*>*dataList;
@property(assign, nonatomic) GSHDeviceEditVCType type;
@property(nonatomic,assign) GSHDeviceEditType deviceEditType;
@property(nonatomic,strong)GSHDeviceM *device;
@property(nonatomic,strong)GSHFloorM *floor;
@property(nonatomic,strong)GSHRoomM *room;
@property (weak, nonatomic) IBOutlet UIButton *relevanceButton; // 关联按钮
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *relevanceButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonTop;

@end

@implementation GSHDeviceEditVC
+(instancetype)deviceEditVCWithDevice:(GSHDeviceM*)device type:(GSHDeviceEditVCType)type {
    GSHDeviceEditVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddDeviceSB" andID:@"GSHDeviceEditVC"];
    vc.device = device;
    vc.type = type;
    vc.deviceEditType = [vc deviceEditTypeWithDeviceType:device.deviceType.stringValue];
    return vc;
}

- (GSHDeviceEditType)deviceEditTypeWithDeviceType:(NSString *)deviceType {
    GSHDeviceEditType deviceEditType;
    if ([deviceType isEqualToString:@"0"]) {
        // 一路智能开关
        deviceEditType = GSHDeviceTypeOneWaySwitch;
    } else if ([deviceType isEqualToString:@"1"]) {
        // 二路智能开关
        deviceEditType = GSHDeviceTypeTwoWaySwitch;
    } else if ([deviceType isEqualToString:@"2"]) {
        // 三路智能开关
        deviceEditType = GSHDeviceTypeThreeWaySwitch;
    } else if ([deviceType isEqualToString:GSHTwoWayCurtainDeviceType.stringValue]) {
        // 二路窗帘面板
        deviceEditType = GSHDeviceTypeTwoWayCurtain;
    } else {
        deviceEditType = GSHDeviceTypeOther;
    }
    return deviceEditType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self reloadData];
    if (self.type != GSHDeviceEditVCTypeEdit) {
        self.tableView.tableFooterView = nil;
    }
    [self getDeviceDetailInfo];
    
    [self observerNotifications];
    
    if ([self.device.deviceType isEqual:GSHOneWaySwitchDeviceType] ||
        [self.device.deviceType isEqual:GSHTwoWaySwitchDeviceType] ||
        [self.device.deviceType isEqual:GSHThreeWaySwitchDeviceType]) {
        self.relevanceButton.hidden = NO;
        self.relevanceButtonHeight.constant = 50;
        self.deleteButtonTop.constant = 10;
//        self.relevanceButton.hidden = YES;
//        self.relevanceButtonHeight.constant = 0;
//        self.deleteButtonTop.constant = 0;
    } else {
        self.relevanceButton.hidden = YES;
        self.relevanceButtonHeight.constant = 0;
        self.deleteButtonTop.constant = 0;
    }
    
}

-(void)observerNotifications{
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification]) {
        [self refreshUI];
    }
}

-(void)dealloc{
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)reloadData {
    
    NSArray *section1;
    if (self.deviceEditType == GSHDeviceTypeOneWaySwitch) {
        // 一路开关
        NSString *firstSwitchName = @"";
        if (self.device.attribute.count > 0) {
            firstSwitchName = self.device.attribute[0].meteName;
        }
        section1 = @[
                     [GSHDeviceEditVCCellModel modelWithTitle:@"设备名称" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : self.device.deviceName placeholder:@"请输入设备名称" type:GSHDeviceEditVCCellModelTypeInput],
                     [GSHDeviceEditVCCellModel modelWithTitle:@"第一路" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : firstSwitchName placeholder:@"请输入第一路开关名称" type:GSHDeviceEditVCCellModelTypeSwitch],
                     ];
    } else if (self.deviceEditType == GSHDeviceTypeTwoWaySwitch) {
        // 二路开关
        NSString *firstSwitchName = @"" , *secondSwitchName = @"";
        if (self.device.attribute.count > 1) {
            firstSwitchName = self.device.attribute[0].meteName;
            secondSwitchName = self.device.attribute[1].meteName;
        }
        section1 = @[
                     [GSHDeviceEditVCCellModel modelWithTitle:@"设备名称" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : self.device.deviceName placeholder:@"请输入设备名称" type:GSHDeviceEditVCCellModelTypeInput],
                     [GSHDeviceEditVCCellModel modelWithTitle:@"第一路" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : firstSwitchName placeholder:@"请输入第一路开关名称" type:GSHDeviceEditVCCellModelTypeSwitch],
                     [GSHDeviceEditVCCellModel modelWithTitle:@"第二路" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : secondSwitchName placeholder:@"请输入第二路开关名称" type:GSHDeviceEditVCCellModelTypeSwitch],
                     ];
    } else if (self.deviceEditType == GSHDeviceTypeThreeWaySwitch) {
        // 三路开关
        NSString *firstSwitchName = @"" , *secondSwitchName = @"" , *thirdSwitchName = @"";
        if (self.device.attribute.count > 2) {
            firstSwitchName = self.device.attribute[0].meteName;
            secondSwitchName = self.device.attribute[1].meteName;
            thirdSwitchName = self.device.attribute[2].meteName;
        }
        section1 = @[
                     [GSHDeviceEditVCCellModel modelWithTitle:@"设备名称" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : self.device.deviceName placeholder:@"请输入设备名称" type:GSHDeviceEditVCCellModelTypeInput],
                     [GSHDeviceEditVCCellModel modelWithTitle:@"第一路" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : firstSwitchName placeholder:@"请输入第一路开关名称" type:GSHDeviceEditVCCellModelTypeSwitch],
                     [GSHDeviceEditVCCellModel modelWithTitle:@"第二路" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : secondSwitchName placeholder:@"请输入第二路开关名称" type:GSHDeviceEditVCCellModelTypeSwitch],
                     [GSHDeviceEditVCCellModel modelWithTitle:@"第三路" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : thirdSwitchName placeholder:@"请输入第三路开关名称" type:GSHDeviceEditVCCellModelTypeSwitch]
                     ];
    } else if (self.deviceEditType == GSHDeviceTypeTwoWayCurtain) {
        // 二路窗帘
        NSString *firstSwitchName = @"" , *secondSwitchName = @"" ;
        if (self.device.attribute.count > 1) {
            firstSwitchName = self.device.attribute[0].meteName;
            secondSwitchName = self.device.attribute[1].meteName;
        }
        section1 = @[
                     [GSHDeviceEditVCCellModel modelWithTitle:@"设备名称" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : self.device.deviceName placeholder:@"请输入设备名称" type:GSHDeviceEditVCCellModelTypeInput],
                     [GSHDeviceEditVCCellModel modelWithTitle:@"第一路" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : firstSwitchName placeholder:@"请输入第一路窗帘开关名称" type:GSHDeviceEditVCCellModelTypeSwitch],
                     [GSHDeviceEditVCCellModel modelWithTitle:@"第二路" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : secondSwitchName placeholder:@"请输入第二路窗帘开关名称" type:GSHDeviceEditVCCellModelTypeSwitch],
                     ];
    } else if (self.deviceEditType == GSHDeviceTypeScenePanel) {
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:[GSHDeviceEditVCCellModel modelWithTitle:@"设备名称" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : self.device.deviceName placeholder:@"请输入设备名称" type:GSHDeviceEditVCCellModelTypeInput]];
        NSArray *titleArr = @[@"第一路",@"第二路",@"第三路",@"第四路",@"第五路",@"第六路"];
        for (int i = 0; i < 6; i ++) {
            [arr addObject:[GSHDeviceEditVCCellModel modelWithTitle:titleArr[i] text:self.type == GSHDeviceEditVCTypeAdd ? @"" : self.device.deviceName placeholder:@"请输入设备名称" type:GSHDeviceEditVCCellModelTypeSwitch]];
        }
        section1 = arr;
    } else {
        section1 = @[
                     [GSHDeviceEditVCCellModel modelWithTitle:@"设备名称" text:self.type == GSHDeviceEditVCTypeAdd ? @"" : self.device.deviceName placeholder:@"请输入设备名称" type:GSHDeviceEditVCCellModelTypeInput]
                     ];
    }
    
    GSHFamilyM *family = [GSHOpenSDKShare share].currentFamily;
    NSArray<GSHFloorM *> * floors = [family filterFloor];
    GSHDeviceEditVCCellModel *roomModel = [GSHDeviceEditVCCellModel modelWithTitle:@"所属房间" text:nil placeholder:nil type:GSHDeviceEditVCCellModelTypeChoose];
    if (floors.count > 1 || floors.firstObject.rooms.count > 1) {
        roomModel.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (self.type != GSHDeviceEditVCTypeAdd) {
            if (floors.count > 1) {
                roomModel.text = [NSString stringWithFormat:@"%@%@",self.device.floorName?self.device.floorName:@"",self.device.roomName?self.device.roomName:@""];
            }else{
                roomModel.text = [NSString stringWithFormat:@"%@",self.device.roomName?self.device.roomName:@""];
            }
        }
    }else{
        roomModel.accessoryType = UITableViewCellAccessoryNone;
        self.floor = floors.firstObject;
        self.room = self.floor.rooms.firstObject;
        if (self.type != GSHDeviceEditVCTypeAdd) {
            roomModel.text = [NSString stringWithFormat:@"%@",self.device.roomName?self.device.roomName:@""];
        }else{
            roomModel.text = [NSString stringWithFormat:@"%@",self.room.roomName?self.room.roomName:@""];
        }
    }
    
    NSArray *section3 = @[
                          [GSHDeviceEditVCCellModel modelWithTitle:@"硬件型号" text:self.device.hardModel placeholder:nil type:GSHDeviceEditVCCellModelTypeText],
                          [GSHDeviceEditVCCellModel modelWithTitle:@"固件版本" text:self.device.firmwareVersion.length > 0 ? self.device.firmwareVersion : (self.device.deviceModel.integerValue == -2 ? @"无" : @"暂无") placeholder:nil type:GSHDeviceEditVCCellModelTypeText],
                          [GSHDeviceEditVCCellModel modelWithTitle:@"MAC" text:self.device.deviceSn placeholder:nil type:GSHDeviceEditVCCellModelTypeText],
                          [GSHDeviceEditVCCellModel modelWithTitle:@"协议类型" text:self.device.agreementType placeholder:nil type:GSHDeviceEditVCCellModelTypeText],
                          [GSHDeviceEditVCCellModel modelWithTitle:@"厂家" text:self.device.manufacturer placeholder:nil type:GSHDeviceEditVCCellModelTypeText]
                          ];
    
    NSArray *section2 = @[roomModel];
    self.dataList = @[section1,section2,section3];
    
    [self.tableView reloadData];
}

#pragma mark - UITextFieldDelegate
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

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataList.count > section) {
        return self.dataList[section].count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataList.count > indexPath.section) {
        NSArray<GSHDeviceEditVCCellModel*>* models = self.dataList[indexPath.section];
        if (models.count > indexPath.row) {
            GSHDeviceEditVCCellModel *model = models[indexPath.row];
            if (model.type == GSHDeviceEditVCCellModelTypeInput) {
                GSHDeviceEditVCInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inputCell" forIndexPath:indexPath];
                cell.tfText.delegate = self;
                cell.model = model;
                return cell;
            }else if (model.type == GSHDeviceEditVCCellModelTypeChoose) {
                GSHDeviceEditVCChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chooseCell" forIndexPath:indexPath];
                cell.model = model;
                return cell;
            } else if (model.type == GSHDeviceEditVCCellModelTypeSwitch) {
                GSHDeviceEditVCSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell" forIndexPath:indexPath];
                cell.tfText.delegate = self;
                cell.model = model;
                @weakify(self)
                cell.switchButtonClickBlock = ^(UISwitch *deviceSwitch) {
                    @strongify(self)
                    [self deviceControlWithRowIndex:indexPath.row deviceSwitch:deviceSwitch];
                };
                return cell;
            } else {
                GSHDeviceEditVCTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
                cell.model = model;
                return cell;
            }
        }
    }
    return [UITableViewCell new];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self)weakSelf = self;
    GSHDeviceEditVCChooseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:GSHDeviceEditVCChooseCell.class] && cell.accessoryType != UITableViewCellAccessoryNone) {
        [self.view endEditing:NO];
        __weak typeof(cell) weakCell = cell;
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
        }else{
            for (GSHRoomM *room in floors.firstObject.rooms) {
                [array addObject:room.roomName];
            }
        }
        
        [GSHPickerView showPickerViewWithDataArray:array completion:^(NSString *selectContent , NSArray *selectRowArray) {
            weakCell.model.text = selectContent;
            weakCell.lblText.text = selectContent;
            
            if (selectRowArray.count == 2) {
                id floorItem = selectRowArray[0];
                if ([floorItem isKindOfClass:NSNumber.class]) {
                    NSInteger floorRow = ((NSNumber*)floorItem).integerValue;
                    if (floors.count > floorRow) {
                        weakSelf.floor = floors[floorRow];
                        id roomItem = selectRowArray[1];
                        if ([roomItem isKindOfClass:NSNumber.class]) {
                            NSInteger roomRow = ((NSNumber*)roomItem).integerValue;
                            if (weakSelf.floor.rooms.count > roomRow) {
                                weakSelf.room = weakSelf.floor.rooms[roomRow];
                            }
                        }
                    }
                }
            }
            if (selectRowArray.count == 1) {
                weakSelf.floor = floors.firstObject;
                id roomItem = selectRowArray[0];
                if ([roomItem isKindOfClass:NSNumber.class]) {
                    NSInteger roomRow = ((NSNumber*)roomItem).integerValue;
                    if (weakSelf.floor.rooms.count > roomRow) {
                        weakSelf.room = weakSelf.floor.rooms[roomRow];
                    }
                }
            }
        }];
    }
    return nil;
}


#pragma mark - method
-(void)deleteDeviceDone{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:GSHDeviceManagerVC.class]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)deleteDevice{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
    [GSHDeviceManager deleteDeviceWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId roomId:self.device.roomId.stringValue deviceId:self.device.deviceId.stringValue deviceSn:self.device.deviceSn deviceModel:self.device.deviceModel.stringValue deviceType:self.device.deviceType.stringValue block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"删除成功" inView:weakSelf.view];
            [weakSelf deleteDeviceDone];
        }
    }];
}

- (IBAction)touchDelete:(UIButton *)sender {
    @weakify(self)
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        @strongify(self)
        if (buttonIndex == 0) {
            [self deleteDevice];
        }
    } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确认删除此设备吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"删除" cancelButtonTitle:@"取消" otherButtonTitles:nil];
}

// 设备关联
- (IBAction)touchDeviceRelevance:(id)sender {
    GSHDeviceRelevanceVC *deviceRelevanceVC = [GSHDeviceRelevanceVC deviceRelevanceVCWithDeviceId:self.device.deviceId.stringValue];
    deviceRelevanceVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:deviceRelevanceVC animated:YES];
}

- (IBAction)touchSave:(UIButton *)sender {
    
    GSHDeviceEditVCCellModel *model = self.dataList.firstObject.firstObject;
    NSString *name = model.text;
    NSString *roomId = nil;
    if(name.length == 0){
        [TZMProgressHUDManager showErrorWithStatus:@"请输入设备名" inView:self.view];
        return;
    }
    if ([name tzm_judgeTheillegalCharacter]) {
        [TZMProgressHUDManager showErrorWithStatus:@"名字不能含特殊字符" inView:self.view];
        return;
    }
    
    if(self.room.roomId.stringValue.length > 0){
        roomId = self.room.roomId.stringValue;
    }else{
        roomId = self.device.roomId.stringValue;
    }
    if(roomId.length == 0){
        [TZMProgressHUDManager showErrorWithStatus:@"请选择所属房间" inView:self.view];
        return;
    }
    
    NSMutableArray *attribute = [NSMutableArray array];
    if (self.deviceEditType == GSHDeviceTypeOneWaySwitch) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        GSHDeviceEditVCCellModel *firstModel = self.dataList.firstObject[1];
        if ([firstModel.text tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第一路开关名称不能为空" inView:self.view];
            return;
        }
        if ([firstModel.text tzm_judgeTheillegalCharacter]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第一路开关名称不能含特殊字符" inView:self.view];
            return;
        }
        [dic setObject:firstModel.text forKey:@"meteName"];
        if (self.device.attribute.count > 0) {
            GSHDeviceAttributeM *attributeM = self.device.attribute[0];
            [dic setObject:attributeM.meteKind forKey:@"meteKind"];
            [dic setObject:attributeM.basMeteId forKey:@"basMeteId"];
        }
        [attribute addObject:dic];
    } else if (self.deviceEditType == GSHDeviceTypeTwoWaySwitch) {
        NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
        GSHDeviceEditVCCellModel *firstModel = self.dataList.firstObject[1];
        if ([firstModel.text tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第一路开关名称不能为空" inView:self.view];
            return;
        }
        if ([firstModel.text tzm_judgeTheillegalCharacter]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第一路开关名称不能含特殊字符" inView:self.view];
            return;
        }
        [dic1 setObject:firstModel.text forKey:@"meteName"];
        if (self.device.attribute.count > 0) {
            GSHDeviceAttributeM *attributeM = self.device.attribute[0];
            [dic1 setObject:attributeM.meteKind forKey:@"meteKind"];
            [dic1 setObject:attributeM.basMeteId forKey:@"basMeteId"];
        }
        [attribute addObject:dic1];
        NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
        GSHDeviceEditVCCellModel *secondModel = self.dataList.firstObject[2];
        if ([secondModel.text tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第二路开关名称不能为空" inView:self.view];
            return;
        }
        if ([secondModel.text tzm_judgeTheillegalCharacter]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第二路开关名称不能含特殊字符" inView:self.view];
            return;
        }
        [dic2 setObject:secondModel.text forKey:@"meteName"];
        if (self.device.attribute.count > 1) {
            GSHDeviceAttributeM *attributeM = self.device.attribute[1];
            [dic2 setObject:attributeM.meteKind forKey:@"meteKind"];
            [dic2 setObject:attributeM.basMeteId forKey:@"basMeteId"];
        }
        [attribute addObject:dic2];
    } else if (self.deviceEditType == GSHDeviceTypeThreeWaySwitch) {
        NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
        GSHDeviceEditVCCellModel *firstModel = self.dataList.firstObject[1];
        if ([firstModel.text tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第一路开关名称不能为空" inView:self.view];
            return;
        }
        if ([firstModel.text tzm_judgeTheillegalCharacter]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第一路开关名称不能含特殊字符" inView:self.view];
            return;
        }
        [dic1 setObject:firstModel.text forKey:@"meteName"];
        if (self.device.attribute.count > 0) {
            GSHDeviceAttributeM *attributeM = self.device.attribute[0];
            [dic1 setObject:attributeM.meteKind forKey:@"meteKind"];
            [dic1 setObject:attributeM.basMeteId forKey:@"basMeteId"];
        }
        [attribute addObject:dic1];
        NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
        GSHDeviceEditVCCellModel *secondModel = self.dataList.firstObject[2];
        if ([secondModel.text tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第二路开关名称不能为空" inView:self.view];
            return;
        }
        if ([secondModel.text tzm_judgeTheillegalCharacter]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第二路开关名称不能含特殊字符" inView:self.view];
            return;
        }
        [dic2 setObject:secondModel.text forKey:@"meteName"];
        if (self.device.attribute.count > 1) {
            GSHDeviceAttributeM *attributeM = self.device.attribute[1];
            [dic2 setObject:attributeM.meteKind forKey:@"meteKind"];
            [dic2 setObject:attributeM.basMeteId forKey:@"basMeteId"];
        }
        [attribute addObject:dic2];
        NSMutableDictionary *dic3 = [NSMutableDictionary dictionary];
        GSHDeviceEditVCCellModel *thirdModel = self.dataList.firstObject[3];
        if ([thirdModel.text tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第三路开关名称不能为空" inView:self.view];
            return;
        }
        if ([thirdModel.text tzm_judgeTheillegalCharacter]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第三路开关名称不能含特殊字符" inView:self.view];
            return;
        }
        [dic3 setObject:thirdModel.text forKey:@"meteName"];
        if (self.device.attribute.count > 2) {
            GSHDeviceAttributeM *attributeM = self.device.attribute[2];
            [dic3 setObject:attributeM.meteKind forKey:@"meteKind"];
            [dic3 setObject:attributeM.basMeteId forKey:@"basMeteId"];
        }
        [attribute addObject:dic3];
    } else if (self.deviceEditType == GSHDeviceTypeTwoWayCurtain) {
        // 二路窗帘开关
        NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
        GSHDeviceEditVCCellModel *firstModel = self.dataList.firstObject[1];
        if ([firstModel.text tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第一路窗帘开关名称不能为空" inView:self.view];
            return;
        }
        if ([firstModel.text tzm_judgeTheillegalCharacter]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第一路窗帘开关名称不能含特殊字符" inView:self.view];
            return;
        }
        [dic1 setObject:firstModel.text forKey:@"meteName"];
        if (self.device.attribute.count > 0) {
            GSHDeviceAttributeM *attributeM = self.device.attribute[0];
            [dic1 setObject:attributeM.meteKind forKey:@"meteKind"];
            [dic1 setObject:attributeM.basMeteId forKey:@"basMeteId"];
        }
        [attribute addObject:dic1];
        NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
        GSHDeviceEditVCCellModel *secondModel = self.dataList.firstObject[2];
        if ([secondModel.text tzm_checkStringIsEmpty]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第二路窗帘开关名称不能为空" inView:self.view];
            return;
        }
        if ([secondModel.text tzm_judgeTheillegalCharacter]) {
            [TZMProgressHUDManager showErrorWithStatus:@"第二路窗帘开关名称不能含特殊字符" inView:self.view];
            return;
        }
        [dic2 setObject:secondModel.text forKey:@"meteName"];
        if (self.device.attribute.count > 1) {
            GSHDeviceAttributeM *attributeM = self.device.attribute[1];
            [dic2 setObject:attributeM.meteKind forKey:@"meteKind"];
            [dic2 setObject:attributeM.basMeteId forKey:@"basMeteId"];
        }
        [attribute addObject:dic2];
    }
    
    __weak typeof(self)weakSelf = self;
    if (self.type == GSHDeviceEditVCTypeAdd) {
        [TZMProgressHUDManager showWithStatus:@"保存中" inView:self.view];
        [GSHDeviceManager postAddDeviceWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId
                                     deviceId:self.device.deviceId.stringValue
                                   deviceType:self.device.deviceType.stringValue
                                       roomId:roomId
                                   deviceName:name
                                    attribute:attribute
                                        block:^(GSHDeviceM *device, NSError *error) {
            if (error) {
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        [weakSelf touchSave:nil];
                    }
                } textFieldsSetupHandler:NULL andTitle:error.localizedDescription andMessage:nil image:[UIImage ZHImageNamed:@"app_icon_error_red"] preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"重试",nil];
            }else{
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    if (buttonIndex == 1) {
                        if (self.isLastDevice) {
                            // 最后一个设备，返回跳转到设备品类页面
                            for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
                                if ([vc isKindOfClass:GSHDeviceCategoryVC.class]) {
                                    [self.navigationController popToViewController:vc animated:NO];
                                }
                            }
                        } else {
                            if (self.deviceAddSuccessBlock) {
                                self.deviceAddSuccessBlock(self.device.deviceId.stringValue);
                            }
                            [weakSelf.navigationController popViewControllerAnimated:NO];
                        }
                    }else{
                        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                    }
                } textFieldsSetupHandler:NULL andTitle:@"设备添加成功" andMessage:nil image:[UIImage ZHImageNamed:@"app_icon_susess"] preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"完成" otherButtonTitles:@"继续添加设备",nil];
            }
        }];
        
    } else {
        [TZMProgressHUDManager showWithStatus:@"修改中" inView:self.view];
        [GSHDeviceManager postUpdateDeviceWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId
                                              deviceId:self.device.deviceId.stringValue
                                              deviceSn:self.device.deviceSn
                                            deviceType:self.device.deviceType.stringValue
                                                roomId:self.device.roomId.stringValue
                                             newRoomId:self.room.roomId.stringValue
                                            deviceName:name
                                             attribute:attribute
                                                 block:^(GSHDeviceM *device, NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager showSuccessWithStatus:@"修改成功" inView:weakSelf.view];
                weakSelf.device.deviceName = name;
                if (weakSelf.floor.floorName.length > 0) {
                    weakSelf.device.floorName = weakSelf.floor.floorName;
                }
                if (weakSelf.room.roomName.length > 0) {
                    weakSelf.device.roomName = weakSelf.room.roomName;
                }
                if (attribute.count > 0) {
                    for (int i = 0; i < attribute.count; i ++) {
                        NSDictionary *dic = attribute[i];
                        GSHDeviceAttributeM *attributeM = weakSelf.device.attribute[i];
                        attributeM.meteName = [dic objectForKey:@"meteName"];
                    }
                }
                if (weakSelf.deviceEditSuccessBlock) {
                    weakSelf.deviceEditSuccessBlock(weakSelf.device);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.device.deviceId.stringValue deviceSign:self.device.deviceType.intValue == 18 ? @"01" : nil block:^(GSHDeviceM *device, NSError *error) {
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
                } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"该设备已被重置，请重新搜索后再次添加" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"我知道了" cancelButtonTitle:nil otherButtonTitles:nil,nil];
            }
        } else {
            if (self.type == GSHDeviceEditVCTypeAdd) {
                for (GSHDeviceAttributeM *attributeM in device.attribute) {
                    attributeM.meteName = @"";
                }
            }
            self.device = device;
            [self reloadData];
            [self refreshUI];
        }
    }];
}

// 控制设备 -- 主要针对开关面板 、 二路窗帘 、场景面板
- (void)deviceControlWithRowIndex:(NSInteger)rowIndex deviceSwitch:(UISwitch *)deviceSwitch {
    if (self.device.attribute.count >= rowIndex && rowIndex > 0) {
        GSHDeviceAttributeM *attributeM = self.device.attribute[rowIndex - 1];
        NSString *value;
        if (self.deviceEditType == GSHDeviceTypeTwoWayCurtain) {
            // 二路窗帘开关
            value = [NSString stringWithFormat:@"%d",!deviceSwitch.on];
        } else {
            value = [NSString stringWithFormat:@"%d",deviceSwitch.on];
        }
        [GSHDeviceManager deviceControlWithDeviceId:self.device.deviceId.stringValue deviceSN:self.device.deviceSn familyId:[GSHOpenSDKShare share].currentFamily.familyId basMeteId:attributeM.basMeteId value:value block:^(NSError *error) {
            if (error) {
                deviceSwitch.on = !deviceSwitch.on;
            }
        }];
    }
}

#pragma mark - 刷新UI
- (void)refreshUI {
    if (self.deviceEditType != GSHDeviceTypeOther) {
        NSDictionary *dic = [self.device realTimeDic];
        if (self.deviceEditType == GSHDeviceTypeOneWaySwitch) {
            // 一路智能开关
            if (self.device.attribute.count > 0) {
                GSHDeviceAttributeM *attributeM = (GSHDeviceAttributeM *)self.device.attribute[0];
                id value = [dic objectForKey:attributeM.basMeteId];
                if (value) {
                    GSHDeviceEditVCSwitchCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:attributeM.meteIndex.intValue inSection:0]];
                    cell.deviceSwitch.on = value ? [value intValue] : 0;
                }
            }
        } else if (self.deviceEditType == GSHDeviceTypeTwoWaySwitch) {
            // 二路智能开关
            if (self.device.attribute.count > 1) {
                for (GSHDeviceAttributeM *attributeM in self.device.attribute) {
                    id value = [dic objectForKey:attributeM.basMeteId];
                    if (value) {
                        GSHDeviceEditVCSwitchCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:attributeM.meteIndex.intValue inSection:0]];
                        cell.deviceSwitch.on = value ? [value intValue] : 0;
                    }
                }
            }
        } else if (self.deviceEditType == GSHDeviceTypeThreeWaySwitch) {
            // 三路智能开关
            if (self.device.attribute.count > 2) {
                for (GSHDeviceAttributeM *attributeM in self.device.attribute) {
                    id value = [dic objectForKey:attributeM.basMeteId];
                    if (value) {
                        GSHDeviceEditVCSwitchCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:attributeM.meteIndex.intValue inSection:0]];
                        cell.deviceSwitch.on = value ? [value intValue] : 0;
                    }
                }
            }
        }
    }
}
@end
