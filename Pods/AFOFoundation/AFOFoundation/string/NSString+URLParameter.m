//
//  NSString+URLParameter.m
//  AFOFoundation
//
//  Created by xianxueguang on 2019/9/30.
//  Copyright © 2019年 AFO Science Technology Ltd. All rights reserved.
//

#import "NSString+URLParameter.h"
#import "NSString+URLSchemes.h"
@implementation NSString (URLParameter)
+ (NSString *)addSchemes:(NSString *)url
                  params:(NSDictionary *)dictionary{
    NSString *baseString = [[NSString readSchemesFromInfoPlist] stringByAppendingString:@"://"];
    baseString = [baseString stringByAppendingString:[NSString readSchemesFromInfoPlist]];
    return [self addQueryStringToUrl:baseString params:dictionary];
}
+ (NSString*)addQueryStringToUrl:(NSString *)url
                          params:(NSDictionary *)params {
    __block NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:url];
    // 转换参数
    if (params) {
        [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *sKey = [key description];
            NSString *sVal = [[[params objectForKey:key] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // 需要添加 add ?k=v or &k=v ?
            if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
                [urlWithQuerystring appendFormat:@"?%@=%@", sKey, sVal];
            } else {
                [urlWithQuerystring appendFormat:@"&%@=%@", sKey, sVal];
            }
        }];
    }
    return urlWithQuerystring;
}
#pragma mark ------
+ (NSString *)settingRoutesParameters:(NSDictionary *)dictionary{
    NSString *strResult;
    NSString *strBase = [[NSString readSchemesFromInfoPlist] stringByAppendingString:@"://"];
    strBase = [strBase stringByAppendingString:dictionary[@"modelName"]];
    NSString *controller = dictionary[@"controller"];
    NSString *present = dictionary[@"present"];
    NSString *action = dictionary[@"action"];
    if (controller != nil && present != nil) {
        strResult = [[strBase stringByAppendingString:@"/"] stringByAppendingString:present];
        strResult = [[strResult stringByAppendingString:@"/"] stringByAppendingString:controller];
        strResult = [[strResult stringByAppendingString:@"/"] stringByAppendingString:action];
    }else{
        strResult = [strBase stringByAppendingString:controller];
        strResult = [[strResult stringByAppendingString:@"/"] stringByAppendingString:action];
    }
    if (dictionary.count > 0) {
        strResult = [NSString addQueryStringToUrl:strResult params:[NSString paramesDictionary:dictionary]];
    }
    return strResult;
}
+ (NSDictionary *)paramesDictionary:(NSDictionary *)dictionary{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    [dic removeObjectsForKeys:@[@"modelName",@"action",@"present"]];
    return dic;
}

@end
