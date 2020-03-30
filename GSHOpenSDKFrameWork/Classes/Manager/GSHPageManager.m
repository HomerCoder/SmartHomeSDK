//
//  GSHPagemanager.m
//  GSHOpenSDKFrame
//
//  Created by zhanghong on 2020/3/20.
//  Copyright © 2020 zhanghong. All rights reserved.
//

#import "GSHPageManager.h"

@implementation GSHPageManager

+ (NSCache *)storyboardCache
{
    static NSCache *cache;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSCache new];
    });

    return cache;
}

+ (id)viewControllerWithSB:(NSString *)storyboardName andID:(NSString *)vcID {
    @try {
        NSBundle *bundle = [NSBundle bundleForClass:[storyboardName class]];
        if (bundle) {
            bundle = MYBUNDLE;
            //[NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resource.bundle"]];
            if (bundle) {
                NSLog(@"bundle:%@",bundle);
            } else {
                NSLog(@"没找到bundle 2");
            }
        } else {
            NSLog(@"没找到bundle 1");
        }
        UIStoryboard *storyboard = [[self storyboardCache] objectForKey:storyboardName];
        if (!storyboard) {
            storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:bundle];
            if (storyboard) {
                [[self storyboardCache] setObject:storyboard forKey:storyboardName];
            }
        }

        if (storyboard) {
            id vc = [storyboard instantiateViewControllerWithIdentifier:vcID];
            if (vc) {
                return vc;
            }
        }
        return nil;
    } @catch (NSException *exception) {
        NSLog(@"ERROR: %@",exception);
        return nil;
    }
}

+ (id)viewControllerWithClass:(Class)clazz nibName:(NSString *)nibName {
    return [(UIViewController *) [clazz alloc] initWithNibName:nibName bundle:MYBUNDLE];
}

@end
