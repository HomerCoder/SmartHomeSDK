//
//  GSHInfraredControllerEditVC.m
//  SmartHome
//
//  Created by gemdale on 2019/3/22.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHInfraredControllerEditVC.h"
#import "GSHPickerView.h"
#import "NSString+TZM.h"

@interface GSHInfraredControllerEditVC ()
@property (weak, nonatomic) IBOutlet UITextField *textF;
@property (weak, nonatomic) IBOutlet UILabel *lblRoom;
@property (weak, nonatomic) IBOutlet UILabel *lblDeviceType;
@property (weak, nonatomic) IBOutlet UILabel *lblSn;
@property (weak, nonatomic) IBOutlet UILabel *lblSuperDevice;
- (IBAction)touchSave:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnEditRemote;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteRemote;
- (IBAction)touchEditRemote:(id)sender;
- (IBAction)touchDeleteRemote:(id)sender;

@property(nonatomic,strong)GSHFloorM *floor;
@property(nonatomic,strong)GSHRoomM *room;

@property (nonatomic,strong)GSHKuKongDeviceTypeM *type;
@property (nonatomic,strong)GSHKuKongRemoteM *remote;
@property (nonatomic,strong)GSHDeviceM *superDevice;
@property (nonatomic,strong)GSHKuKongBrandM *brand;

@property (nonatomic,strong)GSHKuKongInfraredDeviceM *device;
@end

@implementation GSHInfraredControllerEditVC
+(instancetype)infraredControllerEditVCWithType:(GSHKuKongDeviceTypeM*)type remote:(GSHKuKongRemoteM*)remote superDevice:(GSHDeviceM*)superDevice brand:(GSHKuKongBrandM*)brand{
    GSHInfraredControllerEditVC *vc = [GSHPageManager viewControllerWithSB:@"GSHInfraredControllerSB" andID:@"GSHInfraredControllerEditVC"];
    vc.type = type;
    vc.remote = remote;
    vc.superDevice = superDevice;
    vc.brand = brand;
    return vc;
}

+(instancetype)infraredControllerEditVCWithDevice:(GSHKuKongInfraredDeviceM*)device{
    GSHInfraredControllerEditVC *vc = [GSHPageManager viewControllerWithSB:@"GSHInfraredControllerSB" andID:@"GSHInfraredControllerEditVC"];
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    GSHFamilyM *family = [GSHOpenSDKShare share].currentFamily;
    NSArray<GSHFloorM *> * floors = [family filterFloor];
    for (GSHFloorM *floor in floors) {
        BOOL isOK = NO;
        for (GSHRoomM *room in floor.rooms) {
            if ([self.device.roomId isEqualToNumber:room.roomId]) {
                self.floor = floor;
                self.room = room;
                isOK = YES;
                NSLog(@"%@",room.roomName);
                break;
            }
        }
        if (isOK) {
            break;
        }
        NSLog(@"%@",floor.floorName);
    }
    self.device.floorId = self.floor.floorId;
    self.device.floorName = self.floor.floorName;
    self.device.roomName = self.room.roomName;
    
    [self refreshUI];
}

-(void)refreshUI{
    if (self.superDevice) {
        self.lblSn.text = @"无";
        self.lblDeviceType.text = @"虚拟红外";
        
        self.lblSuperDevice.text = self.superDevice.deviceName;
        
        self.btnDeleteRemote.hidden = YES;
        self.btnEditRemote.hidden = YES;
    }else{
        self.lblSn.text = self.device.deviceSn;
        self.lblDeviceType.text = @"虚拟红外";
        self.lblSuperDevice.text = self.device.parentDeviceName;
        self.textF.text = self.device.deviceName;
        
        GSHFamilyM *family = [GSHOpenSDKShare share].currentFamily;
        NSArray<GSHFloorM *> * floors = [family filterFloor];
        if (floors.count > 1) {
            self.lblRoom.text = [NSString stringWithFormat:@"%@%@",self.device.floorName ? self.device.floorName : @"",self.device.roomName ? self.device.roomName : @""];
        }else{
            self.lblRoom.text = [NSString stringWithFormat:@"%@",self.device.roomName ? self.device.roomName : @""];
        }
        
        self.btnDeleteRemote.hidden = NO;
        self.btnEditRemote.hidden = self.device.bindRemoteId.integerValue <= 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 1 || indexPath.section != 0) {
        return nil;
    }
    __weak typeof(self)weakSelf = self;
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
    }else{
        for (GSHRoomM *room in floors.firstObject.rooms) {
            [array addObject:room.roomName];
        }
    }
    
    [GSHPickerView showPickerViewWithDataArray:array completion:^(NSString *selectContent , NSArray *selectRowArray) {
        weakSelf.lblRoom.text = selectContent;
        
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
    return nil;
}

- (IBAction)touchSave:(UIButton *)sender {
    NSNumber *roomId = self.room.roomId ? self.room.roomId : self.device.roomId;
    NSString *deviceName = self.textF.text;
    
    if(deviceName.length == 0){
        [TZMProgressHUDManager showErrorWithStatus:@"请输入设备名" inView:self.view];
        return;
    }
    if ([deviceName tzm_judgeTheillegalCharacter]) {
        [TZMProgressHUDManager showErrorWithStatus:@"名字不能含特殊字符" inView:self.view];
        return;
    }
    
    if((!roomId) || roomId.integerValue == -2){
        [TZMProgressHUDManager showErrorWithStatus:@"请选择所属房间" inView:self.view];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    if (self.superDevice) {
        [TZMProgressHUDManager showWithStatus:@"保存中" inView:self.view];
        NSMutableString *remoteParam = [[NSMutableString alloc] init];
        if (self.type.devicetypeId.integerValue == 5) {
            for (NSNumber * number in [self.remote.airConditionerManager getParams]) {
                [remoteParam appendFormat:@"%02X",[number unsignedCharValue]];//获取遥控器参数
            }
        }
        [GSHInfraredControllerManager postSaveInfraredDeviceWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceSn:self.superDevice.deviceSn deviceId:self.superDevice.deviceId deviceBrand:self.brand.brandId deviceType:self.type.devicetypeId remoteId:self.remote.remoteId deviceName:deviceName roomId:roomId remoteParam:remoteParam block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager showSuccessWithStatus:@"绑定成功" inView:weakSelf.view];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
    
    if (self.device) {
        [TZMProgressHUDManager showWithStatus:@"保存中" inView:self.view];
        [GSHInfraredControllerManager postUpdateInfraredDeviceWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceSn:self.device.deviceSn bindRemoteId:self.device.bindRemoteId deviceName:deviceName roomId:self.device.roomId newRoomId:self.room.roomId block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager showSuccessWithStatus:@"修改成功" inView:weakSelf.view];
                weakSelf.device.deviceName = deviceName;
                weakSelf.device.roomId = roomId;
                weakSelf.device.roomName = weakSelf.room.roomName;
                weakSelf.device.floorId = weakSelf.floor.floorId;
                weakSelf.device.floorName = weakSelf.floor.floorName;
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

- (IBAction)touchEditRemote:(id)sender {
    if (self.device && self.device.bindRemoteId) {
        __weak typeof(self)weakSelf = self;
        [TZMProgressHUDManager showWithStatus:@"解绑中" inView:self.view];
        [GSHInfraredControllerManager postUpdateInfraredDeviceWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceSn:self.device.deviceSn deviceName:self.device.deviceName roomId:self.device.roomId newRoomId:nil block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager showSuccessWithStatus:@"解绑成功" inView:weakSelf.view];
                weakSelf.device.bindRemoteId = nil;
                weakSelf.btnEditRemote.hidden = weakSelf.device.bindRemoteId == nil;
            }
        }];
    }
}

- (IBAction)touchDeleteRemote:(id)sender {
    if (self.device) {
        __weak typeof(self)weakSelf = self;
        [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
        [GSHInfraredControllerManager postDeleteInfraredDeviceWithDeviceSn:self.device.deviceSn roomId:self.device.roomId.stringValue block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager showSuccessWithStatus:@"删除成功" inView:weakSelf.view];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

@end

