//
//  GSHVoiceKeyWordVC.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/24.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHVoiceKeyWordVC : UIViewController

@property (nonatomic , strong) NSMutableArray *keyWordArray;

@property (nonatomic , copy) void (^setVoiceKeyWordBlock)(NSArray *voiceKeyWordArray);

@end
