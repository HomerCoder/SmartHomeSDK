//
//  GSHDeviceEditVC.h
//  SmartHome
//
//  Created by gemdale on 2018/7/6.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GSHDeviceEditVCCellModelTypeInput,
    GSHDeviceEditVCCellModelTypeChoose,
    GSHDeviceEditVCCellModelTypeText,
    GSHDeviceEditVCCellModelTypeSwitch,
} GSHDeviceEditVCCellModelType;

typedef enum : NSUInteger {
    GSHDeviceTypeOneWaySwitch,      // 一路开关
    GSHDeviceTypeTwoWaySwitch,      // 二路开关
    GSHDeviceTypeThreeWaySwitch,    // 三路开关
    GSHDeviceTypeTwoWayCurtain,     // 二路窗帘
    GSHDeviceTypeScenePanel,        // 六路场景面板
    GSHDeviceTypeOther,
} GSHDeviceEditType;

@interface GSHDeviceEditVCCellModel : GSHBaseModel
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *text;
@property(nonatomic,copy)NSString *placeholder;
@property(nonatomic,assign)GSHDeviceEditVCCellModelType type;

@property(nonatomic,assign)UITableViewCellAccessoryType accessoryType;

+(instancetype)modelWithTitle:(NSString*)title text:(NSString*)text placeholder:(NSString*)placeholder type:(GSHDeviceEditVCCellModelType)type;
@end

@interface GSHDeviceEditVCInputCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *tfText;
@property(nonatomic,strong)GSHDeviceEditVCCellModel *model;
@end

@interface GSHDeviceEditVCChooseCell : UITableViewCell
@property(nonatomic,strong)GSHDeviceEditVCCellModel *model;

@end

@interface GSHDeviceEditVCTextCell : UITableViewCell
@property(nonatomic,strong)GSHDeviceEditVCCellModel *model;
@end

@interface GSHDeviceEditVCSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *tfText;
@property (weak, nonatomic) IBOutlet UISwitch *deviceSwitch;

@property(nonatomic,strong)GSHDeviceEditVCCellModel *model;

@property (nonatomic , copy) void (^switchButtonClickBlock)(UISwitch *deviceSwitch);
@end

typedef enum : NSUInteger {
    GSHDeviceEditVCTypeAdd,
    GSHDeviceEditVCTypeEdit,
} GSHDeviceEditVCType;

@interface GSHDeviceEditVC : UIViewController

@property (nonatomic , assign) BOOL isLastDevice;

@property (nonatomic , copy) void (^deviceEditSuccessBlock)(GSHDeviceM *deviceM);

@property (nonatomic , copy) void (^deviceAddSuccessBlock)(NSString *deviceId);

+ (instancetype)deviceEditVCWithDevice:(GSHDeviceM*)device type:(GSHDeviceEditVCType)type ;

@end
