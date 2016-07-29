//
//  UIView+ZXAdjustFrame.h
//  ZXNetWorkDemo
//
//  Created by ZhongXing on 16/7/13.
//  Copyright © 2016  huzhiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ZXAdjustFrame)

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
//@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
//@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint origin;

@end
