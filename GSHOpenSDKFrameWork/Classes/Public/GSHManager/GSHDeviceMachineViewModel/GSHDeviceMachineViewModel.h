//
//  GSHAddSceneVCViewModel.h
//  SmartHome
//
//  Created by zhanghong on 2018/12/18.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHDeviceVC.h"

@interface GSHDeviceMachineViewModel : NSObject

//获取device没有homePageIcon这个字段时，可以通过此方法获取的本地的URL
+(NSURL*)deviceModelImageUrlWithDevice:(GSHDeviceM*)device;
//根据device和deviceEditType弹出不同的设备操作界面
+ (void)jumpToDeviceHandleVCWithVC:(UIViewController *)vc deviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType deviceSetCompleteBlock:(void(^)(NSArray *exts))deviceSetCompleteBlock;
// 根据设备的初始输出当前状态字符串
+(NSString *)getDeviceShowStrWithDeviceM:(GSHDeviceM *)deviceM;
// 根据设备实时数据输出当前状态字符串
+(NSString *)getDeviceRealTimeStateStrWithDeviceType:(NSString *)deviceType RealTimeDict:(NSDictionary *)realTimeDict;
// 设备选中时初始值获取
+ (NSArray *)getInitExtsWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType;
@end
