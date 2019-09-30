//
//  AFOPLMainController+Aspects.m
//  AFOPlaylist
//
//  Created by xueguang xian on 2018/1/25.
//  Copyright © 2018年 AFO. All rights reserved.
//

#import "AFOPLMainController+Aspects.h"
#import <AFOGitHub/AFOGitHub.h>
#import <AFORouter/AFORouter.h>
#import "AFOPLMainControllerCategory.h"
@implementation AFOPLMainController (Aspects)
#pragma mark ------ collectionView:didSelectItemAtIndexPath:
- (void)collectionViewDidSelectRowAtIndexPathExchange{
    [self aspect_hookSelector:@selector(collectionView:didSelectItemAtIndexPath:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, UITableView *tableView, NSIndexPath *indexPath){
        NSString *path = [self vedioPath:indexPath];
        NSString *name = [self vedioName:indexPath];
        NSInteger screen = [self screenPortrait:indexPath];
        
        NSString *baseStr = [[AFORouterManager shareInstance] settingPushControllerRouter:@"AFOMediaPlayController" present:NSStringFromClass([self class]) params:@{@"value": path,
                                                                                                                                                                     @"title" : name,
                                                                                                                                                                     @"direction":@(screen)
                                                                                                                                                                     }];
//        NSString *newString =[[AFORouterManager shareInstance] settingRoutesParameters:];
        NSDictionary *dictionary = @{
                                     @"modelName" :   JLRouteFunctionPlaylist,                                        @"controller" : @"AFOMediaPlayController",
                                     @"present" : NSStringFromClass([self class]),
                                     @"action" :@"push",
                                     @"value" : path,
                                     @"title" : name,
                                     @"direction" : @(screen)
                                     };
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self convertToJsonData:dictionary]]];
    } error:NULL];
}
- (NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    //    NSRange range = {0,jsonString.length};
    //    //去掉字符串中的空格
    //    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}
- (void)dealloc{
    NSLog(@"AFOPLMainController+Aspects dealloc");
}
@end
