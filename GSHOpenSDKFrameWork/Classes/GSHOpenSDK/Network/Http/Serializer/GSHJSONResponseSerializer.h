
#import <Foundation/Foundation.h>
#import "AFURLResponseSerialization.h"

@interface GSHJSONResponseSerializer : AFJSONResponseSerializer
@property(nonatomic,copy)void(^responseBlock)(NSError *error);
@end
