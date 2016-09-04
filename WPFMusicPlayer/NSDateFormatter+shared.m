//
//  NSDateFormatter+shared.m
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import "NSDateFormatter+shared.h"

@implementation NSDateFormatter (shared)

+ (instancetype)sharedDateFormatter {
    static NSDateFormatter *_dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[self alloc]  init];
    });
    return _dateFormatter;
}

@end
