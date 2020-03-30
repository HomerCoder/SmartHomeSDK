//
//  GSHGateWayUpdateVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/1/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const GSHGateWayUpdateResult;

@interface GSHGateWayUpdateVC : UIViewController

+ (instancetype)gateWayUpdateVC;



@end

@interface GSHGateWayUpdateFirstCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTypeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellValueLabel;

@end

@interface GSHGateWayUpdateSecondCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *updateInfoLabel;

@end

NS_ASSUME_NONNULL_END
