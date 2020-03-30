//
//  GSHPushPopoverController.h
//  SmartHome
//
//  Created by gemdale on 2018/12/14.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHAppDelegate.h"
#import "Masonry.h"

@interface GSHPushPopoverController : UIViewController
+(GSHPushPopoverController*)showWithTitle:(NSString*)title content:(NSString*)content;
@end
