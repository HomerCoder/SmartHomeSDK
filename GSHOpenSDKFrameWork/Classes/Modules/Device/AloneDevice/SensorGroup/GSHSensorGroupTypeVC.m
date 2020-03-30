//
//  GSHSensorGroupTypeVC.m
//  SmartHome
//
//  Created by gemdale on 2018/12/26.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHSensorGroupTypeVC.h"
#import "GSHSensorGroupEditVC.h"
#import "UIView+TZMPageStatusViewEx.h"

@interface GSHSensorGroupTypeVCCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iamgeType;
@property (weak, nonatomic) IBOutlet UIImageView *imageSele;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (strong,nonatomic)GSHDeviceCategoryM *category;
@end

@implementation GSHSensorGroupTypeVCCell
-(void)setCategory:(GSHDeviceCategoryM *)category{
    _category = category;
    if (category) {
        self.lblName.text = category.deviceTypeStr;
        [self.iamgeType sd_setImageWithURL:[NSURL URLWithString:category.picPath] placeholderImage:DeviceIconPlaceHoldImage];
    }
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    self.imageSele.hidden = !selected;
    // Configure the view for the selected state
}

@end

@interface GSHSensorGroupTypeVC ()
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)touchNext:(UIButton *)sender;
@property (nonatomic,strong)GSHSensorM *sensor;
@property (nonatomic,strong) NSArray<GSHDeviceCategoryM*> *list;
@property (nonatomic,strong) GSHDeviceCategoryM *seleCategory;
@end

@implementation GSHSensorGroupTypeVC

+ (instancetype)sensorGroupTypeVCWithSensor:(GSHSensorM *)sensor{
    GSHSensorGroupTypeVC *vc = [GSHPageManager viewControllerWithSB:@"GSHSensorGroupSB" andID:@"GSHSensorGroupTypeVC"];
    vc.sensor = sensor;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnNext.enabled = NO;
    // Do any additional setup after loading the view.
    [self reloadData];
}

-(void)reloadData{
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [GSHSensorManager getSensorGroupTypeWithBlock:^(NSArray<GSHDeviceCategoryM *> *list, NSError *error) {
        [TZMProgressHUDManager dismissInView:weakSelf.view];
        [weakSelf.view dismissPageStatusView];
        if (error) {
            [weakSelf.view showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_network"] title:error.localizedDescription desc:nil buttonText:@"刷新" didClickButtonCallback:^(TZMPageStatus status) {
                [weakSelf reloadData];
            }];
        }else{
            weakSelf.list = list;
            [weakSelf.collectionView reloadData];
        }
    }];
}

#pragma mark - Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.list.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GSHSensorGroupTypeVCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (self.list.count > indexPath.row) {
        cell.category = self.list[indexPath.row];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((collectionView.frame.size.width - 16 * 3) / 2, (collectionView.frame.size.width - 16 * 3) / 2 / 164 * 240);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.list.count > indexPath.row) {
        self.seleCategory = self.list[indexPath.row];
        self.btnNext.enabled = YES;
    }
    return YES;
}

- (IBAction)touchNext:(UIButton *)sender {
    if (self.seleCategory) {
        GSHDeviceModelM *model = [GSHDeviceModelM new];
        model.deviceModel = self.seleCategory.deviceModel;
        model.deviceModelStr = self.seleCategory.deviceModelStr;
        model.deviceType = self.seleCategory.deviceType;
        model.deviceTypeStr = self.seleCategory.deviceTypeStr;
        GSHSensorGroupEditVC *vc = [GSHSensorGroupEditVC sensorGroupEditVCWithSensor:self.sensor category:model];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [TZMProgressHUDManager showErrorWithStatus:@"请选择传感器类型" inView:self.view];
    }
}
@end
