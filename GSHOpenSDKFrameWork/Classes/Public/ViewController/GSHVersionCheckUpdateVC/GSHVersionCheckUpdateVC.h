//
//  GSHVersionCheckUpdateVC.h
//  Passenger
//
//  Created by mayer on 16/5/17.
//

#import <UIKit/UIKit.h>
#import "TZMBlanketVC.h"

typedef enum : NSUInteger {
    GSHVersionCheckUpdateVCTypeGW,
    GSHVersionCheckUpdateVCTypeApp,
} GSHVersionCheckUpdateVCType;

@interface GSHVersionCheckUpdateVC : TZMBlanketVC
+(instancetype)versionCheckUpdateVCWithTitle:(NSString*)title content:(NSString*)content type:(GSHVersionCheckUpdateVCType)type cancelTitle:(NSString*)cancelTitle cancelBlock:(void(^)(void))cancelBlock updateBlock:(void(^)(void))updateBlock;
@end
