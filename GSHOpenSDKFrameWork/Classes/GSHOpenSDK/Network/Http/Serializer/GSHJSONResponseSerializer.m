//

#import "GSHJSONResponseSerializer.h"
#import "GSHHTTPAPIClient.h"

@implementation GSHJSONResponseSerializer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.acceptableContentTypes = nil;
        self.removesKeysWithNullValues = YES;
    }
    return self;
}
- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError * __autoreleasing *)error {
    id responseObject = [super responseObjectForResponse:response data:data error:error];
    
    if(responseObject){
        //判断服务器状态码
        id stateCode = [responseObject valueForKey:@"code"];
        if( stateCode != nil && [stateCode respondsToSelector:@selector(intValue)] ) {
            int code = [stateCode intValue];
            // 如果不是成功请求状态则认为有错误发生
            if ( code != 200 ) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                NSString *errorMsg = [responseObject valueForKey:@"msg"];
                [userInfo setValue:errorMsg forKey:NSLocalizedDescriptionKey];
                if (error != NULL){
                    *error = [[NSError alloc] initWithDomain:GSHHTTPAPIErrorDomain code:code userInfo:userInfo];
                }
            }
        }
    }

    if (error && *error) {
        NSLog(@"Response: %@\nError: %@", response.URL, *error);
        
    } else {
#ifdef DEBUG
        NSString *unicodeStr = [NSString stringWithFormat:@"%@",responseObject];
        NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
        NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
        NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
        NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
        NSLog(@"Response: %@\nResult: %@", response.URL, returnStr);
#endif
    }
    if ((*error).code == -1003) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        NSString *errorMsg = @"与服务器失联，请稍后再试";
        [userInfo setValue:errorMsg forKey:NSLocalizedDescriptionKey];
        *error = [[NSError alloc] initWithDomain:(*error).domain code:-1003 userInfo:userInfo];
    }
    if (self.responseBlock) {
        self.responseBlock(*error);
    }
    return [(NSDictionary *)responseObject objectForKey:@"data"];
}
@end
