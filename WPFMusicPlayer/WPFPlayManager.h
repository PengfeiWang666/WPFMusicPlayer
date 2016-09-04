//
//  WPFPlayManager.h
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPFPlayManager : NSObject
@property (nonatomic,assign) NSTimeInterval currentTime;
@property (nonatomic,assign) NSTimeInterval duration;

/** 单例分享 */
+ (instancetype)sharedPlayManager;

/**
 *  播放音乐的方法
 *
 *  @param fileName 音乐文件的名称
 *  @param complete 播放完毕后block回调
 */
- (void)playMusicWithFileName:(NSString *)fileName didComplete:(void(^)())complete;

/** 音乐暂停 */
- (void)pause;


@end
