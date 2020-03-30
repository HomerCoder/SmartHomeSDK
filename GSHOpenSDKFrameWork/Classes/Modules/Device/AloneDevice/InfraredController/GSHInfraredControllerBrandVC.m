//
//  GSHInfraredControllerBrandVC.m
//  SmartHome
//
//  Created by gemdale on 2019/2/22.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHInfraredControllerBrandVC.h"
#import "MJNIndexView.h"
#import "UIView+TZMPageStatusViewEx.h"
#import "GSHInfraredControllerVerifyVC.h"
#import "NSObject+TZM.h"

@interface GSHInfraredControllerBrandVCCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (strong,nonatomic)GSHKuKongBrandM *model;
@end

@implementation GSHInfraredControllerBrandVCCell
-(void)setModel:(GSHKuKongBrandM *)model{
    _model = model;
    self.lblName.text = model.name;
}
@end

@interface GSHInfraredControllerBrandVC ()<UITableViewDataSource,UITableViewDelegate,MJNIndexViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (nonatomic, strong) MJNIndexView *indexView;
@property (strong,nonatomic)GSHKuKongDeviceTypeM *type;
@property (strong,nonatomic)NSMutableArray<GSHKuKongBrandListM*> *dataList;
@property (strong,nonatomic)NSMutableArray<GSHKuKongBrandListM*> *searchList;
@property (strong,nonatomic)NSMutableArray *index;
@property (strong,nonatomic)NSMutableArray *searchindex;
@property (assign,nonatomic)BOOL isSearch;
@property(nonatomic,strong)GSHDeviceM *device;
@end

@implementation GSHInfraredControllerBrandVC
+(instancetype)infraredControllerBrandVCWithType:(GSHKuKongDeviceTypeM*)type device:(GSHDeviceM*)device{
    GSHInfraredControllerBrandVC *vc = [GSHPageManager viewControllerWithSB:@"GSHInfraredControllerSB" andID:@"GSHInfraredControllerBrandVC"];
    vc.device = device;
    vc.type = type;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加入索引
    self.indexView = [[MJNIndexView alloc]initWithFrame:self.tableView.frame];
    self.indexView.dataSource = self;
    [self firstAttributesForMJNIndexView];
    [self.view addSubview:self.indexView];
    
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [GSHInfraredControllerManager getKuKongBrandListWithDeviceType:self.type.devicetypeId block:^(NSMutableArray<GSHKuKongBrandListM *> *list, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            for (int i = (int)list.count; i > 0; i--) {
                GSHKuKongBrandListM *m = list[i - 1];
                if (m.dataList.count == 0) {
                    [list removeObject:m];
                }
            }
            weakSelf.dataList = list;
            weakSelf.index = [NSMutableArray array];
            for (GSHKuKongBrandListM *m in list) {
                [weakSelf.index addObject:m.pyCh];
            }
            [weakSelf.tableView reloadData];
            [weakSelf.indexView refreshIndexItems];
        }
    }];
    
    [self observerNotifications];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.indexView.frame = self.tableView.frame;
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:UITextFieldTextDidChangeNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:UITextFieldTextDidChangeNotification]) {
        if (notification.object == self.tfSearch){
            [self searchText:self.tfSearch.text];
        }
    }
}

- (void)searchText:(NSString*)text{
    self.isSearch = text.length > 0;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name like '*%@*'",text]];
    self.searchList = [NSMutableArray array];
    self.searchindex = [NSMutableArray array];
    for (GSHKuKongBrandListM *m in self.dataList) {
        GSHKuKongBrandListM *seach = [GSHKuKongBrandListM new];
        seach.pyCh = m.pyCh;
        seach.dataList = [m.dataList filteredArrayUsingPredicate:predicate];
        if (seach.dataList.count > 0) {
            [self.searchList addObject:seach];
            [self.searchindex addObject:m.pyCh];
        }
    }
    [self.tableView reloadData];
    [self.indexView refreshIndexItems];
    if (self.isSearch && self.searchList.count == 0) {
        [self.tableView showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_search"] title:@"暂无搜索结果" desc:nil buttonText:nil didClickButtonCallback:NULL];
    }else{
        [self.tableView dismissPageStatusView];
    }
}

- (void)firstAttributesForMJNIndexView{
    self.indexView.getSelectedItemsAfterPanGestureIsFinished = NO;
    self.indexView.font = [UIFont boldSystemFontOfSize:14.0];
    self.indexView.selectedItemFont = [UIFont boldSystemFontOfSize:20.0];
    self.indexView.backgroundColor = [UIColor clearColor];
    
    self.indexView.curtainColor = nil;
    self.indexView.curtainFade = 0.0;
    self.indexView.curtainStays = NO;
    self.indexView.curtainMoves = NO;
    self.indexView.curtainMargins = NO;
    
    self.indexView.ergonomicHeight = NO;
    self.indexView.rangeOfDeflection = 5;
    
    self.indexView.upperMargin = 50.0;
    self.indexView.lowerMargin = 50.0;
    self.indexView.rightMargin = 5;
    
    self.indexView.itemsAligment = NSTextAlignmentCenter;
    self.indexView.maxItemDeflection = 0;
    self.indexView.fontColor = [UIColor colorWithRGB:0x585858];
    self.indexView.selectedItemFontColor = [UIColor colorWithRGB:0x2EB0FF];
    self.indexView.darkening = NO;
    self.indexView.fading = NO;
}

#pragma mark MJMIndexForTableView datasource methods
- (NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView{
    if (self.isSearch) {
        return self.searchindex;
    }
    return self.index;
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    if (self.isSearch) {
        if (index < self.searchList.count && self.searchList[index].dataList.count > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index] atScrollPosition: UITableViewScrollPositionTop animated:NO];
            return;
        }
    }else{
        if (index < self.dataList.count && self.dataList[index].dataList.count > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index] atScrollPosition: UITableViewScrollPositionTop animated:NO];
            return;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.isSearch) {
        return self.searchList.count;
    } else {
        return self.dataList.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearch) {
        if (section < self.searchList.count) {
            return self.searchList[section].dataList.count;
        }
    } else {
        if (section < self.dataList.count) {
            return self.dataList[section].dataList.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHInfraredControllerBrandVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.isSearch) {
        if (indexPath.section < self.searchList.count && indexPath.row < self.searchList[indexPath.section].dataList.count) {
            cell.model = self.searchList[indexPath.section].dataList[indexPath.row];
        }
    } else {
        if (indexPath.section < self.dataList.count && indexPath.row < self.dataList[indexPath.section].dataList.count) {
            cell.model = self.dataList[indexPath.section].dataList[indexPath.row];
        }
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    view.backgroundColor = [UIColor colorWithRGB:0xf6f7fa];
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(25, 5, tableView.frame.size.width - 50, 20)];
    lable.font = [UIFont systemFontOfSize:14];
    lable.textColor = [UIColor colorWithRGB:0x585858];
    [view addSubview:lable];
    if (self.isSearch) {
        if (section < self.searchList.count) {
            lable.text = self.searchList[section].pyCh;
        }
    } else {
        if (section < self.dataList.count) {
            lable.text = self.dataList[section].pyCh;
        }
    }
    return view;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHKuKongBrandM *model;
    if (self.isSearch) {
        if (indexPath.section < self.searchList.count && indexPath.row < self.searchList[indexPath.section].dataList.count) {
            model = self.searchList[indexPath.section].dataList[indexPath.row];
        }
    } else {
        if (indexPath.section < self.dataList.count && indexPath.row < self.dataList[indexPath.section].dataList.count) {
            model = self.dataList[indexPath.section].dataList[indexPath.row];
        }
    }
    if (model) {
        GSHInfraredControllerVerifyVC *vc = [GSHInfraredControllerVerifyVC infraredControllerVerifyVCWithType:self.type brand:model device:self.device];
        [self.navigationController pushViewController:vc animated:YES];
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

@end
