//
//  GSHInfraredControllerVerifyVC.m
//  SmartHome
//
//  Created by gemdale on 2019/2/26.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHInfraredControllerVerifyVC.h"
#import "GSHAlertManager.h"
#import "GSHInfraredControllerEditVC.h"
#import <TZMExternalPackagLib/IRConstants.h>
#import "GSHInfraredControllerEditVC.h"
#import "GSHInfraredControllerInfoVC.h"

@interface GSHInfraredControllerVerifyVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblListCcount;
@property (weak, nonatomic) IBOutlet UILabel *lblRemoteNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblKeyName;
@property (weak, nonatomic) IBOutlet UIButton *btnKey;
@property (weak, nonatomic) IBOutlet UIButton *btnPrevious;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnError;
@property (weak, nonatomic) IBOutlet UIButton *btnSucceed;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewGif;
- (IBAction)touchKey:(UIButton *)sender;
- (IBAction)touchPrevious:(UIButton *)sender;
- (IBAction)touchNext:(UIButton *)sender;
- (IBAction)touchError:(UIButton *)sender;
- (IBAction)touchSuccees:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *viewVerify;

@property (nonatomic,strong)GSHKuKongDeviceTypeM *type;
@property (nonatomic,strong)GSHKuKongBrandM *brand;
@property (nonatomic,strong)NSMutableArray<GSHKuKongRemoteM *> *remoteList;
@property (nonatomic,strong)NSArray<GSHKuKongInfraredTryKeyM *> *keyList;
@property (nonatomic,strong)NSError *error;

@property (nonatomic,assign)NSInteger seleRemoteIndex;
@property (nonatomic,strong)GSHKuKongRemoteM *seleRemote;
@property (nonatomic,assign)NSInteger seleKeyIndex;
@property (nonatomic,strong)GSHKuKongInfraredTryKeyM *seleKey;
@property(nonatomic,strong)GSHDeviceM *device;
@end

@implementation GSHInfraredControllerVerifyVC

+(instancetype)infraredControllerVerifyVCWithType:(GSHKuKongDeviceTypeM*)type brand:(GSHKuKongBrandM*)brand device:(GSHDeviceM*)device{
    GSHInfraredControllerVerifyVC *vc = [GSHPageManager viewControllerWithSB:@"GSHInfraredControllerSB" andID:@"GSHInfraredControllerVerifyVC"];
    vc.type = type;
    vc.brand = brand;
    vc.device = device;
    return vc;
}

-(void)refreshImageViewGifName:(NSString*)name{
    NSURL *filePath;
    if ([UIScreen mainScreen].nativeScale < 2.1) {
        filePath = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@@2x",name] withExtension:@"gif"];
    }else{
        filePath = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@@3x",name] withExtension:@"gif"];
    }
    [self.imageViewGif stopAnimating];
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)filePath, NULL);//将GIF图片转换成对应的图片源
    size_t frameCout = CGImageSourceGetCount(gifSource);//获取其中图片源个数，即由多少帧图片组成
    if (frameCout <= 0) {
        return;
    }
    
    NSMutableArray* frames = [[NSMutableArray alloc] init];//定义数组存储拆分出来的图片
    CGFloat duration = 0.0f;
    for (size_t i = 0; i < frameCout; i++){
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);//从GIF图片中取出源图片
        UIImage* imageName = [UIImage imageWithCGImage:imageRef];//将图片源转换成UIimageView能使用的图片源
        [frames addObject:imageName];//将图片加入数组中
        CGImageRelease(imageRef);
        
        CFDictionaryRef propertiesRef = CGImageSourceCopyPropertiesAtIndex(gifSource, 1, nil);
        //强转为oc对象
        NSDictionary *properties = (__bridge NSDictionary *)propertiesRef;
        //获取当前帧的gif属性
        NSDictionary *gifProperties = properties[(NSString *)kCGImagePropertyGIFDictionary];
        //获取持续时间
        NSNumber *delayTime = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        duration = duration + delayTime.floatValue;
        CFRelease(propertiesRef);
    }
    CFRelease(gifSource);
    
    self.imageViewGif.animationImages = frames;//将图片数组加入UIImageView动画数组中
    self.imageViewGif.image = frames.firstObject;
    self.imageViewGif.animationDuration = duration;//每次动画时长
    self.imageViewGif.animationRepeatCount = 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self refrshData];
    [self refreshImageViewGifName:@"GSHInfraredControllerVerifyVC_but1"];
}

- (void)refrshData{
    __weak typeof(self)weakSelf = self;
    dispatch_group_t group = dispatch_group_create();
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    self.error = nil;
    
    dispatch_group_enter(group);
    [GSHInfraredControllerManager getKuKongRemoteListWithDeviceType:self.type.devicetypeId brand:self.brand block:^(NSMutableArray<GSHKuKongRemoteM *> *list, NSError *error) {
        if (error) {
            weakSelf.error = error;
        }else{
            weakSelf.remoteList = list;
            weakSelf.seleRemoteIndex = 0;
            weakSelf.seleRemote = list.firstObject;
            if (weakSelf.type.devicetypeId.integerValue == 5) {
                [weakSelf getACManagerWithRemote:weakSelf.seleRemote];
            }
        }
        dispatch_group_leave(group);
    }];
    
    if (self.type.devicetypeId.integerValue == 5) {
        GSHKuKongInfraredTryKeyM *key1 = [GSHKuKongInfraredTryKeyM new];
        key1.displayName = @"电源";
        GSHKuKongInfraredTryKeyM *key2 = [GSHKuKongInfraredTryKeyM new];
        key2.displayName = @"制冷";
        self.keyList = @[key1,key2];
    }else{
        dispatch_group_enter(group);
        [GSHInfraredControllerManager getKuKongModuleTryKeysWithDeviceType:self.type.devicetypeId block:^(NSArray<GSHKuKongInfraredTryKeyM *> *keyList, NSError *error) {
            if (error) {
                weakSelf.error = error;
            }else{
                weakSelf.keyList = keyList;
                weakSelf.seleKeyIndex = 0;
                weakSelf.seleKey = keyList.firstObject;
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (weakSelf.error) {
            [TZMProgressHUDManager showErrorWithStatus:weakSelf.error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.lblListCcount.text = [NSString stringWithFormat:@"正在匹配遥控器方案（共%d套）",(int)self.remoteList.count];
            [weakSelf refreshUI];
        }
    });
}

- (void)refreshUI{
    self.lblRemoteNumber.text = [NSString stringWithFormat:@"方案%d",(int)(self.seleRemoteIndex + 1)];
    self.btnPrevious.hidden = self.seleRemoteIndex == 0;
    self.btnNext.hidden = self.remoteList.count == 0 || self.seleRemoteIndex == self.remoteList.count - 1;
    self.lblKeyName.text = self.seleKey.displayName;
}

-(void)getACManagerWithRemote:(GSHKuKongRemoteM *)remote{
    if ([remote airConditionerManager] == nil) {
        __weak typeof(self)weakSelf = self;
        [TZMProgressHUDManager showWithStatus:@"获取按键方案中" inView:self.view];
        [GSHKuKongRemoteM getKuKongDeviceIrDataWithDeviceSn:nil fileUrl:remote.fileUrl fid:remote.fid remoteId:remote.remoteId block:^(KKZipACManager *manager, NSError *error) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:@"获取按键方案失败" inView:weakSelf.view];
            }else{
                [TZMProgressHUDManager dismissInView:weakSelf.view];
                [remote setAirConditionerManager:manager];
            }
        }];
    }
}

- (void)next{
    if (self.seleRemoteIndex + 1 < self.remoteList.count) {
        self.seleRemoteIndex = self.seleRemoteIndex + 1;
        self.seleRemote = self.remoteList[self.seleRemoteIndex];
        if (self.type.devicetypeId.integerValue == 5) {
            [self getACManagerWithRemote:self.seleRemote];
        }
        self.seleKey = self.keyList.firstObject;
        self.seleKeyIndex = 0;
        [self refreshImageViewGifName:@"GSHInfraredControllerVerifyVC_but1"];
        
        self.viewVerify.hidden = YES;
        [self refreshUI];
    }
}

-(void)previous{
    if (self.seleRemoteIndex > 0 && self.seleRemoteIndex - 1 < self.remoteList.count) {
        self.seleRemoteIndex = self.seleRemoteIndex - 1;
        self.seleRemote = self.remoteList[self.seleRemoteIndex];
        if (self.type.devicetypeId.integerValue == 5) {
            [self getACManagerWithRemote:self.seleRemote];
        }
        self.seleKey = self.keyList.firstObject;
        self.seleKeyIndex = 0;
        [self refreshImageViewGifName:@"GSHInfraredControllerVerifyVC_but1"];
        
        self.viewVerify.hidden = YES;
        
        [self refreshUI];
    }
}

-(void)succees{
    if (self.seleKeyIndex >= self.keyList.count - 1) {
        //对码结束
        GSHInfraredControllerEditVC *vc = [GSHInfraredControllerEditVC infraredControllerEditVCWithType:self.type remote:self.seleRemote superDevice:self.device brand:self.brand];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        self.seleKeyIndex++;
        self.seleKey = self.keyList[self.seleKeyIndex];
        [self refreshImageViewGifName:@"GSHInfraredControllerVerifyVC_but2"];
    }
    self.viewVerify.hidden = YES;
    [self refreshUI];
}

-(void)failure{
    if (self.seleRemoteIndex >= self.remoteList.count - 1) {
        //最后一套方案啦
        __weak typeof(self)weakSelf = self;
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 1) {
                weakSelf.seleRemoteIndex = 0;
                weakSelf.seleRemote = weakSelf.remoteList.firstObject;
                if (weakSelf.type.devicetypeId.integerValue == 5) {
                    [weakSelf getACManagerWithRemote:weakSelf.seleRemote];
                }
                [weakSelf refreshUI];
            }else{
                UIViewController *vc;
                for (UIViewController *item in weakSelf.navigationController.viewControllers) {
                    if ([item isKindOfClass:GSHInfraredControllerInfoVC.class]) {
                        vc = item;
                        break;
                    }
                }
                [weakSelf.navigationController popToViewController:vc animated:YES];
            }
        } textFieldsSetupHandler:NULL andTitle:@"无可选方案匹配" andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消新增" otherButtonTitles:@"重新匹配",nil];
        self.viewVerify.hidden = YES;
    }else{
        [self next];
    }
}

-(void)tryKey{
    __weak typeof(self)weakSelf = self;
    if (!self.imageViewGif.isAnimating) {
        [self.imageViewGif startAnimating];
    }
    NSMutableString * ACInfrared1=[[NSMutableString alloc] init];
    NSMutableString * ACInfrared2=[[NSMutableString alloc] init];
    if (self.type.devicetypeId.integerValue == 5) {
        if (self.seleKeyIndex == 0) {
            [self.seleRemote.airConditionerManager changePowerStateWithPowerstate:[self.seleRemote.airConditionerManager getPowerState] == AC_POWER_ON ? AC_POWER_OFF : AC_POWER_ON];
        }else{
            [self.seleRemote.airConditionerManager changeModeStateWithModeState:TAG_AC_MODE_COOL_FUNCTION];
        }
        for (NSNumber * string in [self.seleRemote.airConditionerManager getAirConditionInfrared]) {
            [ACInfrared1 appendFormat:@"%02X",[string unsignedCharValue]];
        }
        NSLog(@"%@",ACInfrared1);//按键参数
        
        for (NSNumber * number in [self.seleRemote.airConditionerManager getParams]) {
            [ACInfrared2 appendFormat:@"%02X",[number unsignedCharValue]];//获取遥控器参数
        }
        NSLog(@"%@",ACInfrared2);
    }
    
    [TZMProgressHUDManager showWithStatus:@"请求中" inView:self.view];
    [GSHInfraredControllerManager postKuKongModuleVerifyWithRemoteId:self.seleRemote.remoteId deviceSN:self.device.deviceSn familyId:[GSHOpenSDKShare share].currentFamily.familyId operType:0 deviceTypeId:self.type.devicetypeId remoteParam:ACInfrared2 keyParam:ACInfrared1 keyId:self.seleKey.keyId block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            weakSelf.viewVerify.hidden = NO;
        }
    }];
}

- (IBAction)touchKey:(UIButton *)sender {
    [self tryKey];
}

- (IBAction)touchPrevious:(UIButton *)sender {
    [self previous];
}

- (IBAction)touchNext:(UIButton *)sender {
    [self next];
}

- (IBAction)touchError:(UIButton *)sender {
    [self failure];
}

- (IBAction)touchSuccees:(UIButton *)sender {
    [self succees];
}
@end
