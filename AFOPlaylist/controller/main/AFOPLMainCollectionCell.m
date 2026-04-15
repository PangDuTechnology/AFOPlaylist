//
//  AFOPlayListMainCollectionCell.m
//  AFOPlaylist
//
//  Created by xueguang xian on 2018/1/4.
//  Copyright © 2018年 AFO. All rights reserved.
//

#import "AFOPLMainCollectionCell.h"
#import <AFOGitHub/AFOGitHub.h>
#import <AFOFoundation/AFOFoundation.h> // 导入 AFOFoundation，包含 WeakObject 宏
#import "AFOPLMainFolderManager.h"
#import "AFOPLThumbnail.h"
@interface AFOPLMainCollectionCell ()
@property (nonnull, nonatomic, strong) UIImageView *postersImageView;
@property (nonnull, nonatomic, strong) UIButton    *deleteButton;
@property (nonnull, nonatomic, strong) UILabel     *postersLB;
@property (nonnull, nonatomic, strong) id           models;
@property (nonatomic, assign)          BOOL         isTouch;
@property (nonatomic, copy)            NSString    *currentImagePathToken;
@end
@implementation AFOPLMainCollectionCell
#pragma mark ------------ init
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self cellAddSubview:frame];
    }
    return self;
}
#pragma mark ------ method
- (void)cellAddSubview:(CGRect)frame{
    self.isTouch = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
    ///------
    self.postersImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height - 20);
    [self.contentView addSubview:self.postersImageView];
    ///------
    self.postersLB.frame = CGRectMake(0, CGRectGetHeight(self.postersImageView.frame), frame.size.width, CGRectGetHeight(frame) - CGRectGetHeight(self.postersImageView.frame));
    [self.contentView addSubview:self.postersLB];
    ///------
    self.deleteButton.frame = self.postersImageView.frame;
    self.deleteButton.hidden = YES ;
    [self.contentView addSubview:self.deleteButton];
}
#pragma mark ------ 控件赋值
- (void)settingSubViews:(id)model{
    AFOPLThumbnail *detail = model;
    NSString *path =[[AFOPLMainFolderManager mediaImagesCacheFolder] stringByAppendingString:@"/"];
    NSString *imagePath = [path stringByAppendingString:detail.image_name ?: @""];
    self.currentImagePathToken = imagePath;
    self.postersImageView.image = [self placeholderPosterImage];
    self.postersImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    WeakObject(self);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        UIImage *image = nil;
        if (imagePath.length > 0) {
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            if (data.length > 0) {
                image = [UIImage imageWithData:data];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
        StrongObject(self);
        if (![self.currentImagePathToken isEqualToString:imagePath]) {
            return;
        }
        if (image && self.imageLoadedBlock) {
            // 通知 CollectionView 重新布局当前单元格
            // 注意：这里无法直接获取 indexPath，需要在 cellForItemAtIndexPath 中传递
            // 为了简化，暂时假设可以在 block 中传递 indexPath
            // 更优雅的方案是在 cellForItemAtIndexPath 中设置一个 target-action 或 delegate
            // 或者，如果只是简单地通知布局失效，可以直接在主线程调用 self.collectionView.collectionViewLayout.invalidateLayout;
            // 但因为我们想精确到单个 cell，所以需要 indexPath
            // 鉴于目前没有直接获取 indexPath 的方法，我们将使用更通用的通知
            // 通知 AFOPLMainController 重新加载数据或者重新布局
            // 为了避免强引用循环，使用 WeakObject(self) 和 StrongObject(self)
            if (self.imageLoadedBlock && self.indexPath) {
                self.imageLoadedBlock(self.indexPath);
                [self setNeedsLayout];
                [self layoutIfNeeded];
            }
        }
            self.postersImageView.image = image ?: [self placeholderPosterImage];
            self.postersImageView.backgroundColor = image ? [UIColor clearColor] : [UIColor colorWithWhite:0.95 alpha:1.0];
        });
    });
    self.postersLB.text = detail.vedio_name;
    ///---
    self.models = model;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.currentImagePathToken = nil;
    self.postersImageView.image = [self placeholderPosterImage];
    self.postersImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.postersLB.text = @"";
}
#pragma mark ------
- (void)deleteVedioItem:(id)sender{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    NSDictionary *dictionary = nil;
    if (button.selected) {
        dictionary = @{@"operation" : @"add",
                       @"value" : self.models
                       };
    }else{
        dictionary = @{@"operation" : @"remove",
                       @"value" : self.models
                       };
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AFOPLEditMenuViewNotification" object:nil userInfo:dictionary ];
}
- (void)showAllDeleteIcon:(BOOL)isShow{
    self.deleteButton.hidden = !isShow;
    self.deleteButton.selected = isShow;
}
- (void)settingCellUnTouch:(BOOL)isTouch{
    self.isTouch = isTouch;
    self.deleteButton.hidden = isTouch;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_isTouch) {
        [super touchesBegan:touches withEvent:event];
    }else{
        [[self nextResponder] touchesBegan:touches withEvent:event];
    }
}
#pragma mark ------------ property
- (UIImageView *)postersImageView{
    if (!_postersImageView) {
        _postersImageView = [[UIImageView alloc] init];
        _postersImageView.contentMode = UIViewContentModeScaleAspectFit; // 设置内容模式
        _postersImageView.clipsToBounds = YES; // 裁剪超出边界的内容
    }
    return _postersImageView;
}
- (UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:nil forState:UIControlStateNormal];
        [_deleteButton setImage:[UIImage imageNamed:@"AFO_delete.png"] forState:UIControlStateSelected];
        [_deleteButton addTarget:self action:@selector(deleteVedioItem:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}
- (UILabel *)postersLB{
    if (!_postersLB) {
        _postersLB = [[UILabel alloc] init];
        _postersLB.font = [UIFont systemFontOfSize:12];
        _postersLB.textColor = [UIColor darkGrayColor];
        _postersLB.numberOfLines = 1;
    }
    return _postersLB;
}

- (UIImage *)placeholderPosterImage {
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(12.0, 8.0);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        [[UIColor colorWithWhite:0.90 alpha:1.0] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return placeholder;
}

#pragma mark ------ layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    self.postersImageView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height - 20);
    self.postersLB.frame = CGRectMake(0, CGRectGetHeight(self.postersImageView.frame), self.contentView.bounds.size.width, self.contentView.bounds.size.height - CGRectGetHeight(self.postersImageView.frame));
    self.deleteButton.frame = self.postersImageView.frame;
}

@end
