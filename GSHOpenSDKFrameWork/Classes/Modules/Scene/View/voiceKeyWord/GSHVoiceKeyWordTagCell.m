//
//  GSHVoiceKeyWordTagCell.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/25.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHVoiceKeyWordTagCell.h"
#import "NSString+TZM.h"

@implementation GSHVoiceKeyWordTagCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = self.contentView.frame.size.height / 2.0;
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    
    UILabel *tagLabel = [[UILabel alloc] init];
    tagLabel.font = [UIFont systemFontOfSize:14];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    self.tagLabel = tagLabel;
    [self.contentView addSubview:tagLabel];
    
    UIButton *deleteButton = [[UIButton alloc] init];
    [deleteButton setImage:[UIImage ZHImageNamed:@"scene_voice_delete_icon"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:deleteButton];
    self.deleteButton = deleteButton;
    
}

- (void)setValueWithTagName:(NSString *)tagName {
    self.tagLabel.text = [NSString stringWithFormat:@"%@",tagName];
    self.tagLabel.frame = CGRectMake(10, 0, ([tagName tzm_getStrWidthWithFontSize:16] + 10), 30);
    
    self.deleteButton.frame = CGRectMake(CGRectGetMaxX(self.tagLabel.frame) + 15, 9, 12, 12);
}

- (void)deleteButtonClick:(UIButton *)button {
    if (self.deleteButtonClickBlock) {
        self.deleteButtonClickBlock();
    }
}

@end
