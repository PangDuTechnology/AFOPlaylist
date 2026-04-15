//
//  AFOPLCorresponding+GCD.m
//  AFOPlaylist
//
//  Created by xueguang xian on 2018/1/16.
//  Copyright © 2018年 AFO. All rights reserved.
//

#import "AFOPLCorresponding+GCD.h"
#import <AFOFoundation/AFOFoundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <TargetConditionals.h>
#if !TARGET_OS_SIMULATOR
#import <AFOFFMpeg/AFOFFMpeg.h>
#endif
#import "AFOPLThumbnail.h"
#import "AFOPLSQLiteManager.h"
#import "AFOPLMainFolderManager.h"

/// 与 AFOPLMainManager resolvedVideoPathForName 一致：支持 AFOLANUpload/xxx.mp4 相对路径及仅文件名落在 AFOLANUpload 目录。
static NSString *AFOPLResolvedVideoFileInDocuments(NSString *relativeName) {
    NSString *documents = [NSFileManager documentSandbox];
    if (relativeName.length == 0) {
        return documents;
    }
    NSString *candidate = documents;
    for (NSString *part in [relativeName pathComponents]) {
        if (part.length == 0 || [part isEqualToString:@"/"]) {
            continue;
        }
        candidate = [candidate stringByAppendingPathComponent:part];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:candidate]) {
        return candidate;
    }
    if ([relativeName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location == NSNotFound) {
        NSString *legacy = [[documents stringByAppendingPathComponent:@"AFOLANUpload"] stringByAppendingPathComponent:relativeName];
        if ([fm fileExistsAtPath:legacy]) {
            return legacy;
        }
    }
    return candidate;
}

@interface AFOPLCorresponding ()
@end
@implementation AFOPLCorresponding (GCD)
#pragma mark ------ 截图
+ (void)cuttingImageSaveSqlite:(NSArray *)array
                         block:(void (^) (NSArray *itemArray))block{
    __block NSMutableArray *newArray = [[NSMutableArray alloc] init];
#if TARGET_OS_SIMULATOR
    // 模拟器分支改为真实抽帧，保证播放列表可看到截图。
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSString *videoRootPath = [NSFileManager documentSandbox];
        NSString *imageFolderPath = [AFOPLMainFolderManager mediaImagesCacheFolder];
        NSFileManager *fileManager = [NSFileManager defaultManager];

        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *videoName = [obj isKindOfClass:[NSString class]] ? obj : @"";
            if (videoName.length == 0) {
                return;
            }

            NSString *videoPath = AFOPLResolvedVideoFileInDocuments(videoName);
            if (![fileManager fileExistsAtPath:videoPath]) {
                return;
            }

            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
            if (!asset) {
                return;
            }
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            imageGenerator.appliesPreferredTrackTransform = YES;
            imageGenerator.maximumSize = CGSizeMake(600, 600);

            CMTime seekTime = kCMTimeZero;
            Float64 durationSeconds = CMTimeGetSeconds(asset.duration);
            if (isfinite(durationSeconds) && durationSeconds > 0.5) {
                seekTime = CMTimeMakeWithSeconds(MIN(1.0, durationSeconds / 3.0), 600);
            }

            NSError *imageError = nil;
            CGImageRef cgImage = [imageGenerator copyCGImageAtTime:seekTime actualTime:NULL error:&imageError];
            if (!cgImage || imageError) {
                if (cgImage) {
                    CGImageRelease(cgImage);
                }
                return;
            }

            UIImage *thumbnailImage = [UIImage imageWithCGImage:cgImage];
            CGImageRelease(cgImage);
            if (!thumbnailImage) {
                return;
            }

            NSString *imageName = [self simulatorImageNameForVideoName:videoName];
            NSString *imagePath = [imageFolderPath stringByAppendingPathComponent:imageName];
            NSData *imageData = UIImageJPEGRepresentation(thumbnailImage, 0.85);
            if (imageData.length == 0) {
                return;
            }
            BOOL writeSuccess = [imageData writeToFile:imagePath atomically:YES];
            if (!writeSuccess) {
                return;
            }

            NSInteger width = (NSInteger)CGImageGetWidth(thumbnailImage.CGImage);
            NSInteger height = (NSInteger)CGImageGetHeight(thumbnailImage.CGImage);
            NSString *createTime = [self simulatorCreateTimeString];

            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            __block BOOL insertSuccess = NO;
            [AFOPLSQLiteManager inserSQLiteDataBase:AFO_PLAYLIST_SCREENSHOTSVEDIOLIST
                                             isHave:YES
                                         createTime:createTime
                                          vedioName:videoName
                                          imageName:imageName
                                              width:(int)width
                                             height:(int)height
                                              block:^(BOOL isFinish) {
                insertSuccess = isFinish;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (!insertSuccess) {
                return;
            }

            AFOPLThumbnail *detail = [[AFOPLThumbnail alloc] init];
            detail.create_time = createTime;
            detail.vedio_name = videoName;
            detail.image_name = imageName;
            detail.image_width = width;
            detail.image_hight = height;
            [newArray addObjectAFOAbnormal:detail];
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(newArray);
            }
        });
    });
    return;
#else
    [[AFOMediaForeignInterface shareInstance] mediaSeekFrameUseQueue:array vediopath:[NSFileManager documentSandbox] imagePath:[AFOPLMainFolderManager mediaImagesAddress] sqlite:[AFOPLMainFolderManager dataBaseAddress] block:^(BOOL isHave,NSString *createTime,NSString *vedioName, NSString *imageName, int width, int height) {
        NSLog(@"AFOPLCorresponding+GCD: mediaSeekFrameUseQueue callback - Image Name: %@, Width: %d, Height: %d", imageName, width, height); // 添加调试日志
        [AFOPLSQLiteManager inserSQLiteDataBase:AFO_PLAYLIST_SCREENSHOTSVEDIOLIST isHave:isHave createTime:createTime vedioName:vedioName imageName:imageName width:width height:height block:^(BOOL isFinish) {
            if (isFinish) {
                AFOPLThumbnail *detail = [[AFOPLThumbnail alloc] init];
                detail.create_time =createTime;
                detail.vedio_name = vedioName;
                detail.image_name = imageName;
                detail.image_width = width;
                detail.image_hight = height;
                [newArray addObjectAFOAbnormal:detail];
                NSLog(@"成功插入数据!");
            }
        }];
        block(newArray);
    }];
#endif
}

+ (NSString *)simulatorImageNameForVideoName:(NSString *)videoName {
    NSString *normalizedName = [videoName stringByDeletingPathExtension];
    if (normalizedName.length == 0) {
        normalizedName = videoName ?: @"video";
    }
    NSString *baseName = [NSString stringWithFormat:@"%llx", (unsigned long long)normalizedName.hash];
    if (baseName.length == 0) {
        baseName = [NSString stringWithFormat:@"thumb_%@", @((long long)(NSDate.date.timeIntervalSince1970 * 1000))];
    }
    return [baseName stringByAppendingString:@".jpg"];
}

+ (NSString *)simulatorCreateTimeString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    return [formatter stringFromDate:[NSDate date]] ?: @"";
}
@end
