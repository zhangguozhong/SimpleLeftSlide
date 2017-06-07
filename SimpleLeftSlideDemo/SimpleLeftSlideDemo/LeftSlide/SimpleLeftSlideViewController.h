//
//  SimpleLeftSlideViewController.h
//  SimpleLeftSlideDemo
//
//  Created by mannyi on 2017/6/7.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, XPQDrawerSideStatus) {
    XPQDrawerSideStatusClosed = 0,
    XPQDrawerSideStatusOpen,
};

@interface SimpleLeftSlideViewController : UIViewController

@property (assign, nonatomic) CGFloat maximumLeftDrawerWidth;
@property (assign, nonatomic) CGFloat contentViewScaleValue;

@property (strong, nonatomic, readonly) UIViewController *leftViewController;
@property (strong, nonatomic, readonly) UIViewController *contentViewController;

- (instancetype)initWithLeftViewController:(UIViewController *)leftViewController contentViewController:(UIViewController *)contentViewController;

- (void)openLeftSlideView;
- (void)closeLeftSlideView;

- (void)setMaximumLeftDrawerWidth:(CGFloat)width animated:(BOOL)animated complete:(void (^)(BOOL finished))complete;

@end
