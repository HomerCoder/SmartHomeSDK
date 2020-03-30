//
//  GSHPushPopoverController.m
//  SmartHome
//
//  Created by gemdale on 2018/12/14.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHPushPopoverController.h"

@interface GSHPushPopoverController ()
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcTop;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (assign,nonatomic)BOOL closing;

@property (strong, nonatomic) NSString *lblContentStr;
@property (strong, nonatomic) NSString *lblTitleStr;
@end

@implementation GSHPushPopoverController

+(NSMutableArray<GSHPushPopoverController*>*)shareVCList{
    static NSMutableArray *pushPopoverControllerList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pushPopoverControllerList = [NSMutableArray array];
    });
    return pushPopoverControllerList;
}

+(GSHPushPopoverController*)showWithTitle:(NSString*)title content:(NSString*)content{
    GSHPushPopoverController *vc = [GSHPageManager viewControllerWithClass:GSHPushPopoverController.class nibName:@"GSHPushPopoverController"];
    vc.lblTitleStr = title;
    vc.lblContentStr = content;
    [vc show];
    [[GSHPushPopoverController shareVCList]addObject:vc];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.lblContent.text = self.lblContentStr;
    self.lblTitle.text = self.lblTitleStr;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.lcTop.constant = -(self.viewContent.size.height);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    __weak typeof(self)weakSelf = self;
    self.lcTop.constant = 40;
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(close)];
        [weakSelf.view addGestureRecognizer:tap];
        [weakSelf performSelector:@selector(close) withObject:nil afterDelay:2];
    }];
}

-(void)dealloc{
    
}

- (void)show{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        GSHAppDelegate *delegate = (GSHAppDelegate*)[UIApplication sharedApplication].delegate;
        if(delegate.window) {
            [delegate.window addSubview:weakSelf.view];
            [weakSelf.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(delegate.window);
            }];
        }
    });
}

- (void)close{
    if (self.closing) {
        return;
    }
    self.closing = YES;
    [GSHPushPopoverController cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.lcTop.constant = -(weakSelf.viewContent.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            [weakSelf.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [weakSelf.view removeFromSuperview];
            [[GSHPushPopoverController shareVCList]removeObject:weakSelf];
        }];
    });
}
@end
