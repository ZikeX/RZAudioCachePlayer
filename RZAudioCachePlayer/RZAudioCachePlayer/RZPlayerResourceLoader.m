//
//  RZPlayerResourceLoader.m
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import "RZPlayerResourceLoader.h"
#import "RZPlayerRequestTask.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "RZPlayerConfiguration.h"
#import "RZPlayerFileHandle.h"

@interface RZPlayerResourceLoader ()<RZPlayerRequestTaskDelegate>
@property (nonatomic, strong) NSMutableArray *requestList;
@property (nonatomic, strong) RZPlayerRequestTask *requestTask;
@end

@implementation RZPlayerResourceLoader

#pragma mark - life cycle

#pragma mark - delegate
#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self addLoadingRequest:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self removeLoadingRequest:loadingRequest];
}
#pragma mark - RZPlayerRequestTaskDelegate
- (void)requestTaskDidUpdateCache:(RZPlayerRequestTask *)task {
    [self processRequestList];
    if (self.delegate && [self.delegate respondsToSelector:@selector(loader:cacheProgress:)]) {
        CGFloat cacheProgress = (CGFloat)self.requestTask.cacheLength / (self.requestTask.fileLength - self.requestTask.requestOffset);
        [self.delegate loader:self cacheProgress:cacheProgress];
    }
}

- (void)requestTask:(RZPlayerRequestTask *)task didFinishLoadingWithCache:(BOOL)cache {
    self.cacheFinished = cache;
}

- (void)requestTask:(RZPlayerRequestTask *)task didFailWithError:(NSError *)error {
    // 加载数据出错
    // TODO:
}

#pragma mark - event response

#pragma mark - public methods
- (void)stopLoading {
    self.requestTask.cancel = YES;
}

#pragma mark - private methods
- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList addObject:loadingRequest];
    @synchronized (self) {
        if (self.requestTask) {
            if (loadingRequest.dataRequest.requestedOffset >= self.requestTask.requestOffset && loadingRequest.dataRequest.requestedOffset <= self.requestTask.requestOffset + self.requestTask.cacheLength) {
                // 数据已缓存, 直接完成
                [self processRequestList];
            }else {
                // 数据未缓存, 等待数据下载; 如果是Seek, 则重新请求
                if (self.seekRequired) {
                    [self newTaskWithLoadingRequest:loadingRequest cache:NO];
                }
            }
        }else {
            [self newTaskWithLoadingRequest:loadingRequest cache:YES];
        }
    }
}

- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList removeObject:loadingRequest];
}

- (void)newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest cache:(BOOL)cache {
    NSUInteger fileLength = 0;
    if (self.requestTask) {
        // 如果已经存在Task, 则退出当前Task, 新建Task
        fileLength = self.requestTask.fileLength;
        self.requestTask.cancel = YES;
    }
    self.requestTask = [[RZPlayerRequestTask alloc] init];
    self.requestTask.requestURL = loadingRequest.request.URL;
    self.requestTask.requestOffset = loadingRequest.dataRequest.requestedOffset;
    self.requestTask.cache = cache;
    if (fileLength > 0) {
        self.requestTask.fileLength = fileLength;
    }
    self.requestTask.delegate = self;
    [self.requestTask start];
    self.seekRequired = NO;
}

- (void)processRequestList {
    NSMutableArray *finishRequestList = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.requestList) {
        if ([self finishLoadingWithLadingRequest:loadingRequest]) {
            [finishRequestList addObject:loadingRequest];
        }
    }
    [self.requestList removeObjectsInArray:finishRequestList];
}

- (BOOL)finishLoadingWithLadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    // 填充信息
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(RZPlayerMimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentLength = self.requestTask.fileLength;
    // 读文件, 填充数据
    NSUInteger cacheLegth = self.requestTask.cacheLength;
    NSUInteger requestedOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestedOffset = loadingRequest.dataRequest.currentOffset;
    }
    NSUInteger canReadLength = cacheLegth - (requestedOffset - self.requestTask.requestOffset);
    NSUInteger respondLength = MIN(canReadLength, loadingRequest.dataRequest.requestedLength);
    
    [loadingRequest.dataRequest respondWithData:[RZPlayerFileHandle readTempFileDataWithOffset:requestedOffset - self.requestTask.requestOffset length:respondLength]];
    // 如果完全响应了所需要的数据, 则完成
    NSUInteger nowendOffset = requestedOffset + canReadLength;
    NSUInteger reqEndOffset = loadingRequest.dataRequest.requestedOffset + loadingRequest.dataRequest.requestedLength;
    if (nowendOffset >= reqEndOffset) {
        [loadingRequest finishLoading];
        return YES;
    }
    return NO;
}


#pragma mark - setter and getter
- (NSMutableArray *)requestList {
    if (!_requestList) {
        _requestList  = [NSMutableArray array];
    }
    return _requestList;
}
@end
