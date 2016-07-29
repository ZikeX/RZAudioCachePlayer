//
//  RZPlayerRequestTask.h
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RZPlayerRequestTask;

@protocol RZPlayerRequestTaskDelegate <NSObject>
 @required
- (void)requestTaskDidUpdateCache:(RZPlayerRequestTask *)task;

 @optional
- (void)requestTaskDidReceiveResponse:(RZPlayerRequestTask *)task;
- (void)requestTask:(RZPlayerRequestTask *)task didFailWithError:(NSError *)error;
- (void)requestTask:(RZPlayerRequestTask *)task didFinishLoadingWithCache:(BOOL)cache;
@end

@interface RZPlayerRequestTask : NSObject
@property (nonatomic, weak) id<RZPlayerRequestTaskDelegate> delegate;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, assign) NSUInteger requestOffset;
@property (nonatomic, assign) NSUInteger fileLength;
@property (nonatomic, assign) NSUInteger cacheLength;
@property (nonatomic, assign) BOOL cache;
@property (nonatomic, assign) BOOL cancel;

- (void)start;
@end
