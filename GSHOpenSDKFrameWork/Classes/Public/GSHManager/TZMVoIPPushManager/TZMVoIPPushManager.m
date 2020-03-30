//
//  TZMVoIPPushManager.m
//  SmartHome
//
//  Created by gemdale on 2019/4/29.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "TZMVoIPPushManager.h"
#import <UserNotifications/UserNotifications.h>
#import <AudioToolbox/AudioToolbox.h>

NSString *const TZMVoIPPushManagerIncomingPushNoticfication = @"TZMVoIPPushManagerIncomingPushNoticfication";
NSString *const TZMVoIPPushManagerPushLastDictionaryPayload = @"TZMVoIPPushManagerPushLastDictionaryPayload";

@interface TZMVoIPPushManager()<PKPushRegistryDelegate>
@property(nonatomic,assign)SystemSoundID soundID;
@property(nonatomic,strong)dispatch_source_t timer;
@end

@implementation TZMVoIPPushManager

+ (instancetype)shared {
    static TZMVoIPPushManager *_pushManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pushManager = [TZMVoIPPushManager new];
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"request authorization succeeded!");
                }
            }];
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                NSLog(@"%@",settings);
            }];
        }
        NSString *keyStringPath = [[NSBundle mainBundle]pathForResource:@"doorbell" ofType:@"wav"];
        NSURL *url = [NSURL URLWithString:keyStringPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &(_pushManager->_soundID));
        _pushManager.canPlaySound = YES;
    });
    return _pushManager;
}

-(void)registry{
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:nil];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

-(void)dealloc{
    AudioServicesDisposeSystemSoundID(self.soundID);
}

+(NSDictionary*)lastDictionaryPayload{
    return [[NSUserDefaults standardUserDefaults] objectForKey:TZMVoIPPushManagerPushLastDictionaryPayload];
}

+(void)setlastDictionaryPayload:(NSDictionary*)dic{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:dic forKey:TZMVoIPPushManagerPushLastDictionaryPayload];
    [userDefaults synchronize];
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type{
    self.token = [[[[pushCredentials.token description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type NS_DEPRECATED_IOS(8_0, 11_0){
    [self didReceiveIncomingPushWithPayload:payload];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void(^)(void))completion {
    [self didReceiveIncomingPushWithPayload:payload];
}

- (void)didReceiveIncomingPushWithPayload:(PKPushPayload *)payload{
    //保存最后信息
    NSNotification *notification = [NSNotification notificationWithName:TZMVoIPPushManagerIncomingPushNoticfication object:payload.dictionaryPayload];
    if([payload.dictionaryPayload isKindOfClass:NSDictionary.class]){
        [self.class setlastDictionaryPayload:payload.dictionaryPayload];
    }
    //发送推送
    NSDictionary *aps = [payload.dictionaryPayload objectForKey:@"aps"];
    if ([aps isKindOfClass:NSDictionary.class]) {
        NSString *title = [aps objectForKey:@"title"];
        if ([title isKindOfClass:NSString.class]) {
            [self push:title];
        }
    }
    //开始震动铃声
    if (self.canPlaySound) {
        [self startPlaySound];
    }
    //通知App
    if ([NSThread isMainThread]) return [[NSNotificationCenter defaultCenter] postNotification:notification];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

- (void)push:(NSString *)string {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.body =[NSString localizedUserNotificationStringForKey:string arguments:nil];
        UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Voip_Push" content:content trigger:trigger];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        }];
    }else{
        UILocalNotification *callNotification = [[UILocalNotification alloc] init];
        callNotification.alertBody = string;
        [[UIApplication sharedApplication] presentLocalNotificationNow:callNotification];
    }
}

- (void)startPlaySound{
    __weak typeof(self) weakSelf = self;
    [self stopPlaySound];
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(weakSelf.timer, DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(weakSelf.timer, ^{
        [weakSelf playSound];
    });
    dispatch_resume(self.timer);
}

- (void)stopPlaySound{
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)playSound{
    AudioServicesPlaySystemSound(self.soundID);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    });
}

@end
