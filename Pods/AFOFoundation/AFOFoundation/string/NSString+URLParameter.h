//
//  NSString+URLParameter.h
//  AFOFoundation
//
//  Created by xianxueguang on 2019/9/30.
//  Copyright © 2019年 AFO Science Technology Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (URLParameter)
+ (NSString *)addSchemes:(NSString *)url
                  params:(NSDictionary *)dictionary;
+ (NSString*)addQueryStringToUrl:(NSString *)url
                          params:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
