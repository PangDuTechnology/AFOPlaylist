//
//  AFOPLMainManager.h
//  AFOPlaylist
//
//  Created by xueguang xian on 2018/1/4.
//  Copyright © 2018年 AFO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AFOPLPlaylistRoutingDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AFOPLMainManagerDelegate <NSObject>
@optional
- (void)mainManagerArray:(NSArray * _Nonnull)array
              indexArray:(NSArray * _Nonnull)indexArray;
@end
@interface AFOPLMainManager : NSObject <AFOPLPlaylistRoutingDataSource>
+ (AFOPLMainManager * _Nonnull)mainManagerDelegate:(id _Nonnull)managerDelegate;
+ (void)deleteMovieRelatedContentLocally:(NSArray * _Nonnull)array
                                   block:(void (^ _Nonnull)(BOOL isSucess))block;
- (void)getThumbnailData:(void (^ _Nonnull)(NSArray * _Nonnull array))block;
/// 重新扫描磁盘视频列表后再执行 completion（内部会更新 nameArray）。
- (void)refreshDirectoryListingWithCompletion:(void (^ _Nullable)(void))completion;
- (CGFloat)thumbnailHight:(NSIndexPath * _Nonnull)indexPath width:(CGFloat)width;
- (NSString * _Nonnull)vedioAddressIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (NSString * _Nonnull)vedioNameIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (UIInterfaceOrientationMask)orientationMask:(NSIndexPath * _Nonnull)indexPath;

/// 与 `AFOPLPlaylistRoutingDataSource` 可选方法对应，供编辑/ViewModel 使用。
- (NSUInteger)playlistItemCount;
- (NSArray * _Nonnull)playlistThumbnailItemsSnapshot;
@end

NS_ASSUME_NONNULL_END
