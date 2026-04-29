//
//  AFOPLMainController.m
//  AFOPlaylist
//
//  Created by xueguang xian on 2017/12/14.
//  Copyright © 2017年 AFO. All rights reserved.
//

#import "AFOPLMainController.h"
#import <AFOFoundation/AFOFoundation.h>
#import <AFOWaterfall/AFOWaterfallFlowLayout.h>
#import "AFOPLMainControllerCategory.h"
#import "AFOPLMainListViewModel.h"
#import "AFOPLMainManager.h"
#import "AFOPLMainCollectionDataSource.h"
#import "AFOPLMainCollectionCell.h"
#import <AFOLANUpload/AFOLANUpload.h>
#import "AFOPlayListNavigationController.h"
#import <TargetConditionals.h>
#if TARGET_OS_SIMULATOR
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#endif
@interface AFOPLMainController ()<UICollectionViewDelegate, AFOWaterfallLayoutDelegate>
@property (nonnull, nonatomic, strong) AFOWaterfallFlowLayout    *defaultLayout;
@property (nonnull, nonatomic, strong) AFOPLMainCollectionDataSource *collectionDataSource;
@property (nonnull, nonatomic, strong, readwrite) UICollectionView             *collectionView;
@property (nonatomic, strong, nullable) AFOPLMainListViewModel *playlistListViewModel;
@property (nonatomic, strong) AFOLANUploadServer *lanUploadServer;
@property (nonatomic, strong) UIBarButtonItem *lanUploadBarButtonItem;
@property (nonatomic, strong, nullable) UIBarButtonItem *thumbnailActivityBarButtonItem;
@property (nonatomic, assign) BOOL isRefreshingThumbnails;
@property (nonatomic, strong) UIRefreshControl *playlistRefreshControl;
@end
@implementation AFOPLMainController
#if TARGET_OS_SIMULATOR
- (void)playVideoInSimulatorAtIndexPath:(NSIndexPath *)indexPath {
    NSString *videoPath = [self vedioPath:indexPath];
    NSLog(@"AFOPLMainController(sim): try play indexPath=%@ path=%@", indexPath, videoPath);
    if (videoPath.length == 0) {
        NSLog(@"AFOPLMainController(sim): empty video path");
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        NSLog(@"AFOPLMainController(sim): file not found at path=%@", videoPath);
        return;
    }
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (videoTrack) {
        CGSize naturalSize = videoTrack.naturalSize;
        CGFloat bitrate = videoTrack.estimatedDataRate;
        NSLog(@"AFOPLMainController(sim): asset size=%.0fx%.0f bitrate=%.0f", naturalSize.width, naturalSize.height, bitrate);
    }

    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = [AVPlayer playerWithURL:videoURL];
    playerVC.videoGravity = AVLayerVideoGravityResizeAspect;
    playerVC.title = [self vedioName:indexPath];
    [self.navigationController pushViewController:playerVC animated:YES];
    [playerVC.player play];
}
#endif
#pragma mark - Lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#if DEBUG
    NSLog(@"AFOPLMainController: viewWillAppear called. Showing TabBar.");
#endif
    // 主页面应展示底部 TabBar，避免首页进入后整栏消失。
    self.tabBarController.tabBar.hidden = NO;

    if (self.navigationController) {
#if DEBUG
        NSLog(@"AFOPLMainController: navigationController exists.");
#endif
        // 确保导航栏是可见的，如果其父控制器或相关配置导致隐藏，此处可强制显示
        self.navigationController.navigationBar.hidden = NO;
        self.navigationController.navigationBar.alpha = 1.0;
        self.navigationController.navigationBar.translucent = NO;
        // 标题设置应保持在 viewDidLoad 或初始化时
        // self.navigationItem.title = @"播放列表";
        // 移除诊断性背景色设置
        // self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    } else {
#if DEBUG
        NSLog(@"AFOPLMainController: navigationController is NIL. This might be the problem.");
#endif
    }
}

#pragma mark - Initialization
- (void)viewDidLoad {
    [super viewDidLoad];
    // self.view.backgroundColor = [UIColor redColor]; // 移除诊断用的背景色
    self.title = @"播放列表";
    [self setupLANUploadButton];
    // self.automaticallyAdjustsScrollViewInsets = NO; // 移除或注释掉此行，让系统自动调整布局
    [self.view addSubview:self.collectionView];
}
#pragma mark - Layout
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.isInitialized) {
        [self initializerInstance];
        [self.editorLogic setupEditButton];
        self.isInitialized = YES;
        // 初次布局时强制刷新，避免视图问题
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView layoutIfNeeded];
    }
}
#pragma mark - Private Methods

- (void)configureCollectionViewData {
    [self addCollectionViewData];
}

- (void)initializerInstance {
    [self configureCollectionViewData];
    if (self.mainManager) {
        self.playlistListViewModel = [[AFOPLMainListViewModel alloc] initWithMainManager:self.mainManager];
    }
    [self addPullToRefresh]; 
    __weak typeof(self) weakSelf = self;
    self.editorLogic.updateCollectionBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf configureCollectionViewData];
    };
}
#pragma mark ------ 下拉刷新（UIRefreshControl）
- (void)addPullToRefresh {
    self.playlistRefreshControl = [[UIRefreshControl alloc] init];
    [self.playlistRefreshControl addTarget:self action:@selector(afo_handlePlaylistPullRefresh) forControlEvents:UIControlEventValueChanged];
    self.collectionView.refreshControl = self.playlistRefreshControl;
}

- (void)afo_handlePlaylistPullRefresh {
    __weak typeof(self) weakSelf = self;
    [self setThumbnailRefreshing:YES];
    [self reloadCollectionDataWithCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setThumbnailRefreshing:NO];
        [strongSelf.playlistRefreshControl endRefreshing];
    }];
}
#pragma mark - Data Handling

- (void)addCollectionViewData {
    [self reloadCollectionDataWithCompletion:nil];
}

- (void)reloadCollectionDataWithCompletion:(void (^ _Nullable)(void))completion {
    if (!self.mainManager) {
        self.mainManager = [AFOPLMainManager mainManagerDelegate:self];
    }
    __weak typeof(self) weakSelf = self;
    [self.mainManager refreshDirectoryListingWithCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            if (completion) {
                completion();
            }
            return;
        }
        [strongSelf addCollectionViewData:^(NSArray *array) {
            __strong typeof(weakSelf) strongSelf2 = weakSelf;
            if (!strongSelf2) {
                if (completion) {
                    completion();
                }
                return;
            }
            [strongSelf2.collectionDataSource settingImageData:array];
            [strongSelf2.playlistListViewModel syncListStateAfterReload];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView performWithoutAnimation:^{
                    [strongSelf2.collectionView.collectionViewLayout invalidateLayout];
                    [strongSelf2.collectionView reloadData];
                    [strongSelf2.collectionView layoutIfNeeded];
                    if (completion) {
                        completion();
                    } else if (strongSelf2.isRefreshingThumbnails) {
                        [strongSelf2 setThumbnailRefreshing:NO];
                    }
                }];
            });
        }];
    }];
}
#pragma mark - UICollectionViewDelegate (AFOWaterfallLayoutDelegate)

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)layout
   heightForItemAtIndexPath:(NSIndexPath *)indexPath
                itemWidth:(CGFloat)itemWidth {
    return [self vedioItemHeight:indexPath width:itemWidth];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
#if DEBUG
    NSLog(@"AFOPLMainController: didSelectItemAtIndexPath: %@", indexPath);
#endif
#if TARGET_OS_SIMULATOR
    [self playVideoInSimulatorAtIndexPath:indexPath];
    return;
#endif
    if (!self.playlistListViewModel && self.mainManager) {
        self.playlistListViewModel = [[AFOPLMainListViewModel alloc] initWithMainManager:self.mainManager];
    }
    [self.playlistListViewModel openPlayerAtIndexPath:indexPath currentControllerClassName:NSStringFromClass([self class])];
}
#pragma mark - Accessors
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:self.defaultLayout];
        _collectionView.pagingEnabled = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self.collectionDataSource;
        _collectionView.alwaysBounceVertical=YES;
        [_collectionView registerClass:[AFOPLMainCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([AFOPLMainCollectionCell class])];
        NSLog(@"AFOPLMainController: CollectionView created. Delegate: %p, DataSource: %p, UserInteractionEnabled: %d, Frame: %@", _collectionView.delegate, _collectionView.dataSource, _collectionView.userInteractionEnabled, NSStringFromCGRect(_collectionView.frame));
    }
    return _collectionView;
}
- (AFOPLMainCollectionDataSource *)collectionDataSource{
    if (!_collectionDataSource) {
        _collectionDataSource = [[AFOPLMainCollectionDataSource alloc] init];
    }
    return _collectionDataSource;
}
- (AFOWaterfallFlowLayout *)defaultLayout{
    if (!_defaultLayout) {
        _defaultLayout = [[AFOWaterfallFlowLayout alloc] init];
        _defaultLayout.defaultColumnCount = 2;
        _defaultLayout.defaultColumnSpacing = 0;
        _defaultLayout.defaultLineSpacing = 0;
        _defaultLayout.defaultSectionInset = UIEdgeInsetsZero;
    }
    return _defaultLayout;
}
#pragma mark - Orientation
- (BOOL)shouldAutorotate{
    return YES;
}
#pragma mark ------ 支持的方向
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Deallocation
- (void)dealloc{
    [self.lanUploadServer stop];
#if DEBUG
    NSLog(@"AFOPLMainController dealloc");
#endif
}


#pragma mark ------ viewDidAppear
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#if DEBUG
    NSLog(@"AFOPLMainController: viewDidAppear called.");
#endif
    if (self.navigationController) {
#if DEBUG
        NSLog(@"AFOPLMainController: viewDidAppear - navigationController exists.");
#endif
#if DEBUG
        NSLog(@"AFOPLMainController: viewDidAppear - navigationBar hidden: %d", self.navigationController.navigationBar.hidden);
        NSLog(@"AFOPLMainController: viewDidAppear - navigationBar alpha: %f", self.navigationController.navigationBar.alpha);
        NSLog(@"AFOPLMainController: viewDidAppear - navigationBar frame: %@", NSStringFromCGRect(self.navigationController.navigationBar.frame));
#endif
        self.navigationController.navigationBar.hidden = NO; // 确保导航栏没有被隐藏
        self.navigationController.navigationBar.alpha = 1.0; // 确保导航栏完全可见
    } else {
#if DEBUG
        NSLog(@"AFOPLMainController: viewDidAppear - navigationController is NIL.");
#endif
    }
}

#pragma mark ------ viewDidDisappear
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
#if DEBUG
    NSLog(@"AFOPLMainController: viewDidDisappear called. Showing TabBar.");
#endif
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - LAN Upload

- (void)setupLANUploadButton {
    self.lanUploadBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"局域网上传"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(toggleLANUpload:)];
    self.navigationItem.leftBarButtonItem = self.lanUploadBarButtonItem;
}

- (void)toggleLANUpload:(id)sender {
    if (!self.lanUploadServer) {
        // 部分局域网会拦截 8080，优先改用不常被拦的端口；若仍失败则回退到随机端口。
        self.lanUploadServer = [[AFOLANUploadServer alloc] initWithPort:18080];
        // 播放列表当前只扫描 Documents 根目录，上传到子目录会被忽略。
        self.lanUploadServer.uploadDirectoryPath = [NSFileManager documentSandbox];
    }
    __weak typeof(self) weakSelf = self;
    self.lanUploadServer.logHandler = ^(NSString *message) {
#if DEBUG
        NSLog(@"%@", message);
#endif
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if ([message hasPrefix:@"AFOLANUpload saved:"]) {
            [strongSelf setThumbnailRefreshing:YES];
            [strongSelf addCollectionViewData];
        }
        [strongSelf updateLANUploadButtonTitle];
    };

    if (self.lanUploadServer.isRunning) {
        [self.lanUploadServer stop];
        [self updateLANUploadButtonTitle];
        [self showLANUploadMessage:@"局域网上传已停止。"];
        return;
    }

    NSError *error = nil;
    BOOL started = [self.lanUploadServer start:&error];
    if (!started && [error.domain isEqualToString:NSPOSIXErrorDomain]) {
        // 端口占用/权限等导致启动失败时，回退到随机端口重试一次。
        if (error.code == EADDRINUSE || error.code == EACCES) {
            self.lanUploadServer = [[AFOLANUploadServer alloc] initWithPort:0];
            self.lanUploadServer.uploadDirectoryPath = [NSFileManager documentSandbox];
            self.lanUploadServer.logHandler = ^(NSString *message) {
#if DEBUG
                NSLog(@"%@", message);
#endif
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                if ([message hasPrefix:@"AFOLANUpload saved:"]) {
                    [strongSelf setThumbnailRefreshing:YES];
                    [strongSelf addCollectionViewData];
                }
                [strongSelf updateLANUploadButtonTitle];
            };
            error = nil;
            started = [self.lanUploadServer start:&error];
        }
    }
    if (!started) {
        NSString *message = [NSString stringWithFormat:@"启动失败：%@", error.localizedDescription ?: @"未知错误"];
        [self showLANUploadMessage:message];
        return;
    }

    [self updateLANUploadButtonTitle];
    NSString *tip = [NSString stringWithFormat:@"已启动。\n请在同一局域网浏览器打开：\n%@", self.lanUploadServer.serverURLString ?: @""];
    [self showLANUploadMessage:tip];
}

- (void)updateLANUploadButtonTitle {
    self.lanUploadBarButtonItem.title = self.lanUploadServer.isRunning ? @"停止上传" : @"局域网上传";
}

- (void)showLANUploadMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"局域网上传"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setThumbnailRefreshing:(BOOL)refreshing {
    self.isRefreshingThumbnails = refreshing;
    // 勿用 navigationItem.prompt：iOS 上会生成 _UINavigationBarModernPromptView，易在宽度为 0 时触发约束冲突。
    if (refreshing) {
        UIActivityIndicatorView *indicator =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.hidesWhenStopped = NO;
        [indicator startAnimating];
        self.thumbnailActivityBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
        NSMutableArray<UIBarButtonItem *> *leftItems = [NSMutableArray array];
        [leftItems addObject:self.thumbnailActivityBarButtonItem];
        if (self.lanUploadBarButtonItem) {
            [leftItems addObject:self.lanUploadBarButtonItem];
        }
        self.navigationItem.leftBarButtonItems = leftItems;
    } else {
        self.thumbnailActivityBarButtonItem = nil;
        if (self.lanUploadBarButtonItem) {
            self.navigationItem.leftBarButtonItems = @[self.lanUploadBarButtonItem];
        } else {
            self.navigationItem.leftBarButtonItems = nil;
        }
    }
}

#pragma mark - AFOTabRootControllerProviding
- (UIViewController *)returnController {
    AFOPlayListNavigationController *navController = [[AFOPlayListNavigationController alloc] initWithRootViewController:self];
    navController.tabBarItem.title = @"播放列表";
    if (@available(iOS 13.0, *)) {
        navController.tabBarItem.image = [UIImage systemImageNamed:@"list.bullet.rectangle"];
        navController.tabBarItem.selectedImage = [UIImage systemImageNamed:@"list.bullet.rectangle.fill"];
    }
#if DEBUG
    NSLog(@"AFOPLMainController: returnController called. Returning UINavigationController: %p with root: %p", navController, self);
#endif
    return navController;
}

@end
