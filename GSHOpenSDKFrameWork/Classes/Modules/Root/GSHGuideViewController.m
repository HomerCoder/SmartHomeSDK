//
//  GSHGuideViewController.m
//  SmartHome
//
//  Created by zhanghong on 2019/12/18.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHGuideViewController.h"
#import "GSHLoginVC.h"
#import "GSHAppDelegate.h"
#import "XHPageControl.h"
#import "GSHBlueRoundButton.h"

@interface GSHGuideViewController () <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    GSHBlueRoundButton *_enterBtn;
    NSArray *_picArr;
    NSArray *_titleArr;
    NSArray *_desArr;
    UILabel *_countLabel;
    NSInteger _currentIndex;
    int _countTimer;
    BOOL _isScrolled;
}

@property (nonatomic, strong) NSTimer *timer;
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@property(nonatomic,strong) XHPageControl *pageControl;

@end

@implementation GSHGuideViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _picArr = @[@"guide_00",@"guide_01",@"guide_02",@"guide_03",@"guide_04"];
        _titleArr = @[@"全新3.0",@"首页",@"玩转",@"家庭指数",@"联动"];
        _desArr = @[@"让科技有温度一点",@"你的家庭,尽在掌握",@"这样的家,想怎么玩就怎么玩",@"有温度,也要更懂你",@"科幻中的场景,我也可以"];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    [self layoutUI];

}

- (void)layoutUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.guideScrollView];
    for (int i = 0; i < _picArr.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 220)];
        imageView.backgroundColor = [UIColor colorWithHexString:@"#F3F5FB"];
        imageView.image = [UIImage ZHImageNamed:_picArr[i]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.guideScrollView addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, CGRectGetMaxY(imageView.frame)+30, SCREEN_WIDTH, 38)];
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:26.0];
        titleLabel.textColor = [UIColor colorWithHexString:@"#3C4366"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = _titleArr[i];
        [self.guideScrollView addSubview:titleLabel];
        
        UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, CGRectGetMaxY(titleLabel.frame)+14, SCREEN_WIDTH, 25)];
        desLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0];
        desLabel.textColor = [UIColor colorWithHexString:@"#3C4366"];
        desLabel.textAlignment = NSTextAlignmentCenter;
        desLabel.text = _desArr[i];
        [self.guideScrollView addSubview:desLabel];
        
        if (i == _picArr.count - 1) {
            self.enterButton.frame = CGRectMake(i * SCREEN_WIDTH + (SCREEN_WIDTH-120)/2.0, SCREEN_HEIGHT - 90, 120, 40);
            self.enterButton.layer.cornerRadius = 20.0f;
            self.enterButton.backgroundColor = [UIColor colorWithHexString:@"#2EB0FF"];
            [self.enterButton setTitle:@"立即体验" forState:UIControlStateNormal];
            self.enterButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
            [self.guideScrollView addSubview:self.enterButton];
        }
    }
    
    self.pageControl = [[XHPageControl alloc] init];
    self.pageControl.frame=CGRectMake(0, SCREEN_HEIGHT - 80,SCREEN_WIDTH, 20);
    self.pageControl.currentColor = [UIColor colorWithHexString:@"#2EB0FF"];
    self.pageControl.numberOfPages = _picArr.count;
    [self.view addSubview:self.pageControl];
    
}

#pragma mark - Lazy
- (UIScrollView *)guideScrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _scrollView.contentSize = CGSizeMake(_picArr.count * SCREEN_WIDTH, SCREEN_HEIGHT);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIButton *)enterButton {
    if (!_enterBtn) {
        _enterBtn = [[GSHBlueRoundButton alloc] init];
        [_enterBtn addTarget:self action:@selector(enterApplication:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterBtn;
}

- (void)enterApplication:(UIButton *)btn {
    GSHLoginVC *loginVC = [GSHLoginVC loginVC];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    nav.navigationBar.translucent = NO;
    [(GSHAppDelegate*)[UIApplication sharedApplication].delegate changeRootController:nav animate:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"isShowGuideVC"];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger currentPage = targetContentOffset->x / SCREEN_WIDTH;
    self.pageControl.currentPage = currentPage;
    if (currentPage == _picArr.count-1) {
        self.pageControl.hidden = YES;
    } else {
        self.pageControl.hidden = NO;
    }
}



@end
