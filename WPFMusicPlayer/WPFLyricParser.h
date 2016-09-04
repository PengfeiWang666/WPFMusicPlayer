//
//  WPFLyricParser.h
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPFLyricParser : NSObject

+ (NSArray *)parserLyricWithFileName:(NSString *)fileName;

@end
