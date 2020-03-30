//
//  GSHAddGWListVC.m
//  SmartHome
//
//  Created by gemdale on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAddGWListVC.h"
#import "GSHAlertManager.h"
#import "GSHAddGWDetailVC.h"
#import "UIView+TZMPageStatusViewEx.h"

@interface GSHAddGWListVCCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *gatewayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *isBindedLabel;

@end

@implementation GSHAddGWListVCCell

-(void)setModel:(NSDictionary *)model{
    _model = model;
    NSString *gwId = [model stringValueForKey:@"gwId" default:nil];
    NSNumber *isBinded = [model numverValueForKey:@"isBinded" default:nil];
    self.lblName.text = gwId;
    self.lblName.textColor = isBinded.intValue == 1 ? [UIColor colorWithHexString:@"#999999"] : [UIColor colorWithHexString:@"#222222"];
    NSString *image = [model stringValueForKey:@"image" default:@""];
    [self.gatewayImageView sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage ZHImageNamed:@"addGWListVC_cell_icon"]];
    self.arrowImageView.hidden = isBinded.intValue == 1 ? YES : NO;
    self.isBindedLabel.hidden = isBinded.intValue == 1 ? NO : YES;
}

@end

@interface GSHAddGWListVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSArray<NSDictionary*> *gwList;
- (IBAction)touchCancel:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(strong,nonatomic)GSHFamilyM *family;
@property(strong,nonatomic)GSHDeviceModelM *model;
@end

@implementation GSHAddGWListVC

+(instancetype)addGWListVCWithGWList:(NSArray<NSDictionary*>*)list family:(GSHFamilyM*)family deviceModel:(GSHDeviceModelM*)model{
    GSHAddGWListVC *vc = [GSHPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHAddGWListVC"];
    vc.gwList = list;
    vc.family = family;
    vc.model = model;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.gwList.count == 0) {
        @weakify(self)
        [self.view showPageStatus:TZMPageStatusNormal image:nil title:@"未搜索到网关，请重试" desc:nil buttonText:@"重试" didClickButtonCallback:^(TZMPageStatus status) {
            @strongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchCancel:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if(buttonIndex == 1){
        }else{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    } textFieldsSetupHandler:NULL andTitle:@"提示" andMessage:@"确定取消添加网关吗？" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"取消",@"确定",nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.gwList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHAddGWListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.gwList.count > indexPath.row) {
        cell.model = self.gwList[indexPath.row];
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *model = self.gwList[indexPath.row];
    NSString *gwId = [model stringValueForKey:@"gwId" default:nil];
    if (gwId.length == 0 || [gwId isEqualToString:@"unkonw"]) {
        [TZMProgressHUDManager showErrorWithStatus:@"网关id未返回" inView:self.view];
        return nil;
    }
    NSNumber *isBinded = [model numverValueForKey:@"isBinded" default:nil];
    if (isBinded.intValue == 1) {
        return nil;
    }
    if (self.family.gatewayId.length > 0) {
        [self.navigationController pushViewController:[GSHAddGWDetailVC changeGWDetailVCWithGW:gwId family:self.family] animated:YES];
    }else{
        [self.navigationController pushViewController:[GSHAddGWDetailVC addGWDetailVCWithGW:gwId family:self.family] animated:YES];
    }
    return nil;
}
@end
