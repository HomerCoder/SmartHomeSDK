//
//  GSHMsgBaseM.h
//  SmartHome
//
//  Created by gemdale on 2018/6/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocol.pbobjc.h"

@interface GSHBaseMsg : NSObject
@property (nonatomic,assign,readonly)int32_t sn;
@property(nonatomic, readwrite) int32_t response_id_p;  // 请求id 对应的返回id 例如：如果 id_p == 301 则 response_id_p = 302
@property (nonatomic,strong,readonly)Protocol_Class *message;

-(NSData*)msgData;

+(GSHBaseMsg *)msgBaseMWithData:(NSData *)data;

+(Protocol_Class*)msgWithData:(NSData*)data;

+(ProtocolNodeMap*)nodeMapWithName:(NSString*)name nodeList:(NSMutableArray<ProtocolNode*>*)node;

+(ProtocolNodeAttribute*)nodeAttributeWithName:(NSString*)name value:(NSString*)value;

+(ProtocolNode*)nodeWithName:(NSString*)name value:(NSString*)value attrArray:(NSMutableArray<ProtocolNodeAttribute*>*)attrArray nodeArray:(NSMutableArray<ProtocolNodeMap*>*)nodeArray;
@end
