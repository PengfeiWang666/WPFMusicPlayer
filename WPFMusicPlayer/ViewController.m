//
//  ViewController.m
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//
// 忽略前缀
#define MAS_SHORTHAND

// 集中装箱  基本数据类型转换成对象
#define MAS_SHORTHAND_GLOBALS
#import "ViewController.h"
#import "Masonry.h"
#import "MJExtension.h"
#import "WPFMusic.h"
#import "WPFPlayManager.h"
#import "WPFTimeTool.h"
#import "WPFLyricParser.h"
#import "WPFLyric.h"
#import "WPFColorLabel.h"
#import "WPFLyricView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <notify.h>

@interface ViewController ()<WPFLyricViewDelegate>

#pragma mark 私有属性
@property (nonatomic,strong) NSArray *musics;
@property (nonatomic,assign) NSInteger currentMusicIndex;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSArray *lyrics;
@property (nonatomic,assign) NSInteger currentLyricIndex;
@property (weak, nonatomic) IBOutlet WPFLyricView *lyricView;

#pragma mark 共用的属性
// 背景图片
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

// 播放按钮
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

// 当前播放时间
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

// 歌曲总时间
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

// 滑动条
@property (weak, nonatomic) IBOutlet UISlider *slider;


#pragma mark 竖屏
// 竖屏界面
@property (weak, nonatomic) IBOutlet UIView *vCenterView;

// 专辑
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;

// 歌词
@property (strong, nonatomic) IBOutletCollection(WPFColorLabel) NSArray *lyricsLabel;

// 竖屏中心图片
@property (weak, nonatomic) IBOutlet UIImageView *vCenterImageView;

// 歌手
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;


#pragma mark 横屏

// 横屏图片
@property (weak, nonatomic) IBOutlet UIImageView *hCennterImageView;

// 播放
- (IBAction)play;

// 下一曲
- (IBAction)next;

// 改变歌曲进度
- (IBAction)changeValue;

// 上一曲
- (IBAction)previous;
@end

static uint64_t isScreenBright;
static uint64_t isLocked;

#define kSetLockScreenLrcNoti @"kSetLockScreenLrcNoti"

@implementation ViewController


- (NSArray *)musics {
    if (!_musics) {
        _musics = [WPFMusic objectArrayWithFilename:@"mlist.plist"];
    }
    return _musics;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleBlack;
    [self.bgImageView addSubview:toolbar];
    
    //添加约束
    [toolbar makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    // 强制布局
    [self.view layoutIfNeeded];
    self.vCenterImageView.layer.cornerRadius = self.vCenterImageView.frame.size.width * 0.5;
    self.vCenterImageView.clipsToBounds = YES;
    
    // 切歌
    [self changeMusic];
    
    self.lyricView.delegate = self;
    
    // 监听锁屏状态
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, updateEnabled, CFSTR("com.apple.iokit.hid.displayStatus"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, lockState, CFSTR("com.apple.springboard.lockstate"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    });
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLockScreen) name:kSetLockScreenLrcNoti object:nil];
}

// 监听在锁定状态下，屏幕是黑暗状态还是明亮状态
static void updateEnabled(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo) {
    
    //    uint64_t state;
    
    int token;
    
    notify_register_check("com.apple.iokit.hid.displayStatus", &token);
    
    notify_get_state(token, &isScreenBright);
    
    notify_cancel(token);
    
    [ViewController checkoutIfSetLrc];
    
    //    NSLog(@"锁屏状态：%llu",isScreenBright);
}

// 监听屏幕是否被锁定
static void lockState(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo) {
    
    uint64_t state;
    
    int token;
    
    notify_register_check("com.apple.springboard.lockstate", &token);
    
    notify_get_state(token, &state);
    
    notify_cancel(token);
    isLocked = state;
    [ViewController checkoutIfSetLrc];
    //    NSLog(@"lockState状态：%llu",state);
}

+ (void)checkoutIfSetLrc {
    if (isLocked && isScreenBright) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSetLockScreenLrcNoti object:nil];
    }
}

- (IBAction)play {
    WPFPlayManager *playManager = [WPFPlayManager sharedPlayManager];
    if (self.playBtn.selected == NO) {
        [self startUpdateProgress];
        WPFMusic *music = self.musics[self.currentMusicIndex];
        [playManager playMusicWithFileName:music.mp3 didComplete:^{
            [self next];
        }];
        self.playBtn.selected = YES;
    }else{
        self.playBtn.selected = NO;
        [playManager pause];
        [self stopUpdateProgress];
    }
    
}

- (IBAction)next {
    if (self.currentMusicIndex == self.musics.count -1) {
        self.currentMusicIndex = 0;
    }else{
        self.currentMusicIndex ++;
    }
    [self changeMusic];
}

/**
 *  切歌
 */
- (void)changeMusic {
    // 防止切歌时歌词数组越界
    
    self.currentLyricIndex = 0;
    // 切歌时销毁当前的定时器
    [self stopUpdateProgress];
    
    WPFPlayManager *pm = [WPFPlayManager sharedPlayManager];
    
    WPFMusic *music = self.musics[self.currentMusicIndex];
    // 歌词
    // 解析歌词
    self.lyrics = [WPFLyricParser parserLyricWithFileName:music.lrc];
    
    // 给竖直歌词赋值
    self.lyricView.lyrics = self.lyrics;
    // 专辑
    self.albumLabel.text = music.album;
    // 歌手
    self.singerLabel.text = [NSString stringWithFormat:@"—  %@  —", music.singer];
    // 图片
    UIImage *image = [UIImage imageNamed:music.image];
    self.vCenterImageView.image = image;
    self.bgImageView.image = image;
    self.hCennterImageView.image = image;
    self.playBtn.selected = NO;
    self.navigationItem.title = music.name;
    [self play];
    self.durationLabel.text = [WPFTimeTool stringWithTime:pm.duration];
}

- (IBAction)changeValue {
//    NSLog(@"%lu",(unsigned long)self.slider.state);
    WPFPlayManager *pm = [WPFPlayManager sharedPlayManager];
    pm.currentTime = self.slider.value * pm.duration;
}

- (IBAction)previous {
    if (self.currentMusicIndex == 0) {
        self.currentMusicIndex = self.musics.count - 1;
    }else{
        self.currentMusicIndex --;
    }
    [self changeMusic];
}

- (void)startUpdateProgress {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    
}

- (void)stopUpdateProgress {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateProgress {
    WPFPlayManager *pm = [WPFPlayManager sharedPlayManager];
    self.currentTimeLabel.text = [WPFTimeTool stringWithTime:pm.currentTime];
    
    self.vCenterImageView.transform = CGAffineTransformRotate(self.vCenterImageView.transform, M_PI_2* 0.01);
    
    self.slider.value = pm.currentTime / pm.duration;
    
    //  更新歌词
    [self updateLyric];
    
    // 更新锁屏界面
    if (isLocked && isScreenBright) {
        [self updateLockScreen];
    }
}

- (void)updateLockScreen {
    // 获取音乐播放信息中心
    MPNowPlayingInfoCenter *nowPlayingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    // 创建可变字典存放信息
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    // 获取当前正在播放的音乐对象
    WPFMusic *music = self.musics[self.currentMusicIndex];
    
    WPFPlayManager *playManager = [WPFPlayManager sharedPlayManager];
    // 专辑名称
    info[MPMediaItemPropertyAlbumTitle] = music.album;
    // 歌手
    info[MPMediaItemPropertyArtist] = music.singer;
    // 专辑图片
    info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:[self lyricImage]];
    // 当前播放进度
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(playManager.currentTime);
    // 音乐总时间
    info[MPMediaItemPropertyPlaybackDuration] = @(playManager.duration);
    // 音乐名称
    info[MPMediaItemPropertyTitle] = music.name;
    
    nowPlayingInfoCenter.nowPlayingInfo = info;
}

- (UIImage *)lyricImage {
    WPFMusic *music = self.musics[self.currentMusicIndex];
    WPFLyric *lyric = self.lyrics[self.currentLyricIndex];
    WPFLyric *lastLyric = [[WPFLyric alloc] init];
    WPFLyric *nextLyric = [[WPFLyric alloc] init];
    
    if (self.currentLyricIndex > 0) {
        lastLyric = self.lyrics[self.currentLyricIndex - 1];
        if (!lastLyric.content.length && self.currentLyricIndex > 1) {
            lastLyric = self.lyrics[self.currentLyricIndex - 2];
        }
    }
    
    if (self.lyrics.count > self.currentLyricIndex + 1) {
        nextLyric = self.lyrics[self.currentLyricIndex + 1];
        
        // 筛选空的时间间隔歌词
        if (!nextLyric.content.length && self.lyrics.count > self.currentLyricIndex + 2) {
            nextLyric = self.lyrics[self.currentLyricIndex + 2];
        }
    }
    
    UIImage *bgImage = [UIImage imageNamed:music.image];
    
    // 创建ImageView
    UIImageView *imgView = [[UIImageView alloc] initWithImage:bgImage];
    imgView.bounds = CGRectMake(0, 0, 640, 640);
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    
    // 添加遮罩
    UIView *cover = [[UIView alloc] initWithFrame:imgView.bounds];
    cover.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [imgView addSubview:cover];
    
    // 添加歌词
    UILabel *lyricLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 480, 620, 150)];
    lyricLabel.textAlignment = NSTextAlignmentCenter;
    lyricLabel.numberOfLines = 3;
    NSString *lyricString = [NSString stringWithFormat:@"%@ \n%@ \n %@", lastLyric.content, lyric.content, nextLyric.content];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lyricString attributes:@{
                            NSFontAttributeName : [UIFont systemFontOfSize:29],
                            NSForegroundColorAttributeName : [UIColor lightGrayColor]
                                                }];
    
    [attributedString addAttributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:34],
                NSForegroundColorAttributeName : [UIColor whiteColor]
                                    } range:[lyricString rangeOfString:lyric.content]];
    lyricLabel.attributedText = attributedString;
    [imgView addSubview:lyricLabel];
    
    // 开始画图
    UIGraphicsBeginImageContext(imgView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [imgView.layer renderInContext:context];
    
    // 获取图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)updateLyric {
    WPFPlayManager *pm = [WPFPlayManager sharedPlayManager];
    WPFLyric *lyric = self.lyrics[self.currentLyricIndex];
    WPFLyric *nextLyric = nil;
    if (self.currentLyricIndex >= self.lyrics.count - 1) {
        nextLyric = [[WPFLyric alloc] init];
        nextLyric.time = pm.duration;
    }else{
        nextLyric = self.lyrics[self.currentLyricIndex + 1];;
    }
    
    
    if (pm.currentTime < lyric.time && self.currentLyricIndex > 0) {
        self.currentLyricIndex --;
        [self updateLyric];
    }else if(pm.currentTime >= nextLyric.time && self.currentLyricIndex < self.lyrics.count - 1){
        self.currentLyricIndex ++;
        [self updateLyric];
    }
    // 设置歌词内容
    [self.lyricsLabel setValue:lyric.content forKey:@"text"];
    
    // 设置歌词颜色
    CGFloat progress = (pm.currentTime - lyric.time) / (nextLyric.time - lyric.time);
    [self.lyricsLabel setValue:@(progress) forKey:@"progress"];

    self.lyricView.currentLyricIndex = self.currentLyricIndex;

    self.lyricView.lyricProgress = progress;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    /*
     UIEventSubtypeRemoteControlPlay                 播放
     UIEventSubtypeRemoteControlPause                暂停
     UIEventSubtypeRemoteControlStop                 停止
     UIEventSubtypeRemoteControlTogglePlayPause      从暂停到播放
     UIEventSubtypeRemoteControlNextTrack            下一曲
     UIEventSubtypeRemoteControlPreviousTrack        上一曲
     UIEventSubtypeRemoteControlBeginSeekingBackward 开始快退
     UIEventSubtypeRemoteControlEndSeekingBackward   结束快退
     UIEventSubtypeRemoteControlBeginSeekingForward  开始快进
     UIEventSubtypeRemoteControlEndSeekingForward    结束快进
     */
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self play];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous];
            break;
            
        default:
            break;
    }
}

#pragma mark 代理
- (void)lyricView:(WPFLyricView *)lyricView withProgress:(CGFloat)progress {
    
    self.vCenterView.alpha = 1- progress;
}
@end
