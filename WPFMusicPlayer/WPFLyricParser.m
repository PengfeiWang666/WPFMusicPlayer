//
//  WPFLyricParser.m
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import "WPFLyricParser.h"
#import "NSDateFormatter+shared.h"
#import "WPFLyric.h"

@implementation WPFLyricParser

+ (NSArray *)parserLyricWithFileName:(NSString *)fileName {
    
    // 根据文件名称获取文件地址
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    // 根据文件地址获取转化后的总体的字符串
    NSString *lyricStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    // 将歌词总体字符串按行拆分开，每句都作为一个数组元素存放到数组中
    NSArray *lineStrs = [lyricStr componentsSeparatedByString:@"\n"];
    
    // 设置歌词时间正则表达式格式
    NSString *pattern = @"\\[[0-9]{2}:[0-9]{2}.[0-9]{2}\\]";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    
    // 创建可变数组存放歌词模型
    NSMutableArray *lyrics = [NSMutableArray array];
    
    // 遍历歌词字符串数组
    for (NSString *lineStr in lineStrs) {
        
        NSArray *results = [reg matchesInString:lineStr options:0 range:NSMakeRange(0, lineStr.length)];
        
        // 歌词内容
        NSTextCheckingResult *lastResult = [results lastObject];
        NSString *content = [lineStr substringFromIndex:lastResult.range.location + lastResult.range.length];
        
        // 每一个结果的range
        for (NSTextCheckingResult *result in results) {
            
            NSString *time = [lineStr substringWithRange:result.range];

            #warning 对于 NSDateFormatter 类似的重大开小对象，最好使用单例管理
            NSDateFormatter *formatter = [NSDateFormatter sharedDateFormatter];
            formatter.dateFormat = @"[mm:ss.SS]";
            NSDate *timeDate = [formatter dateFromString:time];
            NSDate *initDate = [formatter dateFromString:@"[00:00.00]"];
            
            // 创建模型
            WPFLyric *lyric = [[WPFLyric alloc] init];
            lyric.content = content;
            // 歌词的开始时间
            lyric.time = [timeDate timeIntervalSinceDate:initDate];
            
            // 将歌词对象添加到模型数组汇总
            [lyrics addObject:lyric];
        }
    }
    
    // 按照时间正序排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    [lyrics sortUsingDescriptors:@[sortDes]];
   
    return lyrics;
}

@end
