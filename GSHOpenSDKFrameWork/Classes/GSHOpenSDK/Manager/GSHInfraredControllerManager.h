//
//  GSHInfraredControllerM.h
//  SmartHome
//
//  Created by gemdale on 2019/2/21.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDeviceM.h"
#import "KKZipACManager.h"
#import <TZMExternalPackagLib/IRConstants.h>
#import <TZMExternalPackagLib/KookongSDK.h>

//品牌类
@interface GSHKuKongBrandM : GSHBaseModel
@property(nonatomic,strong)NSNumber *brandId;       //品牌ID
@property(nonatomic,strong)NSNumber *spId;          //运营商ID（和品牌ID相互出现）
@property(nonatomic,copy)NSString *enName;          //英文名
@property(nonatomic,copy)NSString *name;            //中文名
@property(nonatomic,assign)BOOL isSP;               //是否是运营商对象转换过来的
@end
//品牌列表
@interface GSHKuKongBrandListM : GSHBaseModel
@property(nonatomic,copy)NSString *pyCh;                            //拼音首字母
@property(nonatomic,strong)NSArray<GSHKuKongBrandM*> *dataList;     //品牌列表
@end
//支持的品类
@interface GSHKuKongDeviceTypeM : GSHBaseModel
@property(nonatomic,strong)NSNumber *devicetypeId;                  //品类ID
@property(nonatomic,copy)NSString *name;                            //名字
@property(nonatomic,copy)NSString *displayName;                     //显示的名字
@property(nonatomic,copy)NSString *kkPicPath;               //图片
@end
//遥控器对象
@interface GSHKuKongRemoteM : GSHBaseModel
//@property(nonatomic,strong)NSNumber *frequency;                     //频率
//@property(nonatomic,strong)NSNumber *type;                          //红外格式
@property(nonatomic,strong)NSNumber *remoteId;                      //遥控器ID
@property(nonatomic,copy)NSString *fid;                             //文件名
@property(nonatomic,copy)NSString *md5;                             //文件校验码
@property(nonatomic,copy)NSString *fileUrl;                         //文件地址
//以下三个方法只有在空调遥控使用到
-(void)setAirConditionerManager:(KKZipACManager *)manager;          //如果是空调遥控可以设置空调管理器
-(KKZipACManager *)airConditionerManager;                           //如果是空调遥控可以获取空调管理器
//通过接口获取空调遥控光利器
+ (NSURLSessionDataTask *)getKuKongDeviceIrDataWithDeviceSn:(NSString*)deviceSn fileUrl:(NSString*)fileUrl fid:(NSString*)fid remoteId:(NSNumber*)remoteId block:(void(^)(KKZipACManager *manager, NSError *error))block;
@end
//遥控器键码
@interface GSHKuKongInfraredTryKeyM : GSHBaseModel
@property(nonatomic,strong)NSNumber *keyId;         //键值ID
@property(nonatomic,copy)NSString *displayName;     //展示名字
//@property(nonatomic,copy)NSString *name;            //名字
@end
//遥控器对应设备
@interface GSHKuKongInfraredDeviceM : GSHDeviceM
@property(nonatomic,copy)NSString *fid;                     //文件fid
@property(nonatomic,copy)NSString *fileUrl;                 //文件地址
@property(nonatomic,strong)NSNumber *kkDeviceBrand;         //设备品牌
@property(nonatomic,strong)NSNumber *kkDeviceType;          //设备类型
@property(nonatomic,copy)NSString *parentDeviceName;        //父设备名
@property(nonatomic,copy)NSString *parentDeviceSn;          //红外转发器设备唯一标识
@property(nonatomic,strong)NSNumber *parentDeviceId;        //红外转发器设备id
@property(nonatomic,strong)NSNumber *remoteId;              //遥控器ID
@property(nonatomic,strong)NSNumber *bindRemoteId;          //绑定的遥控器ID(机顶盒需要绑定电视的遥控)
@property(nonatomic,copy)NSString *kkPicPath;               //图片
@end

@interface GSHInfraredControllerManager : NSObject
//初始化KukongSDK
+ (void)initKuKongSDKWithUserAuthority:(NSString*)userAuthority;
// 获取虚拟遥控列表
+ (NSURLSessionDataTask *)getKuKongDeviceListWithParentDeviceId:(NSNumber*)parentDeviceId familyId:(NSString*)familyId kkDeviceType:(NSNumber*)kkDeviceType deviceSn:(NSString*)deviceSn block:(void(^)(NSArray<GSHKuKongInfraredDeviceM*> *list, NSError *error))block;
// 获取类型列表
+ (NSURLSessionDataTask *)getKuKongDeviceTypeListWithBlock:(void(^)(NSArray<GSHKuKongDeviceTypeM*> *list,NSNumber *version, NSError *error))block;
// 获取品牌列表（机顶盒包括运营商）
+ (NSURLSessionDataTask *)getKuKongBrandListWithDeviceType:(NSNumber*)devicetypeId block:(void(^)(NSMutableArray<GSHKuKongBrandListM*> *list, NSError *error))block;
// 获取遥控列表（机顶盒包括运营商）
+ (NSURLSessionDataTask *)getKuKongRemoteListWithDeviceType:(NSNumber*)devicetypeId brand:(GSHKuKongBrandM*)brand block:(void(^)(NSMutableArray<GSHKuKongRemoteM*> *list, NSError *error))block;
// 用户获取酷控对码按键
+ (NSURLSessionDataTask *)getKuKongModuleTryKeysWithDeviceType:(NSNumber*)devicetypeId block:(void(^)(NSArray<GSHKuKongInfraredTryKeyM*> *keyList, NSError *error))block;
// 用户对码
+ (NSURLSessionDataTask *)postKuKongModuleVerifyWithRemoteId:(NSNumber*)remoteId deviceSN:(NSString*)deviceSN familyId:(NSString*)familyId operType:(NSInteger)operType deviceTypeId:(NSNumber*)deviceTypeId remoteParam:(NSString*)remoteParam keyParam:(NSString*)keyParam keyId:(NSNumber*)keyId block:(void(^)(NSError *error))block;
// 用户获取酷控遥控器按键模板
+ (NSURLSessionDataTask *)getKuKongModulePanelKeysWithDeviceType:(NSNumber*)devicetypeId block:(void(^)(NSString *keyString, NSError *error))block;
// 保存红外设备
+ (NSURLSessionDataTask *)postSaveInfraredDeviceWithFamilyId:(NSString*)familyId deviceSn:(NSString*)deviceSn deviceId:(NSNumber*)parentDeviceId deviceBrand:(NSNumber*)deviceBrand deviceType:(NSNumber*)deviceType remoteId:(NSNumber*)remoteId deviceName:(NSString*)deviceName roomId:(NSNumber*)roomId remoteParam:(NSString*)remoteParam block:(void(^)(NSError *error))block;
// 更新红外设备
+ (NSURLSessionDataTask *)postUpdateInfraredDeviceWithFamilyId:(NSString*)familyId deviceSn:(NSString*)deviceSn bindRemoteId:(NSNumber*)bindRemoteId deviceName:(NSString*)deviceName roomId:(NSNumber*)roomId newRoomId:(NSNumber*)newRoomId block:(void(^)(NSError *error))block;
// 解绑红外设备
+ (NSURLSessionDataTask *)postUpdateInfraredDeviceWithFamilyId:(NSString*)familyId deviceSn:(NSString*)deviceSn deviceName:(NSString*)deviceName roomId:(NSNumber*)roomId newRoomId:(NSNumber*)newRoomId block:(void(^)(NSError *error))block;
// 删除红外设备
+ (NSURLSessionDataTask *)postDeleteInfraredDeviceWithDeviceSn:(NSString*)deviceSn roomId:(NSString*)roomId block:(void(^)(NSError *error))block;
@end

