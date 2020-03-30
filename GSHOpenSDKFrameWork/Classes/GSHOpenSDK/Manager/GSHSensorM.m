//
//  GSHSensorM.m
//  SmartHome
//
//  Created by gemdale on 2018/11/13.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHSensorM.h"
#import "GSHOpenSDKInternal.h"
#import <YYCategories/YYCategories.h>
#import "GSHSensorDao.h"
#import "GSHDeviceInfoDefines.h"

@implementation GSHSensorMonitorM : NSObject
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"valueString":@"lastValue",@"name":@"meteName"};
}
@end

@implementation GSHSensorHistoryMonitorValueM : NSObject
@end

@implementation GSHSensorHistoryMonitorM : NSObject
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"timeValueList":[GSHSensorHistoryMonitorValueM class]};
}

- (NSString *)lineColor {
    NSString *lineColorStr ;
    if ([self.basMeteId isEqualToString:GSHHumitureSensor_temMeteId] ||
        [self.basMeteId isEqualToString:GSHAirBoxSensor_temMeteId]) {
        // 温湿度 或 空气盒子 -- 温度
        lineColorStr = @"0x1890FF";
    } else if ([self.basMeteId isEqualToString:GSHHumitureSensor_humMeteId] ||
               [self.basMeteId isEqualToString:GSHAirBoxSensor_humMeteId]) {
        // 温湿度 或 空气盒子 -- 湿度
        lineColorStr = @"0x2FC25B";
    } else if ([self.basMeteId isEqualToString:GSHAirBoxSensor_pmMeteId]) {
        // 空气盒子 -- PM2.5
        lineColorStr = @"0xFAB114";
    } else {
        lineColorStr = @"0xFFFFFF";
    }
    return lineColorStr;
}
@end

@implementation GSHSensorAlarmM
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"msgTime":@"createTime"};
}
@end

@implementation GSHMissingSensorM
@end

@implementation GSHSensorM
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"attributeList":[GSHSensorMonitorM class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"launchtime":@"launchTime"};
}
- (NSString *)electricString{
    for (GSHSensorMonitorM *m in self.attributeList) {
        NSLog(@"--------------%@",m.basMeteId);
        if ([self.deviceType isEqualToNumber:GSHHumitureSensorDeviceType]) {
            // 温湿度
            if ([m.basMeteId isEqualToString:GSHHumitureSensor_electricMeteId]) {
                if(m.valueString){
                    if (m.valueString.integerValue >= 1) {
                        return @"电量正常";
                    }else{
                        return @"低电量";
                    }
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHGateMagetismSensorDeviceType]) {
            // 门磁
            if ([m.basMeteId isEqualToString:GSHGateMagetismSensor_electricMeteId]) {
                if(m.valueString){
                    if (m.valueString.integerValue >= 1) {
                        return @"电量正常";
                    }else{
                        return @"低电量";
                    }
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
            // 空气盒子
            if ([m.basMeteId isEqualToString:GSHAirBoxSensor_electricMeteId]) {
                if(m.valueString){
                    return [NSString stringWithFormat:@"剩余电量：%@%%",m.valueString];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType]) {
            // 人体红外
            if ([m.basMeteId isEqualToString:GSHSomatasensorySensor_electricMeteId]) {
                if(m.valueString){
                    if (m.valueString.integerValue >= 1) {
                        return @"电量正常";
                    }else{
                        return @"低电量";
                    }
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHGasSensorDeviceType]) {
            // 烟雾传感器
            if ([m.basMeteId isEqualToString:GSHGasSensor_electricMeteId]) {
                if(m.valueString){
                    if (m.valueString.integerValue >= 1) {
                        return @"电量正常";
                    }else{
                        return @"低电量";
                    }
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHCombustibleGasDeviceType]) {
            // 可燃气体传感器
            if ([m.basMeteId isEqualToString:GSHCombustibleGas_electricMeteId]) {
                if(m.valueString){
                    if (m.valueString.integerValue >= 1) {
                        return @"电量正常";
                    }else{
                        return @"低电量";
                    }
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHCoGasSensorDeviceType]) {
            // 一氧化碳传感器
            if ([m.basMeteId isEqualToString:GSHCoGasSensor_electricMeteId]) {
                if(m.valueString){
                    if (m.valueString.integerValue >= 1) {
                        return @"电量正常";
                    }else{
                        return @"低电量";
                    }
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType]) {
            // 水浸传感器
            if ([m.basMeteId isEqualToString:GSHWaterLoggingSensor_electricMeteId]) {
                if(m.valueString){
                    if (m.valueString.integerValue >= 1) {
                        return @"电量正常";
                    }else{
                        return @"低电量";
                    }
                }
            }
        }
    }
    return nil;
}

- (NSDate *)launchDate{
    return [NSDate dateWithTimeIntervalSince1970:self.launchtime.integerValue / 1000];
}

-(NSString *)monitorString{
    NSString *string = self.roomName.length > 0 ? self.roomName : @"";
    if (self.deviceName.length > 0) {
        string = [NSString stringWithFormat:@"%@-%@：",string,self.deviceName];
    }
    for (GSHSensorMonitorM *model in self.showAttributeList) {
        if (model.showMeteStr.length > 0) {
            string = [NSString stringWithFormat:@"%@ %@",string,model.showMeteStr];
            if (model.unit.length > 0) {
                string = [NSString stringWithFormat:@"%@%@",string,model.unit];
            }
        }
    }
    return string;
}

- (NSArray<GSHSensorMonitorM*>*)showAttributeList; {
    NSMutableArray<GSHSensorMonitorM*> *showArray = [NSMutableArray array];
    if (self.attributeList.count > 0) {
        if ([self.deviceModel isEqualToNumber:@(-2)]) {
            //如果是组合传感器的其中一路
            GSHSensorMonitorM *monitorM = self.attributeList.firstObject;
            if (monitorM) {
                if (monitorM.valueString) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"告警" : @"正常";
                }else{
                    monitorM.showMeteStr = @"正常";
                }
                [showArray insertObject:monitorM atIndex:0];
            }
            return showArray;
        }
        if ([self.deviceType isEqualToNumber:GSHHuanjingSensorDeviceType]) {
            // 环境面板
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHHuanjingSensor_youhaiMeteId]) {
                    if (monitorM.valueString) {
                        int value = monitorM.valueString.intValue;
                        if (value < 120) {
                            monitorM.showMeteStr = @"优";
                        }else if (value < 200){
                            monitorM.showMeteStr = @"良";
                        }else if (value < 250){
                            monitorM.showMeteStr = @"中";
                        }else{
                            monitorM.showMeteStr = @"差";
                        }
                    }else{
                        monitorM.showMeteStr = @"暂无";
                    }
                    [showArray insertObject:monitorM atIndex:0];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHHumitureSensorDeviceType]) {
            // 温湿度
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHHumitureSensor_temMeteId]) {
                    monitorM.showMeteStr = monitorM.valueString;
                    [showArray insertObject:monitorM atIndex:0];
                } else if ([monitorM.basMeteId isEqualToString:GSHHumitureSensor_humMeteId]) {
                    monitorM.showMeteStr = monitorM.valueString;
                    [showArray addObject:monitorM];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHGateMagetismSensorDeviceType]) {
            // 门磁
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHGateMagetismSensor_isOpenedMeteId]) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"打开" : @"关闭";
                    [showArray insertObject:monitorM atIndex:0];
                } 
            }
        } else if ([self.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
            // 空气盒子
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                    if ([monitorM.basMeteId isEqualToString:GSHAirBoxSensor_pmMeteId]) {
                    NSString *str;
                    if (monitorM.valueString) {
                        if (monitorM.valueString.integerValue>=0 && monitorM.valueString.integerValue<35) {
                            // 优
                            str = @"优";
                        } else if (monitorM.valueString.integerValue>=35 && monitorM.valueString.integerValue<75) {
                            // 良
                            str = @"良";
                        } else if (monitorM.valueString.integerValue>=75 && monitorM.valueString.integerValue<115) {
                            // 轻度污染
                            str = @"轻度";
                        } else if (monitorM.valueString.integerValue>=115 && monitorM.valueString.integerValue<150) {
                            // 中度污染
                            str = @"中度";
                        } else if (monitorM.valueString.integerValue>=150 && monitorM.valueString.integerValue<250) {
                            // 重度污染
                            str = @"重度";
                        } else if (monitorM.valueString.integerValue>=250) {
                            // 严重污染
                            str = @"严重";
                        }
                    } else {
                        str = @"优";
                    }
                    monitorM.showMeteStr = str;
                    monitorM.unit = @"";
                    [showArray insertObject:monitorM atIndex:0];
                } 
            }
        } else if ([self.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType]) {
            // 人体红外
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHSomatasensorySensor_alarmMeteId]) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"告警" : @"正常";
                    [showArray insertObject:monitorM atIndex:0];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHGasSensorDeviceType]) {
            // 烟雾传感器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHGasSensor_alarmMeteId]) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"告警" : @"正常";
                    [showArray insertObject:monitorM atIndex:0];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHCombustibleGasDeviceType]) {
            // 可燃气体传感器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHCombustibleGas_alarmMeteId]) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"告警" : @"正常";
                    [showArray insertObject:monitorM atIndex:0];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHCoGasSensorDeviceType]) {
            // 一氧化碳传感器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHCoGasSensor_alarmMeteId]) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"告警" : @"正常";
                    [showArray insertObject:monitorM atIndex:0];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType]) {
            // 水浸传感器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHWaterLoggingSensor_alarmMeteId]) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"告警" : @"正常";
                    [showArray insertObject:monitorM atIndex:0];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHSOSSensorDeviceType]) {
            // 紧急按钮
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHSOSSensor_alarmMeteId]) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"看护中" : @"看护中";
                    [showArray insertObject:monitorM atIndex:0];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHInfrareCurtainDeviceType]) {
            // 红外幕帘
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHInfrareCurtain_alarmMeteId]) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"告警" : @"正常";
                    [showArray insertObject:monitorM atIndex:0];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHAudibleVisualAlarmDeviceType]) {
            // 声光报警器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHAudibleVisualAlarm_alarmMeteId]) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"看护中" : @"看护中";
                    [showArray insertObject:monitorM atIndex:0];
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHInfrareReactionDeviceType]) {
            // 红外人体感应面板
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHInfrareReaction_alarmMeteId]) {
                    monitorM.showMeteStr = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? @"告警" : @"正常";
                    [showArray insertObject:monitorM atIndex:0];
                }
            }
        }
    }
    return (NSArray *)showArray;
}

- (NSInteger)grade {
    NSInteger grade = 2;
    if (self.attributeList.count > 0) {
        if ([self.deviceModel isEqualToNumber:@(-2)]) {
            //如果是组合传感器的其中一路
            GSHSensorMonitorM *monitorM = self.attributeList.firstObject;
            grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 5 : 2;
            return grade;
        }
        if ([self.deviceType isEqualToNumber:GSHHumitureSensorDeviceType]) {
            // 温湿度
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                if (grade != 5) { // 当有一个量发生告警之后，不需要再判断其他量
                    GSHSensorMonitorM *monitorM = self.attributeList[i];
                    if ([monitorM.basMeteId isEqualToString:GSHHumitureSensor_temMeteId]) {
                        grade = (monitorM.valueString && monitorM.valueString.integerValue > 38) ? 5 : 2;
                    } else if ([monitorM.basMeteId isEqualToString:GSHHumitureSensor_humMeteId]) {
                        grade = (monitorM.valueString && monitorM.valueString.integerValue > 68) ? 5 : 2;
                    }
                } else {
                    break;
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHGateMagetismSensorDeviceType]) {
            // 门磁
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHGateMagetismSensor_isOpenedMeteId]) {
                    grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 5 : 2;
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHAirBoxSensorDeviceType]) {
            // 空气盒子
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHAirBoxSensor_pmMeteId]) {
                    if (monitorM.valueString) {
                        if (monitorM.valueString.integerValue>=0 && monitorM.valueString.integerValue<35) {
                            // 优
                            grade = 1;
                        } else if (monitorM.valueString.integerValue>=35 && monitorM.valueString.integerValue<75) {
                            // 良
                            grade = 2;
                        } else if (monitorM.valueString.integerValue>=75 && monitorM.valueString.integerValue<115) {
                            // 轻度污染
                            grade = 3;
                        } else if (monitorM.valueString.integerValue>=115 && monitorM.valueString.integerValue<150) {
                            // 中度污染
                            grade = 4;
                        } else if (monitorM.valueString.integerValue>=150 && monitorM.valueString.integerValue<250) {
                            // 重度污染
                            grade = 5;
                        } else if (monitorM.valueString.integerValue>=250) {
                            // 颜色污染
                            grade = 6;
                        }
                    } else {
                        grade = 1;
                    }
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHSomatasensorySensorDeviceType]) {
            // 人体红外传感器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHSomatasensorySensor_alarmMeteId]) {
                    grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 5 : 2;
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHGasSensorDeviceType]) {
            // 烟雾传感器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHGasSensor_alarmMeteId]) {
                    grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 5 : 2;
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHCombustibleGasDeviceType]) {
            // 可燃气体传感器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHCombustibleGas_alarmMeteId]) {
                    grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 5 : 2;
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHCoGasSensorDeviceType]) {
            // 一氧化碳传感器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHCoGasSensor_alarmMeteId]) {
                    grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 5 : 2;
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHWaterLoggingSensorDeviceType]) {
            // 水浸传感器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHWaterLoggingSensor_alarmMeteId]) {
                    grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 5 : 2;
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHSOSSensorDeviceType]) {
            // 紧急按钮
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHSOSSensor_alarmMeteId]) {
                    grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 2 : 2;
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHInfrareCurtainDeviceType]) {
            // 红外幕帘
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHInfrareCurtain_alarmMeteId]) {
                    grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 5 : 2;
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHAudibleVisualAlarmDeviceType]) {
            // 声光报警器
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHAudibleVisualAlarm_alarmMeteId]) {
                    grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 2 : 2;
                }
            }
        } else if ([self.deviceType isEqualToNumber:GSHInfrareReactionDeviceType]) {
            // 红外人体感应面板
            for (int i = 0 ; i < self.attributeList.count ; i ++) {
                GSHSensorMonitorM *monitorM = self.attributeList[i];
                if ([monitorM.basMeteId isEqualToString:GSHInfrareReaction_alarmMeteId]) {
                    grade = (monitorM.valueString && monitorM.valueString.integerValue == 1) ? 5 : 2;
                }
            }
        }
    }
    return grade;
}
@end

@implementation GSHSensorManager
+ (NSURLSessionDataTask *)getSensorListWithFamilyId:(NSString*)familyId floorId:(NSString*)floorId block:(void(^)(NSArray<GSHSensorM*> *list,NSError *error))block{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        // 局域网控制
        NSArray *devices = [[GSHSensorDao shareSensorDao] selectSensorTableWithFloorId:floorId];
        if (block) {
            block(devices,nil);
        }
        return nil;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:floorId forKey:@"floorId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"sensor/getSensorList" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHSensorM.class json:responseObject];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)postSensorRankWithFamilyId:(NSString*)familyId floorId:(NSString*)floorId sensorList:(NSArray<GSHSensorM*> *)sensorList block:(void(^)(NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:floorId forKey:@"floorId"];
    NSMutableArray *idList = [NSMutableArray array];
    for (GSHSensorM *sen in sensorList) {
        if (sen.deviceSn) {
            [idList addObject:sen.deviceSn];
        }
    }
    [dic setValue:idList forKey:@"snList"];
    
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"sensor/setSensorRank" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

+ (NSURLSessionDataTask *)getSensorRealDataWithFamilyId:(NSString*)familyId deviceSn:(NSString*)deviceSn block:(void(^)(GSHSensorM *sensorM, NSError *error))block{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceSn forKey:@"deviceSn"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"sensor/getSensorRealDate" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        GSHSensorM *sensorM = [GSHSensorM yy_modelWithJSON:responseObject];
        if (block) {
            block(sensorM,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)getSensorHistoryDataWithFamilyId:(NSString*)familyId
                                                  deviceSn:(NSString*)deviceSn
                                                deviceType:(NSString*)deviceType
                                                   hisDate:(NSString*)hisDate
                                                     block:(void(^)(NSArray<GSHSensorHistoryMonitorM*>*monitorList, NSArray<GSHSensorAlarmM*>*alarmList, NSError *error))block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceSn forKey:@"deviceSn"];
    [dic setValue:hisDate forKey:@"hisDate"];
    [dic setValue:deviceType forKey:@"deviceType"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"sensor/getSensorHisDate" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *monitorList = [NSArray yy_modelArrayWithClass:GSHSensorHistoryMonitorM.class json:[(NSDictionary *)responseObject objectForKey:@"hisDateList"]];
        CGFloat startTime = [[NSDate dateWithString:hisDate format:@"yyyy-MM-dd"] timeIntervalSince1970] * 1000;
        CGFloat endTime = 0;
        if (![[NSDate dateWithString:hisDate format:@"yyyy-MM-dd"] isToday]) {
            endTime = [[NSDate dateWithString:[NSString stringWithFormat:@"%@ 23:59:59",hisDate] format:@"yyyy-MM-dd HH:mm:ss"] timeIntervalSince1970] * 1000;
        }
        for (GSHSensorHistoryMonitorM *monitor in monitorList) {
            monitor.startTime = startTime;
            if (endTime > 0) {
                monitor.endTime = endTime;
            }
        }
        NSArray *alarmList = [NSArray yy_modelArrayWithClass:GSHSensorAlarmM.class json:[(NSDictionary *)responseObject objectForKey:@"hisAlarmList"]];
        if (block) {
            block(monitorList,alarmList,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)getSensorGroupDetailWithFamilyId:(NSString*)familyId deviceId:(NSString*)deviceId block:(void(^)(NSArray<GSHSensorM*> *list, NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceId forKey:@"deviceId"];
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getCombinedSensorMembers" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHSensorM.class json:[(NSDictionary *)responseObject objectForKey:@"list"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)getSensorGroupTypeWithBlock:(void(^)(NSArray<GSHDeviceCategoryM*> *list, NSError *error))block{
    return [[GSHOpenSDKInternal share].httpAPIClient GET:@"setting/getSensorTypes" parameters:nil progress:nil success:^(id operationOrTask, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:GSHDeviceCategoryM.class json:[(NSDictionary *)responseObject objectForKey:@"list"]];
        if (block) {
            block(list,nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)postSensorGroupUnindWithFamilyId:(NSString*)familyId deviceId:(NSString*)deviceId block:(void(^)(NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceId forKey:@"deviceId"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"setting/unBindCombinedSensor" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

+ (NSURLSessionDataTask *)postSensorGroupUpdataWithFamilyId:(NSString*)familyId deviceId:(NSString*)deviceId deviceType:(NSString*)deviceType roomId:(NSString*)roomId deviceName:(NSString*)deviceName block:(void(^)(NSError *error))block;{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:familyId forKey:@"familyId"];
    [dic setValue:deviceId forKey:@"deviceId"];
    [dic setValue:deviceType forKey:@"deviceType"];
    [dic setValue:roomId forKey:@"roomId"];
    [dic setValue:deviceName forKey:@"deviceName"];
    return [[GSHOpenSDKInternal share].httpAPIClient POST:@"setting/updateCombinedSensor" parameters:dic progress:nil success:^(id operationOrTask, id responseObject) {
        if (block) {
            block(nil);
        }
    } failure:^(id operationOrTask, NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

//获取指数设备
+(NSURLSessionDataTask*)getFamilyIndexDeviceWithFamilyId:(NSString*)familyId floorId:(NSNumber*)floorId block:(void(^)(NSArray<GSHSensorM*> *list,NSArray<GSHMissingSensorM*> *missingList,NSString *tip,NSError *error))block{
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        NSArray *arr = [[GSHSensorDao shareSensorDao] selectSensorTableWithFloorId:floorId.stringValue];
        if (block) {
            block(arr,nil,nil,nil);
        }
        return nil;
    }else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:familyId forKey:@"familyId"];
        [dic setValue:floorId forKey:@"floorId"];
        return [[GSHOpenSDKInternal share].httpAPIClient GET:@"homePage/getFamilyIndexSensor" parameters:dic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSArray *list = nil;
            NSArray *missingList = nil;
            NSString *tip = nil;
            if ([[(NSDictionary *)responseObject objectForKey:@"missingList"] isKindOfClass:NSArray.class]) {
                missingList = [NSArray yy_modelArrayWithClass:GSHMissingSensorM.class json:[(NSDictionary *)responseObject objectForKey:@"missingList"]];
            }
            if ([[(NSDictionary *)responseObject objectForKey:@"sensorList"] isKindOfClass:NSArray.class]) {
                list = [NSArray yy_modelArrayWithClass:GSHSensorM.class json:[(NSDictionary *)responseObject objectForKey:@"sensorList"]];
            }
            if ([[(NSDictionary *)responseObject objectForKey:@"tip"] isKindOfClass:NSString.class]) {
                tip = [(NSDictionary *)responseObject objectForKey:@"tip"];
            }
            if (block) {
                block(list,missingList,tip,nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (block) {
                block(nil,nil,nil,error);
            }
        }];
    }
}
@end
