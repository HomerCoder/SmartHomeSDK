//
//  GSHImagePickerManager.m
//  SmartHome
//
//  Created by gemdale on 2019/11/14.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHImagePickerManager.h"
#import "GSHAlertManager.h"
#import "TZImagePickerController.h"
#import "TZMImagePickerController.h"

@implementation GSHImagePickerManager
+ (void)showImagePickerManagerUrlMaxImagesCount:(NSInteger)maxImagesCount completion:(void (^)(NSArray<NSString*> *urlList))completion{
    
    [self showImagePickerManagerImageMaxImagesCount:maxImagesCount completion:^(NSArray<UIImage *> *imageList) {
        [TZMProgressHUDManager showWithStatus:@"上传中" inView:[UIApplication sharedApplication].keyWindow];
        NSMutableArray<NSString*> *urlList = [NSMutableArray array];
        __block NSError *err = nil;
        dispatch_group_t group = dispatch_group_create();
        for (UIImage *image in imageList) {
            dispatch_group_enter(group);
            [GSHUserManager postImage:image type:GSHUploadingImageTypeIdea progress:^(NSProgress *progress) {
            } block:^(NSString *picPath, NSError *error) {
                dispatch_group_leave(group);
                if (picPath) {
                    [urlList addObject:picPath];
                }
                if (error) {
                    err = error;
                }
            }];
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (err && urlList.count == 0) {
                [TZMProgressHUDManager showErrorWithStatus:err.localizedRecoverySuggestion inView:[UIApplication sharedApplication].keyWindow];
            }else{
                [TZMProgressHUDManager dismissInView:[UIApplication sharedApplication].keyWindow];
            }
            if (completion) {
                completion(urlList);
            }
        });
    }];
}
+ (void)showImagePickerManagerImageMaxImagesCount:(NSInteger)maxImagesCount completion:(void (^)(NSArray<UIImage*> *imageList))completion{
    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
        if (buttonIndex == 1 || buttonIndex == 2) {
            if (buttonIndex == 1) {
                // 拍照
                TZMImagePickerController *picker = [[TZMImagePickerController alloc] init];
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
                    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                    } textFieldsSetupHandler:NULL andTitle:@"没有相机权限" andMessage:@"请到系统设置里设置，设置->隐私->相机，打开应用权限" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"已经打开",@"取消",nil];
                    return;
                }
                picker.block = ^(NSDictionary<NSString *,id> *info) {
                    UIImage *image;
                    if (info) {
                        image = [info objectForKey:UIImagePickerControllerEditedImage];
                    }
                    if (completion) {
                        if (image) {
                            completion(@[image]);
                        }else{
                            completion(nil);
                        }
                    }
                };
                [[UIViewController visibleTopViewController] presentViewController:picker animated:YES completion:NULL];
            } else if (buttonIndex == 2) {
                // 从相册选择
                TZImagePickerController *picker = [[TZImagePickerController alloc]initWithMaxImagesCount:maxImagesCount delegate:nil];
                picker.didFinishPickingPhotosWithInfosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
                    if (completion) {
                        completion(photos);
                    }
                };
                [[UIViewController visibleTopViewController] presentViewController:picker animated:YES completion:NULL];
            }
        }else{
            if (completion) {
                completion(nil);
            }
        }
    } textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
    } andTitle:@"" andMessage:nil image:nil preferredStyle:GSHAlertManagerStyleActionSheet destructiveButtonTitle:@"" cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择",nil];
}


@end
