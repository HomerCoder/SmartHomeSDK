//
//  GSHShengBiKeListVC.m
//  SmartHome
//
//  Created by gemdale on 2019/12/16.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHShengBiKeListVC.h"
#import "GSHShengBiKeAddVC.h"

@interface GSHShengBiKeListVCCell ()
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end
@implementation GSHShengBiKeListVCCell
@end

@interface GSHShengBiKeListVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSMutableArray<GSHDeviceM*>*deviceList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchCancel:(UIButton *)sender;
@end

@implementation GSHShengBiKeListVC
+(instancetype)shengBiKeListVCWithDeviceList:(NSMutableArray<GSHDeviceM *> *)deviceList{
    GSHShengBiKeListVC *vc = [GSHPageManager viewControllerWithSB:@"ShengBiKeSB" andID:@"GSHShengBiKeListVC"];
    vc.deviceList = deviceList;
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView reloadData];
}

- (IBAction)touchCancel:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHShengBiKeListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.deviceList.count) {
        GSHDeviceM *model = self.deviceList[indexPath.row];
        [cell.icon sd_setImageWithURL:[NSURL URLWithString:model.homePageIcon]];
        cell.lblName.text = model.deviceSn;
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.deviceList.count) {
        GSHDeviceM *model = self.deviceList[indexPath.row];
        GSHShengBiKeAddVC *vc = [GSHShengBiKeAddVC shengBiKeAddVCWithDevice:model];
        [self.navigationController pushViewController:vc animated:YES];
    }
    return NO;
}

@end
