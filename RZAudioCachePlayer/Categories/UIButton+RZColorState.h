//
//  UIButton+RZColorState.h
//  FangJS
//
//  Created by Zrocky on 15/12/23.
//  Copyright (c) 2015年 FangJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (RZColorState)

/**
*  设置不同状态下Button的背景色
*  !!! 不能设置同种状态下的背景图片, 不然会造成冲突 !!!
*
*  @param backgroundColor 背景色
*  @param state           Button状态
*/
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end
