//
//  NSURL+RZPlayer.h
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (RZPlayer)
- (NSURL *)customSchemeURL;
- (NSURL *)originalSchemeURL;
@end
