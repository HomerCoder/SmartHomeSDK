//
//  GSHExecuteSceneMsg.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHBaseMsg.h"

@interface GSHExecuteSceneMsg : GSHBaseMsg

- (instancetype)initWithGwId:(NSString *)gwId sn:(int32_t)sn sceneId:(NSString *)sceneId;

@end


