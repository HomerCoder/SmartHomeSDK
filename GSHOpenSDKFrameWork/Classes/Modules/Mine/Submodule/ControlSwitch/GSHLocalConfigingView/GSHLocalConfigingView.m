//
//  GSHLocalConfigingView.m
//  SmartHome
//
//  Created by zhanghong on 2019/2/22.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHLocalConfigingView.h"
#import <SDWebImage/UIImage+GIF.h>

@implementation GSHLocalConfigingView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
//        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"localConfig_gif@2x" ofType:@"gif"];
//        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
//        UIImage *image = [UIImage sd_animatedGIFWithData:imageData];
//        [self.gifImageView setImage:image];
    }
    return self;
}

- (IBAction)closeButtonClick:(id)sender {
    if (self.closeButtonClickBlock) {
        self.closeButtonClickBlock();
    }
}


@end
