//
//  GSHDeviceInfoDefines.h
//  SmartHome
//
//  Created by zhanghong on 2018/11/23.
//  Copyright © 2018 gemdale. All rights reserved.
//


/*
    此文件主要定义设备相关的宏
*/

#ifndef GSHDeviceInfoDefines_h
#define GSHDeviceInfoDefines_h

// 萤石猫眼
#define GSHYingShiMaoYanDeviceType @(15)
// 萤石摄像头
#define GSHYingShiSheXiangTou1DeviceType @(16)
// 萤石摄像头
#define GSHYingShiSheXiangTou2DeviceType @(17)

// 声必可
#define GSHShengBiKeDeviceType @(18)

// 网关
#define GateWayDeviceType 32767
#define GateWayDeviceType2 32766

// 设备在线离线状态属性id
#define GSHDeviceOnLineStateMeteId @"026FFF00DE0001"

// 一路开关
#define GSHOneWaySwitchDeviceType @(0)
#define GSHOneWaySwitch_firstMeteId @"04000000060001"

// 二路开关
#define GSHTwoWaySwitchDeviceType @(1)
#define GSHTwoWaySwitch_firstMeteId @"04000100060001"
#define GSHTwoWaySwitch_secondMeteId @"04000100060002"

// 三路开关
#define GSHThreeWaySwitchDeviceType @(2)
#define GSHThreeWaySwitch_firstMeteId @"04000200060001"
#define GSHThreeWaySwitch_secondMeteId @"04000200060002"
#define GSHThreeWaySwitch_thirdMeteId @"04000200060003"

// 窗帘电机
#define GSHCurtainDeviceType @(515)
#define GSHCurtain_SwitchMeteId @"04020301020001"   // 开关
#define GSHCurtain_PercentMeteId @"03020300080001"  // 百分比

// 一路窗帘开关
#define GSHOneWayCurtainDeviceType @(519)
#define GSHOneWayCurtain_SwitchMeteId @"04020701020001"

// 二路窗帘开关
#define GSHTwoWayCurtainDeviceType @(517)
#define GSHTwoWayCurtain_OneSwitchMeteId @"04020501020001"
#define GSHTwoWayCurtain_TwoSwitchMeteId @"04020501020002"

// 空调
#define GSHAirConditionerDeviceType @(768)
#define GSHAirConditioner_SwitchMeteId @"04030000050002"   // 开关
#define GSHAirConditioner_ModelMeteId @"04030000050001"   // 模式
#define GSHAirConditioner_TemperatureMeteId @"03030000070001"   // 温度
#define GSHAirConditioner_WindSpeedMeteId @"04030000090001"   // 风量

// 空调转换器
#define GSHAirConditionerTranDeviceType @(17476)

// 新风
#define GSHNewWindDeviceType @(7)
#define GSHNewWind_SwitchMeteId @"040007000B0002"   // 开关
#define GSHNewWind_WindSpeedMeteId @"040007000B0001"   // 风量

// 地暖
#define GSHUnderFloorDeviceType @(518)
#define GSHUnderFloor_SwitchMeteId @"04020600060001"   // 开关
#define GSHUnderFloor_TemperatureMeteId  @"03020600110001"   // 温度

// 插座
#define GSHSocket1DeviceType @(81)
#define GSHSocket1_ElectricQuantityKey @"01005100EF0001"    // 电流
#define GSHSocket1_PowerKey @"01005100EC0001"    // 功率
#define GSHSocket1_SocketSwitchMeteId @"04005100060001" // 开关
#define GSHSocket1_USBSwitchMeteId @"04005100060002"    // USB开关

#define GSHSocket2DeviceType @(82)
#define GSHSocket2_ElectricQuantityKey @"01005200EF0001"    // 电流
#define GSHSocket2_PowerKey @"01005200EC0001"    // 功率
#define GSHSocket2_SocketSwitchMeteId @"04005200060001" // 开关

// 场景面板
#define GSHScenePanelDeviceType @(12)
#define GSHScenePanel_FirstMeteId @"02000C00400001" // 第一路
#define GSHScenePanel_SecondMeteId @"02000C00400002" // 第二路
#define GSHScenePanel_ThirdMeteId @"02000C00400003" // 第三路
#define GSHScenePanel_FourthMeteId @"02000C00400004" // 第四路
#define GSHScenePanel_FifthMeteId @"02000C00400005" // 第五路
#define GSHScenePanel_SixthMeteId @"02000C00400006" // 第六路

// 组合传感器
#define GSHSensorGroupDeviceType @(46)

// 红外转发
#define GSHInfraredControllerDeviceType @(254)

#pragma mark - 传感器
// 温湿度传感器
#define GSHHumitureSensorDeviceType @(770)
#define GSHHumitureSensor_temMeteId @"01030204020001"   // 温度
#define GSHHumitureSensor_humMeteId @"01030204050001"   // 湿度
#define GSHHumitureSensor_electricMeteId @"020302003D0001"   //电量

// 人体红外传感器
#define GSHSomatasensorySensorDeviceType @(263)
#define GSHSomatasensorySensor_alarmMeteId @"02010704060001"    // 告警
#define GSHSomatasensorySensor_electricMeteId @"02010700340001"   //电量

// 门磁传感器
#define GSHGateMagetismSensorDeviceType @(21)
#define GSHGateMagetismSensor_isOpenedMeteId @"02001500150001"  // 被打开
#define GSHGateMagetismSensor_electricMeteId @"02001500310001"   //电量

// 水浸传感器
#define GSHWaterLoggingSensorDeviceType @(42)
#define GSHWaterLoggingSensor_alarmMeteId @"02002A002A0001" // 告警
#define GSHWaterLoggingSensor_electricMeteId @"02002A00370001"   //电量

// 空气盒子
#define GSHAirBoxSensorDeviceType @(45)
#define GSHAirBoxSensor_temMeteId @"01002D04020001"   // 温度
#define GSHAirBoxSensor_humMeteId @"01002D04050001"   // 湿度
#define GSHAirBoxSensor_pmMeteId @"01002D200D0001"   // PM2.5
#define GSHAirBoxSensor_electricMeteId @"01002D200E0001"   //电量百分比

// 紧急按钮
#define GSHSOSSensorDeviceType @(277)
#define GSHSOSSensor_alarmMeteId @"02011500410001"  // 告警

// 红外幕帘
#define GSHInfrareCurtainDeviceType @(47)
#define GSHInfrareCurtain_alarmMeteId @"02002F00F10001"

// 双向幕帘
#define GSHBothwayCurtainDeviceType @(48)
#define GSHBothwayCurtain_stateMeteId @"02003000F10001" // 1 : 由外向内 0 : 由内向外 2 : 正常

// 声光报警器
#define GSHAudibleVisualAlarmDeviceType @(1201)
#define GSHAudibleVisualAlarm_alarmMeteId @"0404B100F20001"

// 红外人体感应面板
#define GSHInfrareReactionDeviceType @(49)
#define GSHInfrareReaction_alarmMeteId @"02003100F30001"

// 烟雾传感器
#define GSHGasSensorDeviceType @(40)
#define GSHGasSensor_alarmMeteId @"02002800280001" // 告警
#define GSHGasSensor_electricMeteId @"020028003A0001"   //电量

// 可燃气体传感器
#define GSHCombustibleGasDeviceType @(43)
#define GSHCombustibleGas_alarmMeteId @"02002B00460001" // 可燃气体报警
#define GSHCombustibleGas_electricMeteId @"02002B00470001"  // 电量

// 一氧化碳传感器
#define GSHCoGasSensorDeviceType @(39)
#define GSHCoGasSensor_alarmMeteId @"020027004A0001" // 一氧化碳报警
#define GSHCoGasSensor_electricMeteId   @"020027004B0001"   // 电量

// 环境面板
#define GSHHuanjingSensorDeviceType @(87)
#define GSHHuanjingSensor_wenduMeteId   @"01005704020001" // 温度
#define GSHHuanjingSensor_shiduMeteId   @"01005704050001" // 湿度
#define GSHHuanjingSensor_pm25MeteId    @"010057200D0001" //  pm2.5
#define GSHHuanjingSensor_co2MeteId     @"010057040D0001" // 二氧化碳
#define GSHHuanjingSensor_youhaiMeteId  @"01005704990001" // 有害气体

// 可调开关
#define GSHAdjustLightDeviceType @(257)
#define GSHAdjustLight_offMeteId @"04010100060001"
#define GSHAdjustLight_wenSeMeteId @"03010103010001"
#define GSHAdjustLight_lightMeteId @"03010100020001"

// 门锁
#define GSHDoorLackDeviceType @(10)
#define GSHDoorLack_status @"01000A00960001"
#define GSHDoorLack_electric @"01000A00990001"
#endif
