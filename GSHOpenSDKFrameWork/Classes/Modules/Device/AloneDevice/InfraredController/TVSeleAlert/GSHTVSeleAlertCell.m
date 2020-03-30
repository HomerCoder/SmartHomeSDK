//
//  GSHTVSeleAlertCell.m
//  SmartHome
//
//  Created by gemdale on 2019/4/10.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHTVSeleAlertCell.h"

@interface GSHTVSeleAlertCell()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imageviewSele;

@end

@implementation GSHTVSeleAlertCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.imageviewSele.highlighted = selected;
    // Configure the view for the selected state
}

-(void)refreshName:(NSString*)name{
    self.lblName.text = name;
}

@end
