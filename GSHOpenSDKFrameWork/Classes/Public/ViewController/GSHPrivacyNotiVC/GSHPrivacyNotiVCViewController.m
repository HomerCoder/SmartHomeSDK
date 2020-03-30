//
//  GSHPrivacyNotiVCViewController.m
//  SmartHome
//
//  Created by zhanghong on 2020/1/9.
//  Copyright © 2020 gemdale. All rights reserved.
//

#import "GSHPrivacyNotiVCViewController.h"
#import "GSHWebViewController.h"

@interface GSHPrivacyNotiVCViewController () <UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation GSHPrivacyNotiVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"欢迎使用“智享Home”! 我们非常重视您的个人信息和隐私保护。在您使用“智享Home”服务之前，请仔细阅读《智享Home用户协议》《智享Home隐私政策》，我们将严格按照经您同意的各项条款使用您的个人信息，以便为您提供更好的服务。"];
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"user://"
                             range:[[attributedString string] rangeOfString:@"《智享Home用户协议》"]];
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"privacy://"
                             range:[[attributedString string] rangeOfString:@"《智享Home隐私政策》"]];
    [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSParagraphStyleAttributeName:paragraphStyle} range:attributedString.string.rangeOfAll];
    self.textView.attributedText = attributedString;

    self.textView.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#2EB0FF"],
                                     NSUnderlineColorAttributeName: [UIColor colorWithHexString:@"#222222"],
                                     NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
    
    self.textView.delegate = self;
    self.textView.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
    self.textView.scrollEnabled = NO;
    
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"user"]) {
        // 用户协议
        NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypeAgreement parameter:nil];        
        [[UIViewController visibleTopViewController].navigationController  pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
        return NO;
    } else if ([[URL scheme] isEqualToString:@"privacy"]) {
        // 隐私政策
        NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypePrivacy parameter:nil];
        [[UIViewController visibleTopViewController].navigationController  pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
        return NO;
    }
    return YES;
}

- (IBAction)noAgreeButtonClick:(id)sender {
    [self.view removeFromSuperview];
    [UIView animateWithDuration:0.6 delay:1 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.transform = CGAffineTransformScale(window.transform, 0.1, 0.1);
        window.alpha = 0;
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

- (IBAction)agreeButtonClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isShowPrivacyAlert"];
    [self.view removeFromSuperview];
}



@end
