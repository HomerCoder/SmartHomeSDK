//
//  GSHBothwayCutainSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2020/2/20.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHBothwayCurtainSetVC.h"

@interface GSHBothwayCurtainSetVC () <UIPickerViewDelegate,UIPickerViewDataSource>


@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic , strong) NSArray *pickerViewDataArr;
@property (nonatomic , strong) NSArray *pickerViewDataMeteValueArr;
@property (nonatomic , assign) int pickerIndex;
@property (weak, nonatomic) IBOutlet UIImageView *guideImageView;

@property (nonatomic,strong) NSArray *exts;

@end

@implementation GSHBothwayCurtainSetVC

+ (instancetype)bothwayCurtainSetVCWithDeviceM:(GSHDeviceM *)deviceM {
    GSHBothwayCurtainSetVC *vc = [GSHPageManager viewControllerWithSB:@"GSHBothwayCurtainSB" andID:@"GSHBothwayCurtainSetVC"];
    vc.deviceM = deviceM;
    vc.exts = deviceM.exts;
    return vc;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.pickerIndex = 0;
    self.pickerViewDataArr = @[@"正常",@"由外向内",@"由内向外"];
    self.pickerViewDataMeteValueArr = @[@"2",@"1",@"0"];
    
    [self getDeviceDetailInfo];
    if (self.exts.count > 0) {
        [self refreshUI];
    }
}

- (void)refreshUI {
    GSHDeviceExtM *extM = self.exts.firstObject;
    self.pickerIndex = (int)[self.pickerViewDataMeteValueArr indexOfObject:extM.rightValue];
    [self.pickerView selectRow:self.pickerIndex inComponent:0 animated:NO];
}

#pragma mark - method
// 确定
- (IBAction)sureButtonClick:(id)sender {
    
    NSMutableArray *exts = [NSMutableArray array];
    
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = GSHBothwayCurtain_stateMeteId ;
    extM.conditionOperator = @"==";
    extM.rightValue = self.pickerViewDataMeteValueArr[self.pickerIndex];
    [exts addObject:extM];
    
    if (self.deviceSetCompleteBlock) {
        self.deviceSetCompleteBlock(exts);
    }
    [self closeWithComplete:^{
        
    }];
}

#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceSign:nil block:^(GSHDeviceM *device, NSError *error) {
        @strongify(self)
            [self.guideImageView sd_setImageWithURL:[NSURL URLWithString:device.controlPicPath] placeholderImage:GlobalPlaceHoldImage];
    }];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerViewDataArr.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //获取选中的文字，以便于在别的地方使用
    if (self.pickerViewDataArr.count > row) {
        self.pickerIndex = (int)row;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews) {
        if (singleLine.frame.size.height < 1) {
            singleLine.backgroundColor = [UIColor blackColor];
        } else {
            singleLine.backgroundColor = [UIColor clearColor];
        }
    }
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.backgroundColor = [UIColor clearColor];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.textColor = [UIColor colorWithHexString:@"#222222"];
    genderLabel.text = self.pickerViewDataArr[row];
    return genderLabel;
    
}

@end
