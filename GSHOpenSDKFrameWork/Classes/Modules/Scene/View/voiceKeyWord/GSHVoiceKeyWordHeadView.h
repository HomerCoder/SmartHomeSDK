//
//  GSHVoiceKeyWordHeadView.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/15.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHVoiceKeyWordHeadView : UIView

@property (weak, nonatomic) IBOutlet UITextField *keyWordTextField;

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (weak, nonatomic) IBOutlet UIView *flagView;

@property (copy, nonatomic) void (^addButtonClickBlock)(NSString *keyWordStr);

@end
