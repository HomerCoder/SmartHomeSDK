//
//  GSHAutoAddVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/11/12.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAutoAddVC.h"
#import "GSHAutoCreateVC.h"
#import "GSHAutoErrorCell.h"

@implementation GSHAutoAddCell

@end

@interface GSHAutoAddVC ()

@property (nonatomic,strong) NSMutableArray *autoTemplateArray;
@property (strong,nonatomic) NSError *autoTemplateError;
@property (weak, nonatomic) IBOutlet UIView *tableHeadView;

@end

@implementation GSHAutoAddVC

+ (instancetype)autoAddVC {
    GSHAutoAddVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddAutomationSB" andID:@"GSHAutoAddVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = self.tableHeadView.frame;
    frame.size.height = SCREEN_WIDTH * (158 / 375.0);
    self.tableHeadView.frame = frame;
    [self.tableView setTableHeaderView:self.tableHeadView];
    
    self.autoTemplateArray = [NSMutableArray array];
    
    [self getAutoTemplateListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId];
    [self.tableView registerNib:[UINib nibWithNibName:@"GSHAutoErrorCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"autoErrorCell"];
    
    @weakify(self)
    self.tableView.mj_header = [GSHPullDownHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self getAutoTemplateListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId];
    }];
}

#pragma mark - method

- (IBAction)addAutoButtonClick:(id)sender {
    GSHAutoCreateVC *vc = [GSHAutoCreateVC autoCreateVCWithAutoVCType:AddAutoVCTypeAdd oldAutoM:nil oldOssAutoM:nil];
    vc.hidesBottomBarWhenPushed = YES;
    vc.addAutoSuccessBlock = self.addAutoSuccessBlock;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - request
// 获取联动模版列表
- (void)getAutoTemplateListWithFamilyId:(NSString *)familyId {
    @weakify(self)
    self.autoTemplateError = nil;
    [TZMProgressHUDManager showWithStatus:@"获取联动模版列表中" inView:self.view];
    [GSHAutoManager getAutoTemplateListWithFamilyId:familyId isOnlyRecommend:@"0" block:^(NSArray<GSHAutoM *> *autoTemplateList, NSError *error) {
        @strongify(self)
        [TZMProgressHUDManager dismissInView:self.view];
        [self.tableView.mj_header endRefreshing];
        if (error) {
            self.autoTemplateError = error;
        } else {
            if (self.autoTemplateArray.count > 0) {
                [self.autoTemplateArray removeAllObjects];
            }
            [self.autoTemplateArray addObjectsFromArray:autoTemplateList];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.autoTemplateError) {
        // 模版列表请求出错
        return 1;
    }
    return self.autoTemplateArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.autoTemplateError) {
        // 模版列表请求出错
        return 300.0f;
    }
    return (SCREEN_WIDTH - 32) * (100 / 343.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.autoTemplateError) {
        // 模版列表请求出错
        GSHAutoErrorCell *errorCell = [tableView dequeueReusableCellWithIdentifier:@"autoErrorCell" forIndexPath:indexPath];
        @weakify(self)
        errorCell.refreshButtonClickBlock = ^{
            // 请求模版列表
            @strongify(self)
            [self getAutoTemplateListWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId];
        };
        return errorCell;
    } else {
        GSHAutoAddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"autoAddCell" forIndexPath:indexPath];
        if (self.autoTemplateArray.count > indexPath.section) {
            GSHAutoM *autoM = self.autoTemplateArray[indexPath.section];
            [cell.templateImageView sd_setImageWithURL:[NSURL URLWithString:autoM.picPath]];
        }
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.autoTemplateError) {
        return;
    }
    if (self.autoTemplateArray.count > indexPath.section) {
        GSHAutoM *autoM = self.autoTemplateArray[indexPath.section];
        GSHAutoCreateVC *autoCreateVC = [GSHAutoCreateVC autoCreateVCWithAutoVCType:AddAutoVCTypeTemplate oldAutoM:autoM oldOssAutoM:nil];
        autoCreateVC.addAutoSuccessBlock = self.addAutoSuccessBlock;
        [self.navigationController pushViewController:autoCreateVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 45.0f;
    }
    return 8.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
         
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, 200, 25)];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18.0];
        label.text = @"推荐联动";
        [view addSubview:label];
        return view;
    } else {
        return [[UIView alloc] init];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}


@end
