

#import "PopoverAction.h"

@interface PopoverAction ()

@property (nonatomic, strong, readwrite) UIImage *image; ///< 图标
@property (nonatomic, copy, readwrite) NSString *title; ///< 标题
@property (nonatomic, copy, readwrite) void(^handler)(PopoverAction *action); ///< 选择回调
@property (nonatomic, copy, readwrite) NSString *imageUrl;

@end

@implementation PopoverAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(PopoverAction *action))handler {
    return [self actionWithImage:nil title:title handler:handler];
}

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)(PopoverAction *action))handler {
    PopoverAction *action = [[self alloc] init];
    action.image = image;
    action.title = title ? : @"";
    action.handler = handler ? : NULL;
    
    return action;
}

+ (instancetype)actionWithImageUrl:(NSString *)imageUrl title:(NSString *)title handler:(void (^)(PopoverAction *action))handler{
    PopoverAction *action = [[self alloc] init];
    action.imageUrl = imageUrl;
    action.title = title ? : @"";
    action.handler = handler ? : NULL;
    
    return action;
}

@end
