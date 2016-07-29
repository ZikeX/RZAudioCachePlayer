//
//  UIImage+RZColorImage.h
//  FangJS
//
//  Created by Zrocky on 15/11/27.
//  Copyright (c) 2015年 FangJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RZColorImage)

/**
 *  通过色值和Rect生成图片
 */
+ (UIImage *)imageFromColor:(UIColor *)color rect:(CGRect)rect;

/**
 *  通过颜色生成图片
 */
+ (UIImage *)imageFromColor:(UIColor *)color;

@end
