//
//  GSHAdjustLightSetVC.m
//  SmartHome
//
//  Created by gemdale on 2019/10/11.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAdjustLightSetVC.h"
#import <UINavigationController+TZM.h>

@implementation GSHAdjustLightViewModel
+(instancetype)adjustLightViewModelWithType:(GSHAdjustLightViewModelType)type{
    GSHAdjustLightViewModel *model = [GSHAdjustLightViewModel new];
    switch (type) {
        case GSHAdjustLightViewModelTypeYueDu:
            model.liangDu = 100;
            model.seWen = 5700;
            break;
        case GSHAdjustLightViewModelTypeShengHuo:
            model.liangDu = 100;
            model.seWen = 4600;
            break;
        case GSHAdjustLightViewModelTypeRouHe:
            model.liangDu = 40;
            model.seWen = 3100;
            break;
        case GSHAdjustLightViewModelTypeYeDeng:
            model.liangDu = 10;
            model.seWen = 2900;
            break;
        case GSHAdjustLightViewModelTypeWenXin:
            model.liangDu = 100;
            model.seWen = 2700;
            break;
        default:
            model.liangDu = 0;
            model.seWen = 0;
            break;
    }
    return model;
}

+(GSHAdjustLightViewModelType)typeWithSeWen:(NSInteger)seWen liangDu:(NSInteger)liangDu{
    if (seWen == 5700 && liangDu == 100) {
        return GSHAdjustLightViewModelTypeYueDu;
    }else if (seWen == 4600 && liangDu == 100) {
        return GSHAdjustLightViewModelTypeShengHuo;
    }else if (seWen == 3100 && liangDu == 40) {
        return GSHAdjustLightViewModelTypeRouHe;
    }else if (seWen == 2900 && liangDu == 10) {
        return GSHAdjustLightViewModelTypeYeDeng;
    }else if (seWen == 2700 && liangDu == 100) {
        return GSHAdjustLightViewModelTypeWenXin;
    }else if (seWen == 0 && liangDu == 0) {
        return GSHAdjustLightViewModelTypeMoRen;
    }else{
        return GSHAdjustLightViewModelTypeError;
    }
}
@end

@interface GSHAdjustLightSetVC()
@property (nonatomic , copy) void (^block)(NSArray *exts);
- (IBAction)touchOk:(UIButton *)sender;
- (IBAction)touchOpen:(UISwitch *)sender;
- (IBAction)touchModel:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btnList;
@property (weak, nonatomic) IBOutlet UISwitch *off;
@end

@implementation GSHAdjustLightSetVC
+(instancetype)adjustLightSetVCWithDevice:(GSHDeviceM*)device type:(GSHDeviceVCType)type block:(void(^)(NSArray *exts))block{
    GSHAdjustLightSetVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAdjustLight" andID:@"GSHAdjustLightSetVC"];
    vc.deviceM = device;
    vc.block = block;
    vc.deviceEditType = type;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)refreshWithDevice:(GSHDeviceM*)device{
    NSInteger off = 0;
    NSInteger seWen = 0;
    NSInteger liangDu = 0;
    for (GSHDeviceExtM *extM in device.exts) {
        if ([extM.basMeteId isEqualToString:GSHAdjustLight_offMeteId]) {
            off = extM.rightValue.intValue;
        } else if ([extM.basMeteId isEqualToString:GSHAdjustLight_wenSeMeteId]) {
            seWen = extM.rightValue.intValue;
        } else if ([extM.basMeteId isEqualToString:GSHAdjustLight_lightMeteId]) {
            liangDu = extM.rightValue.intValue;
        }
    }
    if (off == 0) {
        self.off.on = NO;
        [self touchOpen:self.off];
    }else{
        GSHAdjustLightViewModelType type = [GSHAdjustLightViewModel typeWithSeWen:seWen liangDu:liangDu];
        NSInteger tag;
        switch (type) {
            case GSHAdjustLightViewModelTypeYueDu:
                tag = 1006;
                break;
            case GSHAdjustLightViewModelTypeShengHuo:
                tag = 1002;
                break;
            case GSHAdjustLightViewModelTypeRouHe:
                tag = 1003;
                break;
            case GSHAdjustLightViewModelTypeYeDeng:
                tag = 1004;
                break;
            case GSHAdjustLightViewModelTypeWenXin:
                tag = 1005;
                break;
            default:
                tag = 1001;
                break;
        }
        for (UIButton *btn in self.btnList) {
            if (btn.tag == tag) {
                btn.selected = YES;
            }else{
                btn.selected = NO;
            }
        }
        self.off.on = YES;
        [self touchOpen:self.off];
    }

}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tzm_prefersNavigationBarHidden = YES;
    
    self.lblTitle.text = self.deviceM.deviceName;
    for (UIButton *btn in self.btnList) {
        [btn setTitleColor:[UIColor colorWithRGB:0xDEDEDE] forState:UIControlStateDisabled|UIControlStateSelected];
    }
    [self refreshWithDevice:self.deviceM];
}

- (IBAction)touchOk:(UIButton *)sender {
    NSMutableArray *exts = [NSMutableArray array];
    int off = 1,tag = 0;
    for (UIButton *btn in self.btnList) {
        if (btn.enabled == NO) {
            off = 0;
            break;
        }
        if (btn.selected == YES) {
            tag = (int)btn.tag;
            break;
        }
    }
    GSHDeviceExtM *extM1 = [[GSHDeviceExtM alloc] init];
    extM1.basMeteId = GSHAdjustLight_offMeteId;
    extM1.conditionOperator = @"==";
    extM1.rightValue = @(off).stringValue;
    [exts addObject:extM1];
    if (off == 1 && tag > 1000) {
        GSHAdjustLightViewModel *model;
        switch (tag) {
            case 1006:
                model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeYueDu];
                break;
            case 1002:
                model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeShengHuo];
                break;
            case 1003:
                model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeRouHe];
                break;
            case 1004:
                model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeYeDeng];
                break;
            case 1005:
                model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeWenXin];
                break;
            default:
                model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeMoRen];
                break;
        }
        if (model.seWen > 0) {
            GSHDeviceExtM *extM2 = [[GSHDeviceExtM alloc] init];
            extM2.basMeteId = GSHAdjustLight_wenSeMeteId;
            extM2.conditionOperator = @"==";
            extM2.rightValue = @(model.seWen).stringValue;
            [exts addObject:extM2];
            GSHDeviceExtM *extM3 = [[GSHDeviceExtM alloc] init];
            extM3.basMeteId = GSHAdjustLight_lightMeteId;
            extM3.conditionOperator = @"==";
            extM3.rightValue = @(model.liangDu).stringValue;
            [exts addObject:extM3];
        }
    }
    if (self.block) {
        self.block(exts);
    }
    [self closeWithComplete:NULL];
}

- (IBAction)touchOpen:(UISwitch *)sender {
    if (sender.on) {
        for (UIButton *btn in self.btnList) {
            btn.enabled = YES;
            if (btn.selected) {
                btn.layer.borderColor = [UIColor clearColor].CGColor;
            }else{
                btn.layer.borderColor = [UIColor colorWithRGB:0x2EB0FF].CGColor;
            }
        }
    }else{
        for (UIButton *btn in self.btnList) {
            btn.enabled = NO;
            btn.layer.borderColor = [UIColor colorWithRGB:0xDEDEDE].CGColor;
        }
    }
}

- (IBAction)touchModel:(UIButton *)sender {
    for (UIButton *btn in self.btnList) {
        btn.selected = NO;
        btn.layer.borderColor = [UIColor colorWithRGB:0x2EB0FF].CGColor;
    }
    sender.layer.borderColor = [UIColor clearColor].CGColor;
    sender.selected = YES;
}
@end
