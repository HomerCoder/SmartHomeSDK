//
//  GSHHeartMsg.m
//  SmartHome
//
//  Created by gemdale on 2018/6/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHHeartMsg.h"

@implementation GSHHeartMsg
-(instancetype)initWithGatewayId:(NSString*)gatewayId{
    self = [super init];
    if (self) {
        self.message.errCode = 0;
        self.message.id_p = 315;
        self.message.gwId = gatewayId;
    }
    return self;
}
@end
