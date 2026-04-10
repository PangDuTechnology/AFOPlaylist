//
//  AFOPLMainListViewModel.h
//  AFOPlaylist
//

#import <Foundation/Foundation.h>
#import "AFOPLPlaylistRoutingDataSource.h"

@class AFOPLMainManager;

NS_ASSUME_NONNULL_BEGIN

@interface AFOPLMainListViewModel : NSObject

@property (nonatomic, strong, readonly) id<AFOPLPlaylistRoutingDataSource> routingDataSource;

/// 默认调用 `AFORoutingPerformWithParameters`；单元测试可赋值以捕获参数、避免真实跳转。
@property (nonatomic, copy, nullable) void (^routePerformBlock)(NSDictionary *parameters);

- (instancetype)initWithRoutingDataSource:(id<AFOPLPlaylistRoutingDataSource>)dataSource;

/// 等价于 `initWithRoutingDataSource:`。
- (instancetype)initWithMainManager:(nullable AFOPLMainManager *)mainManager;

- (void)openPlayerAtIndexPath:(NSIndexPath *)indexPath currentControllerClassName:(NSString *)currentClassName;

@end

NS_ASSUME_NONNULL_END
