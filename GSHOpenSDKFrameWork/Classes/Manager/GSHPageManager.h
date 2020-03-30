//
//  GSHPagemanager.h
//  GSHOpenSDKFrame
//
//  Created by zhanghong on 2020/3/20.
//  Copyright © 2020 zhanghong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSHPageManager : NSObject

+ (id)viewControllerWithSB:(NSString *)storyboardName andID:(NSString *)vcID;

+ (id)viewControllerWithClass:(Class)clazz nibName:(NSString *)nibName;

@end

NS_ASSUME_NONNULL_END
