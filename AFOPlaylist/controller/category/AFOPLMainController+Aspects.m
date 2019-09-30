//
//  AFOPLMainController+Aspects.m
//  AFOPlaylist
//
//  Created by xueguang xian on 2018/1/25.
//  Copyright © 2018年 AFO. All rights reserved.
//

#import "AFOPLMainController+Aspects.h"
#import <AFOGitHub/AFOGitHub.h>
#import <AFOFoundation/AFOFoundation.h>
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
        NSString *base = @"url://";[NSString addSchemes:nil params:dictionary];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:base]];
    } error:NULL];
}
- (void)dealloc{
    NSLog(@"AFOPLMainController+Aspects dealloc");
}
@end
