//
//  RZFileHandle.m
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import "RZPlayerFileHandle.h"
#import "NSString+RZPlayer.h"
#import "RZPlayerConfiguration.h"

@interface RZPlayerFileHandle ()

@end

@implementation RZPlayerFileHandle

+ (BOOL)createTempFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString tempFilePath];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}

+ (void)writeTempFileData:(NSData *)data {
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[NSString tempFilePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
//    [handle closeFile];
}

+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:[NSString tempFilePath]];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (void)cacheTempFileWithFileName:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cacheFolderPath = [NSString cacheFolderPath];
    if (![manager fileExistsAtPath:cacheFolderPath]) {
        [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@", cacheFolderPath, name];
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:[NSString tempFilePath] toPath:cacheFilePath error:nil];
    NSLog(@"cache file: %@", success ? @"success" : @"fail");
    if ([self cacheCount] > RZPlayerMaxCacheCount) {
        [self clearCache];
    }
}

+ (NSString *)cacheFileExistsWithURL:(NSURL *)URL {
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:URL]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
}

+ (BOOL)clearCache {
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:[NSString cacheFolderPath] error:nil];
}

+ (NSInteger)cacheCount {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *dict = [manager attributesOfItemAtPath:[NSString cacheFolderPath] error:nil];
    return [dict[@"NSFileReferenceCount"] integerValue];
}

@end
