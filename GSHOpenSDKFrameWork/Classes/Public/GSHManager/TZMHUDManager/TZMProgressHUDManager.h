//
//
//
//
//
//

#import <UIKit/UIKit.h>

@interface TZMProgressHUDManager : NSObject
+ (void)showInView:(UIView*)view;
+ (void)showWithStatus:(NSString*)status inView:(UIView*)view;
+ (void)showProgress:(float)progress inView:(UIView*)view;
+ (void)showProgress:(float)progress status:(NSString*)status inView:(UIView*)view;
+ (void)showInfoWithStatus:(NSString*)status inView:(UIView*)view;
+ (void)showSuccessWithStatus:(NSString*)status inView:(UIView*)view;
+ (void)showErrorWithStatus:(NSString*)status inView:(UIView*)view;
+ (void)dismissInView:(UIView*)view;
@end

