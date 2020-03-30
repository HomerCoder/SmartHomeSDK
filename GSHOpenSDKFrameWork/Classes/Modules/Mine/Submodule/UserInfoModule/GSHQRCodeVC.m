//
//  GSHQRCodeVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/14.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHQRCodeVC.h"
#import "GSHAlertManager.h"

@interface GSHQRCodeVC ()
@property(nonatomic,strong)GSHUserInfoM *userInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewQRCode;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewHead;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
- (IBAction)touchNavRightBut:(UIButton *)sender;
@property (assign, nonatomic) NSInteger inputCorrectionLevel;
@end

@implementation GSHQRCodeVC

+(instancetype)qrCodeVCWithUserInfo:(GSHUserInfoM*)userInfo{
    GSHQRCodeVC *vc = [GSHPageManager viewControllerWithSB:@"GSHUserInfoSB" andID:@"GSHQRCodeVC"];
    vc.userInfo = userInfo;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.inputCorrectionLevel = 0;
    [self refreshQRCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshQRCode{
    self.lblName.text = self.userInfo.nick;
    [self.imageViewHead sd_setImageWithURL:[NSURL URLWithString:self.userInfo.picPath] placeholderImage:[UIImage ZHImageNamed:@"app_headImage_default_icon"]];
    
    GSHFamilyMemberM *member = [GSHFamilyMemberM new];
    member.childUserName = self.userInfo.nick;
    member.childUserPicPath = self.userInfo.picPath;
    member.childUserPhone = self.userInfo.phone;
    member.childUserId = [GSHUserManager currentUser].userId;
    NSString *qrCodeString = [member yy_modelToJSONString];
    qrCodeString = qrCodeString.base64EncodedString;
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [qrCodeString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    switch ((self.inputCorrectionLevel % 4)) {
        case 0:
            [filter setValue:@"L" forKey:@"inputCorrectionLevel"];
            break;
        case 1:
            [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
            break;
        case 2:
            [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
            break;
        case 3:
            [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
            break;
        default:
            [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
            break;
    }
    CIImage *image = [filter outputImage];
    
    UIImage *uiImage =  [UIImage imageWithCIImage:image];
    
    
    UIImage *resized = nil;
    CGFloat width = 260;
    CGFloat height = 260;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    [uiImage drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imageViewQRCode.image = resized;
}

- (IBAction)touchNavRightBut:(UIButton *)sender {
    
    @weakify(self)
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        @strongify(self)
        if (buttonIndex == 1 || buttonIndex == 2) {
            if (buttonIndex == 1) {
                if (self.imageViewQRCode.image) {
                    UIGraphicsBeginImageContextWithOptions(self.imageViewQRCode.bounds.size, NO, 0);
                    CGContextRef ctx =  UIGraphicsGetCurrentContext();
                    [self.imageViewQRCode.layer renderInContext:ctx];
                    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
                    //保存到本地相机
                    UIImageWriteToSavedPhotosAlbum(newImage,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
                }
            } else if (buttonIndex == 2){
                self.inputCorrectionLevel++;
                [self refreshQRCode];
            }
        }
        
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
        
    } andTitle:@"" andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:@"" cancelButtonTitle:@"取消" otherButtonTitles:@"保存图片",@"重置二维码",nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
    } else {
        [TZMProgressHUDManager showSuccessWithStatus:@"保存成功" inView:self.view];
    }
}
@end
