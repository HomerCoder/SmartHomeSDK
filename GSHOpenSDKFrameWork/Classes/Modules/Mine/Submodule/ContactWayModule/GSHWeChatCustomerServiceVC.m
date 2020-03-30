//
//  GSHWeChatCustomerServiceVC.m
//  SmartHome
//
//  Created by gemdale on 2019/11/20.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHWeChatCustomerServiceVC.h"
#import "GSHAlertManager.h"

@interface GSHWeChatCustomerServiceVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewQRCode;
- (IBAction)touchNavRightBut:(UIButton *)sender;
@property (strong,nonatomic)NSURL *url;
@end

@implementation GSHWeChatCustomerServiceVC
+(instancetype)weChatCustomerServiceVCWithQRCodeUrl:(NSURL*)url{
    GSHWeChatCustomerServiceVC *vc = [GSHPageManager viewControllerWithSB:@"GSHContactWaySB" andID:@"GSHWeChatCustomerServiceVC"];
    vc.url = url;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.imageViewQRCode sd_setImageWithURL:self.url];
}

- (IBAction)touchNavRightBut:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1) {
            if (weakSelf.imageViewQRCode.image) {
                UIGraphicsBeginImageContextWithOptions(weakSelf.imageViewQRCode.bounds.size, NO, 0);
                CGContextRef ctx =  UIGraphicsGetCurrentContext();
                [weakSelf.imageViewQRCode.layer renderInContext:ctx];
                UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIImageWriteToSavedPhotosAlbum(newImage,weakSelf,@selector(image:didFinishSavingWithError:contextInfo:),nil);
            }
        }
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
    } andTitle:@"" andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:@"" cancelButtonTitle:@"取消" otherButtonTitles:@"保存图片",nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
    } else {
        [TZMProgressHUDManager showSuccessWithStatus:@"保存成功" inView:self.view];
    }
}

@end
