//
//  GSHDeviceRealTimeMsg.m
//  SmartHome
//
//  Created by gemdale on 2018/6/22.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDeviceRealTimeMsg.h"

@implementation GSHDeviceRealTimeMsg
- (instancetype)initWithGwId:(NSString *)gwId {
    self = [super init];
    if (self) {
        self.message.errCode = 0;
        self.message.id_p = 301;
        self.message.gwId = gwId; //@"261702845899146592";
        self.response_id_p = 302;
        
        ProtocolNodeMap *map = [ProtocolNodeMap new];
        
        ProtocolNode *note = [ProtocolNode new];
        note.name = @"RealTime";
        
        ProtocolNodeAttribute *attr1 =  [ProtocolNodeAttribute new];
        attr1.name = @"randomcode";
        attr1.value = @"1";
        note.attrArray = [NSMutableArray arrayWithObjects:attr1,nil];
        note.name = @"RealTime";
        
        map.nodeArray = [NSMutableArray arrayWithObject:note];
        map.name = @"RealTime";
        self.message.nodeArray = [NSMutableArray arrayWithObject:map];
    }
    return self;
}


@end
