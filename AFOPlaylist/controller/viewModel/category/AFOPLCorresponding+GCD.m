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
    // 真机原先用 FFmpeg 抽帧；AFOMediaSeekFrame 在多数码流下因 key_frame 判断/失败路径无回调导致永远不走完，
    // 列表 validDatabaseCount 一直为 0。统一改用 AVFoundation，与模拟器行为一致且稳定。
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
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

            // 与 Pods/AFOFFMpeg AFOMediaThumbnail imageName: 一致，保证与历史数据及 imageAddress: 解析一致。
            NSString *imageName = [[NSString md5HexDigest:videoName] stringByAppendingString:@".jpg"];
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
            NSString *createTime = [self thumbnailCreateTimeString];

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
}

+ (NSString *)thumbnailCreateTimeString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    return [formatter stringFromDate:[NSDate date]] ?: @"";
}
@end
