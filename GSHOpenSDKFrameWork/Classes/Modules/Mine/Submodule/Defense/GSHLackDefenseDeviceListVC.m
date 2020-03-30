//
//  GSHLackDefenseDeviceListVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/2/13.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHLackDefenseDeviceListVC.h"
#import "GSHPageManager.h"
#import "WXApi.h"

@interface GSHLackDefenseDeviceListVCCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
- (IBAction)touchBut:(UIButton *)sender;
@property (nonatomic,strong)GSHDefenseDeviceTypeM *model;
@end

@implementation GSHLackDefenseDeviceListVCCell
-(void)setModel:(GSHDefenseDeviceTypeM *)model{
    _model = model;
    self.lblName.text = model.typeName;
    [self.imageIcon sd_setImageWithURL:[NSURL URLWithString:model.picPath] placeholderImage:nil];
}
- (IBAction)touchBut:(UIButton *)sender {
    if ([GSHOpenSDKShare share].currentFamily.permissions != GSHFamilyMPermissionsMember) {
        WXLaunchMiniProgramReq *launch = [WXLaunchMiniProgramReq object];
        launch.userName = @"gh_9a81fc7a8861";
        launch.miniProgramType = WXMiniProgramTypeRelease;
        [WXApi sendReq:launch];
    } else {
    }
}
@end

@interface GSHLackDefenseDeviceListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<GSHDefenseDeviceTypeM *> *list;
@end

@implementation GSHLackDefenseDeviceListVC
+(instancetype)lackDefenseDeviceListVCWithList:(NSArray<GSHDefenseDeviceTypeM *>*)list{
    GSHLackDefenseDeviceListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDefenseSB" andID:@"GSHLackDefenseDeviceListVC"];
    vc.list = list;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHLackDefenseDeviceListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.list.count) {
        cell.model = self.list[indexPath.row];
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

@end
