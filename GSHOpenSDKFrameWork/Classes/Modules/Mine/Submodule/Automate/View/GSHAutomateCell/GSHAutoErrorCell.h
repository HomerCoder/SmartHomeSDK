//
//  GSHAutoErrorCell.h
//  SmartHome
//
//  Created by zhanghong on 2019/11/25.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHAutoErrorCell : UITableViewCell

@property (copy , nonatomic) void(^refreshButtonClickBlock)(void);

@end

NS_ASSUME_NONNULL_END
