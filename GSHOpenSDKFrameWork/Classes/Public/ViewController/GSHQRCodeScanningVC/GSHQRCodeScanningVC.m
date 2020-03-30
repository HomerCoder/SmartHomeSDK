//
//  GSHQRCodeScanningVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/21.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHQRCodeScanningVC.h"

@interface GSHQRCodeScanningVC ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UIButton *btnShanGuang;
@property (weak, nonatomic) IBOutlet UIImageView *lineView;
- (IBAction)touchShanGuang:(UIButton *)sender;
@property (nonatomic, copy)NSString *text;
@property (nonatomic, copy)BOOL(^block)(NSString *code, GSHQRCodeScanningVC *vc);

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (strong,nonatomic)CABasicAnimation *animation;
@end

@implementation GSHQRCodeScanningVC

+(GSHQRCodeScanningVC*)qrCodeScanningVCWithText:(NSString*)text title:(NSString*)title block:(BOOL(^)(NSString *code, GSHQRCodeScanningVC *vc))block{
    GSHQRCodeScanningVC *vc = [GSHPageManager viewControllerWithClass:GSHQRCodeScanningVC.class nibName:@"GSHQRCodeScanningVC"];
    vc.block = block;
    vc.text = text;
    vc.title = title;
    return vc;
}

+(UINavigationController*)qrCodeScanningNavWithText:(NSString*)text title:(NSString*)title block:(BOOL(^)(NSString *code, GSHQRCodeScanningVC *vc))block{
    GSHQRCodeScanningVC *vc = [self qrCodeScanningVCWithText:text title:title block:block];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [nav.navigationBar setBarStyle:UIBarStyleBlack];
    return nav;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage ZHImageNamed:@"qrCodeScanningVC_navBack_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(xiangce)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    self.lblText.text = self.text;
    // Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // Preview
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    if ([self.session canAddInput:self.input]){
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output]){
        [self.session addOutput:self.output];
    }
    
    self.animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    self.animation.duration = 1;
    self.animation.repeatCount = HUGE_VALF;
    self.animation.autoreverses = YES;
    self.animation.removedOnCompletion = NO;
    [self startScanning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.preview.frame = self.view.layer.bounds;
    [self.lineView.layer removeAllAnimations];
    self.animation.toValue = @(self.lineView.frame.size.width);
    [self.lineView.layer addAnimation:self.animation forKey:@"animation"];
}

-(void)dealloc{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasFlash]) return;
    [device lockForConfiguration:nil];
    if (device.flashMode == AVCaptureFlashModeOn) {
        device.flashMode = AVCaptureFlashModeOff;
        device.torchMode = AVCaptureTorchModeOff;
    }
    [device unlockForConfiguration];
    [self.lineView.layer removeAllAnimations];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

-(void)startScanning{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        [self.session startRunning];
    }else{
        __weak typeof(self)weakSelf = self;
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 1) {
                [weakSelf startScanning];
            }
        } textFieldsSetupHandler:NULL andTitle:@"没有相机权限" andMessage:@"请到系统设置里设置，设置->隐私->相机，打开应用权限" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"已经打开",@"取消",nil];
    }
}

-(void)back{
    if (self.navigationController.viewControllers.firstObject == self) {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)xiangce{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self.session stopRunning];
    [self presentViewController:picker animated:YES completion:^{
    }];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue;
    if ([metadataObjects count] > 0){
        //停止扫描
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    if (stringValue.length > 0) {
        if (self.block) {
            BOOL again = self.block(stringValue, self);
            //是否需要再次扫描
            if (again){
                [self.session startRunning];
            }
        }
    }else{
        //没有扫描到继续扫描
        [self.session startRunning];
    }
}

- (IBAction)touchShanGuang:(UIButton *)sender {
    //  获取摄像机单例对象
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if (![device hasFlash]) return;
    //修改前必须先锁定
    [device lockForConfiguration:nil];
    if (device.flashMode == AVCaptureFlashModeOff) {
        device.flashMode = AVCaptureFlashModeOn;
        device.torchMode = AVCaptureTorchModeOn;
        sender.selected = YES;
    } else if (device.flashMode == AVCaptureFlashModeOn) {
        device.flashMode = AVCaptureFlashModeOff;
        device.torchMode = AVCaptureTorchModeOff;
        sender.selected = NO;
    }
    [device unlockForConfiguration];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:NO completion:NULL];
    // 从info中将图片取出，并加载到imageView当中
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *image;
    if (editedImage.size.width > originalImage.size.width || editedImage.size.height > originalImage.size.height) {
        image = originalImage;
    }else{
        image = editedImage;
    }

    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSData *imageData = UIImagePNGRepresentation(image);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    NSArray *features;
    @try {
        features = [detector featuresInImage:ciImage];
    }
    @catch (NSException *exception) {
    }
    CIQRCodeFeature *feature = features.firstObject;
    NSString *scannedResult = feature.messageString;
    if (scannedResult.length > 0) {
        if (self.block) {
            BOOL again = self.block(scannedResult, self);
            //是否需要再次扫描
            if (again){
                [self.session startRunning];
            }
        }
    }else{
        //没有扫描到继续扫描
        [self.session startRunning];
        [TZMProgressHUDManager showErrorWithStatus:@"未识别到二维码" inView:self.view];
    }
}

// 取消选取调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.session startRunning];
    [picker dismissViewControllerAnimated:NO completion:NULL];
}
@end
