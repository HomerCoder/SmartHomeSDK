//
//  GSHContactWayVC.m
//  SmartHome
//
//  Created by gemdale on 2019/11/20.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHContactWayVC.h"
#import "GSHWebViewController.h"
#import "GSHWeChatCustomerServiceVC.h"

@interface GSHContactWayVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblGuanWang;
@property (weak, nonatomic) IBOutlet UILabel *lblDianHua;

@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *websiteUrl;
@property (copy, nonatomic) NSString *wechatQrcodeUrl;
@end

@implementation GSHContactWayVC
+(instancetype)contactWayVC{
    GSHContactWayVC *vc = [GSHPageManager viewControllerWithSB:@"GSHContactWaySB" andID:@"GSHContactWayVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"获取信息中" inView:self.view];
    [GSHRequestManager getWithPath:@"general/getContactUsDetail" parameters:nil block:^(id responseObjec, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if ([responseObjec isKindOfClass:NSDictionary.class]) {
                weakSelf.phone = [(NSDictionary*)responseObjec stringValueForKey:@"phone" default:nil];
                weakSelf.websiteUrl = [(NSDictionary*)responseObjec stringValueForKey:@"websiteUrl" default:nil];
                weakSelf.wechatQrcodeUrl = [(NSDictionary*)responseObjec stringValueForKey:@"wechatQrcodeUrl" default:nil];
            }
            weakSelf.lblGuanWang.text = weakSelf.websiteUrl;
            weakSelf.lblDianHua.text = weakSelf.phone;
        }
    }];
}

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSURL *url = [NSURL URLWithString:self.websiteUrl];
        [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
    } else if (indexPath.section == 0 && indexPath.row == 1){
        NSString *str = [[NSString alloc] initWithFormat:@"telprompt://%@",self.phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    } else if (indexPath.section == 0 && indexPath.row == 2){
        NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypeFeedback parameter:nil];
        [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
    }
    return nil;
}


@end
