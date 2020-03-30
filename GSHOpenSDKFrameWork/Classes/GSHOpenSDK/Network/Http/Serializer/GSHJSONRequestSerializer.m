//
//

#import "GSHJSONRequestSerializer.h"
#import "GSHRSAHandler.h"
#import "GSHUserM.h"

@interface GSHJSONRequestSerializer ()
@end

@implementation GSHJSONRequestSerializer

- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                              URLString:(NSString *)URLString
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                                  error:(NSError *__autoreleasing *)error{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([URLString rangeOfString:@"general/checkVersion"].location == NSNotFound) {
        // 通用参数
        GSHUserM *user = [GSHUserManager currentUser];
        if (user) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:@"21" forKey:@"userId"];
            [dic setValue:@"iot_app_8031882743fa440498440ce65dc0cccc" forKey:@"sessionId"];
            [dict setValuesForKeysWithDictionary:dic];
        }
    }
    // 覆盖参数与公用参数中重名的参数
    if (parameters) [dict setValuesForKeysWithDictionary:parameters];
    //加入签名
    [dict setValue:[GSHJSONRequestSerializer signWithDic:dict] forKey:@"sign"];
    
    // 如果是 POST 也需要将上面的数据加入到 URL 中
    NSMutableURLRequest * urlRequest;
    urlRequest = [super multipartFormRequestWithMethod:method URLString:URLString parameters:dict constructingBodyWithBlock:block error:error];
    
    if ([@"GET" isEqualToString:[urlRequest.HTTPMethod uppercaseString]] ){
        NSLog(@"Request GET: %@", urlRequest.URL);
    }else if ([@"POST" isEqualToString:[urlRequest.HTTPMethod uppercaseString]]) {
        NSLog(@"Request POST: %@, %@", urlRequest.URL,dict);
    }else {
        NSLog(@"Request OTHER: %@, %@", urlRequest.URL,dict);
    }
    
    return urlRequest;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError *__autoreleasing *)error{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([URLString rangeOfString:@"general/checkVersion"].location == NSNotFound) {
        // 通用参数
        GSHUserM *user = [GSHUserManager currentUser];
        if (user) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:user.userId forKey:@"userId"];
            [dic setValue:user.sessionId forKey:@"sessionId"];
            [dict setValuesForKeysWithDictionary:dic];
        }
    }
    // 覆盖参数与公用参数中重名的参数
    if (parameters) [dict setValuesForKeysWithDictionary:parameters];
    //加入签名
    [dict setValue:[GSHJSONRequestSerializer signWithDic:dict] forKey:@"sign"];

    // 如果是 POST 也需要将上面的数据加入到 URL 中
    NSMutableURLRequest * urlRequest;
    urlRequest = [super requestWithMethod:method URLString:URLString parameters:dict error:error];
    
    if ([@"GET" isEqualToString:[urlRequest.HTTPMethod uppercaseString]] ){
        NSLog(@"Request GET: %@", urlRequest.URL);
    }else if ([@"POST" isEqualToString:[urlRequest.HTTPMethod uppercaseString]]) {
        NSLog(@"Request POST: %@, %@", urlRequest.URL,dict);
    }else {
        NSLog(@"Request OTHER: %@, %@", urlRequest.URL,dict);
    }
    
    return urlRequest;
}

+(void)userNewAccessKey:(BOOL)isNew{
    NSString *keyString;
    if (isNew) {
        keyString = @"MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCheEzQDVV1lR/4QBJW/zDFsLbssYx3An5FLrvqOOvSFlRmOOgS1y1o6we87tw1bn3FPAUx08J3nr/daurM7LLdWZwvDxsegSmv9ZDMcqCxfbIK2e3Vjsn3ey6v/SLlLHJgGC7AXL2yemviMhM5zp3fEKz9MrW3hfu4/tnnKae3HSlSAHrc3FUKoLjbyy0KQjh2nShmBzsGisIYoMfru6di0XzXSzGNtAc9GvgDWHlWTCtD/iGxKM/0QI4IEXor4KCNrNCNlIS7cnkBEfNv4gQ+O4pH35CJBRQb2jrapfcS/W9lC+ch9IOTfBixllixph3O+7zkqPa0hLsCcCu6kxlNAgMBAAECggEAXF9p8gvuu9mX9HkTBNnwmOfDfh0EcoDmo8Vck14E6qcDmYcsnLqkq8TpJFixeY/AO7leb2bpdW1H7e9ga+NtX9wH0ZQeu5DAvH0LXSqma2OxGywZN3b8a6v4xY1XDSwkMn0jIcDsdNI8LabgAM4G2rm7fQ4pjtgDbY2+MtRNsh79MOYf22smMG3MUg34cDgzMWvVoxP8PRzRd+E5fbhnw7z60hTQ75TSOjubL+ks7OJk8Wkn4hj3wpk6lREERH1yoACEATMjMLhnY+G4Q4AV876/gBrWgM0EFzkPozrelocICWmT29UKNlNxqrgpzRov1+6KO43Kk0gpHBFl6WTisQKBgQDtrtTlUoFi5/D/ZsoyrxjxV70GM1BV9ZPxBsLcd1UiunjxuAXlT+B3wHSTInfrMqKofoApdAxN38f4FpHBHM3yvnaX0qxrazZIUL1r8F/WOSHsdnGh7NMZzj9YZy2qD9GO6UI2ma6fINeyS6eFidRwbYbMaLneXdcwkyKLT47uPwKBgQCt6eMQdqR1yNsQcsafFxEcOpq2L0MRMh1BSsSJffJnE8LFhc3k8WTgv3+ZwjrmNUGMCB7G3OI16Iu5RSHsNHO57R/2PWJfztTPyDiWbf+ytIX/Yto8UQ/UvzCXleTUCStJK1duyBGhLnV6KFupW9l0cm3LygUtJLRkvfIyvUMtcwKBgGYguVnQGchl4SfdAwTEN/N7v7zqT5qf6vGl9hTFMc+6UD2M1PuzVsAd8flG1kA5garksC0fsCnF/iabjAVuWw/yxwJ1g6CkcK6iAsJehs+FvQ3d1vW8zPhJpu5VZ0mrgl/l2o2be2zkr8nsuA6pKp8kcMdkOHlT2SMGFdHGXaQBAoGAb2Ka8RJrppxr4Y8BMydc6A2IxSJj/AFyxzyRv9WQiQAZANT/15/bki5UFTBW9NYrEvqoa4lQwGIeCx0B6vx1GiGLFPSfqukXV7TOuVneKKCCKd0wFO1+DC4fexafpkXxGT3PE77Du827o+9xNXkEPxaCx8CtrAoUF2moU2LwQY0CgYEAoJJy6WIKF4cVFl/S5sXY3OGWxgBLg4Qe+sHSASsYOGP/tYjFfY1RGiVkj1Yrt0yzwKz5oMBpjGKSq39Ph1rnBe2vz7yQANd/Xog/MfKuchXrr9GB/KIzeUSKcmubalFCcNkWVypjGRjCbxamPBfVK5VFu4BktEV1AnYQyoA2y/A=";
    }else{
        keyString = @"MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCf97g0lvMHQkKe+4vIKBTeqITPHIiC/yG0Q8zhgBsgfRX2TxYanxdUJ7NjpjrPA3mAfzLO36C/tnZ5xd+X9K0djTip6abRmX+uFUGBOVepoNtN9vOddCM+/0WP/NtQihMJaJ+jKVAZtqa3FOIB8Iat9vcyVGCV8IQfbLto4CyIpoU8slxCfYVvGh5pRUeOTrFwQGaICWj3SKU/OhuLga8GCmP+Mzn557ZZQOd6PVbtE2jFAz8u+LuvSHsK8R39AGJwF+B69lxFB5CggkiimMH3Jmjyju4vkr7WeMoDj5IowlwABx+hfYGDaPtg4Fp1u8PtFoJJ6Uso1AYOJuRm4G5TAgMBAAECggEAJwWz3shP4p5sSAIO2DXG2YX8V9WbC3GXVDUR3pR0iZlZ6SrjtnzGoRXKMe3T/LnZQtpEl6h/uySUhCIb6CKctE/F2dUQh6LNPbcbsp09YDjIJp2uUeOJ0Y1N99Dz4xK7kBkAkDm8u3kN9C1Y8KYvBHLxXEqvAQSaBlxs3ymIU5D+tglD5KvN2GoZ1c86L4Wo3AjVwttk7NH7XX08Jgqvq9bPE3N/cvVa5lspkVtTkXDwAuz5xtnBVaDsX1cbQtqGD5uFZhCuz3/2I2cQkjiDtmzIL5AONIrzCK2BudlFtm95BO100ikSMuJxvqp77YsYfl2vMx2DXu6G2s9wG7+dGQKBgQD4MRPE69eRiqlqq4WJiMlhV0szu5xtxv3jp4DkFiGYb9TN1prx0JYSFlvf4PM8PBnKdSo39PMpxvqDKe3tZ34XFKr3y9h0yJLzESuQyeKWqCEM4BuhOIVqScFekOesL6FGkM+TWGrFUiPi09DHIIoat+u8S/4F5jJy9lKM086q3QKBgQClABcrloNTBasIlF7Qyvax5NMHqhdhD1rQdhIQB7BZm9qumjTwUp6eUzoXjjGznok3QR2yYGFitgDp5TdZvPPT9kcmb9UD158KK5tBFueeUKmQNHVKO7agaMZOK59GO2d0IQSRDCU5cmqi5tN8NaXh/5nIVT4ZGvPaVF62OXLy7wKBgQDONWB6hYTmvLGEGhxqKAdBZBjsU51lrCa35iz11Nl24LuLhhnYffih8IfHHAyb6Ed5ah14voDmHhd3sPeo/wrJPHfMSEaAyUEmyQZMVyB3EhvbqbvrGJ3osH0ECBskebJigeClSJn1dgiw5lIZkBSOnG81VGIrHpad48C0lyqn1QKBgGpCFanXYzkrFEsRKcJygs5rW0+7RRUXi1dmQhmaqgH7Mahx3JfLzSSO2oFi7DUNarZvs8007mJgbVQzbiLXYXrmRknFiTvRNzWYgYI4Wu8EaT5Z2hL1Q5YoA1VCGG9lQCl0PfmfBbXqLiw8VIPQFMTnE0UFSFlolxPKc7gMZS93AoGAXWz7x6T8/4nzLvERaTH18llGFsoAyFYaNbCBVT5EpD+V2oHZBKuNsAOJt1+deB0cHZB2qeSmeoDWLkogdwnhc7iaGX6ciyTcKlN8GlLRQk8mBhIQW/CMsHV9bK6Ra0ZtsR2lUw4JPqwyOOPr/mSJo355XoCa5XltToFm+BJ2+Hw=";
    }
    GSHRSAHandler* handler = [GSHRSAHandler new];
    BOOL status = [handler importKeyWithType:KeyTypePrivate andkeyString:keyString];
    if (status) {
        _handler = handler;
    }
}

static GSHRSAHandler *_handler = nil;
+ (NSString*)signWithDic:(NSDictionary*)dic{
    if (!_handler) {
        NSString *keyString = @"MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCf97g0lvMHQkKe+4vIKBTeqITPHIiC/yG0Q8zhgBsgfRX2TxYanxdUJ7NjpjrPA3mAfzLO36C/tnZ5xd+X9K0djTip6abRmX+uFUGBOVepoNtN9vOddCM+/0WP/NtQihMJaJ+jKVAZtqa3FOIB8Iat9vcyVGCV8IQfbLto4CyIpoU8slxCfYVvGh5pRUeOTrFwQGaICWj3SKU/OhuLga8GCmP+Mzn557ZZQOd6PVbtE2jFAz8u+LuvSHsK8R39AGJwF+B69lxFB5CggkiimMH3Jmjyju4vkr7WeMoDj5IowlwABx+hfYGDaPtg4Fp1u8PtFoJJ6Uso1AYOJuRm4G5TAgMBAAECggEAJwWz3shP4p5sSAIO2DXG2YX8V9WbC3GXVDUR3pR0iZlZ6SrjtnzGoRXKMe3T/LnZQtpEl6h/uySUhCIb6CKctE/F2dUQh6LNPbcbsp09YDjIJp2uUeOJ0Y1N99Dz4xK7kBkAkDm8u3kN9C1Y8KYvBHLxXEqvAQSaBlxs3ymIU5D+tglD5KvN2GoZ1c86L4Wo3AjVwttk7NH7XX08Jgqvq9bPE3N/cvVa5lspkVtTkXDwAuz5xtnBVaDsX1cbQtqGD5uFZhCuz3/2I2cQkjiDtmzIL5AONIrzCK2BudlFtm95BO100ikSMuJxvqp77YsYfl2vMx2DXu6G2s9wG7+dGQKBgQD4MRPE69eRiqlqq4WJiMlhV0szu5xtxv3jp4DkFiGYb9TN1prx0JYSFlvf4PM8PBnKdSo39PMpxvqDKe3tZ34XFKr3y9h0yJLzESuQyeKWqCEM4BuhOIVqScFekOesL6FGkM+TWGrFUiPi09DHIIoat+u8S/4F5jJy9lKM086q3QKBgQClABcrloNTBasIlF7Qyvax5NMHqhdhD1rQdhIQB7BZm9qumjTwUp6eUzoXjjGznok3QR2yYGFitgDp5TdZvPPT9kcmb9UD158KK5tBFueeUKmQNHVKO7agaMZOK59GO2d0IQSRDCU5cmqi5tN8NaXh/5nIVT4ZGvPaVF62OXLy7wKBgQDONWB6hYTmvLGEGhxqKAdBZBjsU51lrCa35iz11Nl24LuLhhnYffih8IfHHAyb6Ed5ah14voDmHhd3sPeo/wrJPHfMSEaAyUEmyQZMVyB3EhvbqbvrGJ3osH0ECBskebJigeClSJn1dgiw5lIZkBSOnG81VGIrHpad48C0lyqn1QKBgGpCFanXYzkrFEsRKcJygs5rW0+7RRUXi1dmQhmaqgH7Mahx3JfLzSSO2oFi7DUNarZvs8007mJgbVQzbiLXYXrmRknFiTvRNzWYgYI4Wu8EaT5Z2hL1Q5YoA1VCGG9lQCl0PfmfBbXqLiw8VIPQFMTnE0UFSFlolxPKc7gMZS93AoGAXWz7x6T8/4nzLvERaTH18llGFsoAyFYaNbCBVT5EpD+V2oHZBKuNsAOJt1+deB0cHZB2qeSmeoDWLkogdwnhc7iaGX6ciyTcKlN8GlLRQk8mBhIQW/CMsHV9bK6Ra0ZtsR2lUw4JPqwyOOPr/mSJo355XoCa5XltToFm+BJ2+Hw=";
        GSHRSAHandler* handler = [GSHRSAHandler new];
        BOOL status = [handler importKeyWithType:KeyTypePrivate andkeyString:keyString];
        if (status) {
            _handler = handler;
        }
    }
    NSString *paramsString = [self getCombinedParameterStringWithParameterDic:dic];
    paramsString = [paramsString stringByReplacingOccurrencesOfString:@" " withString:@""];
    paramsString = [paramsString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (paramsString.length == 0) {
        return nil;
    }
    NSString *sign = [_handler signMD5String:paramsString];
    return sign;
}

// 将传入的参数字典，按key的字母升序排序后拼接成字符串返回
+ (NSString *)getCombinedParameterStringWithParameterDic:(NSDictionary *)parameterDic {
    NSArray *keyArray = [parameterDic allKeys];
    NSArray *sortedArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *parameterString = [NSMutableString string];
    for (NSString *keyStr in sortedArray) {
        id value = [parameterDic valueForKey:keyStr];
        if ([value isKindOfClass:NSDictionary.class]) {
            value = [self getSubDicJsonStrWithDic:value];
        } else if ([value isKindOfClass:NSArray.class]) {
            value = [self getSubDicJsonStrWithArray:value];
        }
        NSString *parameterItemStr = [NSString stringWithFormat:@"%@=%@&",keyStr,value];
        [parameterString appendString:parameterItemStr];
    }
    return parameterString.length > 0 ? [parameterString substringToIndex:parameterString.length - 1] : nil;
}


+ (NSString *)getSubDicJsonStrWithDic:(NSDictionary *)dic {
    NSArray *keyArray = [dic allKeys];
    NSArray *sortedArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *parameterString = [NSMutableString stringWithString:@"{"];
    for (NSString *keyStr in sortedArray) {
        id value = [dic valueForKey:keyStr];
        if ([value isKindOfClass:NSDictionary.class]) {
            value = [self getSubDicJsonStrWithDic:value];
        } else if ([value isKindOfClass:NSArray.class]) {
            value = [self getSubDicJsonStrWithArray:value];
        }
        NSString *parameterItemStr = [NSString stringWithFormat:@"%@=%@,",keyStr,value];
        [parameterString appendString:parameterItemStr];
    }
    if (dic.allKeys.count > 0) {
        [parameterString deleteCharactersInRange:NSMakeRange(parameterString.length - 1, 1)];
    }
    [parameterString appendString:@"}"];
    return parameterString;
}

+ (NSString *)getSubDicJsonStrWithArray:(NSArray *)array {
    NSMutableString *parameterString = [NSMutableString stringWithString:@"["];
    NSString *str = nil;
    for (id value in array) {
        str = [NSString stringWithFormat:@"%@",value];
        if ([value isKindOfClass:NSDictionary.class]) {
            str = [self getSubDicJsonStrWithDic:(NSDictionary *)value];
        } else if ([value isKindOfClass:NSArray.class]) {
            str = [self getSubDicJsonStrWithArray:(NSArray *)value];
        }
        str = [NSString stringWithFormat:@"%@,",str];
        [parameterString appendString:str];
    }
    if (array.count > 0) {
        [parameterString deleteCharactersInRange:NSMakeRange(parameterString.length - 1, 1)];
    }
    [parameterString appendString:@"]"];
    return parameterString;
}



@end
