//
//  WPFSliderView.m
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

// 忽略前缀
#define MAS_SHORTHAND
// 集中装箱  基本数据类型转换成对象
#define MAS_SHORTHAND_GLOBALS
#import "WPFSliderView.h"
#import "Masonry.h"
#import "WPFTimeTool.h"
#import "WPFPlayManager.h"


@interface WPFSliderView ()

@property (nonatomic,weak) UIImageView *bgImageView;

@property (nonatomic,weak) UILabel  *timeLabel;

@property (nonatomic,weak) UILabel  *tipLabel;

@property (nonatomic,weak) UIButton  *playBtn;
@end


@implementation WPFSliderView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;

}

- (void)setUp {
    // 初始化控件
    UIImageView *bgImageView = [[UIImageView alloc] init];
    self.bgImageView = bgImageView;
    [self addSubview:bgImageView];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:timeLabel];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    self.tipLabel = tipLabel;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:tipLabel];
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn = playBtn;
    [playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playBtn];
    
    // 添加约束
    [bgImageView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [timeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(8);
    }];
    
    [tipLabel makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [playBtn makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-8);
    }];
    
    // 设置属性
    bgImageView.image = [UIImage imageNamed:@"lyric_tipview_backimg"];
    
    timeLabel.text = @"00:00";
    
    tipLabel.text = @"请点击右边按钮在这行播放";
    
    [playBtn setImage:[UIImage imageNamed:@"slide_icon_play"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"slide_icon_play_pressed"] forState:UIControlStateHighlighted];
}

- (void)setTime:(NSTimeInterval)time {
    _time = time;
    self.timeLabel.text = [WPFTimeTool stringWithTime:time];
}

- (void)playBtnClick {
    WPFPlayManager *pm = [WPFPlayManager sharedPlayManager];
    pm.currentTime = self.time;
}
@end
