//
//  UIViewController+LeftSlide.h
//  SimpleLeftSlideDemo
//
//  Created by mannyi on 2017/6/7.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleLeftSlideViewController.h"

@interface UIViewController (LeftSlide)

@property (strong, readonly, nonatomic) SimpleLeftSlideViewController *leftSlideViewController;
@property (assign, readonly, nonatomic) CGRect leftVisibleDrawerFrame;

@end
