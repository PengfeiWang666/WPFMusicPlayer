//
//  WPFColorLabel.h
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPFColorLabel : UILabel

/** 歌词播放进度 */
@property (nonatomic,assign) CGFloat progress;

/** 歌词颜色 */
@property (nonatomic,strong) UIColor *currentColor;
@end
