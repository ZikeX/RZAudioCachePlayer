//
//  RZPlayerResourceLoader.h
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class RZPlayerResourceLoader;

@protocol RZPlayerResourceLoaderDelegate <NSObject>
 @required
- (void)loader:(RZPlayerResourceLoader *)loader cacheProgress:(CGFloat)progress;
 @optional
- (void)loader:(RZPlayerResourceLoader *)loader failLoadingWithError:(NSError *)error;
@end

@interface RZPlayerResourceLoader : NSObject<AVAssetResourceLoaderDelegate>
@property (nonatomic, weak) id<RZPlayerResourceLoaderDelegate> delegate;
@property (nonatomic, assign) BOOL seekRequired;
@property (nonatomic, assign) BOOL cacheFinished;

- (void)stopLoading;
@end
