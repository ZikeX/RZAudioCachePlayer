//
//  RZPlayer.m
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import "RZPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "RZPlayerFileHandle.h"
#import "RZPlayerResourceLoader.h"
#import "NSURL+RZPlayer.h"
#import "NSString+RZPlayer.h"

@interface RZPlayer ()<RZPlayerResourceLoaderDelegate>
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) RZPlayerResourceLoader *resourceLoader;
@end

@implementation RZPlayer

#pragma mark - delegate
#pragma mark - RZPlayerResourceLoaderDelegate
- (void)loader:(RZPlayerResourceLoader *)loader cacheProgress:(CGFloat)progress {
    self.cacheProgress = progress;
}

#pragma mark - event response
- (void)playbackFinished {
    [self stop];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        self.state = self.player.rate == 0.0 ? RZPlayerStatePaused : RZPlayerStatePlaying;
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        AVPlayerItem *playerItem = object;
        NSArray * array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        if (self.duration > 0.0) {
            self.cacheProgress = totalBuffer / self.duration;
        }
    }
}

#pragma mark - public methods
- (instancetype)initWithURL:(NSURL *)URL {
    if (self == [super init]) {
        self.URL = URL;
        [self reloadCurrentItem];
    }
    return self;
}

- (void)replaceItemWithURL:(NSURL *)URL {
    self.URL = URL;
    [self reloadCurrentItem];
    
}

- (void)play {
    if (self.state == RZPlayerStatePaused || self.state == RZPlayerStateWaiting) {
        [self.player play];
    }
}

- (void)pause {
    if (self.state == RZPlayerStatePlaying) {
        [self.player pause];
    }
}

- (void)stop {
    if (self.state != RZPlayerStateStopped) {
        [self.player pause];
        [self removeObserver];
        if (self.player) {
            [self.player replaceCurrentItemWithPlayerItem:nil];
        }
        self.currentItem = nil;
        self.player = nil;
        self.progress = 0.0;
        self.duration = 0.0;
        self.cacheProgress = 0.0;
        self.state = RZPlayerStateStopped;
    }
}

- (void)seekToTime:(CGFloat)seconds {
    if (self.state == RZPlayerStatePlaying || self.state == RZPlayerStatePaused) {
        [self.player pause];
        self.resourceLoader.seekRequired = YES;
        [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
            [self.player play];
        }];
    }
}

- (BOOL)currentItemCacheState {
    if ([self.URL.absoluteString hasPrefix:@"http"]) {
        if (self.resourceLoader) {
            return self.resourceLoader.cacheFinished;
        }
        return YES;
    }
    return NO;
}

- (NSString *)currentItemCacheFilePath {
    if (![self currentItemCacheState]) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:self.URL]];
}

+ (BOOL)clearCache {
    [RZPlayerFileHandle clearCache];
    return YES;
}

#pragma mark - private methods
- (void)reloadCurrentItem {
    if ([self.URL.absoluteString hasPrefix:@"http"]) {
        // online
        NSString *cacheFilePath = [RZPlayerFileHandle cacheFileExistsWithURL:self.URL];
        if (cacheFilePath.length > 0) {
            // cached
            NSURL *URL = [NSURL fileURLWithPath:cacheFilePath];
            self.currentItem = [AVPlayerItem playerItemWithURL:URL];
        }else {
            // no cached
            self.resourceLoader = [[RZPlayerResourceLoader alloc] init];
            self.resourceLoader.delegate = self;
            
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self.URL customSchemeURL] options:nil];
            [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
            self.currentItem = [AVPlayerItem playerItemWithAsset:asset];
        }
    }else {
        // local
        self.currentItem = [AVPlayerItem playerItemWithURL:self.URL];
    }
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.currentItem];
    [self addObserver];
    self.state = RZPlayerStateWaiting;
}

- (void)addObserver {
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat current = CMTimeGetSeconds(time);
        CGFloat total = CMTimeGetSeconds(weakSelf.currentItem.duration);
        weakSelf.duration = total;
        weakSelf.progress = current / total;
    }];
}

- (void)removeObserver {
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}
#pragma mark - setter and getter
- (void)setProgress:(CGFloat)progress {
    [self willChangeValueForKey:@"progress"];
    _progress = progress;
    [self didChangeValueForKey:@"progress"];
}

- (void)setState:(RZPlayerState)state {
    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
}

- (void)setCacheProgress:(CGFloat)cacheProgress {
    [self willChangeValueForKey:@"cacheProgress"];
    _cacheProgress = cacheProgress;
    [self didChangeValueForKey:@"cacheProgress"];
}

- (void)setDuration:(CGFloat)duration {
    if (duration != _duration && !isnan(duration)) {
        [self willChangeValueForKey:@"duration"];
        _duration = duration;
        [self didChangeValueForKey:@"duration"];
    }
}
@end
