//
//  GSHChooseSceneListVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/10.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHChooseSceneListVC.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "UIView+TZMPageStatusViewEx.h"

@interface GSHChooseSceneListVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) NSMutableArray *sourceArray;
@property (nonatomic , strong) GSHOssSceneM *selectOssSceneM;
@property (nonatomic , strong) GSHDeviceM *scenePanelDeviceM;
@property (nonatomic , assign) int indexValue;
@property (nonatomic , strong) NSString *basMeteId;
@property (strong, nonatomic) IBOutlet UITableView *sceneTableView;

@end

@implementation GSHChooseSceneListVC

+ (instancetype)chooseSceneListVCWithDeviceM:(GSHDeviceM *)deviceM indexValue:(int)indexValue basMeteId:(NSString *)basMeteId {
    GSHChooseSceneListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHChooseSceneListSB" andID:@"GSHChooseSceneListVC"];
    vc.indexValue = indexValue;
    vc.scenePanelDeviceM = deviceM;
    vc.basMeteId = basMeteId;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 请求场景列表
    [self getSceneList];
}

#pragma mark - Lazy
- (NSMutableArray *)sourceArray {
    if (!_sourceArray) {
        _sourceArray = [NSMutableArray array];
    }
    return _sourceArray;
}

#pragma mark - request

// 请求场景列表
- (void)getSceneList {
    [TZMProgressHUDManager showWithStatus:@"场景获取中" inView:self.view];
    @weakify(self)
    [GSHSceneManager getSceneListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId currPage:nil block:^(GSHSceneListM *sceneListM,NSError *error) {
        @strongify(self)
        [TZMProgressHUDManager dismissInView:self.view];
        if (error) {
            [self.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [self getSceneList];
            }];
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [self dismissPageStatusView];
            if (self.sourceArray.count > 0) {
                [self.sourceArray removeAllObjects];
            }
            [self.sourceArray addObjectsFromArray:sceneListM.scenarios];

            [self.sceneTableView reloadData];
            if (self.sourceArray.count == 0) {
                [self showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_homescene"] title:@"暂无场景" desc:nil buttonText:nil didClickButtonCallback:nil];
            }
        }
    }];
}

- (void)showBlankView {
    
    @weakify(self)
    [self showPageStatus:TZMPageStatusNormal
                   image:[UIImage ZHImageNamed:@"blankpage_icon_homescene"]
                   title:@"还未添加场景"
                    desc:@""
              buttonText:@"刷新"
  didClickButtonCallback:^(TZMPageStatus status) {
      @strongify(self)
      [self getSceneList];
  }];
}

// 确定
- (IBAction)sureButtonClick:(id)sender {
    if (!self.selectOssSceneM) {
        [TZMProgressHUDManager showErrorWithStatus:@"未选择场景" inView:self.view];
        return;
    }
    GSHAutoActionListM *actionListM = [[GSHAutoActionListM alloc] init];
    actionListM.scenarioId = self.selectOssSceneM.scenarioId;
    actionListM.scenarioName = self.selectOssSceneM.scenarioName;
    actionListM.businessId = self.selectOssSceneM.businessId;
    
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = self.basMeteId;
    extM.rightValue = [NSString stringWithFormat:@"%d",self.indexValue];
    extM.conditionOperator = @"==";
    
    GSHDeviceM *deviceM = [[GSHDeviceM alloc] init];
    deviceM.deviceSn = self.scenePanelDeviceM.deviceSn;
    deviceM.deviceId = self.scenePanelDeviceM.deviceId;
    deviceM.deviceType = self.scenePanelDeviceM.deviceType;
    deviceM.deviceModel = self.scenePanelDeviceM.deviceModel;
    deviceM.deviceName = self.scenePanelDeviceM.deviceName;
    
    GSHAutoTriggerConditionListM *conditionListM = [[GSHAutoTriggerConditionListM alloc] init];
    conditionListM.week = 0;
    conditionListM.device = deviceM;
    [conditionListM.device.exts addObject:extM];
    
    GSHAutoTriggerM *triggerM = [[GSHAutoTriggerM alloc] init];
    triggerM.relationType = @(0);
    triggerM.name = @"联动条件";
    [triggerM.conditionList addObject:conditionListM];
    
    GSHAutoM *setAutoM = [[GSHAutoM alloc] init];
    setAutoM.week = 127;
    setAutoM.startTime = @(0);
    setAutoM.endTime = @(0);
    setAutoM.status = @(1);
    setAutoM.type = @(0);
    setAutoM.familyId = [GSHOpenSDKShare share].currentFamily.familyId.numberValue;
    [setAutoM.actionList addObject:actionListM];
    setAutoM.trigger = triggerM;
    
    GSHOssAutoM *ossAutoM = [[GSHOssAutoM alloc] init];
    ossAutoM.familyId = [GSHOpenSDKShare share].currentFamily.familyId.numberValue;
    ossAutoM.name = setAutoM.automationName;
    ossAutoM.type = setAutoM.type;
    ossAutoM.status = setAutoM.status;
    ossAutoM.md5 = [[setAutoM yy_modelToJSONString] md5String];
    ossAutoM.relationType = setAutoM.trigger.relationType;
    
    @weakify(self)
    [TZMProgressHUDManager showWithStatus:@"绑定中" inView:self.view];
    [GSHAutoManager bindSceneWithOssAutoM:ossAutoM
                                    autoM:setAutoM
                                 deviceId:self.scenePanelDeviceM.deviceId.stringValue
                                basMeteId:self.basMeteId
                               scenarioId:self.selectOssSceneM.scenarioId.stringValue
                                    block:^(NSString *ruleId, NSError *error) {
                                        @strongify(self)
                                        if (error) {
                                            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
                                        } else {
                                            [TZMProgressHUDManager showSuccessWithStatus:@"绑定成功" inView:self.view];
                                            if (self.bindSceneSuccessBlock) {
                                                self.bindSceneSuccessBlock(self.selectOssSceneM);
                                            }
                                            [self.navigationController popViewControllerAnimated:YES];
                                        }
                                    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSHChooseSceneListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSHChooseSceneListCell" forIndexPath:indexPath];
    if (self.sourceArray.count > indexPath.row) {
        GSHOssSceneM *ossSceneM = self.sourceArray[indexPath.row];
        cell.sceneNameLabel.text = ossSceneM.scenarioName;
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseSceneListCell *cell = (GSHChooseSceneListCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.checkButton.selected = YES;
    cell.sceneNameLabel.textColor = [UIColor colorWithHexString:@"#2EB0FF"];
    GSHOssSceneM *ossSceneM = self.sourceArray[indexPath.row];
    self.selectOssSceneM = ossSceneM;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseSceneListCell *cell = (GSHChooseSceneListCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.checkButton.selected = NO;
    cell.sceneNameLabel.textColor = [UIColor colorWithHexString:@"#222222"];
}

@end

@implementation GSHChooseSceneListCell



@end
