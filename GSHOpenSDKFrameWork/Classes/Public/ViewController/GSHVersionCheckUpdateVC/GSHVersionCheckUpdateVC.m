//
//  GSHVersionCheckUpdateVC.m
//  Passenger
//
//  Created by mayer on 16/5/17.
//

#import "GSHVersionCheckUpdateVC.h"
#import "GSHPageManager.h"
#import "GSHGateWayUpdateVC.h"
#import "UIViewController+TZM.h"
#import "GSHAppDelegate.h"
#import "Masonry.h"

@interface GSHVersionCheckUpdateVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIButton *btnLgnore;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdate;
- (IBAction)touchLgnore:(UIButton *)sender;
- (IBAction)touchUpdate:(UIButton *)sender;
@property(copy,nonatomic)NSString *versionTitle;
@property(copy,nonatomic)NSString *content;
@property(assign,nonatomic)GSHVersionCheckUpdateVCType type;
@property(copy,nonatomic)NSString *cancelTitle;
@property(copy,nonatomic)void(^cancelBlock)(void);
@property(copy,nonatomic)void(^updateBlock)(void);
@end

@implementation GSHVersionCheckUpdateVC


static NSMutableArray *_versionCheckUpdateVCList;
+(instancetype)versionCheckUpdateVCWithTitle:(NSString*)title content:(NSString*)content type:(GSHVersionCheckUpdateVCType)type cancelTitle:(NSString*)cancelTitle cancelBlock:(void(^)(void))cancelBlock updateBlock:(void(^)(void))updateBlock{
    GSHVersionCheckUpdateVC *VC = [GSHPageManager viewControllerWithClass:GSHVersionCheckUpdateVC.class nibName:@"GSHVersionCheckUpdateVC"];
    VC.versionTitle = title;
    VC.content = content;
    VC.type = type;
    VC.cancelTitle = cancelTitle;
    VC.cancelBlock = cancelBlock;
    VC.updateBlock = updateBlock;
    return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.enableAroundClose = NO;
    
    self.lblTitle.text = self.versionTitle;
    self.lblContent.text = self.content;
    if (self.cancelTitle.length > 0) {
        [self.btnLgnore setTitle:self.cancelTitle forState:UIControlStateNormal];
        self.btnLgnore.hidden = NO;
    }else{
        self.btnLgnore.hidden = YES;
    }
    if (self.type == GSHVersionCheckUpdateVCTypeGW){
        [self.btnUpdate setTitle:@"去升级" forState:UIControlStateNormal];
    }else{
        [self.btnUpdate setTitle:@"立即升级" forState:UIControlStateNormal];
    }
}

-(void)dealloc{
    
}

- (void)show{
    if (!_versionCheckUpdateVCList) {
        _versionCheckUpdateVCList = [NSMutableArray array];
    }
    if ([_versionCheckUpdateVCList indexOfObject:self] == NSNotFound) {
        [_versionCheckUpdateVCList addObject:self];
    }
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        GSHAppDelegate *delegate = (GSHAppDelegate*)[UIApplication sharedApplication].delegate;
        if(delegate.window) {
            [delegate.window addSubview:weakSelf.view];
            [weakSelf.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(delegate.window);
            }];
        }
        if(weakSelf.didCallShowCallback)weakSelf.didCallShowCallback(weakSelf);
    });
}

- (IBAction)close{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.view removeFromSuperview];
        if(weakSelf.didCallCloseCallback)weakSelf.didCallCloseCallback(weakSelf);
        if (_versionCheckUpdateVCList) {
            [_versionCheckUpdateVCList removeObject:weakSelf];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchLgnore:(UIButton *)sender {
    [self close];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (IBAction)touchUpdate:(UIButton *)sender {
    if (self.updateBlock) {
        self.updateBlock();
    }
    if (self.type == GSHVersionCheckUpdateVCTypeGW) {
        [self close];
        GSHGateWayUpdateVC *updateVC = [GSHGateWayUpdateVC gateWayUpdateVC];
        [[UIViewController visibleTopNavigationController] pushViewController:updateVC animated:YES];
    }else if (self.type == GSHVersionCheckUpdateVCTypeApp){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/in/app/id1407112008"]];
        [[UIApplication sharedApplication] openURL:url];
        exit(0);
    }else{
        
    }
}
@end
