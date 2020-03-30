//
//  GSHUpdateAutoStatusMsg.h
//  SmartHome
//
//  Created by zhanghong on 2019/4/8.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHBaseMsg.h"

@interface GSHUpdateAutoStatusMsg : GSHBaseMsg

- (instancetype)initWithGwId:(NSString *)gwId
                          sn:(int32_t)sn
                      ruleId:(NSString *)ruleId
                      status:(NSString *)status;

@end
