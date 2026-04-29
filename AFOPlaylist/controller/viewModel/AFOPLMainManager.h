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
- (void)mainManagerArray:(NSArray *)array
              indexArray:(NSArray *)indexArray;
@end
@interface AFOPLMainManager : NSObject <AFOPLPlaylistRoutingDataSource>
+ (AFOPLMainManager *)mainManagerDelegate:(id)managerDelegate;
+ (void)deleteMovieRelatedContentLocally:(NSArray *)array
                                   block:(void (^)(BOOL isSucess))block;
- (void)getThumbnailData:(void (^)(NSArray *array))block;
/// 重新扫描磁盘视频列表后再执行 completion（内部会更新 nameArray）。
- (void)refreshDirectoryListingWithCompletion:(void (^ _Nullable)(void))completion;
- (CGFloat)thumbnailHight:(NSIndexPath *)indexPath width:(CGFloat)width;
- (NSString *)vedioAddressIndexPath:(NSIndexPath *)indexPath;
- (NSString *)vedioNameIndexPath:(NSIndexPath *)indexPath;
- (UIInterfaceOrientationMask)orientationMask:(NSIndexPath *)indexPath;

/// 与 `AFOPLPlaylistRoutingDataSource` 可选方法对应，供编辑/ViewModel 使用。
- (NSUInteger)playlistItemCount;
- (NSArray *)playlistThumbnailItemsSnapshot;
@end

NS_ASSUME_NONNULL_END
