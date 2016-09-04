//
//  WPFColorLabel.m
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import "WPFColorLabel.h"

@implementation WPFColorLabel

- (void)setProgress:(CGFloat)progress {
    
    _progress = progress;
    // 重绘
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    // 设置颜色
    [self.currentColor set];
    rect.size.width *= self.progress;
    
    // 图形混合模式
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
}

- (UIColor *)currentColor {
    
    if (_currentColor == nil) {
        _currentColor = [UIColor greenColor];
    }
    return _currentColor;
}
@end
