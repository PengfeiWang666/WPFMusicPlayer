//
//  WPFTimeTool.m
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import "WPFTimeTool.h"

@implementation WPFTimeTool
+ (NSString *)stringWithTime:(NSTimeInterval)time {
    
    int minute = time / 60;
    int second = (int)time % 60;
    return [NSString stringWithFormat:@"%02d:%02d",minute,second];
}
@end
