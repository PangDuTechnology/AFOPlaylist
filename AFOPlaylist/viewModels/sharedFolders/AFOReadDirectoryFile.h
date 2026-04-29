//
//  AFOReadDirectoryFile.h
//  AFOPlayer
//
//  Created by xueguang xian on 2018/1/4.
//  Copyright © 2018年 AFO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AFOReadDirectoryFileDelegate <NSObject>
@required
- (void)directoryFromDocument:(NSArray *)array;
@end

@interface AFOReadDirectoryFile : NSObject
+ (instancetype)readDirectoryFiledelegate:(id)directoryDelegate;
/// 异步重新扫描 Documents（含 AFOLANUpload），在主线程通知 delegate 后调用 completion（下拉刷新、手动同步列表用）。
- (void)rescanApplyingDelegateWithCompletion:(void (^ _Nullable)(void))completion;
@end

NS_ASSUME_NONNULL_END
