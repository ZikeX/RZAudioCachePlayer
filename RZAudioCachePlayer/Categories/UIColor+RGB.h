//
//  UIColor+RGB.h
//  ZXNetWorkDemo
//
//  Created by ZhongXing on 16/7/13.
//  Copyright © 2016  huzhiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) green:((float)((rgbValue & 0xFF00) >> 8)) blue:((float)(rgbValue & 0xFF))]

#define RGBA(rgbValue,a) [UIColor alphaColorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) green:((float)((rgbValue & 0xFF00) >> 8)) blue:((float)(rgbValue & 0xFF)) alpha:a]

@interface UIColor (RGB)

+ (instancetype)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (instancetype)alphaColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
@end
