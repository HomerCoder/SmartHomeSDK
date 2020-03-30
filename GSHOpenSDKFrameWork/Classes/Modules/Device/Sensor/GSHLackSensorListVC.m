//
//  GSHLackSensorListVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/2/13.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHLackSensorListVC.h"
#import "GSHPageManager.h"
#import "WXApi.h"

@interface GSHLackSensorListVCCell()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblScore;
- (IBAction)touchBut:(UIButton *)sender;
@property (nonatomic,strong)GSHMissingSensorM *model;
@end

@implementation GSHLackSensorListVCCell
-(void)setModel:(GSHMissingSensorM *)model{
    _model = model;
    self.lblName.text = model.deviceName;
    self.lblScore.text = [NSString stringWithFormat:@"+%@",model.statusDesc];
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

@interface GSHLackSensorListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<GSHMissingSensorM *> *list;
@end

@implementation GSHLackSensorListVC
+(instancetype)lackSensorListVCWithList:(NSArray<GSHMissingSensorM *>*)list{
    GSHLackSensorListVC *vc = [GSHPageManager viewControllerWithSB:@"SensorListSB" andID:@"GSHLackSensorListVC"];
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
    GSHLackSensorListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.list.count) {
        cell.model = self.list[indexPath.row];
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

@end
