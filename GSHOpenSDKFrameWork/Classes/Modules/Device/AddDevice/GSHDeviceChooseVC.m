//
//  GSHDeviceChooseVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/5.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDeviceChooseVC.h"
#import "GSHDeviceEditVC.h"

@interface GSHDeviceChooseVCCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end

@implementation GSHDeviceChooseVCCell
-(void)setDevice:(GSHDeviceM *)device{
    _device = device;
    self.lblName.text = device.deviceName;
    [self.imageViewLogo sd_setImageWithURL:[NSURL URLWithString:device.homePageIcon] placeholderImage:DeviceIconPlaceHoldImage];
}
@end


@interface GSHDeviceChooseVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchCancel:(UIButton *)sender;

@property(nonatomic,strong)NSMutableArray<GSHDeviceM*>*deviceList;
@end

@implementation GSHDeviceChooseVC
+(instancetype)deviceChooseVCWithDeviceList:(NSMutableArray<GSHDeviceM *> *)deviceList{
    GSHDeviceChooseVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddDeviceSB" andID:@"GSHDeviceChooseVC"];
    vc.deviceList = deviceList;
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)touchCancel:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHDeviceChooseVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.deviceList.count > indexPath.row) {
        cell.device = self.deviceList[indexPath.row];
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.deviceList.count > indexPath.row) {
        GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:self.deviceList[indexPath.row] type:GSHDeviceEditVCTypeAdd];
        @weakify(self)
        deviceEditVC.isLastDevice = self.deviceList.count == 1 ? YES : NO;
        deviceEditVC.deviceAddSuccessBlock = ^(NSString *deviceId) {
            @strongify(self)
            for (GSHDeviceM *deviceM in self.deviceList) {
                if ([deviceId.numberValue isKindOfClass:NSNumber.class]) {
                    if ([deviceM.deviceId isEqualToNumber:deviceId.numberValue]) {
                        [self.deviceList removeObject:deviceM];
                        break;
                    }
                }
            }
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:deviceEditVC animated:YES];
    }
    return nil;
}

@end
