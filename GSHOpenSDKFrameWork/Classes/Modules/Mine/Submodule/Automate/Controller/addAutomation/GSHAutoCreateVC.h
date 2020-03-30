//
//  GSHAutoCreateVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/11/13.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AddAutoVCType) {
    AddAutoVCTypeAdd  = 0,  // 添加联动
    AddAutoVCTypeEdit     = 1,    // 编辑联动
    AddAutoVCTypeTemplate = 2,  //  模版进入
};

@interface GSHAutoCreateTimeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;

@end

@interface GSHAutoCreateDeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *deviceIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceExtLabel;


@end

@interface GSHAutoCreateVC : UIViewController

+ (instancetype)autoCreateVCWithAutoVCType:(AddAutoVCType)addAutoVCType
                                  oldAutoM:(GSHAutoM *)oldAutoM
                               oldOssAutoM:(GSHOssAutoM *)oldOssAutoM ;

// 玩转 -- 领走 调用
+ (instancetype)autoCreateVCWithAutoListDataDictionary:(NSDictionary *)dataDictionary;

@property (nonatomic , assign) BOOL isAlertToNotiUser;

@property (copy , nonatomic) void(^addAutoSuccessBlock)(GSHOssAutoM *ossAutoM);
@property (copy , nonatomic) void(^updateAutoSuccessBlock)(GSHOssAutoM *ossAutoM);

@end

