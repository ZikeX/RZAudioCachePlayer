//
//  RZFileHandle.h
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZPlayerFileHandle : NSObject
+ (BOOL)createTempFile;
+ (void)writeTempFileData:(NSData *)data;
+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length;
+ (void)cacheTempFileWithFileName:(NSString *)name;
/**
 *  是否存在缓存文件 存在: 返回文件路径 不存在: 返回nil
 */
+ (NSString *)cacheFileExistsWithURL:(NSURL *)URL;
+ (BOOL)clearCache;
@end
