//
//  GSHShengBiKeGuideVC.m
//  SmartHome
//
//  Created by gemdale on 2019/12/16.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHShengBiKeGuideVC.h"
#import "GSHShengBiKeSearchVC.h"

@interface GSHShengBiKeGuideVC ()
@property(nonatomic,strong)GSHDeviceModelM *category;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewGuide;
- (IBAction)touchNext:(UIButton *)sender;
@end

@implementation GSHShengBiKeGuideVC
+(instancetype)shengBiKeGuideVCWithGategory:(GSHDeviceModelM*)category{
    GSHShengBiKeGuideVC *vc = [GSHPageManager viewControllerWithSB:@"ShengBiKeSB" andID:@"GSHShengBiKeGuideVC"];
    vc.category = category;
    return vc;
}

-(void)setCategory:(GSHDeviceModelM *)category{
    _category = category;
    self.title = category.modelNameDesc;
    [self.imageViewGuide sd_setImageWithURL:[NSURL URLWithString:category.introPic] placeholderImage:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.category = _category;
}

- (IBAction)touchNext:(UIButton *)sender {
    GSHShengBiKeSearchVC *vc = [GSHShengBiKeSearchVC shengBiKeSearchVCWithGategory:self.category];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
