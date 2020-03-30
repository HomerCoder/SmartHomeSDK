//
//  GSHAddGWDetailVC.h
//  SmartHome
//
//  Created by gemdale on 2018/6/28.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceCategoryVC.h"

typedef enum : NSUInteger {
    GSHAddGWDetailVCTypeAdd,
    GSHAddGWDetailVCTypeEdit,
    GSHAddGWDetailVCTypeChange,
} GSHAddGWDetailVCType;

@interface GSHAddGWDetailVCCell : UITableViewCell
@end

@interface GSHAddGWDetailVC : UIViewController
@property (nonatomic , copy) void (^deviceEditSuccessBlock)(GSHDeviceM *deviceM);
+(instancetype)changeGWDetailVCWithGW:(NSString *)gwId family:(GSHFamilyM*)family;
+(instancetype)addGWDetailVCWithGW:(NSString *)gwId family:(GSHFamilyM*)family;
+(instancetype)editGWDetailVCWithDevice:(GSHDeviceM*)deviceM;
@end
