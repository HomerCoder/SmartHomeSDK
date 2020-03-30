//
//  GSHDoorLackSetVC.m
//  SmartHome
//
//  Created by 唐作明 on 2020/3/2.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHDoorLackSetVC.h"

@interface GSHDoorLackSetVCCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UIImageView *imageSele;
@end

@implementation GSHDoorLackSetVCCell
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.lblText.textColor = [UIColor colorWithRGB:0x2EB0FF];
        self.imageSele.hidden = NO;
    }else{
        self.lblText.textColor = [UIColor colorWithRGB:0x222222];
        self.imageSele.hidden = YES;
    }
}

@end

@interface GSHDoorLackSetVC ()<UITableViewDelegate,UITableViewDataSource
>
@property (nonatomic , copy) void (^block)(NSArray *exts);
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchSure:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@end

@implementation GSHDoorLackSetVC

+(instancetype)doorLackSetVCWithDevice:(GSHDeviceM*)device type:(GSHDeviceVCType)type block:(void(^)(NSArray *exts))block{
    GSHDoorLackSetVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDoorLackSB" andID:@"GSHDoorLackSetVC"];
    vc.deviceM = device;
    vc.block = block;
    vc.deviceEditType = type;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)touchSure:(UIButton *)sender {
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHDoorLackSetVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectedBackgroundView = [UIView new];
    if (indexPath.row == 0) {
        cell.lblText.text = @"任意开锁";
    }else if (indexPath.row == 1){
        cell.lblText.text = @"门锁被撬";
    }else if (indexPath.row == 2){
        cell.lblText.text = @"多次尝试开锁";
    }else if (indexPath.row == 3){
        cell.lblText.text = @"门锁被重置恢复出厂状态";
    }else{
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
