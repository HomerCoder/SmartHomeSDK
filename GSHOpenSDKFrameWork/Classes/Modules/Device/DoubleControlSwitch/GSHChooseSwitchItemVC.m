//
//  GSHChooseSwitchItemVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHChooseSwitchItemVC.h"
#import "GSHDeviceRelevanceVC.h"

@interface GSHChooseSwitchItemVC () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) GSHDeviceAttributeM *choosedAttributeM;
@property (strong, nonatomic) GSHSwitchBindM *switchBindM;
@property (strong, nonatomic) GSHDeviceM *deviceM;
@property (strong, nonatomic) GSHSwitchMeteBindInfoModelM *switchMeteBindInfoModelM;

@end

@implementation GSHChooseSwitchItemVC

+ (instancetype)chooseSwitchItemVCWithDeviceM:(GSHDeviceM *)deviceM switchBindM:(GSHSwitchBindM *)switchBindM switchMeteBindInfoModelM:(GSHSwitchMeteBindInfoModelM *)switchMeteBindInfoModelM {
    GSHChooseSwitchItemVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoubleControlSwitchSB" andID:@"GSHChooseSwitchItemVC"];
    vc.deviceM = deviceM;
    vc.switchBindM = switchBindM;
    vc.switchMeteBindInfoModelM = switchMeteBindInfoModelM;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self alertSwitchAttribute];
}

#pragma mark - method
- (IBAction)sureButtonClick:(UIButton *)button {
    if (!self.choosedAttributeM) {
        [TZMProgressHUDManager showErrorWithStatus:@"请选择要绑定的那一路开关" inView:self.view];
        return;
    }
    [TZMProgressHUDManager showWithStatus:@"绑定中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHDeviceManager bindMultiControlWithDeviceId:self.switchBindM.deviceId
                                    deviceSn:self.switchBindM.deviceSn
                                   basMeteId:self.switchMeteBindInfoModelM.basMeteId
                                 relDeviceId:self.deviceM.deviceId.stringValue
                                 relDeviceSn:self.deviceM.deviceSn
                                relBasMeteId:self.choosedAttributeM.basMeteId
                                       block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"绑定成功" inView:weakSelf.view];
            if (weakSelf.bindSuccessBlock) {
                weakSelf.bindSuccessBlock();
            }
            for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
                if ([vc isKindOfClass:[GSHDeviceRelevanceVC class]]) {
                    [weakSelf.navigationController popToViewController:vc animated:YES];
                }
            }
        }
    }];
}

// 过滤已经关联的属性
- (void)alertSwitchAttribute {
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (GSHDeviceAttributeM *tmpAttributeM in self.deviceM.attribute) {
        for (GSHSwitchMeteBindInfoModelM *tmpMeteBindInfoModelM in self.switchBindM.switchMeteBindInfoModels) {
            for (GSHMeteBindedInfoListM *infoListM in tmpMeteBindInfoModelM.meteBindedInfoList) {
                if ([infoListM.deviceSn isEqualToString:self.deviceM.deviceSn] &&
                    [tmpAttributeM.basMeteId isEqualToString:infoListM.basMeteId]) {
                    [tmpArray addObject:tmpAttributeM];
                }
            }
        }
    }
    [self.deviceM.attribute removeObjectsInArray:tmpArray];
}


#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.deviceM.attribute.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseSwitchItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHChooseSwitchItemCell" forIndexPath:indexPath];
    if (self.deviceM.attribute.count > indexPath.row) {
        GSHDeviceAttributeM *attributeM = self.deviceM.attribute[indexPath.row];
        cell.switchItemNameLabel.text = attributeM.meteName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseSwitchItemCell *cell = (GSHChooseSwitchItemCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.checkImageView.hidden = NO;
    GSHDeviceAttributeM *attributeM = self.deviceM.attribute[indexPath.row];
    self.choosedAttributeM = attributeM;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseSwitchItemCell *cell = (GSHChooseSwitchItemCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.checkImageView.hidden = YES;
}

@end


@implementation GSHChooseSwitchItemCell



@end
