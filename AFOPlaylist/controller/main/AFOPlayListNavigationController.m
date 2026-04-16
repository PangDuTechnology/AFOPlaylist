//
//  AFOPlayListNavigationController.m
//  AFOPlaylist
//
//  Created by xueguang xian on 2017/12/13.
//  Copyright © 2017年 AFO. All rights reserved.
//

#import "AFOPlayListNavigationController.h"
@interface AFOPlayListNavigationController () <UINavigationControllerDelegate>
@end
@implementation AFOPlayListNavigationController
#pragma mark ------------------ viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarItem.title = @"播放列表";
    self.delegate = self;

    // 统一标题外观，避免 standard/scrollEdge 切换导致标题“消失”
    self.navigationBar.hidden = NO;
    self.navigationBar.alpha = 1.0;
    self.navigationBar.translucent = NO;
    if (@available(iOS 11.0, *)) {
        self.navigationBar.prefersLargeTitles = NO;
    }

    UIColor *titleColor = [UIColor blackColor];
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:0.90 green:0.95 blue:1.00 alpha:1.0];
        appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : titleColor };
        appearance.largeTitleTextAttributes = @{ NSForegroundColorAttributeName : titleColor };
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationBar.compactAppearance = appearance;
    } else {
        self.navigationBar.barTintColor = [UIColor colorWithRed:0.90 green:0.95 blue:1.00 alpha:1.0];
        self.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : titleColor };
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if (!viewController) {
        return;
    }
    if (@available(iOS 11.0, *)) {
        viewController.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    // 根页面（播放列表）返回时必须恢复标题，避免残留为上一个播放页标题
    BOOL isRoot = (viewController == self.viewControllers.firstObject);
    BOOL isPlaylistRoot = isRoot || [NSStringFromClass([viewController class]) isEqualToString:@"AFOPLMainController"];

    NSString *t = nil;
    if (isPlaylistRoot) {
        t = @"播放列表";
    } else {
        // 如果页面有 title（如播放页视频名），确保赋到 navigationItem 上
        t = viewController.navigationItem.title.length > 0 ? viewController.navigationItem.title : viewController.title;
    }

    if (t.length > 0) {
        viewController.title = t;
        viewController.navigationItem.title = t;
        viewController.navigationItem.titleView = nil;
        // 关键兜底：直接写到 navBar.topItem，避免某些情况下 title 没被渲染
        self.navigationBar.topItem.title = t;
    }

    // 再兜底一次标题样式（可能被其他模块在运行时覆盖）
    NSDictionary *attrs = @{
        NSForegroundColorAttributeName : [UIColor blackColor],
        NSFontAttributeName : [UIFont boldSystemFontOfSize:17.0]
    };
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = self.navigationBar.standardAppearance ?: [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:0.90 green:0.95 blue:1.00 alpha:1.0];
        appearance.titleTextAttributes = attrs;
        appearance.largeTitleTextAttributes = attrs;
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationBar.compactAppearance = appearance;
    } else {
        self.navigationBar.titleTextAttributes = attrs;
    }
}
#pragma mark ------
-(BOOL)shouldAutorotate{
    return self.topViewController.shouldAutorotate;
}
#pragma mark ------ 支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
