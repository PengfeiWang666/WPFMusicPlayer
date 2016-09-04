//
//  WPFLyric.h
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPFLyric : NSObject
/** 歌词开始时间 */
@property (nonatomic,assign) NSTimeInterval time;

/** 歌词内容 */
@property (nonatomic,copy) NSString *content;

@end
