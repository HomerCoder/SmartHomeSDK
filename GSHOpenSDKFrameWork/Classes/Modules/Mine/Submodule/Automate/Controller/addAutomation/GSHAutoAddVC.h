//
//  GSHAutoAddVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/11/12.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHAutoAddCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *templateImageView;

@end

@interface GSHAutoAddVC : UITableViewController

+ (instancetype)autoAddVC;

@property (copy,nonatomic) void(^addAutoSuccessBlock)(GSHOssAutoM *ossAutoM);
@property (copy,nonatomic) void(^updateAutoSuccessBlock)(GSHOssAutoM *ossAutoM);

@end

NS_ASSUME_NONNULL_END
