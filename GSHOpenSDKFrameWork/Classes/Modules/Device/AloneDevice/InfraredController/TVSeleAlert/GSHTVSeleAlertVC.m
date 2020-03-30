//
//  GSHTVSeleAlertVC.m
//  SmartHome
//
//  Created by gemdale on 2019/4/9.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHTVSeleAlertVC.h"
#import "GSHTVSeleAlertCell.h"

@interface GSHTVSeleAlertVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchOk:(id)sender;
- (IBAction)touchCancel:(id)sender;
@property(nonatomic,assign)NSInteger seleIndex;
@property(nonatomic,strong)NSArray<GSHKuKongInfraredDeviceM*> *list;
@property(nonatomic,copy)void(^seleBlock)(NSInteger index);
@end

@implementation GSHTVSeleAlertVC

+(instancetype)tvSeleAlertVCWithList:(NSArray<GSHKuKongInfraredDeviceM*> *)list seleBlock:(void(^)(NSInteger index))seleBlock{
    GSHTVSeleAlertVC *VC = [GSHPageManager viewControllerWithClass:GSHTVSeleAlertVC.class nibName:@"GSHTVSeleAlertVC"];
    VC.list = list;
    VC.seleBlock = seleBlock;
    VC.showRightAway = YES;
    return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.enableAroundClose = NO;
    self.seleIndex = -1;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"GSHTVSeleAlertCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"cell"];
}

-(void)dealloc{
    
}

- (IBAction)touchOk:(id)sender {
    [self close];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.seleBlock) self.seleBlock(self.seleIndex);
    });
}

- (IBAction)touchCancel:(id)sender {
    [self close];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHTVSeleAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.list.count > indexPath.row) {
        [cell refreshName:self.list[indexPath.row].deviceName];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.seleIndex = indexPath.row;
}
@end
