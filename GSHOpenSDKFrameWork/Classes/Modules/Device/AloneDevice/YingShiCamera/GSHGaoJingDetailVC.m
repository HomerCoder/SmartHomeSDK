//
//  GSHGaoJingDetailVC.m
//  SmartHome
//
//  Created by gemdale on 2018/8/10.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHGaoJingDetailVC.h"
#import "GSHYingShiVideoVC.h"
#import "TZMPhotoLibraryManager.h"
#import "NSObject+TZM.h"
#import "UIImageView+WebCache.h"

NSString * const GSHYingShiGaoJingCollectChangeNotification = @"GSHYingShiGaoJingCollectChangeNotification";

@interface GSHGaoJingDetailVCCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic,strong)GSHYingShiGaoJingM *model;
@end

@implementation GSHGaoJingDetailVCCell
-(void)setModel:(GSHYingShiGaoJingM *)model{
    _model = model;
    NSURL *url = [NSURL URLWithString:self.model.alarmPicUrl];
    [self.imageView sd_setImageWithURL:url placeholderImage:[UIImage ZHImageNamed:@"GSHGaoJingDetailVC_defaultImage_icon"]];
}
@end

@interface GSHGaoJingDetailVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblWeiJie;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewShouCang;
@property (weak, nonatomic) IBOutlet UILabel *lblShouCang;
- (IBAction)touchVideo:(UIButton *)sender;
- (IBAction)touchBaoCun:(UIButton *)sender;
- (IBAction)touchShouCang:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnVideo;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property(nonatomic,strong)GSHYingShiGaoJingM *model;
@property(nonatomic,strong)NSArray<GSHYingShiGaoJingM*>* modelList;
@property(nonatomic, copy)NSString *verifyCode;
@property(nonatomic, copy)NSString *deviceSerial;
@end

@implementation GSHGaoJingDetailVC

+(instancetype)gaoJingDetailVCWithModel:(GSHYingShiGaoJingM*)model verifyCode:(NSString *)verifyCode deviceSerial:(NSString*)deviceSerial modelList:(NSArray<GSHYingShiGaoJingM*>*)modelList{
    GSHGaoJingDetailVC *vc = [GSHPageManager viewControllerWithSB:@"GSHYingshiCameraToolSB" andID:@"GSHGaoJingDetailVC"];
    vc.verifyCode = verifyCode;
    vc.deviceSerial = deviceSerial;
    vc.modelList = modelList;
    vc.model = model;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.model.isChecked == 0) {
        self.model.isChecked = 1;
        [GSHYingShiManager postAlarmReadWithAlarmIdList:@[self.model.alarmId] block:^(NSError *error) {
        }];
    }
    if([self.model.alarmType isEqualToString:@"calling"]){
        self.title = @"门铃呼叫详情";
    }else{
        self.title = @"告警详情";
    }
    self.model = self.model;
    NSURL *url = [NSURL URLWithString:self.model.alarmPicUrl];
    [self.imageView sd_setImageWithURL:url placeholderImage:[UIImage ZHImageNamed:@"GSHGaoJingDetailVC_defaultImage_icon"]];
}

-(void)dealloc{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.imageView.hidden) {
        NSInteger index = [self.modelList indexOfObject:self.model];
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        self.imageView.hidden = YES;
    }
}

-(void)setModel:(GSHYingShiGaoJingM *)model{
    _model = model;
    self.lblName.text = model.alarmName;
    if ([GSHOpenSDKShare share].currentFamily.floor.count > 1) {
        self.lblTitle.text = [NSString stringWithFormat:@"来自：%@%@",model.floorName,model.roomName];
    }else{
        self.lblTitle.text = [NSString stringWithFormat:@"来自：%@",model.roomName];
    }
    self.lblTime.text = [model.alarmTimeDate stringWithFormat:@"HH:mm:ss"];
    if (model.checkRecord == GSHYingShiGaoJingMCheckRecordStateNone || model.checkRecord == GSHYingShiGaoJingMCheckRecordStateError) {
        model.checkRecord = GSHYingShiGaoJingMCheckRecordStateChecking;
        [self updateVideoWithModel:model];
        self.btnVideo.hidden = YES;
    }else if (model.checkRecord == GSHYingShiGaoJingMCheckRecordStateChecking){
        self.btnVideo.hidden = YES;
    }else{
        self.btnVideo.hidden = model.file == nil;
    }
    if (model.collectState == 0) {
        self.lblShouCang.text = @"收藏";
        self.imageViewShouCang.highlighted = NO;
    }else{
        self.lblShouCang.text = @"取消收藏";
        self.imageViewShouCang.highlighted = YES;
    }
    
    
    if ([model.alarmType isEqualToString:@"motiondetect"]) {
        self.lblWeiJie.hidden = YES;
        self.lblTitle.hidden = NO;
    } else {
        self.lblTitle.hidden = YES;
        if ([model.alarmType isEqualToString:@"calling"]) {
            self.lblName.text = @"有人按门铃";
            self.lblWeiJie.hidden = NO;
            if (model.isPicked) {
                self.lblWeiJie.backgroundColor = [UIColor colorWithRGB:0x4CD664];
                self.lblWeiJie.text = @"已接";
            }else{
                self.lblWeiJie.backgroundColor = [UIColor colorWithRGB:0xE64430];
                self.lblWeiJie.text = @"未接";
            }
        } else {
            self.lblWeiJie.hidden = YES;
        }
    }
}

-(void)updateVideoWithModel:(GSHYingShiGaoJingM*)model{
    __weak typeof(self)weakSelf = self;
    NSDate *startTime = [NSDate dateWithTimeInterval:0 sinceDate:self.model.alarmTimeDate];
    NSDate *endTime = [NSDate dateWithTimeInterval:10 sinceDate:self.model.alarmTimeDate];
    [EZOpenSDK searchRecordFileFromDevice:self.deviceSerial cameraNo:model.channelNo beginTime:startTime endTime:endTime completion:^(NSArray *deviceRecords, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                model.checkRecord = GSHYingShiGaoJingMCheckRecordStateError;
            }else{
                model.checkRecord = GSHYingShiGaoJingMCheckRecordStateSucceed;
                EZDeviceRecordFile *file = deviceRecords.firstObject;
                model.file = file;
                weakSelf.btnVideo.hidden = weakSelf.model.file == nil;
            }
        });
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.modelList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GSHGaoJingDetailVCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (self.modelList.count > indexPath.row) {
        cell.model = self.modelList[indexPath.row];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return collectionView.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    GSHGaoJingDetailVCCell *cell = [self.collectionView visibleCells].firstObject;
    if (cell.model) self.model = cell.model;
}

- (IBAction)touchVideo:(UIButton *)sender {
    if (self.model.file) {
        [TZMProgressHUDManager dismissInView:self.view];
        GSHYingShiVideoVC *vc = [GSHYingShiVideoVC yingShiCameraVCWithDeviceSerial:self.deviceSerial cameraNo:self.model.channelNo recordFile:self.model.file verifyCode:self.verifyCode];
        vc.title = @"告警录像";
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [TZMProgressHUDManager showErrorWithStatus:@"录像读取错误，请检查设备存储" inView:self.view];
    }
}

- (IBAction)touchBaoCun:(UIButton *)sender {
    GSHGaoJingDetailVCCell *cell = [self.collectionView visibleCells].firstObject;
    if (cell.imageView.image) {
        __weak typeof(self)weakSelf = self;
        [TZMPhotoLibraryManager saveImageIntoAlbumWithImage:cell.imageView.image block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager showSuccessWithStatus:@"截图已经保存到相册" inView:weakSelf.view];
            }
        }];
    }else{
        [TZMProgressHUDManager showErrorWithStatus:@"图片加载中，请等加载完图片后再保存" inView:self.view];
    }
}

- (IBAction)touchShouCang:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    if (self.imageViewShouCang.highlighted) {
        [TZMProgressHUDManager showWithStatus:@"取消收藏中" inView:self.view];
        [GSHYingShiManager postUncollectAlarmWithAlarmIdList:@[self.model.alarmId] block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                weakSelf.model.collectState = 0;
                weakSelf.imageViewShouCang.highlighted = NO;
                weakSelf.lblShouCang.text = @"收藏";
                [NSObject postNotification:GSHYingShiGaoJingCollectChangeNotification object:@{@"collect":@"0",@"alarmId":weakSelf.model.alarmId,@"dateDay":weakSelf.model.dateDay}];
            }
        }];
    }else{
        [TZMProgressHUDManager showWithStatus:@"收藏中" inView:self.view];
        [GSHYingShiManager postCollectAlarmWithAlarmIdList:@[self.model.alarmId] block:^(NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                weakSelf.model.collectState = 1;
                weakSelf.imageViewShouCang.highlighted = YES;
                weakSelf.lblShouCang.text = @"取消收藏";
                [NSObject postNotification:GSHYingShiGaoJingCollectChangeNotification object:@{@"collect":@"1",@"alarmId":weakSelf.model.alarmId,@"dateDay":weakSelf.model.dateDay}];
            }
        }];
    }
}
@end
