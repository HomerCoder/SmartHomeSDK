//
//  GSHAutoAddActionVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutoAddActionVC.h"
#import "GSHAutoAddActionSceneVC.h" // 执行场景
#import "GSHAutoAddAutoVC.h"    // 执行联动
#import "GSHChooseDeviceVC.h"

@interface GSHAutoAddActionVC ()

@end

@implementation GSHAutoAddActionVC

+ (instancetype)autoAddActionVC {
    GSHAutoAddActionVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddAutoAction" andID:@"GSHAutoAddActionVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            // 执行场景
            GSHAutoAddActionSceneVC *sceneVC = [GSHAutoAddActionSceneVC autoAddActionSceneVC];
            sceneVC.choosedActionArray = self.choosedActionArray;
            @weakify(self)
            sceneVC.chooseSceneBlock = ^(NSArray *choosedArray , NSArray *noChoosedArray) {
                @strongify(self)
                if (self.chooseSceneBlock) {
                    self.chooseSceneBlock(choosedArray , noChoosedArray);
                }
            };
            [self.navigationController pushViewController:sceneVC animated:YES];
            break;
        }
//        case 1: {
//            // 执行联动
//            GSHAutoAddAutoVC *autoAddAutoVC = [GSHAutoAddAutoVC autoAddAutoVC];
//            autoAddAutoVC.currentAutoId = self.currentAutoId;
//            autoAddAutoVC.choosedActionArray = self.choosedActionArray;
//            @weakify(self)
//            autoAddAutoVC.chooseAutoBlock = ^(NSArray *choosedArray, NSArray *noChoosedArray) {
//                @strongify(self)
//                if (self.chooseAutoBlock) {
//                    self.chooseAutoBlock(choosedArray , noChoosedArray);
//                }
//            };
//            [self.navigationController pushViewController:autoAddAutoVC animated:YES];
//            break;
//        }
        case 1: {
            // 执行设备动作
            NSMutableArray *deviceArray = [NSMutableArray array];
            for (GSHAutoActionListM *autoActionListM in self.choosedActionArray) {
                if (autoActionListM.device) {
                    [deviceArray addObject:autoActionListM.device];
                }
            }
            GSHChooseDeviceVC *chooseDeviceVC = [[GSHChooseDeviceVC alloc] initWithSelectDeviceArray:deviceArray];
            chooseDeviceVC.fromFlag = ChooseDeviceFromAddAutoAddAction;
            @weakify(self)
            chooseDeviceVC.selectDeviceBlock = ^(NSArray *selectedDeviceArray) {
                @strongify(self)
                if (self.chooseDeviceBlock) {
                    self.chooseDeviceBlock(selectedDeviceArray);
                }
            };
            [self.navigationController pushViewController:chooseDeviceVC animated:YES];
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
