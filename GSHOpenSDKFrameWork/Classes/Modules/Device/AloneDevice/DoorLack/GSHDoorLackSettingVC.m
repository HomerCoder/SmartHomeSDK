//
//  GSHDoorLackSettingVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/2/19.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDoorLackSettingVC.h"
#import "GSHNewSinglePasswordVC.h"
#import "GSHPasswordListVC.h"
#import "GSHDeviceEditVC.h"

@interface GSHDoorLackSettingVC ()
@property (strong, nonatomic)GSHDeviceM *device;
@end

@implementation GSHDoorLackSettingVC
+(instancetype)doorLackSettingVCWithDevice:(GSHDeviceM*)device{
    GSHDoorLackSettingVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoorLackSB" andID:@"GSHDoorLackSettingVC"];
    vc.device = device;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController *vc;
    if (indexPath.row == 0) {
        vc = [GSHNewSinglePasswordVC newSinglePasswordVCWithDevice:self.device];
    }else if(indexPath.row == 1){
        vc = [GSHPasswordListVC passwordListVCWithDevice:self.device];
    }else if(indexPath.row == 2){
        
    }else if(indexPath.row == 3){
        vc = [GSHDeviceEditVC deviceEditVCWithDevice:self.device type:GSHDeviceEditVCTypeEdit];
    }
    [self.navigationController pushViewController:vc animated:YES];
    return NO;
}
@end
