//
//  UIImage+ZHSDK.m
//  GSHOpenSDKFrame
//
//  Created by zhanghong on 2020/3/22.
//  Copyright © 2020 zhanghong. All rights reserved.
//

#import "UIImage+ZHSDK.h"

@implementation UIImage (ZHSDK)

+ (nullable UIImage *)ZHImageNamed:(NSString *)imageName {
     return [self imageNamed:imageName inBundle:MYBUNDLE compatibleWithTraitCollection:nil];
}

@end
