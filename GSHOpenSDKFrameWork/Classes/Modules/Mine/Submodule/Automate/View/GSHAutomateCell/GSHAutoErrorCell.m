//
//  GSHAutoErrorCell.m
//  SmartHome
//
//  Created by zhanghong on 2019/11/25.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAutoErrorCell.h"

@implementation GSHAutoErrorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)refreshButtonClick:(id)sender {
    if (self.refreshButtonClickBlock) {
        self.refreshButtonClickBlock();
    }
}


@end
