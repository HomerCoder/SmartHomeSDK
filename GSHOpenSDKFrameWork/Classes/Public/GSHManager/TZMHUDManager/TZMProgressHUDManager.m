//
//
//
//
//

#import "TZMProgressHUDManager.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImage+GIF.h>
#import <Lottie/LOTAnimationView.h>
#import <Masonry.h>

@interface TZMProgressHUDManager ()
@end

@implementation TZMProgressHUDManager {
}

+ (MBProgressHUD*)mbProgressHUDWithView:(UIView*)view{
    if (!view) {
        return nil;
    }
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.detailsLabel.font = [UIFont systemFontOfSize:14.0];
        hud.contentColor = [UIColor colorWithHexString:@"#3C4366"];
        hud.minSize = CGSizeMake(100, 100);
        hud.margin = 5;
        hud.bezelView.color = [UIColor whiteColor];
        hud.layer.shadowColor = [UIColor blackColor].CGColor;
        hud.layer.shadowOffset = CGSizeMake(0, 4);
        hud.layer.shadowOpacity = 0.05;
//        hud.backgroundView.blurEffectStyle = UIBlurEffectStyleDark;
    }
    return hud;
}

+ (void)showInView:(UIView*)view{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *hud = [self mbProgressHUDWithView:view];
        hud.mode = MBProgressHUDModeCustomView;
        LOTAnimationView *animationView = [LOTAnimationView animationNamed:@"loadingJson" inBundle:MYBUNDLE];
        animationView.loopAnimation = YES;
        [animationView playFromProgress:0 toProgress:1 withCompletion:^(BOOL animationFinished) {

        }];
        hud.customView = animationView;
        [hud.customView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(60));
            make.height.equalTo(@(60));
        }];
    });
}
+ (void)showWithStatus:(NSString*)status inView:(UIView*)view{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *hud = [self mbProgressHUDWithView:view];
        hud.mode = MBProgressHUDModeCustomView;
        hud.detailsLabel.text = status;
        LOTAnimationView *animationView = [LOTAnimationView animationNamed:@"loadingJson" inBundle:MYBUNDLE];
        animationView.loopAnimation = YES;
        [animationView playFromProgress:0 toProgress:1 withCompletion:^(BOOL animationFinished) {

        }];
        hud.customView = animationView;
        [hud.customView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(60));
            make.height.equalTo(@(60));
        }];
    });
}
+ (void)showProgress:(float)progress inView:(UIView*)view{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *hud = [self mbProgressHUDWithView:view];
        hud.customView = nil;
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.progress = progress;
    });
}
+ (void)showProgress:(float)progress status:(NSString*)status inView:(UIView*)view{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *hud = [self mbProgressHUDWithView:view];
        hud.customView = nil;
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.detailsLabel.text = status;
        hud.progress = progress;
    });
}
+ (void)showInfoWithStatus:(NSString*)status inView:(UIView*)view{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *hud = [self mbProgressHUDWithView:view];
        hud.detailsLabel.text = status;
        hud.mode = MBProgressHUDModeCustomView;
        CGFloat s = status.length / 10 + 0.5;
        [hud hideAnimated:YES afterDelay:s > 1 ? s : 1];
        hud.customView = [[UIImageView alloc]initWithImage:[UIImage ZHImageNamed:@"TZMProgressHUDManager_error"]];
    });
}
+ (void)showSuccessWithStatus:(NSString*)status inView:(UIView*)view{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *hud = [self mbProgressHUDWithView:view];
        hud.detailsLabel.text = status;
        hud.mode = MBProgressHUDModeCustomView;
        CGFloat s = status.length / 10 + 0.5;
        [hud hideAnimated:YES afterDelay:s > 1 ? s : 1];
        hud.customView = [[UIImageView alloc]initWithImage:[UIImage ZHImageNamed:@"TZMProgressHUDManager_success"]];
    });
}
+ (void)showErrorWithStatus:(NSString*)status inView:(UIView*)view{
    dispatch_async_on_main_queue(^{
        MBProgressHUD *hud = [self mbProgressHUDWithView:view];
        hud.detailsLabel.text = status;
        hud.mode = MBProgressHUDModeCustomView;
        CGFloat s = status.length / 10 + 0.5;
        [hud hideAnimated:YES afterDelay:s > 1 ? s : 1];
        hud.customView = [[UIImageView alloc]initWithImage:[UIImage ZHImageNamed:@"TZMProgressHUDManager_error"]];
    });
}
+ (void)dismissInView:(UIView*)view{
    dispatch_async_on_main_queue(^{
        [MBProgressHUD hideHUDForView:view animated:YES];
    });
}
@end
