//
//  NSDateFormatter+shared.h
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (shared)

/** 对于重大开销对象最好使用单例管理 */
+ (instancetype)sharedDateFormatter;
@end
