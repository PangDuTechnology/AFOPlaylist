//
//  AFOPLMainListViewModel.m
//  AFOPlaylist
//

#import "AFOPLMainListViewModel.h"
#import "AFOPLMainManager.h"
#import <AFORouter/AFORouting.h>

@implementation AFOPLMainListViewModel

- (instancetype)initWithRoutingDataSource:(id<AFOPLPlaylistRoutingDataSource>)dataSource {
    if (self = [super init]) {
        _routingDataSource = dataSource;
    }
    return self;
}

- (instancetype)initWithMainManager:(AFOPLMainManager *)mainManager {
    return [self initWithRoutingDataSource:(id<AFOPLPlaylistRoutingDataSource>)mainManager];
}

- (void)openPlayerAtIndexPath:(NSIndexPath *)indexPath currentControllerClassName:(NSString *)currentClassName {
    if (!self.routingDataSource || !indexPath || currentClassName.length == 0) {
        return;
    }
    NSString *path = [self.routingDataSource vedioAddressIndexPath:indexPath];
    NSString *name = [self.routingDataSource vedioNameIndexPath:indexPath];
    UIInterfaceOrientationMask mask = [self.routingDataSource orientationMask:indexPath];
    NSDictionary *parameters = @{
        AFORouteKeyModelName : @"playlist",
        AFORouteKeyCurrent : currentClassName,
        AFORouteKeyNext : @"AFOMediaPlayController",
        AFORouteKeyAction : @"push",
        AFORouteKeyValue : path ?: @"",
        AFORouteKeyTitle : name ?: @"",
        AFORouteKeyDirection : @(mask)
    };
    if (self.routePerformBlock) {
        self.routePerformBlock(parameters);
    } else {
        AFORoutingPerformWithParameters(parameters);
    }
}

@end
