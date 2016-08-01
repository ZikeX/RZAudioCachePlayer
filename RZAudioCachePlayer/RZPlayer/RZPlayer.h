//
//  RZPlayer.h
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RZPlayerState) {
    RZPlayerStateWaiting,
    RZPlayerStatePlaying,
    RZPlayerStatePaused,
    RZPlayerStateStopped,
    RZPlayerStateBuffering,
    RZPlayerStateError
};

/**
 *  暂时问题时网络重连后的播放问题
 */
@interface RZPlayer : NSObject
@property (nonatomic, assign) RZPlayerState state;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat cacheProgress;

- (instancetype)initWithURL:(NSURL *)URL;
- (void)replaceItemWithURL:(NSURL *)URL;
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(CGFloat)seconds;
// 当前歌曲缓存情况 YES:已缓存 NO:未缓存 (seek的都不会缓存)
- (BOOL)currentItemCacheState;
- (NSString *)currentItemCacheFilePath;
+ (BOOL)clearCache;
@end
