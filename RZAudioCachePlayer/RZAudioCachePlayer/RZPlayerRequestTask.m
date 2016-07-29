//
//  RZPlayerRequestTask.m
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import "RZPlayerRequestTask.h"
#import "RZPlayerFileHandle.h"
#import "NSURL+RZPlayer.h"
#import "RZPlayerConfiguration.h"
#import "NSString+RZPlayer.h"

@interface RZPlayerRequestTask ()<NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionTask *task;
@end

@implementation RZPlayerRequestTask
#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        [RZPlayerFileHandle createTempFile];
    }
    return self;
}

#pragma mark - delegate
#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (self.cancel) return;
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *contentRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
    NSString *fileLength = [[contentRange componentsSeparatedByString:@"/"] lastObject];
    self.fileLength = fileLength.integerValue > 0 ? fileLength.integerValue : response.expectedContentLength;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidReceiveResponse:)]) {
        [self.delegate requestTaskDidReceiveResponse:self];
    }
}
// 数据返回, 可能会多次调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.cancel) return;
    [RZPlayerFileHandle writeTempFileData:data];
    self.cacheLength += data.length;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidUpdateCache:)]) {
        [self.delegate requestTaskDidUpdateCache:self];
    }
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.cancel) return;
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestTask:didFailWithError:)]) {
            [self.delegate requestTask:self didFailWithError:error];
        }
    }else {
        if (self.cache) {
            [RZPlayerFileHandle cacheTempFileWithFileName:[NSString fileNameWithURL:self.requestURL]];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestTask:didFinishLoadingWithCache:)]) {
            [self.delegate requestTask:self didFinishLoadingWithCache:self.cache];
        }
    }
}

#pragma mark - event response

#pragma mark - public methods
- (void)start {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.requestURL originalSchemeURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:RZPlayerRequstTimeout];
    if (self.requestOffset > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld", self.requestOffset, self.fileLength - 1] forHTTPHeaderField:@"Range"];
    }
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}
#pragma mark - private methods

#pragma mark - setter and getter
- (void)setCancel:(BOOL)cancel {
    _cancel = cancel;
    [self.task cancel];
    [self.session invalidateAndCancel];
}
@end
