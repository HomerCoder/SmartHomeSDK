//
//  GSHDeviceModelListVC.m
//  SmartHome
//
//  Created by gemdale on 2019/11/26.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDeviceModelListVC.h"
#import "GSHDeviceCategoryGuideVC.h"
#import "GSHAddGWApIntroVC.h"
#import "GSHAddGWGuideVC.h"

@interface GSHDeviceModelListVCCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblModel;
@end

@implementation GSHDeviceModelListVCCell
@end

@interface GSHDeviceModelListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property(nonatomic,strong)NSArray<GSHDeviceModelM*> *list;
@property(nonatomic,copy)NSString *deviceSn;
@end

@implementation GSHDeviceModelListVC

+(instancetype)deviceModelListVCWithList:(NSArray<GSHDeviceModelM*>*)list sn:(NSString*)sn{
    GSHDeviceModelListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddDeviceSB" andID:@"GSHDeviceModelListVC"];
    vc.list = list;
    vc.deviceSn = sn;
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblType.text = self.list.firstObject.deviceTypeStr;
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHDeviceModelListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.list.count > indexPath.row) {
        GSHDeviceModelM *model = self.list[indexPath.row];
        [cell.imageViewIcon sd_setImageWithURL:[NSURL URLWithString:model.homePageIcon]];
        cell.lblModel.text = model.modelNameDesc;
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.list.count > indexPath.row) {
        GSHDeviceModelM *model = self.list[indexPath.row];
        if (model.deviceType.intValue == GateWayDeviceType) {
            [self.navigationController pushViewController:[GSHAddGWGuideVC addGWGuideVCWithFamily:[GSHOpenSDKShare share].currentFamily deviceModel:model sn:self.deviceSn] animated:YES];
        }else{
            GSHDeviceCategoryGuideVC *vc = [GSHDeviceCategoryGuideVC deviceCategoryGuideVCWithGategory:model deviceSn:self.deviceSn];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    return nil;
}


@end
