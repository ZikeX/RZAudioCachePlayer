//
//  UIColor+RGB.m
//  ZXNetWorkDemo
//
//  Created by ZhongXing on 16/7/13.
//  Copyright © 2016  huzhiyi. All rights reserved.
//

#import "UIColor+RGB.h"

@implementation UIColor (RGB)

+ (instancetype)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return [self colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}
+ (instancetype)alphaColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [self colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}
@end
