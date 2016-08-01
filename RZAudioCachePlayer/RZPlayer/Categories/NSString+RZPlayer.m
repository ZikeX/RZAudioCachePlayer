//
//  NSString+RZPlayer.m
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import "NSString+RZPlayer.h"

@implementation NSString (RZPlayer)
+ (NSString *)tempFilePath {
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"AudioTemp.mp4"];
}

+ (NSString *)cacheFolderPath {
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"AudioCaches"];
}

+ (NSString *)fileNameWithURL:(NSURL *)URL {
    return [[URL.path componentsSeparatedByString:@"/"] lastObject];
}
@end
