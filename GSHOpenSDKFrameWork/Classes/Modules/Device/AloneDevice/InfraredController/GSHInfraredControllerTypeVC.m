//
//  GSHInfraredControllerTypeVC.m
//  SmartHome
//
//  Created by gemdale on 2019/2/22.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHInfraredControllerTypeVC.h"
#import "GSHInfraredControllerBrandVC.h"

@interface GSHInfraredControllerTypeVCCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (strong,nonatomic)GSHKuKongDeviceTypeM *model;
@end

@implementation GSHInfraredControllerTypeVCCell
-(void)setModel:(GSHKuKongDeviceTypeM *)model{
    _model = model;
    self.lblName.text = model.displayName;
    [self.imageViewIcon sd_setImageWithURL:[NSURL URLWithString:model.kkPicPath] placeholderImage:DeviceIconPlaceHoldImage];
}
@end

@interface GSHInfraredControllerTypeVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)NSArray<GSHKuKongDeviceTypeM*> *dataList;
@property(nonatomic,strong)GSHDeviceM *device;
@end

@implementation GSHInfraredControllerTypeVC

+(instancetype)infraredControllerTypeVCWithDevice:(GSHDeviceM*)device{
    GSHInfraredControllerTypeVC *vc = [GSHPageManager viewControllerWithSB:@"GSHInfraredControllerSB" andID:@"GSHInfraredControllerTypeVC"];
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [GSHInfraredControllerManager getKuKongDeviceTypeListWithBlock:^(NSArray<GSHKuKongDeviceTypeM *> *list, NSNumber *version, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.dataList = list;
            [weakSelf.tableView reloadData];
        }
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHInfraredControllerTypeVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.dataList.count) cell.model = self.dataList[indexPath.row];
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.dataList.count){
        GSHInfraredControllerBrandVC *vc = [GSHInfraredControllerBrandVC infraredControllerBrandVCWithType:self.dataList[indexPath.row] device:self.device];
        [self.navigationController pushViewController:vc animated:YES];
    }
    return nil;
}

@end
