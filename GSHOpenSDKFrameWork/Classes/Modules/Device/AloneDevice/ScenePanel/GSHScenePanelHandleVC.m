//
//  GSHScenePanelHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/9/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHScenePanelHandleVC.h"
#import "UINavigationController+TZM.h"
#import "GSHDeviceEditVC.h"

#import "GSHScenePanelEditVC.h"

/*
 1:02000C00400001
 2:02000C00400002
 3:02000C00400003
 4:02000C00400004
 5:02000C00400005
 6:02000C00400006
 */

@interface GSHScenePanelHandleVC () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *scenePanelTableView;

@property (nonatomic,strong) NSMutableDictionary *meteIdDic;
@property (nonatomic,strong) NSArray *buttonNameArray;
@property (nonatomic,strong) NSArray *exts;

@property (nonatomic,assign) int selectIndex;

@end

@implementation GSHScenePanelHandleVC

+ (instancetype)scenePanelHandleVCDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
   
    GSHScenePanelHandleVC *vc = [GSHPageManager viewControllerWithSB:@"GSHScenePanelHandleSB" andID:@"GSHScenePanelHandleVC"];
    vc.deviceM = deviceM;
    vc.deviceEditType = deviceEditType;
    vc.exts = deviceM.exts;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tzm_prefersNavigationBarHidden = YES;
    
    self.buttonNameArray = @[@"第一路",@"第二路",@"第三路",@"第四路",@"第五路",@"第六路"];
    
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"" : @"确定";
    NSString *buttonImageName = self.deviceEditType == GSHDeviceVCTypeControl ? @"device_set_btn" : @"";
    [self.rightNaviButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    [self.rightNaviButton setImage:[UIImage ZHImageNamed:buttonImageName] forState:UIControlStateNormal];
    self.rightNaviButton.hidden = ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    [self getDeviceDetailInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy
- (NSMutableDictionary *)meteIdDic {
    if (!_meteIdDic) {
        _meteIdDic = [NSMutableDictionary dictionary];
    }
    return _meteIdDic;
}

#pragma mark - method

- (IBAction)enterDeviceButtonClick:(id)sender {
    // 设备控制 -- 进入设备
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        [TZMProgressHUDManager showInfoWithStatus:@"离线环境无法查看" inView:self.view];
        return;
    }
    if (!self.deviceM) {
        [TZMProgressHUDManager showErrorWithStatus:@"设备数据出错" inView:self.view];
        return;
    }
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        
        GSHScenePanelEditVC *scenePanelEditVC = [GSHScenePanelEditVC scenePanelEditVCWithDeviceM:self.deviceM type:GSHScenePanelEditTypeEdit];
        scenePanelEditVC.hidesBottomBarWhenPushed = YES;
        @weakify(self)
        scenePanelEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
            @strongify(self)
            self.deviceM = deviceM;
            self.deviceNameLabel.text = self.deviceM.deviceName;
            [self.scenePanelTableView reloadData];
        };
        scenePanelEditVC.bindSceneSuccessBlock = ^(GSHOssSceneM * _Nonnull ossSceneM , int buttonIndex) {
            @strongify(self)
            for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                if (attributeM.meteIndex.intValue == buttonIndex) {
                    attributeM.scenarioName = ossSceneM.scenarioName;
                    break;
                }
            }
            [self.scenePanelTableView reloadData];
        };
        scenePanelEditVC.unbindSceneSuccessBlock = ^(int buttonIndex) {
            @strongify(self)
            for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                if (attributeM.meteIndex.intValue == buttonIndex) {
                    attributeM.scenarioName = @"";
                    break;
                }
            }
            [self.scenePanelTableView reloadData];
        };
        [self closeWithComplete:^{
            [[UIViewController visibleTopViewController].navigationController pushViewController:scenePanelEditVC animated:YES];
        }];
    } else {
        if (self.selectIndex == 0) {
            [TZMProgressHUDManager showErrorWithStatus:@"请选择一个场景开关" inView:self.view];
            return;
        }
        if (self.deviceM.attribute.count > self.selectIndex-1) {
            GSHDeviceAttributeM *attributeM = self.deviceM.attribute[self.selectIndex-1];
            NSMutableArray *exts = [NSMutableArray array];
            GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
            extM.basMeteId = attributeM.basMeteId;
            extM.conditionOperator = @"==";
            extM.rightValue = [NSString stringWithFormat:@"%d",self.selectIndex];
            [exts addObject:extM];
            
            if (self.deviceSetCompleteBlock) {
                self.deviceSetCompleteBlock(exts);
            }
            [self closeWithComplete:^{
                
            }];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.deviceM.attribute.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHScenePanelHandleCell *scenePanelHandleCell = [tableView dequeueReusableCellWithIdentifier:@"scenePanelHandleCell" forIndexPath:indexPath];
    if (self.deviceM.attribute.count > indexPath.section) {
        GSHDeviceAttributeM *attributeM = self.deviceM.attribute[indexPath.section];
        scenePanelHandleCell.bindNameLabel.text = attributeM.scenarioName.length > 0 ? attributeM.scenarioName : @"未绑定";
        scenePanelHandleCell.bindNameLabel.textColor = attributeM.scenarioName.length > 0 ? [UIColor colorWithHexString:@"#222222"] : [UIColor colorWithHexString:@"#999999"];
        scenePanelHandleCell.buttonNameLabel.text = attributeM.meteName;
        [scenePanelHandleCell setCellValueWithDeviceEditType:self.deviceEditType];
        @weakify(self)
        scenePanelHandleCell.execButtonClickBlock = ^(UIButton *button) {
            @strongify(self)
            // 执行
            [self controlScenePanelWithBasMeteId:attributeM.basMeteId value:[NSString stringWithFormat:@"%d",attributeM.meteIndex.intValue]];
        };
        if (self.exts.count > 0) {
            GSHDeviceExtM *extM = self.exts[0];
            if (indexPath.section == extM.rightValue.integerValue-1) {
                [scenePanelHandleCell layoutCellIsSelected:YES];
                self.selectIndex = extM.rightValue.intValue;
            } else {
                [scenePanelHandleCell layoutCellIsSelected:NO];
            }
        }
    }
    return scenePanelHandleCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.deviceEditType != GSHDeviceVCTypeControl) {
        for (int i = 0; i < self.deviceM.attribute.count; i ++) {
            GSHScenePanelHandleCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
            [cell layoutCellIsSelected:NO];
        }
        GSHScenePanelHandleCell *tmpCell = [tableView cellForRowAtIndexPath:indexPath];
        [tmpCell layoutCellIsSelected:YES];
        self.selectIndex = (int)indexPath.section+1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 6;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceSign:nil block:^(GSHDeviceM *device, NSError *error) {
        @strongify(self)
        if (!error) {
            self.deviceM = device;
            for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                NSString *key = [NSString stringWithFormat:@"%@%@",attributeM.meteType,attributeM.meteIndex];
                [self.meteIdDic setObject:attributeM.basMeteId forKey:key];
            }
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
            }
            self.deviceNameLabel.text = self.deviceM.deviceName;
            [self.scenePanelTableView reloadData];
        }
    }];
}

// 设备控制
- (void)controlScenePanelWithBasMeteId:(NSString *)basMeteId
                                 value:(NSString *)value {
    
    [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue
                                 deviceSN:self.deviceM.deviceSn
                                 familyId:[GSHOpenSDKShare share].currentFamily.familyId
                                basMeteId:basMeteId
                                    value:value
                                    block:^(NSError *error) {
        
    }];
}

@end

@interface GSHScenePanelHandleCell()

@property (weak, nonatomic) IBOutlet UIButton *execButton;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@property (assign, nonatomic) GSHDeviceVCType deviceEditType;

@end

@implementation GSHScenePanelHandleCell

-(void)awakeFromNib {
    [super awakeFromNib];
        
    self.checkImageView.hidden = YES;
}

- (void)setCellValueWithDeviceEditType:(GSHDeviceVCType)deviceEditType {
    self.execButton.hidden = deviceEditType == GSHDeviceVCTypeControl ? NO : YES;
    self.bindNameLabel.hidden = deviceEditType == GSHDeviceVCTypeControl ? NO : YES;
}

- (void)layoutCellIsSelected:(BOOL)isSelected {
    self.checkImageView.hidden = !isSelected;
    self.buttonNameLabel.textColor = isSelected ? [UIColor colorWithHexString:@"#2EB0FF"] : [UIColor colorWithHexString:@"#222222"];
}

- (IBAction)execButtonClick:(UIButton *)sender {
    if (self.execButtonClickBlock) {
        self.execButtonClickBlock(sender);
    }
}




@end
