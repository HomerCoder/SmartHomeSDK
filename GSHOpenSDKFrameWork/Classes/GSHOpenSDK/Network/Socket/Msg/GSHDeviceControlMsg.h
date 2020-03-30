//
//  GSHDeviceControlMsg.h
//  SmartHome
//
//  Created by gemdale on 2019/2/19.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHBaseMsg.h"

@interface GSHDeviceControlMsg : GSHBaseMsg
- (instancetype)initWithGwId:(NSString *)gwId sn:(int32_t)sn deviceSN:(NSString*)deviceSN basMeteId:(NSString*)basMeteId value:(NSString*)value;
@end
