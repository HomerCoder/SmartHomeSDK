
//
//  GSHDeviceControlMsg.m
//  SmartHome
//
//  Created by gemdale on 2019/2/19.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHDeviceControlMsg.h"

@implementation GSHDeviceControlMsg
- (instancetype)initWithGwId:(NSString *)gwId sn:(int32_t)sn deviceSN:(NSString*)deviceSN basMeteId:(NSString*)basMeteId value:(NSString*)value{
    self = [super init];
    if (self) {
        self.message.errCode = 0;
        self.message.id_p = 401;
        self.message.gwId = gwId;
        self.message.sn = sn;
        
        ProtocolNodeMap *map = [ProtocolNodeMap new];
        
        ProtocolNode *note = [ProtocolNode new];
        note.name = @"Control";
        
        ProtocolNodeAttribute *attr1 =  [ProtocolNodeAttribute new];
        attr1.name = @"deviceSN";
        attr1.value = deviceSN;
        ProtocolNodeAttribute *attr2 =  [ProtocolNodeAttribute new];
        attr2.name = @"basMeteId";
        attr2.value = basMeteId;
        ProtocolNodeAttribute *attr3 =  [ProtocolNodeAttribute new];
        attr3.name = @"value";
        attr3.value = value;
        note.attrArray = [NSMutableArray arrayWithObjects:attr1,attr2,attr3,nil];
        note.name = @"Control";
        
        map.nodeArray = [NSMutableArray arrayWithObject:note];
        map.name = @"Control";
        self.message.nodeArray = [NSMutableArray arrayWithObject:map];
        
        self.response_id_p = 402;
    }
    return self;
}
@end
