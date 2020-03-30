//
//  TZMProgressBar.m
//  SmartHome
//
//  Created by gemdale on 2018/9/13.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "TZMProgressBar.h"

@interface TZMProgressBar()
@property (weak, nonatomic) IBOutlet UILabel *lblUpdate;
@property (weak, nonatomic) IBOutlet UIProgressView *progressUpdate;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@end

@implementation TZMProgressBar

- (instancetype)init
{
    NSArray *nib = [MYBUNDLE loadNibNamed:@"TZMProgressBar" owner:self options:nil];
    TZMProgressBar *progressBar = nib.firstObject;
    return progressBar;
}

- (void)setProgress:(float)progress{
    self.progressUpdate.progress = progress;
    self.lblUpdate.text = [NSString stringWithFormat:@"%d%%",(int)(progress * 100)];
}

-(float)progress{
    return self.progressUpdate.progress;
}

-(void)setText:(NSString *)text{
    self.lblText.text = text;
}

- (NSString *)text{
    return self.lblText.text;
}
@end
