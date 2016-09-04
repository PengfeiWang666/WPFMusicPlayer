//
//  WPFPlayManager.m
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import "WPFPlayManager.h"
#import <AVFoundation/AVFoundation.h>

@interface WPFPlayManager()<AVAudioPlayerDelegate>
@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic,copy) NSString *fileName;
@property (nonatomic,copy) void(^complete)();
@end
@implementation WPFPlayManager

+ (instancetype)sharedPlayManager {
    static WPFPlayManager *_playManger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _playManger = [[self alloc] init];
    });
    return _playManger;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    }
    return self;
}

- (void)audioSessionInterruptionNotification:(NSNotification *)noti {
    
//    NSLog(@"%@",noti.userInfo[AVAudioSessionInterruptionTypeKey]);
    AVAudioSessionInterruptionType type = [noti.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self.player pause];
    }else if(type == AVAudioSessionInterruptionTypeEnded){
        [self.player play];
    }
}

- (void)playMusicWithFileName:(NSString *)fileName didComplete:(void(^)())complete {
    if (_fileName != fileName) {
        // 播放音乐
        NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        self.player = player;
        [player prepareToPlay];
        
        player.delegate = self;
        self.fileName = fileName;
        self.complete = complete;
    }
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.complete();
}
#pragma mark setters 和getters方法
- (NSTimeInterval)currentTime {
    return self.player.currentTime;
}

- (NSTimeInterval)duration {
    return self.player.duration;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    self.player.currentTime = currentTime;
}
@end
