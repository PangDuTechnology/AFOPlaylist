//
//  AFORouterPushAction.m
//  AFORouter
//
//  Created by xianxueguang on 2019/10/1.
//  Copyright © 2019年 AFO. All rights reserved.
//

#import "AFORouterPushAction.h"
@interface AFORouterPushAction ()

@end

@implementation AFORouterPushAction
#pragma mark ------ 
- (void)currentController:(UIViewController *)current
           nextController:(NSString *)next
                parameter:(nonnull NSDictionary *)paramenter{
    Class class = NSClassFromString(next);
    UIViewController *controller = [[class alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [AFOSchedulerBaseClass schedulerController:current present:controller parameters:paramenter];
    UINavigationController *navController = current.navigationController;
    if (!navController && current.tabBarController) {
        navController = current.tabBarController.selectedViewController;
        if ([navController isKindOfClass:[UINavigationController class]]) {
            NSLog(@"AFORouterPushAction: Found navigationController from tabBarController. Nav controller: %p", navController);
        } else {
            navController = nil; // Not a navigation controller
        }
    }

    if (navController) {
        NSLog(@"AFORouterPushAction: Pushing view controller onto navigation stack. Current nav controller: %p", navController);
        [navController pushViewController:controller animated:YES];
    } else {
        NSLog(@"AFORouterPushAction: No navigationController found. Cannot push view controller.");
        // Optionally, handle this case, e.g., present modally or show an alert
        [AFOSchedulerBaseClass schedulerController:current present:controller parameters:paramenter];
    }
}
@end
