//
//

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"

@interface GSHJSONRequestSerializer : AFJSONRequestSerializer
+(void)userNewAccessKey:(BOOL)isNew;
@end
