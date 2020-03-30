//
//  GSHExecuteSceneMsg.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHExecuteSceneMsg.h"

@implementation GSHExecuteSceneMsg

- (instancetype)initWithGwId:(NSString *)gwId sn:(int32_t)sn sceneId:(NSString *)sceneId{
    self = [super init];
    if (self) {
        self.message.errCode = 0;
        self.message.id_p = 403;
        self.message.gwId = gwId;
        self.message.sn = sn;
        
        ProtocolNodeMap *map = [ProtocolNodeMap new];
        
        ProtocolNode *note = [ProtocolNode new];
        note.name = @"ExecuteScenario";
        
        ProtocolNodeAttribute *attr1 =  [ProtocolNodeAttribute new];
        attr1.name = @"id";
        attr1.value = sceneId;
        
        note.attrArray = [NSMutableArray arrayWithObjects:attr1,nil];
        note.name = @"ExecuteScenario";
        
        map.nodeArray = [NSMutableArray arrayWithObject:note];
        map.name = @"ExecuteScenario";
        self.message.nodeArray = [NSMutableArray arrayWithObject:map];
        
        self.response_id_p = 404;
    }
    return self;
}

@end
