//
//  GSHAddSceneVCViewModel.m
//  SmartHome
//
//  Created by zhanghong on 2018/12/18.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHDeviceMachineViewModel.h"

#import "GSHThreeWaySwitchHandleVC.h"
#import "GSHAirConditionerHandleVC.h"
#import "GSHNewWindHandleVC.h"
#import "GSHUnderFloorHeatVC.h"
#import "GSHAirConditionerSetVC.h"
#import "GSHScenePanelHandleVC.h"
#import "GSHGateMagnetismSetVC.h"
#import "GSHTwoWayCurtainHandleVC.h"
#import "GSHHumitureSensorSetVC.h"
#import "GSHDeviceSocketHandleVC.h"
#import "GSHAirBoxSensorSetVC.h"
#import "GSHAlarmSensorSetVC.h"
#import "GSHAdjustLightSetVC.h"
#import "GSHAdjustLightHandleVC.h"
#import "GSHSensorGroupVC.h"
#import "GSHInfraredVirtualDeviceTVVC.h"
#import "GSHInfraredControllerInfoVC.h"
#import "GSHInfraredVirtualDeviceAirConditionerVC.h"
#import "GSHShengBiKePlayVC.h"
#import "GSHDoorLackVC.h"
#import "GSHBothwayCurtainSetVC.h"
#import "GSHDoorLackSetVC.h"

@implementation GSHDeviceMachineViewModel

static NSDictionary *json;
+(NSURL*)deviceModelImageUrlWithDevice:(GSHDeviceM*)device{
    if (!json) {
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"device_type_icon_json" ofType:@"txt"];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
        json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    }
    if (device.deviceType.stringValue) {
        NSDictionary *typeDic = [json objectForKey:device.deviceType.stringValue];
        NSString *typeUrl = [typeDic objectForKey:@"picPath"];
        [NSURL URLWithString:typeUrl];
        if (device.deviceModel.stringValue) {
            NSDictionary *modelDic = [typeDic objectForKey:@"model"];
            if (modelDic) {
                NSString *modelUrl = [modelDic objectForKey:device.deviceModel.stringValue];
                if (modelUrl) {
                    return [NSURL URLWithString:modelUrl];
                }
            }
        }
        if (typeUrl) {
            return [NSURL URLWithString:typeUrl];
        }
    }
    return nil;
}

// 添加场景 -- 跳转设备操作页面
+ (void)jumpToDeviceHandleVCWithVC:(UIViewController *)vc deviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType deviceSetCompleteBlock:(void(^)(NSArray *exts))deviceSetCompleteBlock{
    GSHDeviceVC *showVC;
    UIViewController *pushVC;
    if ([deviceM.deviceType isEqualToNumber:GSHBothwayCurtainDeviceType]) {
        // 双向幕帘
        GSHBothwayCurtainSetVC *jumpVC = [GSHBothwayCurtainSetVC bothwayCurtainSetVCWithDeviceM:deviceM];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHShengBiKeDeviceType]) {
        showVC = [GSHShengBiKePlayVC shengBiKePlayVCWithDevice:deviceM];
    }else if ([deviceM.deviceType isEqualToNumber:GSHAdjustLightDeviceType]) {
        if (deviceEditType == GSHDeviceVCTypeControl) {
            showVC = [GSHAdjustLightHandleVC adjustLightHandleVCWithDevice:deviceM];
        }else{
            showVC = [GSHAdjustLightSetVC adjustLightSetVCWithDevice:deviceM type:deviceEditType block:deviceSetCompleteBlock];
        }
    }else if ([deviceM.deviceType isEqualToNumber:GSHDoorLackDeviceType]) {
        if (deviceEditType == GSHDeviceVCTypeControl) {
            showVC = [GSHDoorLackVC doorLackVCWithDevice:deviceM];
        }else{
            showVC = [GSHDoorLackSetVC doorLackSetVCWithDevice:deviceM type:deviceEditType block:deviceSetCompleteBlock];
        }
    }else if ([deviceM.deviceType isEqualToNumber:GSHNewWindDeviceType]) {
        // 新风面板
        GSHNewWindHandleVC *jumpVC = [GSHNewWindHandleVC newWindHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHAirConditionerDeviceType]) {
        //空调
        if (deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
            GSHAirConditionerSetVC *jumpVC = [GSHAirConditionerSetVC airConditionerSetVCWithDeviceM:deviceM deviceEditType:deviceEditType];
            if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
            showVC = jumpVC;
        } else {
            GSHAirConditionerHandleVC *jumpVC = [GSHAirConditionerHandleVC airConditionerHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType];
            if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
            showVC = jumpVC;
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHOneWaySwitchDeviceType] ||
               [deviceM.deviceType isEqualToNumber:GSHTwoWaySwitchDeviceType] ||
               [deviceM.deviceType isEqualToNumber:GSHThreeWaySwitchDeviceType]) {
        // 开关
        GSHThreeWaySwitchHandleVC *jumpVC = [GSHThreeWaySwitchHandleVC threeWaySwitchHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType];
        if ([deviceM.deviceType isEqualToNumber:GSHOneWaySwitchDeviceType]) {
            jumpVC.switchType = SwitchHandleVCTypeOneWay;
        } else if ([deviceM.deviceType isEqualToNumber:GSHTwoWaySwitchDeviceType]) {
            jumpVC.switchType = SwitchHandleVCTypeTwoWay;
        } else if ([deviceM.deviceType isEqualToNumber:GSHThreeWaySwitchDeviceType]) {
            jumpVC.switchType = SwitchHandleVCTypeThreeWay;
        }
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHCurtainDeviceType]) {
        // 开合窗帘电机
        GSHTwoWayCurtainHandleVC *jumpVC = [GSHTwoWayCurtainHandleVC twoWayCurtainHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType type:GSHTwoWayCurtainMotorHandleVC];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHOneWayCurtainDeviceType]) {
        // 一路窗帘开关
        GSHTwoWayCurtainHandleVC *jumpVC = [GSHTwoWayCurtainHandleVC twoWayCurtainHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType type:GSHTwoWayCurtainHandleVCOneWay];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHTwoWayCurtainDeviceType]) {
        // 二路窗帘开关
        GSHTwoWayCurtainHandleVC *jumpVC = [GSHTwoWayCurtainHandleVC twoWayCurtainHandleVCWithDeviceM:deviceM deviceEditType:deviceEditType type:GSHTwoWayCurtainHandleVCTwoWay];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    }else if ([deviceM.deviceType isEqualToNumber:GSHUnderFloorDeviceType]) {
        // 地暖
        GSHUnderFloorHeatVC *jumpVC = [GSHUnderFloorHeatVC underFloorHeatHandleVCDeviceM:deviceM deviceEditType:deviceEditType];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHScenePanelDeviceType]) {
        // 场景面板
        GSHScenePanelHandleVC *jumpVC = [GSHScenePanelHandleVC scenePanelHandleVCDeviceM:deviceM deviceEditType:deviceEditType];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHSocket1DeviceType]) {
        // 智能插座
        GSHDeviceSocketHandleVC *jumpVC = [GSHDeviceSocketHandleVC deviceSocketHandleVCDeviceM:deviceM deviceEditType:deviceEditType];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHSocket2DeviceType]) {
       // 智能插座
       GSHDeviceSocketHandleVC *jumpVC = [GSHDeviceSocketHandleVC deviceSocketHandleVCDeviceM:deviceM deviceEditType:deviceEditType];
       if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
       showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHSensorGroupDeviceType]) {
        //组合传感器
        if (deviceEditType == GSHDeviceVCTypeControl) {
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
               [TZMProgressHUDManager showInfoWithStatus:@"离线环境无法查看" inView:[UIViewController visibleTopViewController].view];
               return;
            }
            pushVC = [GSHSensorGroupVC sensorGroupVCWithDeviceM:deviceM];
        }
    }else if ([deviceM.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
        // 空气盒子 （PM2.5 + 温湿度）
        GSHAirBoxSensorSetVC *jumpVC = [GSHAirBoxSensorSetVC airBoxSensorSetVCWithDeviceM:deviceM];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHHuanjingSensorDeviceType]) {
        // 环境面板
        GSHAirBoxSensorSetVC *jumpVC = [GSHAirBoxSensorSetVC airBoxSensorSetVCWithDeviceM:deviceM];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
    } else if ([deviceM.deviceType isEqualToNumber:GSHHumitureSensorDeviceType]) {
       // 温湿度传感器
       GSHHumitureSensorSetVC *jumpVC = [GSHHumitureSensorSetVC humitureSensorSetVCWithDeviceM:deviceM];
       if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
       showVC = jumpVC;
   } else if ([deviceM.deviceType isEqualToNumber:GSHGateMagetismSensorDeviceType]) {
       // 门磁
       GSHGateMagnetismSetVC *jumpVC = [GSHGateMagnetismSetVC gateMagnetismSetVCWithDeviceM:deviceM];
       if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
       showVC = jumpVC;
   } else if ([deviceM.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType] ||
            [deviceM.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType] ||
            [deviceM.deviceType isEqualToNumber:GSHGasSensorDeviceType] ||
            [deviceM.deviceType isEqualToNumber:GSHSOSSensorDeviceType] ||
            [deviceM.deviceType isEqualToNumber:GSHInfrareCurtainDeviceType] ||
            [deviceM.deviceType isEqualToNumber:GSHAudibleVisualAlarmDeviceType] ||
            [deviceM.deviceType isEqualToNumber:GSHInfrareReactionDeviceType] ||
              [deviceM.deviceType isEqualToNumber:GSHCoGasSensorDeviceType] ||
              [deviceM.deviceType isEqualToNumber:GSHCombustibleGasDeviceType]) {
        NSInteger sensorType;
        if ([deviceM.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType]) {
          // 人体红外传感器
          sensorType = GSHSomatasensorySensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType]) {
          // 水浸传感器
          sensorType = GSHWaterLoggingSensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHGasSensorDeviceType]) {
          // 气体传感器
          sensorType = GSHSmogGasSensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHSOSSensorDeviceType]) {
          // 紧急按钮
          sensorType = GSHSOSSensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHInfrareCurtainDeviceType]) {
          // 红外幕帘
          sensorType = GSHInfrareCurtainSensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHAudibleVisualAlarmDeviceType]) {
          // 声光报警器
          sensorType = GSHAudibleVisualAlarmSensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHCoGasSensorDeviceType]) {
          // 一氧化碳传感器
          sensorType = GSHCoGasSensor;
        } else if ([deviceM.deviceType isEqualToNumber:GSHCombustibleGasDeviceType]) {
          // 可燃气体传感器
          sensorType = GSHCombustibleSensor;
        } else {
          // 红外人体感应面板
          sensorType = GSHInfrareReactionSensor;
        }
        GSHAlarmSensorSetVC *jumpVC = [GSHAlarmSensorSetVC alarmSensorSetVCWithDeviceM:deviceM sensorType:sensorType deviceEditType:deviceEditType];
        if (deviceSetCompleteBlock) jumpVC.deviceSetCompleteBlock = deviceSetCompleteBlock;
        showVC = jumpVC;
   }else if ([deviceM.deviceType isEqualToNumber:GSHInfraredControllerDeviceType]) {
       //红外设备
       if (deviceM.deviceModel.integerValue < 0) {
           [TZMProgressHUDManager showWithStatus:@"获取遥控器参数中" inView:[UIViewController visibleTopViewController].view];
           [GSHInfraredControllerManager getKuKongDeviceListWithParentDeviceId:nil familyId:[GSHOpenSDKShare share].currentFamily.familyId kkDeviceType:nil deviceSn:deviceM.deviceSn block:^(NSArray<GSHKuKongInfraredDeviceM *> *list, NSError *error) {
               if (error) {
                   [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:[UIViewController visibleTopViewController].view];
               }else{
                   [TZMProgressHUDManager dismissInView:[UIViewController visibleTopViewController].view];
                   GSHDeviceVC *page;
                   GSHKuKongInfraredDeviceM *device = list.firstObject;
                   device.onlineStatus = deviceM.onlineStatus;
                   switch (device.kkDeviceType.integerValue) {
                       case 1:
                           page = [GSHInfraredVirtualDeviceTVVC tvHandleVCWithDevice:device];
                           break;
                       case 2:
                           page = [GSHInfraredVirtualDeviceTVVC tvHandleVCWithDevice:device];
                           break;
                       case 5:
                           page = [GSHInfraredVirtualDeviceAirConditionerVC infraredVirtualDeviceAirConditionerVCWithDevice:device];
                           break;
                       default:
                           break;
                   }
                   [page show];
               }
           }];
           return;
       }else{
           pushVC = [GSHInfraredControllerInfoVC infraredControllerInfoVCWithDevice:deviceM];
       }
   }
    if (pushVC) {
        pushVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:pushVC animated:YES];
        return;
    }
    if (showVC) {
        showVC.deviceEditType = deviceEditType;
        [showVC show];
        return;
    }
}

+(NSString *)getDeviceRealTimeStateStrWithDeviceType:(NSString *)deviceType RealTimeDict:(NSDictionary *)realTimeDict {
    NSString *showStateStr = @"";
    if ([deviceType isEqualToString:GSHOneWaySwitchDeviceType.stringValue]) {
        // 一路开关
        NSString *value = [realTimeDict objectForKey:GSHOneWaySwitch_firstMeteId];
        showStateStr = [NSString stringWithFormat:@"%@",[value intValue] == 0 ? @"关":@"开"];
    } else if ([deviceType isEqualToString:GSHTwoWaySwitchDeviceType.stringValue]) {
        // 二路开关
        NSString *value1 = [realTimeDict objectForKey:GSHTwoWaySwitch_firstMeteId];
        NSString *value2 = [realTimeDict objectForKey:GSHTwoWaySwitch_secondMeteId];
        showStateStr = [NSString stringWithFormat:@"%@ | %@",[value1 intValue] == 0 ? @"关":@"开" ,[value2 intValue] == 0 ? @"关":@"开"];
    }  else if ([deviceType isEqualToString:GSHThreeWaySwitchDeviceType.stringValue]) {
        // 三路开关
        NSString *value1 = [realTimeDict objectForKey:GSHThreeWaySwitch_firstMeteId];
        NSString *value2 = [realTimeDict objectForKey:GSHThreeWaySwitch_secondMeteId];
        NSString *value3 = [realTimeDict objectForKey:GSHThreeWaySwitch_thirdMeteId];
        showStateStr = [NSString stringWithFormat:@"%@ | %@ | %@",[value1 intValue] == 0 ? @"关":@"开" ,[value2 intValue] == 0 ? @"关":@"开" ,[value3 intValue] == 0 ? @"关":@"开"];
    } else if ([deviceType isEqualToString:GSHNewWindDeviceType.stringValue]) {
        // 新风
        NSString *value = [realTimeDict objectForKey:GSHNewWind_SwitchMeteId];
        NSString *windSpeedValue = [realTimeDict objectForKey:GSHNewWind_WindSpeedMeteId];
        NSString *windSpeedStr = @"";
        if ([windSpeedValue isEqualToString:@"1"]) {
            windSpeedStr = @"低风";
        } else if ([windSpeedValue isEqualToString:@"2"]) {
            windSpeedStr = @"中风";
        } else if ([windSpeedValue isEqualToString:@"3"]) {
            windSpeedStr = @"高风";
        }
        if ([value intValue] == 0) {
            showStateStr = @"关";
        } else {
            if (windSpeedStr.length > 0) {
                showStateStr = [NSString stringWithFormat:@"开 | %@",windSpeedStr];
            } else {
                showStateStr = @"开";
            }
        }
    } else if ([deviceType isEqualToString:GSHAirConditionerDeviceType.stringValue]) {
        // 空调
        NSString *value = [realTimeDict objectForKey:GSHAirConditioner_SwitchMeteId];
        NSString *modelValue = [realTimeDict objectForKey:GSHAirConditioner_ModelMeteId];
        NSString *temperatureValue = [realTimeDict objectForKey:GSHAirConditioner_TemperatureMeteId];
        NSString *windSpeedValue = [realTimeDict objectForKey:GSHAirConditioner_WindSpeedMeteId];
        NSString *temperatureStr = @"";
        NSString *modelStr = @"";
        NSString *windSpeedStr = @"";
        
        if (value.integerValue == 0) {
            // 关
            showStateStr = [NSString stringWithFormat:@"%@",[value intValue] == 0 ? @"关":@"开"];
        } else {
            if ([modelValue isEqualToString:@"3"]) {
                modelStr = @"制冷";
            } else if ([modelValue isEqualToString:@"4"]) {
                modelStr = @"制热";
            } else if ([modelValue isEqualToString:@"7"]) {
                modelStr = @"送风";
            } else if ([modelValue isEqualToString:@"8"]) {
                modelStr = @"除湿";
            }
            temperatureStr = [NSString stringWithFormat:@"%@˚C",temperatureValue];
            
            if (windSpeedValue.integerValue == 1) {
                windSpeedStr = @"低风";
            } else if (windSpeedValue.integerValue == 2) {
                windSpeedStr = @"中风";
            } else if (windSpeedValue.integerValue == 3) {
                windSpeedStr = @"高风";
            }
            
            NSMutableString *attributeStr = [NSMutableString stringWithString:@"开"];
            NSArray *attributeArr = @[temperatureStr,modelStr,windSpeedStr];
            for (NSString *str in attributeArr) {
                if (str.length > 0) {
                    [attributeStr appendString:[NSString stringWithFormat:@" | %@",str]];
                }
            }
            showStateStr = (NSString *)attributeStr;
        }
    } else if ([deviceType isEqualToString:GSHScenePanelDeviceType.stringValue]) {
        // 场景开关面板
        showStateStr = @"在线";
    } else if ([deviceType isEqualToString:GSHCurtainDeviceType.stringValue]) {
        // 开合窗帘电机
        NSString *value = [realTimeDict objectForKey:GSHCurtain_SwitchMeteId];
        NSString *deviceStateStr = @"";
        if (value.intValue == 0) {
            deviceStateStr = @"开";
        } else if (value.intValue == 1) {
            deviceStateStr = @"关";
        } else if (value.intValue == 2) {
            deviceStateStr = @"暂停";
        }
        deviceStateStr = @"开";
        NSString *percentValue = [realTimeDict objectForKey:GSHCurtain_PercentMeteId];
        NSString *percentStr = @"";
        if (percentValue) {
            percentStr = [NSString stringWithFormat:@"%@%%",percentValue];
        }
        if ([deviceStateStr isEqualToString:@"关"]) {
            showStateStr = deviceStateStr;
        } else {
            if (percentStr.length > 0) {
                showStateStr = [NSString stringWithFormat:@"%@ | %@",deviceStateStr,percentStr];
            } else {
                showStateStr = deviceStateStr;
            }
        }
    } else if ([deviceType isEqualToString:GSHOneWayCurtainDeviceType.stringValue]) {
        // 一路窗帘开关
        showStateStr = @"在线";
    } else if ([deviceType isEqualToString:GSHTwoWayCurtainDeviceType.stringValue]) {
        // 二路窗帘开关
        showStateStr = @"在线";
    } else if ([deviceType isEqualToString:GSHUnderFloorDeviceType .stringValue]) {
        // 地暖
        NSString *value = [realTimeDict objectForKey:GSHUnderFloor_SwitchMeteId];    // 开关
        NSString *temperatureValue = [realTimeDict objectForKey:GSHUnderFloor_TemperatureMeteId];   // 温度
        if ([value intValue] == 0) {
            showStateStr = @"关";
        } else {
            showStateStr = [NSString stringWithFormat:@"开 | %@˚C",temperatureValue];
        }
    } else if ([deviceType isEqualToString:GSHSocket1DeviceType.stringValue]) {
        // 智能插座
        NSString *openSwitchValue = [realTimeDict objectForKey:GSHSocket1_SocketSwitchMeteId];    // 插座开关
        NSString *usbSwitchValue = [realTimeDict objectForKey:GSHSocket1_USBSwitchMeteId];   // USB开关
        showStateStr = [NSString stringWithFormat:@"插座: %@ | USB: %@",openSwitchValue.intValue == 1 ? @"开" : @"关" , usbSwitchValue.intValue == 1 ? @"开" : @"关"];
    } else if ([deviceType isEqualToString:GSHSocket2DeviceType.stringValue]) {
       // 智能插座
       NSString *openSwitchValue = [realTimeDict objectForKey:GSHSocket2_SocketSwitchMeteId];    // 插座开关
       showStateStr = [NSString stringWithFormat:@"插座: %@",openSwitchValue.intValue == 1 ? @"开" : @"关"];
    } else if ([deviceType isEqualToString:GSHAudibleVisualAlarmDeviceType.stringValue]) {
        // 声光报警器
        showStateStr = @"在线";
    } else if ([deviceType isEqualToString:GSHAdjustLightDeviceType.stringValue]) {
        // 调光开关
        NSString *off = [realTimeDict objectForKey:GSHAdjustLight_offMeteId];    // 插座开关
        NSString *wense = [realTimeDict objectForKey:GSHAdjustLight_wenSeMeteId];    // 插座开关
        NSString *light = [realTimeDict objectForKey:GSHAdjustLight_lightMeteId];   // USB开关
        NSMutableString *string = [NSMutableString string];
        if (off) {
            [string appendFormat:@"%@ |",off.intValue == 1 ? @"开" : @"关" ];
        }
        if (off.intValue == 1) {
            if (wense) {
                [string appendFormat:@"%@ |",wense];
            }
            if (light) {
                [string appendFormat:@"%@%% |",light];
            }
        }
        NSInteger index = string.length > 2 ? string.length - 2 : 0;
        showStateStr = [string substringToIndex:index];
    }
    return showStateStr;
}

+(NSString *)getDeviceShowStrWithDeviceM:(GSHDeviceM *)deviceM {
    NSString *showStr = @"";
    if ([deviceM.deviceType isEqual:GSHBothwayCurtainDeviceType]) {
        //  双向幕帘
        NSString *value = deviceM.exts.firstObject.rightValue;
        if (value.intValue == 0) {
            showStr = @"由内向外";
        } else if (value.intValue == 1) {
            showStr = @"由外向内";
        } else {
            showStr = @"正常";
        }
    } else if ([deviceM.deviceType isEqual:GSHAdjustLightDeviceType]) {
        NSString *str1 = @"",*str2 = @"",*str3 = @"";
        // 调光开关
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHAdjustLight_offMeteId]) {
                str1 = [NSString stringWithFormat:@"%@",extM.rightValue.intValue == 0 ? @"关":@"开"];
            } else if ([extM.basMeteId isEqualToString:GSHAdjustLight_wenSeMeteId]) {
                if (extM.rightValue) {
                    str2 = [NSString stringWithFormat:@"色温%@K",extM.rightValue];
                }
            } else if ([extM.basMeteId isEqualToString:GSHAdjustLight_lightMeteId]) {
                if (extM.rightValue) {
                    str3 = [NSString stringWithFormat:@"亮度%@%%",extM.rightValue];
                }
            }
        }
        if (str2.length * str3.length == 0) {
            showStr = str1;
        }else{
            showStr = [NSString stringWithFormat:@"%@ | %@ | %@",str1,str2,str3];
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHOneWaySwitchDeviceType]) {
        // 一路开关
        NSString *value = deviceM.exts.firstObject.rightValue;
        showStr = [NSString stringWithFormat:@"一路%@",[value intValue] == 0 ? @"关":@"开"];
    } else if ([deviceM.deviceType isEqualToNumber:GSHTwoWaySwitchDeviceType]) {
        // 二路开关
        NSString *value1,*showStr1;
        NSString *value2,*showStr2;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHTwoWaySwitch_firstMeteId]) {
                value1 = extM.rightValue?extM.rightValue:extM.param;
                if (value1) {
                    showStr1 = [NSString stringWithFormat:@"一路%@",[value1 intValue] == 0 ? @"关":@"开"];
                }
            } else if ([extM.basMeteId isEqualToString:GSHTwoWaySwitch_secondMeteId]) {
                value2 = extM.rightValue?extM.rightValue:extM.param;
                if (value2) {
                    showStr2 = [NSString stringWithFormat:@"二路%@",[value2 intValue] == 0 ? @"关":@"开"];
                }
            }
        }
        NSString  *deviceActionShowStr = @"";
        if (showStr1) {
            if (showStr2) {
                deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@",showStr1,showStr2];
            } else {
                deviceActionShowStr = showStr1;
            }
        } else {
            deviceActionShowStr = showStr2;
        }
        showStr = deviceActionShowStr;
    }  else if ([deviceM.deviceType isEqualToNumber:GSHThreeWaySwitchDeviceType]) {
        // 三路开关
        NSString *value1,*showStr1;
        NSString *value2,*showStr2;
        NSString *value3,*showStr3;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHThreeWaySwitch_firstMeteId]) {
                value1 = extM.rightValue?extM.rightValue:extM.param;
                if (value1) {
                    showStr1 = [NSString stringWithFormat:@"一路%@",[value1 intValue] == 0 ? @"关":@"开"];
                }
            } else if ([extM.basMeteId isEqualToString:GSHThreeWaySwitch_secondMeteId]) {
                value2 = extM.rightValue?extM.rightValue:extM.param;
                if (value2) {
                    showStr2 = [NSString stringWithFormat:@"二路%@",[value2 intValue] == 0 ? @"关":@"开"];
                }
            } else if ([extM.basMeteId isEqualToString:GSHThreeWaySwitch_thirdMeteId]) {
                value3 = extM.rightValue?extM.rightValue:extM.param;
                if (value3) {
                    showStr3 = [NSString stringWithFormat:@"三路%@",[value3 intValue] == 0 ? @"关":@"开"];
                }
            }
        }
        NSString  *deviceActionShowStr = @"";
        if (showStr1) {
            if (showStr2) {
                if (showStr3) {
                    deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@ | %@",showStr1,showStr2,showStr3];
                } else {
                    deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@",showStr1,showStr2];
                }
            } else {
                if (showStr3) {
                    deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@",showStr1,showStr3];
                } else  {
                    deviceActionShowStr = showStr1;
                }
            }
        } else {
            if (showStr2) {
                if (showStr3) {
                    deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@",showStr2,showStr3];
                } else {
                    deviceActionShowStr = showStr2;
                }
            } else {
                if (showStr3) {
                    deviceActionShowStr = showStr3;
                } else  {
                    deviceActionShowStr = @"";
                }
            }
        }
        showStr = deviceActionShowStr;
    } else if ([deviceM.deviceType isEqualToNumber:GSHNewWindDeviceType]) {
        // 新风
        NSString *value;
        NSString *windSpeedValue;
        NSString *windSpeedStr = @"";
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHNewWind_WindSpeedMeteId]) {
                windSpeedValue = extM.rightValue;
            } else if ([extM.basMeteId isEqualToString:GSHNewWind_SwitchMeteId]) {
                value = extM.rightValue;
            }
        }
        if (windSpeedValue) {
            if ([windSpeedValue isEqualToString:@"1"]) {
                windSpeedStr = @"低风";
            } else if ([windSpeedValue isEqualToString:@"2"]) {
                windSpeedStr = @"中风";
            } else if ([windSpeedValue isEqualToString:@"3"]) {
                windSpeedStr = @"高风";
            }
        }
        
        if (value && value.intValue == 0) {
            showStr = @"关";
        } else {
            if (windSpeedStr.length > 0) {
                showStr = [NSString stringWithFormat:@"开 | %@",windSpeedStr];
            } else {
                showStr = @"开";
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHAirConditionerDeviceType]) {
        // 空调
        NSString *value;
        NSString *modelValue;
        NSString *windSpeedValue;
        NSString *temperatureValue;
        NSString *operator=@"";
        NSString *modelStr = @"";
        NSString *windSpeedStr = @"";
        NSString *temperatureStr = @"";
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHAirConditioner_SwitchMeteId]) {
                value = extM.rightValue?extM.rightValue:extM.param;
            }
        }
        if (value && value.integerValue == 0) {
            // 关
            showStr = @"关";
        } else {
            for (GSHDeviceExtM *extM in deviceM.exts) {
                if ([extM.basMeteId isEqualToString:GSHAirConditioner_ModelMeteId]) {
                    modelValue = extM.rightValue?extM.rightValue:extM.param;
                } else if ([extM.basMeteId isEqualToString:GSHAirConditioner_TemperatureMeteId]) {
                    operator = extM.conditionOperator;
                    temperatureValue = extM.rightValue?extM.rightValue:extM.param;
                } else if ([extM.basMeteId isEqualToString:GSHAirConditioner_WindSpeedMeteId]) {
                    windSpeedValue = extM.rightValue?extM.rightValue:extM.param;
                }
            }
            if ([modelValue isEqualToString:@"3"]) {
                modelStr = @"制冷";
            } else if ([modelValue isEqualToString:@"4"]) {
                modelStr = @"制热";
            } else if ([modelValue isEqualToString:@"7"]) {
                modelStr = @"送风";
            } else if ([modelValue isEqualToString:@"8"]) {
                modelStr = @"除湿";
            }

            if (windSpeedValue.integerValue == 1) {
                windSpeedStr = @"低风";
            } else if (windSpeedValue.integerValue == 2) {
                windSpeedStr = @"中风";
            } else if (windSpeedValue.integerValue == 3) {
                windSpeedStr = @"高风";
            }
            if (temperatureValue) {
                if (operator.length > 0 && ![operator isEqualToString:@"=="]) {
                    temperatureStr = [NSString stringWithFormat:@"%@%d˚C",operator,[temperatureValue intValue]];
                } else {
                    temperatureStr = [NSString stringWithFormat:@"%d˚C",[temperatureValue intValue]];
                }
            }

            NSMutableString *attributeStr = [NSMutableString stringWithString:@"开"];
            NSArray *attributeArr = @[temperatureStr,modelStr,windSpeedStr];
            for (NSString *str in attributeArr) {
                if (str.length > 0) {
                    [attributeStr appendString:[NSString stringWithFormat:@"| %@",str]];
                }
            }
            showStr = (NSString *)attributeStr;
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHCurtainDeviceType] ||
               [deviceM.deviceType isEqualToNumber:GSHOneWayCurtainDeviceType]) {
        // 窗帘电机 & 一路窗帘开关
        NSString *deviceStateStr = @"" , *processStr = @"";
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHCurtain_SwitchMeteId] ||
                [extM.basMeteId isEqualToString:GSHOneWayCurtain_SwitchMeteId]) {
                NSString *value = extM.rightValue;
                if (value.intValue == 0) {
                    deviceStateStr = @"开";
                } else if (value.intValue == 1) {
                    deviceStateStr = @"关";
                } else if (value.intValue == 2) {
                    deviceStateStr = @"暂停";
                }
            } else if ([extM.basMeteId isEqualToString:GSHCurtain_PercentMeteId]) {
                // 百分比
                processStr = [NSString stringWithFormat:@"%@%%",extM.rightValue];
            }
        }
        showStr = [NSString stringWithFormat:@"%@ | %@",deviceStateStr,processStr];
    } else if ([deviceM.deviceType isEqualToNumber:GSHTwoWayCurtainDeviceType]) {
        // 二路窗帘开关
        NSString *value1,*showStr1;
        NSString *value2,*showStr2;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHTwoWayCurtain_OneSwitchMeteId]) {
                // 一路
                value1 = extM.rightValue?extM.rightValue:extM.param;
                if (value1) {
                    NSString *str = nil;
                    if (value1.integerValue == 0) {
                        str = @"开";
                    } else if (value1.integerValue == 1) {
                        str = @"关";
                    } else {
                        str = @"暂停";
                    }
                    showStr1 = [NSString stringWithFormat:@"一路%@",str];
                }
            } else if ([extM.basMeteId isEqualToString:GSHTwoWayCurtain_TwoSwitchMeteId]) {
                // 二路
                value2 = extM.rightValue?extM.rightValue:extM.param;
                if (value2) {
                    NSString *str = nil;
                    if (value2.integerValue == 0) {
                        str = @"开";
                    } else if (value2.integerValue == 1) {
                        str = @"关";
                    } else {
                        str = @"暂停";
                    }
                    showStr2 = [NSString stringWithFormat:@"二路%@",str];
                }
            }
        }
        NSString  *deviceActionShowStr = @"";
        if (showStr1) {
            if (showStr2) {
                deviceActionShowStr = [NSString stringWithFormat:@"%@ | %@",showStr1,showStr2];
            } else {
                deviceActionShowStr = showStr1;
            }
        } else {
            deviceActionShowStr = showStr2;
        }
        showStr = deviceActionShowStr;
    } else if ([deviceM.deviceType isEqualToNumber:GSHUnderFloorDeviceType]) {
        // 地暖
        NSString *value;
        NSString *temperatureValue;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHUnderFloor_SwitchMeteId]) {
                value = extM.rightValue;
            }
        }
        if (value && value.integerValue == 0) {
            // 关
            showStr = @"关";
        } else {
            for (GSHDeviceExtM *extM in deviceM.exts) {
                if ([extM.basMeteId isEqualToString:GSHUnderFloor_TemperatureMeteId]) {
                    temperatureValue = extM.rightValue;
                }
            }
            temperatureValue = [NSString stringWithFormat:@"%d˚C",[temperatureValue intValue]];
            showStr = [NSString stringWithFormat:@"开 | %@",temperatureValue];
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHScenePanelDeviceType]) {
        // 场景面板
        NSArray *arr = @[@"第一路",@"第二路",@"第三路",@"第四路",@"第五路",@"第六路"];
        for (GSHDeviceExtM *extM in deviceM.exts) {
           if (extM.rightValue.integerValue > 0 && extM.rightValue.integerValue < 7) {
               showStr = arr[extM.rightValue.intValue-1];
           } else {
               showStr = @"数据错误";
           }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHSocket1DeviceType]) {
        // 智能插座
        NSString *openSwitchValue;
        NSString *usbSwitchValue;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHSocket1_SocketSwitchMeteId]) {
                openSwitchValue = extM.rightValue;
            } else if ([extM.basMeteId isEqualToString:GSHSocket1_USBSwitchMeteId]) {
                usbSwitchValue = extM.rightValue;
            }
        }
        if (openSwitchValue && !usbSwitchValue) {
            showStr = [NSString stringWithFormat:@"插座: %@",openSwitchValue.intValue==1?@"开":@"关"];
        } else if (!openSwitchValue && usbSwitchValue) {
            showStr = [NSString stringWithFormat:@"USB: %@",usbSwitchValue.intValue==1?@"开":@"关"];
        } else {
            showStr = [NSString stringWithFormat:@"插座: %@ | USB: %@",openSwitchValue.intValue==1?@"开":@"关",usbSwitchValue.intValue==1?@"开":@"关"];
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHSocket2DeviceType]) {
        // 智能插座
        NSString *openSwitchValue;
        NSString *usbSwitchValue;
        for (GSHDeviceExtM *extM in deviceM.exts) {
           if ([extM.basMeteId isEqualToString:GSHSocket2_SocketSwitchMeteId]) {
               openSwitchValue = extM.rightValue;
           }
        }
        if (openSwitchValue && !usbSwitchValue) {
           showStr = [NSString stringWithFormat:@"插座: %@",openSwitchValue.intValue==1?@"开":@"关"];
        } else if (!openSwitchValue && usbSwitchValue) {
           showStr = [NSString stringWithFormat:@"USB: %@",usbSwitchValue.intValue==1?@"开":@"关"];
        } else {
           showStr = [NSString stringWithFormat:@"插座: %@ | USB: %@",openSwitchValue.intValue==1?@"开":@"关",usbSwitchValue.intValue==1?@"开":@"关"];
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType]) {
        // 体感传感器 -- 仅在触发条件出现
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHSomatasensorySensor_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHGateMagetismSensorDeviceType]) {
        // 门磁 -- 仅在触发条件出现
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"被打开" : @"被关闭";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHGateMagetismSensor_isOpenedMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"被打开" : @"被关闭";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHHumitureSensorDeviceType]) {
        // 温湿度传感器
        NSString *temStr;
        NSString *humStr;
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHHumitureSensor_temMeteId]) {
                temStr = [NSString stringWithFormat:@"温度: %@%@",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHHumitureSensor_humMeteId]) {
                humStr = [NSString stringWithFormat:@"湿度: %@%@",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            }
        }
        if (temStr && !humStr) {
            showStr = temStr;
        } else if (!temStr && humStr) {
            showStr = humStr;
        } else {
            showStr = [NSString stringWithFormat:@"%@ | %@",temStr,humStr];
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHHuanjingSensorDeviceType]) {
        // 空气盒子
        NSString *huangjingStr = @"";
        NSString *temStr = @"";
        NSString *humStr = @"";
        NSString *pmStr = @"";
        NSString *co2Str = @"";
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHHuanjingSensor_wenduMeteId]) {
                temStr = [NSString stringWithFormat:@"%@%@˚C",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHHuanjingSensor_shiduMeteId]) {
                humStr = [NSString stringWithFormat:@"%@%@%%",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHHuanjingSensor_pm25MeteId]) {
                pmStr = [NSString stringWithFormat:@"%@%@ug/m3",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHHuanjingSensor_co2MeteId]) {
                co2Str = [NSString stringWithFormat:@"%@%@ppm",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHHuanjingSensor_youhaiMeteId]) {
                NSString *str = @"";
                if ([extM.conditionOperator isEqualToString:@"<"] && extM.rightValue.integerValue == 120) {
                    str = @"空气质量优";
                } else if ([extM.conditionOperator isEqualToString:@"<"] && extM.rightValue.integerValue == 200) {
                    str = @"空气质量良";
                } else if ([extM.conditionOperator isEqualToString:@">"] && extM.rightValue.integerValue == 200) {
                    str = @"空气质量中";
                } else if ([extM.conditionOperator isEqualToString:@">"] && extM.rightValue.integerValue == 250) {
                    str = @"空气质量差";
                }
                huangjingStr = str;
            }
        }
        
        NSMutableString *attributeStr = [NSMutableString stringWithString:@""];
        NSArray *attributeArr = @[huangjingStr,temStr,humStr,pmStr,co2Str];
        for (NSString *str in attributeArr) {
            if (str.length > 0) {
                [attributeStr appendString:[NSString stringWithFormat:@"%@ | ",str]];
            }
        }
        if (attributeStr.length > 0) {
            attributeStr = [[attributeStr substringToIndex:attributeStr.length-3] mutableCopy];
        }
        showStr = attributeStr;
    } else if ([deviceM.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
        // 空气盒子
        NSString *temStr = @"";
        NSString *humStr = @"";
        NSString *pmStr = @"";
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_temMeteId]) {
                temStr = [NSString stringWithFormat:@"%@%@˚C",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_humMeteId]) {
                humStr = [NSString stringWithFormat:@"%@%@%%",[extM.conditionOperator isEqualToString:@">"] ? @"高于" : @"低于",extM.rightValue];
            } else if ([extM.basMeteId isEqualToString:GSHAirBoxSensor_pmMeteId]) {
                NSString *str = @"轻度污染";
                if (extM.rightValue.integerValue == 35) {
                    str = @"优";
                } else if ([extM.conditionOperator isEqualToString:@"<"] && extM.rightValue.integerValue == 75) {
                    str = @"良";
                } else if ([extM.conditionOperator isEqualToString:@">"] && extM.rightValue.integerValue == 75) {
                    str = @"轻度污染";
                } else if (extM.rightValue.integerValue == 115) {
                    str = @"中度污染";
                } else if (extM.rightValue.integerValue == 150) {
                    str = @"重度污染";
                } else if (extM.rightValue.integerValue == 250) {
                    str = @"严重污染";
                }
                pmStr = str;
            }
        }
        
        NSMutableString *attributeStr = [NSMutableString stringWithString:@""];
        NSArray *attributeArr = @[pmStr,temStr,humStr];
        for (NSString *str in attributeArr) {
            if (str.length > 0) {
                [attributeStr appendString:[NSString stringWithFormat:@"%@ | ",str]];
            }
        }
        if (attributeStr.length > 0) {
            attributeStr = [[attributeStr substringToIndex:attributeStr.length-3] mutableCopy];
        }
        showStr = attributeStr;
    }  else if ([deviceM.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType]) {
        // 水浸传感器
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHWaterLoggingSensor_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHGasSensorDeviceType]) {
        // 烟雾传感器
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHGasSensor_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHCoGasSensorDeviceType]) {
        // 一氧化碳传感器
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHCoGasSensor_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHCombustibleGasDeviceType]) {
        // 可燃气体传感器
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHCombustibleGas_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHSOSSensorDeviceType]) {
        // 紧急按钮
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHSOSSensor_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHInfrareCurtainDeviceType]) {
        // 红外幕帘 -- 仅在触发条件出现
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHInfrareCurtain_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHAudibleVisualAlarmDeviceType]) {
        // 声光报警器
        for (GSHDeviceExtM *extM in deviceM.exts) {
            if ([deviceM.deviceSn containsString:@"_"] ) {
                // 组合传感器 --
                if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                    showStr = extM.rightValue.intValue == 1 ? @"响铃+发光" : @"正常";
                }
            } else {
                if ([extM.basMeteId isEqualToString:GSHAudibleVisualAlarm_alarmMeteId]) {
                    showStr = extM.rightValue.intValue == 1 ? @"响铃+发光" : @"正常";
                }
            }
        }
    } else if ([deviceM.deviceType isEqualToNumber:GSHInfrareReactionDeviceType]) {
        // 红外人体感应面板 -- 仅在触发条件出现
        for (GSHDeviceExtM *extM in deviceM.exts) {
           if ([deviceM.deviceSn containsString:@"_"] ) {
               // 组合传感器 --
               if ([extM.basMeteId isEqualToString:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn]]) {
                   showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
               }
           } else {
               if ([extM.basMeteId isEqualToString:GSHInfrareReaction_alarmMeteId]) {
                   showStr = extM.rightValue.intValue == 1 ? @"告警" : @"正常";
               }
           }
        }
    }
    return showStr;
}

// 设备选中时初始值获取
+ (NSArray *)getInitExtsWithDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType{
    NSMutableArray *exts = [NSMutableArray array];
    if ([deviceM.deviceSn containsString:@"_"]) {
        // 虚拟传感器
        [exts addObject:[self extMWithBasMeteId:[deviceM getBaseMeteIdFromDeviceSn:deviceM.deviceSn] conditionOperator:@"==" rightValue:@"1"]];
    } else {
        if ([deviceM.deviceType isEqual:GSHAdjustLightDeviceType]) {
            GSHAdjustLightViewModel *model = [GSHAdjustLightViewModel adjustLightViewModelWithType:GSHAdjustLightViewModelTypeMoRen];
            [exts addObject:[self extMWithBasMeteId:GSHAdjustLight_offMeteId conditionOperator:@"==" rightValue:@"1"]];
            if (model.seWen > 0) {
                [exts addObject:[self extMWithBasMeteId:GSHAdjustLight_wenSeMeteId conditionOperator:@"==" rightValue:@(model.seWen).stringValue]];
                [exts addObject:[self extMWithBasMeteId:GSHAdjustLight_lightMeteId conditionOperator:@"==" rightValue:@(model.liangDu).stringValue]];
            }
        } else if ([deviceM.deviceType isEqual:GSHOneWaySwitchDeviceType]) {
            // 一路开关
            [exts addObject:[self extMWithBasMeteId:GSHOneWaySwitch_firstMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHTwoWaySwitchDeviceType]) {
            // 二路开关
            for (int i = 0; i < 2; i ++) {
                if (i == 0) {
                    [exts addObject:[self extMWithBasMeteId:GSHTwoWaySwitch_firstMeteId conditionOperator:@"==" rightValue:@"1"]];
                } else {
                    [exts addObject:[self extMWithBasMeteId:GSHTwoWaySwitch_secondMeteId conditionOperator:@"==" rightValue:@"1"]];
                }
            }
        } else if ([deviceM.deviceType isEqual:GSHThreeWaySwitchDeviceType]) {
            // 三路开关
            for (int i = 0; i < 3; i ++) {
                if (i == 0) {
                    [exts addObject:[self extMWithBasMeteId:GSHThreeWaySwitch_firstMeteId conditionOperator:@"==" rightValue:@"1"]];
                } else if (i == 1) {
                    [exts addObject:[self extMWithBasMeteId:GSHThreeWaySwitch_secondMeteId conditionOperator:@"==" rightValue:@"1"]];
                } else {
                    [exts addObject:[self extMWithBasMeteId:GSHThreeWaySwitch_thirdMeteId conditionOperator:@"==" rightValue:@"1"]];
                }
            }
        } else if ([deviceM.deviceType isEqual:GSHCurtainDeviceType]) {
            // 窗帘电机
            [exts addObject:[self extMWithBasMeteId:GSHCurtain_SwitchMeteId conditionOperator:@"==" rightValue:@"0"]];
        } else if ([deviceM.deviceType isEqual:GSHOneWayCurtainDeviceType]) {
            // 一路窗帘开关
            [exts addObject:[self extMWithBasMeteId:GSHOneWayCurtain_SwitchMeteId conditionOperator:@"==" rightValue:@"0"]];
        } else if ([deviceM.deviceType isEqual:GSHTwoWayCurtainDeviceType]) {
            // 二路窗帘开关
            for (int i = 0; i < 2; i ++) {
                if (i == 0) {
                    [exts addObject:[self extMWithBasMeteId:GSHTwoWayCurtain_OneSwitchMeteId conditionOperator:@"==" rightValue:@"0"]];
                } else {
                    [exts addObject:[self extMWithBasMeteId:GSHTwoWayCurtain_TwoSwitchMeteId conditionOperator:@"==" rightValue:@"0"]];
                }
            }
        } else if ([deviceM.deviceType isEqual:GSHAirConditionerDeviceType]) {
            // 空调
            [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_ModelMeteId conditionOperator:@"==" rightValue:@"3"]];
//            [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_SwitchMeteId conditionOperator:@"==" rightValue:@"10"]];
            if (deviceEditType == GSHDeviceVCTypeAutoTriggerSet) {
                // 联动 -- 触发条件
                [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_TemperatureMeteId conditionOperator:@">" rightValue:@"26"]];
            } else {
                // 联动 -- 执行动作
                [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_WindSpeedMeteId conditionOperator:@"==" rightValue:@"1"]];
                [exts addObject:[self extMWithBasMeteId:GSHAirConditioner_TemperatureMeteId conditionOperator:@"" rightValue:@"26"]];
            }
        } else if ([deviceM.deviceType isEqual:GSHNewWindDeviceType]) {
            // 新风
            // 默认 低风
            [exts addObject:[self extMWithBasMeteId:GSHNewWind_WindSpeedMeteId conditionOperator:@"==" rightValue:@"1"]];
            // 默认开
//            [exts addObject:[self extMWithBasMeteId:GSHNewWind_SwitchMeteId conditionOperator:@"==" rightValue:@"4"]];
        } else if ([deviceM.deviceType isEqual:GSHUnderFloorDeviceType]) {
            // 地暖
            // 默认 开
//            [exts addObject:[self extMWithBasMeteId:GSHUnderFloor_SwitchMeteId conditionOperator:@"==" rightValue:@"10"]];
            // 默认 20度
            [exts addObject:[self extMWithBasMeteId:GSHUnderFloor_TemperatureMeteId conditionOperator:@"==" rightValue:@"20"]];
            
        } else if ([deviceM.deviceType isEqual:GSHSocket1DeviceType]) {
            // 插座
            [exts addObject:[self extMWithBasMeteId:GSHSocket1_SocketSwitchMeteId conditionOperator:@"==" rightValue:@"1"]];
            [exts addObject:[self extMWithBasMeteId:GSHSocket1_USBSwitchMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHSocket2DeviceType]) {
            // 插座
            [exts addObject:[self extMWithBasMeteId:GSHSocket2_SocketSwitchMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHScenePanelDeviceType]) {
            // 场景面板
            [exts addObject:[self extMWithBasMeteId:GSHScenePanel_FirstMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHInfrareCurtainDeviceType]) {
            // 红外幕帘
            [exts addObject:[self extMWithBasMeteId:GSHInfrareCurtain_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHAudibleVisualAlarmDeviceType]) {
            // 声光报警器
            [exts addObject:[self extMWithBasMeteId:GSHAudibleVisualAlarm_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHHumitureSensorDeviceType]) {
            // 温湿度传感器
            for (int i = 0; i < 2; i ++) {
                if (i == 0) {
                    [exts addObject:[self extMWithBasMeteId:GSHHumitureSensor_temMeteId conditionOperator:@">" rightValue:@"26"]];
                } else {
                    [exts addObject:[self extMWithBasMeteId:GSHHumitureSensor_humMeteId conditionOperator:@">" rightValue:@"68"]];
                }
            }
        } else if ([deviceM.deviceType isEqual:GSHSomatasensorySensorDeviceType]) {
            // 人体红外传感器
            [exts addObject:[self extMWithBasMeteId:GSHSomatasensorySensor_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHGateMagetismSensorDeviceType]) {
            // 门磁
            [exts addObject:[self extMWithBasMeteId:GSHGateMagetismSensor_isOpenedMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHGasSensorDeviceType]) {
            // 烟雾传感器
            [exts addObject:[self extMWithBasMeteId:GSHGasSensor_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHCoGasSensorDeviceType]) {
            // 一氧化碳传感器
            [exts addObject:[self extMWithBasMeteId:GSHCoGasSensor_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHCombustibleGasDeviceType]) {
            // 可燃气体传感器
            [exts addObject:[self extMWithBasMeteId:GSHCombustibleGas_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHWaterLoggingSensorDeviceType]) {
            // 水浸传感器
            [exts addObject:[self extMWithBasMeteId:GSHWaterLoggingSensor_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHAirBoxSensorDeviceType]) {
            // 空气盒子
            for (int i = 0; i < 3; i ++) {
                if (i == 0) {
                    [exts addObject:[self extMWithBasMeteId:GSHAirBoxSensor_temMeteId conditionOperator:@">" rightValue:@"26"]];
                } else if(i == 1){
                    [exts addObject:[self extMWithBasMeteId:GSHAirBoxSensor_humMeteId conditionOperator:@">" rightValue:@"68"]];
                } else {
                    [exts addObject:[self extMWithBasMeteId:GSHAirBoxSensor_pmMeteId conditionOperator:@">" rightValue:@"75"]];
                }
            }
        } else if ([deviceM.deviceType isEqual:GSHHuanjingSensorDeviceType]) {
           // 空气盒子
            [exts addObject:[self extMWithBasMeteId:GSHHuanjingSensor_youhaiMeteId conditionOperator:@">" rightValue:@"200"]];
            [exts addObject:[self extMWithBasMeteId:GSHHuanjingSensor_wenduMeteId conditionOperator:@">" rightValue:@"26"]];
            [exts addObject:[self extMWithBasMeteId:GSHHuanjingSensor_shiduMeteId conditionOperator:@">" rightValue:@"65"]];
            [exts addObject:[self extMWithBasMeteId:GSHHuanjingSensor_pm25MeteId conditionOperator:@">" rightValue:@"250"]];
            [exts addObject:[self extMWithBasMeteId:GSHHuanjingSensor_co2MeteId conditionOperator:@">" rightValue:@"1000"]];
        } else if ([deviceM.deviceType isEqual:GSHSOSSensorDeviceType]) {
            // 紧急按钮
            [exts addObject:[self extMWithBasMeteId:GSHSOSSensor_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
        } else if ([deviceM.deviceType isEqual:GSHInfrareReactionDeviceType]) {
            // 红外人体感应面板
            [exts addObject:[self extMWithBasMeteId:GSHInfrareReaction_alarmMeteId conditionOperator:@"==" rightValue:@"1"]];
        }
    }
    return (NSArray *)exts;
}

+ (GSHDeviceExtM *)extMWithBasMeteId:(NSString *)basMeteId
                   conditionOperator:(NSString *)conditionOperator
                          rightValue:(NSString *)rightValue {
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = basMeteId;
    extM.conditionOperator = conditionOperator;
    extM.rightValue = rightValue;
    return extM;
}

@end
