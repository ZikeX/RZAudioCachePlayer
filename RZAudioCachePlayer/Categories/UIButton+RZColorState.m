//
//  UIButton+RZColorState.m
//  FangJS
//
//  Created by Zrocky on 15/12/23.
//  Copyright (c) 2015年 FangJW. All rights reserved.
//

#import "UIButton+RZColorState.h"
#import "UIImage+RZColorImage.h"

@implementation UIButton (RZColorState)
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    [self setBackgroundImage:[UIImage imageFromColor:backgroundColor] forState:state];
}
@end
