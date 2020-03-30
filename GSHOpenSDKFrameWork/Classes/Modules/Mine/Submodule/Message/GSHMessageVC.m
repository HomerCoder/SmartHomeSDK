//
//  GSHMessageVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHMessageVC.h"
#import "GSHMessageTableViewVC.h"
#import "GSHAlertManager.h"

#import "ZJScrollPageView.h"
#import "UIView+YeeBadge.h"
#import "YeeBadgeView.h"

#import "GSHMessageNotiSetVC.h"
#import "NSObject+TZM.h"

#define pageMenuH 40
#define scrollViewHeight (SCREEN_HEIGHT - KNavigationBar_Height - pageMenuH)

NSString *const GSHQueryIsHasUnReadMsgNotification = @"GSHQueryIsHasUnReadMsgNotification";

@interface GSHMessageVC () <UIScrollViewDelegate,ZJScrollPageViewDelegate>

@property(strong, nonatomic)NSArray<NSString *> *titles;
@property(strong, nonatomic)NSArray<UIViewController *> *childVcs;
@property (nonatomic, strong) ZJScrollPageView *scrollPageView;
@property (nonatomic, assign) NSInteger selectIndex;
@property(strong, nonatomic) NSMutableArray *titleViewArray;
@property(strong, nonatomic) NSMutableDictionary *subTableViewDictionary;
@property(strong, nonatomic) NSMutableIndexSet *unReadMsgIndexSet;

@end

@implementation GSHMessageVC

- (void)dealloc {
    NSLog(@"delloc");
}

- (instancetype)initWithSelectIndex:(NSInteger)selectIndex
{
    self = [super init];
    if (self) {
        self.selectIndex = selectIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    [self initNavigation];
    
    ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
    // 显示滚动条
    style.showLine = YES;
    // 颜色渐变
    style.gradualChangeTitleColor = YES;
    style.normalTitleColor = [UIColor colorWithHexString:@"#999999"];
    style.selectedTitleColor = [UIColor colorWithHexString:@"#3C4366"];
    style.titleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0];
    style.scaleTitle = YES;
    style.titleBigScale = 16 / 14.0 ;
    style.titleMargin = SCREEN_WIDTH / 7.0;
    style.scrollLineColor = [UIColor colorWithHexString:@"#3C4366"];
    style.scrollLineHeight = 3.0f;
    style.adjustTitleWhenBeginDrag = YES;
    style.segmentHeight = 40.0;
    
    self.titles = @[@"告警",@"系统",@"场景",@"联动"];
    // 初始化
    _scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KNavigationBar_Height) segmentStyle:style titles:self.titles parentViewController:self delegate:self];
    _scrollPageView.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
    _scrollPageView.segmentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_scrollPageView];
    [_scrollPageView setSelectedIndex:self.selectIndex animated:YES];
    
    [self setMsgToBeReadWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId
                             msgType:[self getMsgTypeWithSelectIndex:self.selectIndex].integerValue
                               block:^(NSError * _Nonnull error) {
    }];
    
    [self queryIsHasUnReadMsg];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfChildViewControllers {
    return self.titles.count;
}

- (UIViewController<ZJScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ZJScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index {
    UIViewController<ZJScrollPageViewChildVcDelegate> *childVc = reuseViewController;
    
    if (!childVc) {
        GSHMessageTableViewVC *vc = [[GSHMessageTableViewVC alloc] initWithMsgType:[self getMsgTypeWithSelectIndex:index]];
        childVc = vc;
    }
    self.selectIndex = index;
    NSString *indexKey = [NSString stringWithFormat:@"%zd",index];
    [self.subTableViewDictionary setObject:childVc forKey:indexKey];

    return childVc;
}

/**
 *  页面将要出现
 *
 *  @param scrollPageController
 *  @param childViewController
 *  @param index
 */
- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllWillAppear:(UIViewController *)childViewController forIndex:(NSInteger)index {
    [self showOrHiddenBadgeViewWithTypeIndex:index isShow:NO];
}

- (void)setUpTitleView:(ZJTitleView *)titleView forIndex:(NSInteger)index {
    titleView.label.redDotOffset = CGPointMake(0, 12);
    [self.titleViewArray insertObject:titleView atIndex:index];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}

#pragma mark - UI
- (void)initNavigation {
    
    self.navigationItem.title = @"消息";

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setImage:[UIImage ZHImageNamed:@"message_icon_edit"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(messageEditButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark - Lazy
- (NSMutableArray *)titleViewArray {
    if (!_titleViewArray) {
        _titleViewArray = [NSMutableArray array];
    }
    return _titleViewArray;
}

- (NSMutableDictionary *)subTableViewDictionary {
    if (!_subTableViewDictionary) {
        _subTableViewDictionary = [NSMutableDictionary dictionary];
    }
    return _subTableViewDictionary;
}

- (NSMutableIndexSet *)unReadMsgIndexSet {
    if (!_unReadMsgIndexSet) {
        _unReadMsgIndexSet = [NSMutableIndexSet indexSet];
    }
    return _unReadMsgIndexSet;
}

#pragma mark - method
- (void)messageEditButtonClick:(UIButton *)button {
    
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1) {
            // 提醒设置
            GSHMessageNotiSetVC *messageNotiSetVC = [GSHMessageNotiSetVC messageNotiSetVC];
            [self.navigationController pushViewController:messageNotiSetVC animated:YES];
        } else if (buttonIndex == 2) {
            // 清空消息
            [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                if (buttonIndex == 0) {
                    //清空消息代码
                    [self clearMsgWithMsgType:[self getMsgTypeWithSelectIndex:self.selectIndex]];
                }
            } textFieldsSetupHandler:NULL andTitle:nil andMessage:@"确认清空所有消息？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:@"清空" cancelButtonTitle:@"取消" otherButtonTitles:nil];
        }
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
        
    } andTitle:@"" andMessage:@"" image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:@"" cancelButtonTitle:@"取消" otherButtonTitles:@"提醒设置",@"清空消息",nil];

}

- (void)back {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 显示或隐藏指定类别的小红点
- (void)showOrHiddenBadgeViewWithTypeIndex:(NSInteger)typeIndex isShow:(BOOL)isShow {
    
    if (self.titleViewArray.count > typeIndex) {
        ZJTitleView *titleView = self.titleViewArray[typeIndex];
        if (isShow) {
            [titleView.label ShowBadgeView];
            [self.unReadMsgIndexSet addIndex:typeIndex];
        } else {
            [titleView.label hideBadgeView];
            if ([self.unReadMsgIndexSet containsIndex:typeIndex]) {
                @weakify(self)
                [self setMsgToBeReadWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId msgType:[self getMsgTypeWithSelectIndex:typeIndex].integerValue block:^(NSError * _Nonnull error) {
                    @strongify(self)
                    if (!error) {
                        if (self.unReadMsgIndexSet.count == 1) {
                            [self postNotification:GSHQueryIsHasUnReadMsgNotification object:nil];
                        }
                    }
                    [self.unReadMsgIndexSet removeIndex:typeIndex];
                }];
            }
        }
    }
}

- (void)changeSelectIndex:(NSInteger)selectIndex {
    self.selectIndex = selectIndex;
    [_scrollPageView setSelectedIndex:self.selectIndex animated:YES];
    NSString *indexKey = [NSString stringWithFormat:@"%d",(int)selectIndex];
    if ([self.subTableViewDictionary objectForKey:indexKey]) {
        [[self.subTableViewDictionary objectForKey:indexKey] refreshMsg];
    }
}

#pragma mark - request
// 查询是否有未读消息
- (void)queryIsHasUnReadMsg {
    
    @weakify(self)
    [GSHMessageManager queryIsHasUnReadMsgWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSArray<NSNumber *> * _Nonnull list, NSError * _Nonnull error) {
        @strongify(self)
        if (!error) {
            if (list.count > 0) {
                for (NSNumber *str in list) {
                    if ([self getSelectIndexWithMsgType:str.stringValue] != (int)self.selectIndex) {
                        [self showOrHiddenBadgeViewWithTypeIndex:[self getSelectIndexWithMsgType:str.stringValue] isShow:YES];
                    }
                }
            } else {
                [self postNotification:GSHQueryIsHasUnReadMsgNotification object:nil];
            }
        }
    }];
}

// 清空消息
- (void)clearMsgWithMsgType:(NSString *)msgType {
    [TZMProgressHUDManager showWithStatus:@"删除中" inView:self.view];
    @weakify(self)
    [GSHMessageManager deleteMsgWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId msgType:msgType.integerValue block:^(NSError * _Nonnull error) {
        @strongify(self)
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        } else {
            [TZMProgressHUDManager showSuccessWithStatus:@"删除成功" inView:self.view];
            NSString *indexKey = [NSString stringWithFormat:@"%ld",[self getSelectIndexWithMsgType:msgType]];
            if ([self.subTableViewDictionary objectForKey:indexKey]) {
                [[self.subTableViewDictionary objectForKey:indexKey] clearMsg];
            }
        }
    }];
}

// 将某一类消息置为已读
- (void)setMsgToBeReadWithFamilyId:(NSString *)familyId msgType:(NSInteger)msgType block:(void(^)(NSError * _Nonnull error))block {
    [GSHMessageManager setMsgToBeReadWithFamilyId:familyId msgType:msgType block:block];
}


- (NSString *)getMsgTypeWithSelectIndex:(NSInteger)selectIndex {
    if (selectIndex == 0) {
        return @"1";
    } else if (selectIndex == 1) {
        return @"2";
    } else if (selectIndex == 2) {
        return @"4";
    } else if (selectIndex == 3){
        return @"5";
    }
    return @"2";
}

- (NSInteger)getSelectIndexWithMsgType:(NSString *)msgType {
    if (msgType.integerValue == 1) {
        // 告警
        return 0;
    } else if (msgType.integerValue == 2) {
        // 系统
        return 1;
    } else if (msgType.integerValue == 4) {
        // 场景
        return 2;
    }  else if (msgType.integerValue == 5) {
        // 联动
        return 3;
    }
    return 0;
}


@end
