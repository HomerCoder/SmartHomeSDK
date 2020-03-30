//
//  GSHVoiceVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/29.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHVoiceVC : UIViewController
+ (instancetype)voiceVC;
@end

@interface GSHVoiceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@end
