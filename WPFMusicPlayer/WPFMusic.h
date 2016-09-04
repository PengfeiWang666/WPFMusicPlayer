//
//  WPFMusic.h
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    WPFMusicTypeLocal,
    WPFMusicTypeRemote
}WPFMusicType;

@interface WPFMusic : NSObject

/** 图片 */
@property (nonatomic,copy) NSString *image;

/** 歌词 */
@property (nonatomic,copy) NSString *lrc;

/** 歌曲 */
@property (nonatomic,copy) NSString *mp3;

/** 歌曲名 */
@property (nonatomic,copy) NSString *name;

/** 歌手 */
@property (nonatomic,copy) NSString *singer;

/** 专辑 */
@property (nonatomic,copy) NSString *album;

/** 类型 */
@property (nonatomic,assign) WPFMusicType type;

@end
