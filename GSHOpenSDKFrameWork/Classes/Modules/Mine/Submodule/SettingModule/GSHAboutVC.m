//
//  GSHAboutVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAboutVC.h"
#import "GSHWebViewController.h"
#import "GSHAlertManager.h"

@interface GSHAboutVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblVersions;
@end

@implementation GSHAboutVC{
}

+(instancetype)aboutVC{
    GSHAboutVC *vc = [GSHPageManager viewControllerWithSB:@"SettingSB" andID:@"GSHAboutVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblVersions.text = [NSString stringWithFormat:@"当前版本 V%@",[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypeAgreement parameter:nil];
        [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
    } else {
        NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypePrivacy parameter:nil];
        [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
    }
    return nil;
}
@end
