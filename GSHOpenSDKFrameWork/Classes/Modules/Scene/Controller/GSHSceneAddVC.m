//
//  GSHSceneAddVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/11/5.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHSceneAddVC.h"
#import "GSHSceneCustomVC.h"

@implementation GSHSceneAddCell

- (IBAction)activeButtonClick:(id)sender {
    if (self.activeButtonClickBlock) {
        self.activeButtonClickBlock();
    }
}

@end


@interface GSHSceneAddVC ()

@property (weak, nonatomic) IBOutlet UIView *tableHeadView;

@property (nonatomic , strong) NSMutableArray *sceneTemplateArray;
@property (nonatomic , strong) NSNumber *lastRank;

@end

@implementation GSHSceneAddVC

+ (instancetype)sceneAddVCWithLastRank:(NSNumber *)lastRank {
    GSHSceneAddVC *vc = [GSHPageManager viewControllerWithSB:@"GSHSceneSB" andID:@"GSHSceneAddVC"];
    vc.lastRank = lastRank;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = self.tableHeadView.frame;
    frame.size.height = SCREEN_WIDTH * (158 / 375.0);
    self.tableHeadView.frame = frame;
    [self.tableView setTableHeaderView:self.tableHeadView];
    
    self.sceneTemplateArray = [NSMutableArray array];
    // 获取场景模版列表
    [self getSceneTemplateList];
        
}

#pragma mark - method
// 创建自定义场景 -- 添加场景
- (IBAction)customClick:(id)sender {
    
    GSHSceneCustomVC *customVC = [GSHSceneCustomVC sceneCustomVCWithSceneM:nil
                                                                sceneListM:nil
                                                                  lastRank:nil
                                                                templateId:nil
                                                           sceneCustomType:SceneCustomTypeAdd];
    customVC.saveSceneBlock = self.saveSceneBlock;
    [self.navigationController pushViewController:customVC animated:YES];
    
}

// 激活按钮点击
- (void)activeButtonClickWithTemplateId:(NSNumber *)templateId {
    GSHSceneCustomVC *sceneCustomVC = [GSHSceneCustomVC sceneCustomVCWithSceneM:nil sceneListM:nil lastRank:@(0) templateId:templateId sceneCustomType:SceneCustomTypeTemplate];
    sceneCustomVC.hidesBottomBarWhenPushed = YES;
    sceneCustomVC.saveSceneBlock = self.saveSceneBlock;
    [self.navigationController pushViewController:sceneCustomVC animated:YES];
}

#pragma mark - request
// 获取场景模版列表
- (void)getSceneTemplateList {
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    @weakify(self)
    [GSHSceneManager getSceneTemplateListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId isOnlyRecommend:@"0" block:^(NSArray<GSHSceneTemplateM *> *list, NSError *error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager dismissInView:self.view];
            if (self.sceneTemplateArray.count > 0) {
                [self.sceneTemplateArray removeAllObjects];
            }
            [self.sceneTemplateArray addObjectsFromArray:list];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sceneTemplateArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHSceneAddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sceneAddCell" forIndexPath:indexPath];
    if (self.sceneTemplateArray.count > indexPath.row) {
        GSHSceneTemplateM *sceneTemplateM = self.sceneTemplateArray[indexPath.row];
        [cell.templateImageView sd_setImageWithURL:[NSURL URLWithString:sceneTemplateM.imgUrl] placeholderImage:DeviceIconPlaceHoldImage];
        cell.templateNameLabel.text = sceneTemplateM.name;
        cell.templateDesLabel.text = sceneTemplateM.descriptionStr;
        @weakify(self)
        cell.activeButtonClickBlock = ^{
            @strongify(self)
            // 激活按钮点击
            [self activeButtonClickWithTemplateId:sceneTemplateM.sceneTemplateId];
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 37.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 37)];
     
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, 200, 25)];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18.0];
    label.text = @"场景模板";
    [view addSubview:label];
    
    return view;
}



@end
