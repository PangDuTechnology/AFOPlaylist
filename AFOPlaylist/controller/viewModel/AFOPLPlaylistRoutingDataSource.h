//
//  AFOPLPlaylistRoutingDataSource.h
//  AFOPlaylist
//
//  列表项路由所需数据（由 AFOPLMainManager 实现，单测可提供桩对象）。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AFOPLPlaylistRoutingDataSource <NSObject>

- (NSString *)vedioAddressIndexPath:(NSIndexPath *)indexPath;
- (NSString *)vedioNameIndexPath:(NSIndexPath *)indexPath;
- (UIInterfaceOrientationMask)orientationMask:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
