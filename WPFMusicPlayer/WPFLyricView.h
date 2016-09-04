//
//  WPFLyricView.h
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WPFLyricView;

@protocol WPFLyricViewDelegate  <NSObject>

@optional

- (void)lyricView:(WPFLyricView *)lyricView withProgress:(CGFloat)progress;
@end

@interface WPFLyricView : UIView

@property (nonatomic,weak) id <WPFLyricViewDelegate> delegate;

/** 歌词模型数组 */
@property (nonatomic,strong) NSArray *lyrics;

/** 每行歌词行高 */
@property (nonatomic,assign) NSInteger rowHeight;

/** 当前正在播放的歌词索引 */
@property (nonatomic,assign) NSInteger currentLyricIndex;

/** 歌曲播放进度 */
@property (nonatomic,assign) CGFloat lyricProgress;

/** 竖直滚动的view，即歌词View */
@property (nonatomic,weak) UIScrollView *vScrollerView;

@end
