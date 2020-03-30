//
//  GSHSensorGroupEditVC.m
//  SmartHome
//
//  Created by gemdale on 2018/12/27.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHSensorGroupEditVC.h"
#import "GSHPickerView.h"
#import "NSString+TZM.h"
#import "GSHSensorGroupVC.h"

@interface GSHSensorGroupEditVC ()
@property (weak, nonatomic) IBOutlet UITextField *textF;
@property (weak, nonatomic) IBOutlet UILabel *lblRoom;
@property (weak, nonatomic) IBOutlet UILabel *lblDeviceType;
@property (weak, nonatomic) IBOutlet UILabel *lblSn;
@property (weak, nonatomic) IBOutlet UILabel *lblXieYi;
@property (weak, nonatomic) IBOutlet UILabel *lblChangJia;
- (IBAction)touchSave:(UIButton *)sender;

@property (strong,nonatomic)GSHDeviceModelM *category;
@property (nonatomic,strong)GSHSensorM *sensor;
@property(nonatomic,strong)GSHFloorM *floor;
@property(nonatomic,strong)GSHRoomM *room;

@end

@implementation GSHSensorGroupEditVC
+ (instancetype)sensorGroupEditVCWithSensor:(GSHSensorM *)sensor category:(GSHDeviceModelM*)category{
    GSHSensorGroupEditVC *vc = [GSHPageManager viewControllerWithSB:@"GSHSensorGroupSB" andID:@"GSHSensorGroupEditVC"];
    vc.sensor = sensor;
    vc.category = category;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self refreshUI];
}

-(void)refreshUI{
    self.lblSn.text = self.sensor.deviceSn;
    self.lblXieYi.text = self.sensor.agreementType;
    self.lblChangJia.text = self.sensor.manufacturer;
    if (self.sensor.deviceType.intValue == -2) {
        self.lblRoom.text = nil;
        self.lblDeviceType.text = self.category.deviceTypeStr;
        self.textF.text = nil;
    }else{
        self.lblDeviceType.text = self.sensor.deviceTypeStr;
        self.textF.text = self.sensor.deviceName;
        
        GSHFamilyM *family = [GSHOpenSDKShare share].currentFamily;
        NSArray<GSHFloorM *> * floors = [family filterFloor];
        if (floors.count > 1) {
            self.lblRoom.text = [NSString stringWithFormat:@"%@%@",self.sensor.floorName ? self.sensor.floorName : @"",self.sensor.roomName ? self.sensor.roomName : @""];
        }else{
            self.lblRoom.text = [NSString stringWithFormat:@"%@",self.sensor.roomName ? self.sensor.roomName : @""];
        }
    }
}

- (IBAction)touchSave:(UIButton *)sender {
    NSNumber *roomId = self.room.roomId ? self.room.roomId : self.sensor.roomId;
    NSNumber *deviceType = self.category.deviceType ? self.category.deviceType : self.sensor.deviceType;
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
    [TZMProgressHUDManager showWithStatus:@"绑定中" inView:self.view];
    [GSHSensorManager postSensorGroupUpdataWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.sensor.deviceId.stringValue deviceType:deviceType.stringValue roomId:roomId.stringValue deviceName:deviceName block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager showSuccessWithStatus:@"绑定成功" inView:weakSelf.view];
            weakSelf.sensor.roomId = roomId;
            weakSelf.sensor.roomName = weakSelf.room.roomName;
            weakSelf.sensor.floorName = weakSelf.floor.floorName;
            weakSelf.sensor.floorId = weakSelf.floor.floorId;
            weakSelf.sensor.deviceName = deviceName;
            weakSelf.sensor.deviceType = deviceType;
            weakSelf.sensor.deviceTypeStr = weakSelf.category.deviceTypeStr;
            
            NSMutableArray<UIViewController*> *vcs = [NSMutableArray array];
            for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
                [vcs addObject:vc];
                if ([vc isKindOfClass:GSHSensorGroupVC.class]) {
                    [weakSelf.navigationController setViewControllers:vcs animated:YES];
                    break;
                }
            }
        }
    }];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 1) {
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

@end
