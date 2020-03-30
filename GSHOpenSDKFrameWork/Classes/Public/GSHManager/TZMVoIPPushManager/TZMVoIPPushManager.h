//
//  TZMVoIPPushManager.h
//  SmartHome
//
//  Created by gemdale on 2019/4/29.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>

extern NSString *const TZMVoIPPushManagerIncomingPushNoticfication;

@interface TZMVoIPPushManager : NSObject
@property(nonatomic,copy)NSString *token;
@property(nonatomic,assign)BOOL canPlaySound;

+ (instancetype)shared;

-(void)registry;

+(NSDictionary*)lastDictionaryPayload;

- (void)stopPlaySound;

- (void)startPlaySound;
@end
