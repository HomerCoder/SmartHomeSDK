//
//  GSHImagePickerManager.h
//  SmartHome
//
//  Created by gemdale on 2019/11/14.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSHImagePickerManager : NSObject
+ (void)showImagePickerManagerUrlMaxImagesCount:(NSInteger)maxImagesCount completion:(void (^)(NSArray<NSString*> *urlList))completion;
+ (void)showImagePickerManagerImageMaxImagesCount:(NSInteger)maxImagesCount completion:(void (^)(NSArray<UIImage*> *imageList))completion;
@end
