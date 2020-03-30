//
//  GSHGWSearchM.m
//  SmartHome
//
//  Created by zhanghong on 2018/8/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHGWSearchMsg.h"

@implementation GSHGWSearchMsg

-(instancetype)init{
    self = [super init];
    if (self) {
        self.message.errCode = 0;
        self.message.id_p = 801;
    }
    return self;
}

@end
