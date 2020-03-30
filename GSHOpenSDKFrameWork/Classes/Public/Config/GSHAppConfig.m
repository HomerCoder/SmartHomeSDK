//
//  GSHAppConfig.m
//  SmartHome
//
//  Created by gemdale on 2018/4/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAppConfig.h"

NSString * const GSHHTTPAPICustomIp = @"GSHHTTPAPICustomIp";
NSString * const GSHHTTPAPIInternetIp = @"GSHHTTPAPIInternetIp";
NSString * const GSHOSSAPIInternetIp = @"GSHOSSAPIInternetIp";

@interface GSHAppConfig()
@property (nonatomic, readwrite) GSHAppConfigType type;
@property (nonatomic, readwrite) NSString *typeString;
@property (nonatomic, readwrite) NSString *desc;

@property (nonatomic, readwrite, copy) NSString *tcpDomainString;
@property (nonatomic, readwrite, assign) uint16_t tcpHostPort;

@property (nonatomic, readwrite, copy) NSString *udpDomainString;
@property (nonatomic, readwrite, assign) uint16_t udpHostPort;
@end

@implementation GSHAppConfig

-(void)setHttpIpString:(NSString *)httpIpString{
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:httpIpString forKey:GSHHTTPAPIInternetIp];
    [userDefaults synchronize];
}

-(NSString *)httpIpString{
    NSString *ipString = [[NSUserDefaults standardUserDefaults] objectForKey:GSHHTTPAPIInternetIp];
    if (ipString.length > 0) {
        return ipString;
    }else{
        if (self.type == GSHAppConfigTypeProduction) {
            return @"120.77.143.38";
        } else {
            return self.httpHostString;
        }
    }
}

-(void)setOssIpString:(NSString *)ossIpString {
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:ossIpString forKey:GSHOSSAPIInternetIp];
    [userDefaults synchronize];
}

-(NSString *)ossIpString{
    NSString *ipString = [[NSUserDefaults standardUserDefaults] objectForKey:GSHOSSAPIInternetIp];
    if (ipString.length > 0) {
        return ipString;
    }else{
        return @"120.77.143.38";
    }
}


+ (void)load {
    [super load];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{@"GSHAppConfigType" : @(GSHAppConfigTypeProduction)}];
}

+ (instancetype)config {
    GSHAppConfigType type = (GSHAppConfigType)[[NSUserDefaults standardUserDefaults] integerForKey:@"GSHAppConfigType"];
    return [self configWithType:type];
}

+ (instancetype)configWithType:(GSHAppConfigType)type {
    switch (type) {
        case GSHAppConfigTypeIP:
            return [self.class ipConfig];
        case GSHAppConfigTypePrepare:
            return [self.class preConfig];
        case GSHAppConfigTypeTest:
            return [self.class testConfig];
        default:
            return [self.class proConfig];
    }
}

+(instancetype)proConfig{
    static dispatch_once_t onceToken;
    static GSHAppConfig *shard;
    dispatch_once(&onceToken, ^{
        GSHAppConfig *config = [GSHAppConfig new];
        config.type = GSHAppConfigTypeProduction;
        config.typeString = @"production";
        config.desc = @"正式环境";
        config.httpHostString = @"api.gemdalehome.com";
        config.httpPort = @(8777);
        config.h5IpString = @"h5.gemdalehome.com";
        config.httpDomainString = @"api.gemdalehome.com";
        config.ossDomainString = @"dfs.gemdalehome.com";
        config.ossHostString = @"";
        
        config.tcpDomainString = @"";
        config.tcpHostPort = 0;
        
        config.udpDomainString = @"";
        config.udpHostPort = 0;
        shard = config;
    });
    return shard;
}

+(instancetype)preConfig{
    static dispatch_once_t onceToken;
    static GSHAppConfig *shard;
    dispatch_once(&onceToken, ^{
        GSHAppConfig *config = [GSHAppConfig new];
        config.type = GSHAppConfigTypePrepare;
        config.typeString = @"prepare";
        config.desc = @"预发布环境";
        config.httpHostString = @"ppeapi.gemdalehome.com";
        config.h5IpString = @"ppeapi.gemdalehome.com";//@"10.34.4.45";
        config.httpDomainString = @"ppeapi.gemdalehome.com";
        config.httpPort = @(8887);
        config.ossDomainString = @"dfs.gemdalehome.com";//@"10.34.4.45:9333";
        config.ossHostString = @"dfs.gemdalehome.com";//@"10.34.4.45:9333";
        
        config.tcpDomainString = @"";
        config.tcpHostPort = 0;
        
        config.udpDomainString = @"";
        config.udpHostPort = 0;
        shard = config;
    });
    return shard;
}

+(instancetype)testConfig{
    static dispatch_once_t onceToken;
    static GSHAppConfig *shard;
    dispatch_once(&onceToken, ^{
        GSHAppConfig *config = [GSHAppConfig new];
        config.type = GSHAppConfigTypeTest;
        config.typeString = @"test";
        config.desc = @"测试环境";

        NSString *ipString = @"10.34.4.17";
        config.h5IpString = @"10.34.4.45:8089";//ipString;
        if (ipString.length > 0) {
            config.httpDomainString = ipString;
        }else{
            config.httpDomainString = @"120.77.143.38";
        }
        config.httpPort = [ipString containsString:@"io"]? @(80) : @(8777);
        config.httpHostString = config.httpDomainString;
        config.ossDomainString = @"10.34.4.45:9333";
        config.ossHostString = @"10.34.4.45:9333";
        
        config.tcpDomainString = @"";
        config.tcpHostPort = 0;
        
        config.udpDomainString = @"";
        config.udpHostPort = 0;
        shard = config;
    });
    return shard;
}

+(instancetype)ipConfig{
    static dispatch_once_t onceToken;
    static GSHAppConfig *shard;
    dispatch_once(&onceToken, ^{
        GSHAppConfig *config = [GSHAppConfig new];
        config.type = GSHAppConfigTypeIP;
        config.typeString = @"ip";
        config.desc = @"直连ip";

        NSString *ipString = [[NSUserDefaults standardUserDefaults] objectForKey:GSHHTTPAPICustomIp];
        config.h5IpString = @"10.244.100.28:8083";//ipString;
        if (ipString.length > 0) {
            config.httpDomainString = ipString;
        }else{
            config.httpDomainString = @"120.77.143.38";
        }
        config.httpPort = [ipString containsString:@"io"]? @(80) : @(8777);
        config.httpHostString = config.httpDomainString;
        config.ossDomainString = @"10.34.4.45:9333";
        config.ossHostString = @"10.34.4.45:9333";
        
        config.tcpDomainString = @"";
        config.tcpHostPort = 0;
        
        config.udpDomainString = @"";
        config.udpHostPort = 0;
        shard = config;
    });
    return shard;
}

+ (void)showChangeAlertViewWithVC:(UIViewController*)VC {
    NSDictionary *mobileProvision = [NSDictionary tzm_mobileProvisionDictionary];
    if ([[mobileProvision mutableArrayValueForKeyPath:@"ProvisionedDevices"] count] == 0) {
        return;
    }
    NSString *bundleVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    NSString *provisionName = [mobileProvision stringValueForKey:@"Name" default:nil];
    NSString *apsEnv = [mobileProvision stringValueForKey:@"Entitlements/aps-environment" default:nil];
    NSString *message = [NSString stringWithFormat:@"build: %@\nprovision name: %@\naps-environment: %@\nPush Token: %@\n",
                         bundleVersion, provisionName, apsEnv, [TZMPushManager shared].deviceToken];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"切换环境" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[self alertViewButtonTitleWithType:GSHAppConfigTypeProduction] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [GSHAppConfig change:GSHAppConfigTypeProduction httpHostString:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[self alertViewButtonTitleWithType:GSHAppConfigTypePrepare] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [GSHAppConfig change:GSHAppConfigTypePrepare httpHostString:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[self alertViewButtonTitleWithType:GSHAppConfigTypeTest] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [GSHAppConfig change:GSHAppConfigTypeTest httpHostString:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[self alertViewButtonTitleWithType:GSHAppConfigTypeIP] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [GSHAppConfig inputIpWithVC:VC];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [VC presentViewController:alertController animated:YES completion:NULL];
}

+ (void)inputIpWithVC:(UIViewController*)VC{
    UIAlertController *textAlertController = [UIAlertController alertControllerWithTitle:@"请输入IP" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak UIAlertController *weakTextAlertController = textAlertController;
    [textAlertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *ipString = weakTextAlertController.textFields.firstObject.text;
        [GSHAppConfig change:GSHAppConfigTypeIP httpHostString:ipString];
    }]];
    [textAlertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [textAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    [VC presentViewController:textAlertController animated:YES completion:NULL];
}

+ (NSString *)alertViewButtonTitleWithType:(GSHAppConfigType)type {
    GSHAppConfig *config = [self configWithType:type];
    if ( [self config].type == config.type ) {
        return [config.desc stringByAppendingString:@"[当前]"];
    } else {
        return config.desc;
    }
}

+ (void)change:(GSHAppConfigType)type httpHostString:(NSString*)httpHostString{
    [TZMProgressHUDManager showInView:[UIApplication sharedApplication].keyWindow];
    if (type == GSHAppConfigTypeIP && httpHostString.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"请输入ip" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 切换配置类型
        [NSUserDefaults resetStandardUserDefaults];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *keys = [userDefaults.dictionaryRepresentation.allKeys copy];
        for (NSString *key in keys){
            [userDefaults removeObjectForKey:key];
        }
        [userDefaults setObject:httpHostString forKey:GSHHTTPAPICustomIp];
        [userDefaults setInteger:type forKey:@"GSHAppConfigType"];
        [userDefaults synchronize];
        
        // 还原成应用刚安装上的初始状态
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *tmpPath = NSTemporaryDirectory();
        [self removePath:cachePath];
        [self removePath:documentsPath];
        [self removePath:tmpPath];
        
        [UIView animateWithDuration:0.6 delay:3 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.transform = CGAffineTransformScale(window.transform, 0.1, 0.1);
            window.alpha = 0;
        } completion:^(BOOL finished) {
            exit(0);
        }];
    });
}

+ (void)removePath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager new];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:@[NSURLNameKey,NSURLIsDirectoryKey] options:0 errorHandler:^BOOL(NSURL *url, NSError *error) {
        return YES;
    }];
    for (NSURL *fileURL in directoryEnumerator) {
        NSError *error = nil;
        NSString *name; [fileURL getResourceValue:&name forKey:NSURLNameKey error:nil];
        NSNumber *isDir; [fileURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
        [fileManager removeItemAtURL:fileURL error:&error];
        NSLog(@"删除%@ %@ %@",(isDir.boolValue?@"目录":@"文件"),(error?@"失败":@"成功"),fileURL);
    }
}

@end
