//
//  GSHDeviceCategoryVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/9/17.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHDeviceCategoryHeadView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIButton *arrowButton;
@property (weak, nonatomic) IBOutlet UILabel *typeNameLabel;

@end

@interface GSHDeviceSearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *deviceIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceTypeNameLabel;

@end

@interface GSHDeviceCategoryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *deviceModelImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceModelNameLabel;

@end

@interface GSHDeviceCategoryNameCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftFlagLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@interface GSHDeviceCategoryVC : UIViewController

+(instancetype)deviceCategoryVC;

@end

NS_ASSUME_NONNULL_END
