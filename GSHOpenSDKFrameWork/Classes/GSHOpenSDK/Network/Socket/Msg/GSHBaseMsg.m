//
//  GSHMsgBaseM.m
//  SmartHome
//
//  Created by gemdale on 2018/6/19.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHBaseMsg.h"

@interface GSHBaseMsg ()
@property (nonatomic,strong,readwrite)Protocol_Class *message;
@property (nonatomic,assign,readwrite)int32_t sn;
@end

@implementation GSHBaseMsg
-(instancetype)init{
    self = [super init];
    if (self) {
        static int32_t socketMsgSn = 0;
        _sn = ++socketMsgSn;
        _message = [Protocol_Class new];
        self.message.sn = (int32_t)self.sn;
    }
    return self;
}

-(NSData*)msgData{
    NSData *data = [self.message data];
    NSInteger length = (NSInteger)(data.length);
    NSData *dataLength = [GSHBaseMsg intToData:length];
    
    NSMutableData *requestData = [NSMutableData data];
    [requestData appendData:dataLength];
    [requestData appendData:data];
    
    return requestData;
}

+ (NSData *)intToData:(NSInteger)value {
    Byte byte[4] = {};
    byte[0] =  (Byte) ((value>>24) & 0xFF);
    byte[1] =  (Byte) ((value>>16) & 0xFF);
    byte[2] =  (Byte) ((value>>8) & 0xFF);
    byte[3] =  (Byte) (value & 0xFF);
    return [NSData dataWithBytes:byte length:4];
}

+ (int)dataToInt:(NSData *)data {
    Byte byte[4] = {};
    [data getBytes:byte length:4];
    int value;
    value = (int) (((byte[0] & 0xFF)<<24)
                   | ((byte[1] & 0xFF)<<16)
                   | ((byte[2] & 0xFF)<<8)
                   | (byte[3] & 0xFF));
    
    return value;
}

+(GSHBaseMsg *)msgBaseMWithData:(NSData *)data {
    GSHBaseMsg *baseM = [GSHBaseMsg new];
    baseM.message = [GSHBaseMsg msgWithData:data];
    baseM.sn = baseM.message.sn;
    return baseM;
}

+(Protocol_Class*)msgWithData:(NSData*)data{
    NSData *lengthData = [data subdataWithRange:NSMakeRange(0, 4)];
    NSInteger length = [self dataToInt:lengthData];
    NSData *msgData = [data subdataWithRange:NSMakeRange(4, length)];
    NSError *err;
    Protocol_Class *message = [Protocol_Class parseFromData:msgData error:&err];
    return message;
}

+(ProtocolNodeMap*)nodeMapWithName:(NSString*)name nodeList:(NSMutableArray<ProtocolNode*>*)node{
    ProtocolNodeMap *map = [ProtocolNodeMap new];
    map.name = name;
    map.nodeArray = node;
    return map;
}

+(ProtocolNodeAttribute*)nodeAttributeWithName:(NSString*)name value:(NSString*)value{
    ProtocolNodeAttribute *attr = [ProtocolNodeAttribute new];
    attr.name = name;
    attr.value = value;
    return attr;
}

+(ProtocolNode*)nodeWithName:(NSString*)name value:(NSString*)value attrArray:(NSMutableArray<ProtocolNodeAttribute*>*)attrArray nodeArray:(NSMutableArray<ProtocolNodeMap*>*)nodeArray{
    ProtocolNode *node = [ProtocolNode new];
    node.name = name;
    node.value = value;
    node.attrArray = attrArray;
    node.nodeArray = nodeArray;
    return node;
}

@end
