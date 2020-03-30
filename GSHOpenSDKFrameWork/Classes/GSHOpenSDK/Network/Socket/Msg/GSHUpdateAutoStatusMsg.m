//
//  GSHUpdateAutoStatusMsg.m
//  SmartHome
//
//  Created by zhanghong on 2019/4/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHUpdateAutoStatusMsg.h"

@implementation GSHUpdateAutoStatusMsg

- (instancetype)initWithGwId:(NSString *)gwId
                          sn:(int32_t)sn
                      ruleId:(NSString *)ruleId
                      status:(NSString *)status {
    self = [super init];
    if (self) {
        self.message.errCode = 0;
        self.message.id_p = 219;
        self.message.gwId = gwId;
        self.message.sn = sn;
        
        ProtocolNodeMap *map = [ProtocolNodeMap new];
        
        ProtocolNode *note = [ProtocolNode new];
        note.name = @"UpdateAutoInfo";
        
        ProtocolNodeAttribute *attr1 =  [ProtocolNodeAttribute new];
        attr1.name = @"ruleId";
        attr1.value = ruleId;
        
        ProtocolNodeAttribute *attr2 =  [ProtocolNodeAttribute new];
        attr1.name = @"status";
        attr1.value = status;
        
        note.attrArray = [NSMutableArray arrayWithObjects:attr1,attr2,nil];
        note.name = @"UpdateAutoInfo";
        
        map.nodeArray = [NSMutableArray arrayWithObject:note];
        map.name = @"UpdateAutoInfo";
        self.message.nodeArray = [NSMutableArray arrayWithObject:map];
        
        self.response_id_p = 220;
    }
    return self;
}

@end
