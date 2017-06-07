//
//  UIViewController+LeftSlide.m
//  SimpleLeftSlideDemo
//
//  Created by mannyi on 2017/6/7.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "UIViewController+LeftSlide.h"

@implementation UIViewController (LeftSlide)

- (SimpleLeftSlideViewController *)leftSlideViewController
{
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController) {
        if ([parentViewController isKindOfClass:[SimpleLeftSlideViewController class]]) {
            return (SimpleLeftSlideViewController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}

- (CGRect)leftVisibleDrawerFrame
{
    if ([self isEqual:self.leftSlideViewController.leftViewController] ||
        [self.navigationController isEqual:self.leftSlideViewController.leftViewController]) {
        CGRect rect = self.leftSlideViewController.view.bounds;
        rect.size.width = self.leftSlideViewController.maximumLeftDrawerWidth;
        
        return rect;
    }
    
    return CGRectNull;
}

@end
