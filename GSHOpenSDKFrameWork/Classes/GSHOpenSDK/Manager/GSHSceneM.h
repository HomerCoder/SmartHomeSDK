//
//  GSHSceneM.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseModel.h"
#import "GSHDeviceM.h"
//#import "GSHFloorM.h"
@class GSHFloorM;

@interface GSHSceneBackgroundImageM : GSHBaseModel

@property (nonatomic , strong) NSNumber *scenarioBgImgId;   //背景图片id
@property (nonatomic , strong) NSString *picUrl;   //背景图片url

@end

// 场景banner model , 此model可封装为全局通用，暂时先放在GSHSceneM中
@interface GSHSceneBannerM : GSHBaseModel

@property (nonatomic,strong) NSNumber *bannerId;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *picUrl;
@property (nonatomic,copy) NSString *title;

@end

// 场景模版model
@interface GSHSceneTemplateM : GSHBaseModel

@property (nonatomic,copy) NSString *descriptionStr;
@property (nonatomic,copy) NSString *imgUrl;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSNumber *sceneTemplateId;

@end

// 场景模版详情model
@interface GSHSceneTemplateDetailInfoM : GSHBaseModel

@property (nonatomic,copy) NSString *bgImgUrl;  // 场景背景图url
@property (nonatomic,strong) NSNumber *bgImgId; // 场景背景图id
@property (nonatomic,copy) NSString *descriptionStr;
@property (nonatomic,strong) NSNumber *sceneTemplateId;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *imgUrl;
@property (nonatomic,strong) NSMutableArray <GSHDeviceTypeM *> *deviceTypes;

@end

@interface GSHOssSceneM : GSHBaseModel

@property (nonatomic , strong) NSNumber *backgroundId;
@property (nonatomic , strong) NSString *backgroundUrl;   //背景图片url
@property (nonatomic , strong) NSNumber *familyId;
@property (nonatomic , copy) NSString *fid;
@property (nonatomic , strong) NSNumber *scenarioId;
@property (nonatomic , copy) NSString *md5;
@property (nonatomic , strong) NSNumber *rank;
@property (nonatomic , copy) NSString *scenarioName;
@property (nonatomic , copy) NSString *floorName;
@property (nonatomic , copy) NSString *roomName;
@property (nonatomic , strong) NSNumber *roomId;
@property (nonatomic , strong) NSString *voiceKeyword;
@property (nonatomic , strong) NSNumber *businessId;
@property (nonatomic , strong) NSNumber *scenarioTplId;

- (BOOL)isSelected;
- (void)setIsSelected:(BOOL)isSelected;

@end

// v3.0 场景列表model
@interface GSHSceneListM : GSHBaseModel

@property (nonatomic,strong) NSMutableArray <GSHSceneBannerM *> *banners;
@property (nonatomic,strong) NSMutableArray <GSHSceneTemplateM *> *scenarioTpls;
@property (nonatomic,strong) NSNumber *total;   // 场景总数
@property (nonatomic,strong) NSMutableArray <GSHOssSceneM *> *scenarios;

@end

@interface GSHNameIdM : GSHBaseModel

@property (nonatomic,copy) NSNumber *idStr;     //
@property (nonatomic,copy) NSString *nameStr;   //

@end

@class GSHFloorM;
@interface GSHSceneM : GSHBaseModel 

@property (nonatomic , strong) NSNumber *backgroundId;   //背景图片id
@property (nonatomic , strong) NSString *picUrl;   //背景图片url
@property (nonatomic , strong) NSNumber *familyId;   //家庭id
@property (nonatomic , strong) NSNumber *floorId;   //楼层id
@property (nonatomic , copy) NSString *floorName;   //楼层名称
@property (nonatomic , strong) NSNumber *roomId;   //房间id
@property (nonatomic , copy) NSString *roomName;   //房间名称
@property (nonatomic , strong) NSNumber *scenarioId;   //情景id
@property (nonatomic , strong) NSNumber *rank;   //排序
@property (nonatomic , strong) NSNumber *userId;   //用户id
@property (nonatomic , copy) NSString *scenarioName;   //情景名称
@property (nonatomic , copy) NSString *voiceKeyword;    // 语音关键词
@property (nonatomic , strong) NSMutableArray<GSHDeviceM *> *devices;    

- (BOOL)isSelected;
- (void)setIsSelected:(BOOL)isSelected;

// 添加场景页面 -- 根据backgroundId获取场景背景图片
+(UIImage*)getSceneBackgroundImageWithId:(int)backgroundId;

// 首页 -- 场景背景图片
+(UIImage*)getHomeSceneBackgroundImageWithId:(int)backgroundId;

// 场景列表页面 -- 获取场景背景图片
+(UIImage*)getSceneListBackgroundImageWithId:(int)backgroundId;

@end


@interface GSHSceneManager : NSObject
#pragma mark - 场景相关基本功能
// 添加场景
+ (NSURLSessionDataTask *)addSceneWithSceneM:(GSHSceneM *)sceneM
                                   ossSceneM:(GSHOssSceneM *)ossSceneM
                                       block:(void(^)(NSString *scenarionId , NSError *error))block;

// 删除场景
+ (NSURLSessionDataTask *)deleteSceneWithOssSceneM:(GSHOssSceneM *)ossSceneM
                                          familyId:(NSString *)familyId
                                             block:(void(^)(NSError *error))block;

// 修改场景
+ (NSURLSessionDataTask *)alertSceneWithVolumeId:(NSString *)volumeId
                                       oldRoomId:(NSString *)oldRoomId
                                          sceneM:(GSHSceneM *)sceneM
                                       ossSceneM:(GSHOssSceneM *)ossSceneM
                                           block:(void(^)(NSError *error))block;

// 获取场景列表
+ (NSURLSessionDataTask *)getSceneListWithFamilyId:(NSString *)familyId
                                          currPage:(NSString *)currPage
                                             block:(void(^)(GSHSceneListM *sceneListM,NSError *error))block;

// 场景列表排序
+ (NSURLSessionDataTask *)sortSceneWithFamilyId:(NSString *)familyId
                                      rankArray:(NSArray *)rankArray
                                          block:(void(^)(NSError *error))block;

// 执行场景
+ (NSURLSessionDataTask *)executeSceneWithFamilyId:(NSString *)familyId
                                         gateWayId:(NSString *)gateWayId
                                        scenarioId:(NSString *)scenarioId
                                             block:(void(^)(NSError *error))block;


// 校验语音关键词
+ (NSURLSessionDataTask *)verifyVoiceKeyWordWithFamilyId:(NSString *)familyId
                                            voiceKeyWord:(NSString *)voiceKeyWord
                                                   block:(void(^)(NSError *error))block;

// 场景选择设备 -- 查询楼层房间信息
+ (NSURLSessionDataTask *)getAllFloorAndRoomWithFamilyId:(NSString *)familyId
                                                   block:(void(^)(NSArray<GSHFloorM*>*list,NSError *error))block;

// 单独获取首页某房间场景
+ (NSURLSessionDataTask *)getHomeVCSceneWithFamilyId:(NSString *)familyId
                                              roomId:(NSNumber*)roomId
                                               block:(void(^)(NSArray<GSHSceneM*>*list,NSError *error))block;

// 校验设备信息是否有更改，设备是否被删除
+ (NSURLSessionDataTask *)checkDevicesFromServerWithDeviceIdArray:(NSArray *)deviceIdArray
                                                       sceneArray:(NSArray *)sceneArray
                                                        autoArray:(NSArray *)autoArray
                                                         familyId:(NSString *)familyId
                                                            block:(void(^)(NSArray <GSHNameIdM*> *deviceArr,NSError *error))block;
// 场景模块 -- 获取执行动作设备
+ (NSURLSessionDataTask *)getSceneDevicesListWithFamilyId:(NSString *)familyId
                                                   roomId:(NSString *)roomId
                                                    block:(void(^)(NSArray<GSHDeviceM*> *list,NSError *error))block;

// 从oss服务端获取场景数据
+ (void)getSceneFileFromOssWithFid:(NSString *)fid
                             block:(void(^)(NSString *json,NSError *error))block;

// v3.0新增 -- 获取所有情景模板
+ (NSURLSessionDataTask *)getSceneTemplateListWithFamilyId:(NSString *)familyId
                                           isOnlyRecommend:(NSString *)isOnlyRecommend
                                                     block:(void(^)(NSArray<GSHSceneTemplateM*>*list,NSError *error))block;

// v3.0新增 -- 获取情景模板详情
+ (NSURLSessionDataTask *)getSceneTemplateDetailWithFamilyId:(NSString *)familyId
                                             sceneTemplateId:(NSNumber *)sceneTemplateId
                                                       block:(void(^)(GSHSceneTemplateDetailInfoM *sceneTemplateDetailInfoM,NSError *error))block;

// v3.0新增 -- 获取场景背景图片
+ (NSURLSessionDataTask *)getScenarioBackgroundImageListblock:(void(^)(NSArray<GSHSceneBackgroundImageM *>*list,NSError *error))block;
@end

