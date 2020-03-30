//
//  GSHVoiceExampleVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/7/2.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHVoiceExampleVC.h"
#import "UIView+TZM.h"
#import "UINavigationController+TZM.h"

@interface GSHVoiceExampleVC () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIScrollView *exampleScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) NSMutableArray *exampleArray;

@end

@implementation GSHVoiceExampleVC

+ (instancetype)voiceExampleVC {
    GSHVoiceExampleVC *vc = [GSHPageManager viewControllerWithSB:@"GSHVoiceSB" andID:@"GSHVoiceExampleVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [UIScreen mainScreen].bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithHexString:@"#2D50C5"].CGColor,
                       (id)[UIColor colorWithHexString:@"#0D82C9"].CGColor,
                       (id)[UIColor colorWithHexString:@"#04B5C1"].CGColor, nil];
    [self.backView.layer addSublayer:gradient];
    
    [self layoutScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy
- (NSMutableArray *)exampleArray {
    if (!_exampleArray) {
        _exampleArray = [NSMutableArray array];
        for (int i = 0; i < 10; i ++) {
            NSString *str = [NSString stringWithFormat:@"空调设置开启%d",i];
            [_exampleArray addObject:str];
        }
    }
    return _exampleArray;
}

#pragma mark - UI

- (void)layoutScrollView {
    int a = (int)(self.exampleArray.count % 9) == 0 ? (int)(self.exampleArray.count / 9) : (int)(self.exampleArray.count / 9) + 1;
    
    self.exampleScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * a, self.exampleScrollView.height);
    self.exampleScrollView.showsHorizontalScrollIndicator = NO;
    self.exampleScrollView.pagingEnabled = YES;
    self.exampleScrollView.delegate = self;
    CGFloat labelHeight = self.exampleScrollView.height / 9.0;
    for (int i = 0; i < self.exampleArray.count; i ++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * (i / 9), labelHeight * (i % 9), SCREEN_WIDTH, labelHeight)];
        label.text = self.exampleArray[i];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:18.0];
        label.textAlignment = NSTextAlignmentCenter;
        [self.exampleScrollView addSubview:label];
    }
    
    self.pageControl.numberOfPages = a;
    self.pageControl.currentPage = self.exampleScrollView.contentOffset.x / SCREEN_WIDTH;
    [self.pageControl addTarget:self action:@selector(pageControlClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = scrollView.contentOffset.x / SCREEN_WIDTH;
}

#pragma mark - method
- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pageControlClick:(UIPageControl *)pageControl {
    [self.exampleScrollView setContentOffset:CGPointMake(pageControl.currentPage * SCREEN_WIDTH, 0) animated:YES];
}


@end
