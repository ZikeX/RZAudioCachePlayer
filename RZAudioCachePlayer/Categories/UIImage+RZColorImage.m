//
//  UIImage+RZColorImage.m
//  FangJS
//
//  Created by Zrocky on 15/11/27.
//  Copyright (c) 2015年 FangJW. All rights reserved.
//

#import "UIImage+RZColorImage.h"

@implementation UIImage (RZColorImage)

+ (UIImage *)imageFromColor:(UIColor *)color rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)imageFromColor:(UIColor *)color
{
    return [self imageFromColor:color rect:CGRectMake(0, 0, 1, 1)];
}

@end
