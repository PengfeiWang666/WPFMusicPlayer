//
//  WPFLyricView.m
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

// 忽略前缀
#define MAS_SHORTHAND

// 集中装箱  基本数据类型转换成对象
#define MAS_SHORTHAND_GLOBALS
#import "WPFLyricView.h"
#import "Masonry.h"
#import "WPFColorLabel.h"
#import "WPFLyric.h"
#import "WPFSliderView.h"

@interface WPFLyricView ()<UIScrollViewDelegate>

/* 水平滚动的大view，包含音乐播放界面及歌词界面 */
@property (nonatomic,weak) UIScrollView *hScrollerView;

/** 定位播放的View */
@property (nonatomic,weak) WPFSliderView *sliderView;

@end


@implementation WPFLyricView

@synthesize currentLyricIndex = _currentLyricIndex;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    
    // 1.创建水平滚动的scrollerView
    UIScrollView *hScrollerView = [[UIScrollView alloc] init];
    [self addSubview:hScrollerView];
    self.hScrollerView = hScrollerView;
    hScrollerView.delegate = self;
    
    // 隐藏滑动条
    hScrollerView.showsHorizontalScrollIndicator = NO;
    
    // 分页
    hScrollerView.pagingEnabled = YES;
    
    // 2.创建竖直滚动的scrollerView
    UIScrollView *vScrollerView = [[UIScrollView alloc] init];
    [hScrollerView addSubview:vScrollerView];
    vScrollerView.delegate = self;
    self.vScrollerView = vScrollerView;
    
    // 添加约束
    [hScrollerView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    // 添加sliderView
    WPFSliderView *sliderView = [[WPFSliderView alloc] init];
    [self addSubview:sliderView];
    sliderView.hidden = YES;
    self.sliderView = sliderView;
    
    [sliderView makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.equalTo(self);
        make.height.equalTo(self.rowHeight);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.hScrollerView.contentSize = CGSizeMake(self.bounds.size.width * 2, 0);
    [self.vScrollerView makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.width.equalTo(self);
        make.left.equalTo(self.bounds.size.width);
    }];
    
    self.vScrollerView.contentSize = CGSizeMake(0, self.lyrics.count * self.rowHeight);
#warning 必须使用self.bounds.size.height  不能使用self.vScrollerView.bounds.size.height   这个layoutSubviews只作用于self   所以self.vScrollerView可能还没有布局完成
    CGFloat top = (self.bounds.size.height - self.rowHeight) * 0.5;
    CGFloat bottom = top;
    self.vScrollerView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
    
}

#pragma mark UIScrollerView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.hScrollerView) {
        [self hScrollerViewDidScroll];
    }else if(scrollView == self.vScrollerView){
        [self vScrollerViewDidScroll];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.vScrollerView) {
        self.sliderView.hidden = NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if (scrollView == self.vScrollerView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.vScrollerView.isDragging == YES) {
                return ;
            }
            self.sliderView.hidden = YES;
        });
    }
}

/**
 *  水平滚动
 */
- (void)hScrollerViewDidScroll {
    
    CGFloat scrollProgress = self.hScrollerView.contentOffset.x / self.bounds.size.width;
//    NSLog(@"%lf",scrollProgress);
    if ([self.delegate respondsToSelector:@selector(lyricView:withProgress:)]) {
        [self.delegate lyricView:self withProgress:scrollProgress];
    }
}

- (void)vScrollerViewDidScroll {
    CGFloat offy = self.vScrollerView.contentOffset.y + self.vScrollerView.contentInset.top;
    NSInteger currentIndex = offy / self.rowHeight;
    if (currentIndex < 0) {
        currentIndex = 0;
    }else if(currentIndex > self.lyrics.count - 1){
        currentIndex = self.lyrics.count - 1;
    }
    WPFLyric *lyric = self.lyrics[currentIndex];
    self.sliderView.time = lyric.time;
}


#pragma mark setter和getter
- (void)setLyrics:(NSArray *)lyrics {
    
    _lyrics = lyrics;
    [self.vScrollerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i =0; i < lyrics.count; i ++) {
        
        WPFColorLabel *colorLabel = [[WPFColorLabel alloc] init];
        colorLabel.textColor = [UIColor whiteColor];
        colorLabel.font = [UIFont systemFontOfSize:16];
        WPFLyric *lyric = lyrics[i];
        colorLabel.text = lyric.content;
        [self.vScrollerView addSubview:colorLabel];
        
        // 添加约束
        [colorLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.vScrollerView);
            make.top.equalTo(self.rowHeight * i);
            make.height.equalTo(self.rowHeight);
        }];
    }
    
//    self.vScrollerView.contentSize = CGSizeMake(0, self.lyrics.count * self.rowHeight);
}

- (NSInteger)rowHeight {
    if (_rowHeight == 0) {
        _rowHeight = 44;
    }
    return _rowHeight;
}


- (void)setCurrentLyricIndex:(NSInteger)currentLyricIndex {
    
    // 切歌时数组越界
    WPFColorLabel *preLabel = self.vScrollerView.subviews[self.currentLyricIndex];
    preLabel.progress = 0;
    preLabel.font = [UIFont systemFontOfSize:16];
    _currentLyricIndex = currentLyricIndex;
    WPFColorLabel *colorLabel = self.vScrollerView.subviews[currentLyricIndex];
    colorLabel.font = [UIFont systemFontOfSize:20];
    
//    if (self.vScrollerView.hidden == NO) {
//        return;
//    }
    
    NSInteger offY = currentLyricIndex * self.rowHeight - self.vScrollerView.contentInset.top;
    self.vScrollerView.contentOffset = CGPointMake(0, offY);
    [self.vScrollerView setContentOffset:CGPointMake(0, offY) animated:YES];
}

- (NSInteger)currentLyricIndex {
    
    if (_currentLyricIndex <0) {
        _currentLyricIndex = 0;
    }else if(_currentLyricIndex >= self.lyrics.count - 1){
        _currentLyricIndex = self.lyrics.count - 1;
    }
    return _currentLyricIndex;
}

- (void)setLyricProgress:(CGFloat)lyricProgress {
    
    _lyricProgress = lyricProgress;
    WPFColorLabel *colorLabel = self.vScrollerView.subviews[self.currentLyricIndex];
    colorLabel.progress = lyricProgress;
}


@end
