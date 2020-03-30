//
//  GSHVoiceKeyWordTagCell.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/25.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHVoiceKeyWordTagCell : UICollectionViewCell

//标签
@property (nonatomic,strong) UILabel *tagLabel;

@property (nonatomic,strong) UIButton *deleteButton;

@property (nonatomic, copy) void (^deleteButtonClickBlock)(void);

- (void)setValueWithTagName:(NSString *)tagName;

@end
