//
//  SimpleLeftSlideViewController.m
//  SimpleLeftSlideDemo
//
//  Created by mannyi on 2017/6/7.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "SimpleLeftSlideViewController.h"
#import "UIViewController+LeftSlide.h"


//@interface XPQDrawerContainerView : UIView
//
//@property (assign, nonatomic) XPQDrawerSide openSlide;
//
//@end
//
//
//@implementation XPQDrawerContainerView
//
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView *hitView = [super hitTest:point withEvent:event];
//    if (hitView && self.openSlide != XPQDrawerSideNone) {
//        UINavigationBar *navBar = [self navigationBarContainedWithinSubviewsOfView:self];
//        CGRect navBarFrame = [navBar convertRect:navBar.bounds toView:self];
//        if (CGRectContainsPoint(navBarFrame, point) == NO) {
//            hitView = nil;
//        }
//    }
//    return hitView;
//}
//
//- (UINavigationBar *)navigationBarContainedWithinSubviewsOfView:(UIView *)view
//{
//    UINavigationBar *navBar = nil;
//    for (UIView * subview in [view subviews]) {
//        if ([view isKindOfClass:[UINavigationBar class]]) {
//            navBar = (UINavigationBar *)view;
//            break;
//        } else {
//            navBar = [self navigationBarContainedWithinSubviewsOfView:subview];
//            if (navBar) {
//                break;
//            }
//        }
//    }
//    return navBar;
//}
//
//@end


NSTimeInterval const XPQDrawerMinimumAnimationDuration = 0.15f;
CGFloat const XPQDrawerDefaultWidth = 150.0f;

CGFloat const XPQDrawerDefaultAnimationVelocity = 840.0f;
CGFloat const XPQDrawerPanVelocityXAnimationThreshold = 200.0f;


@interface SimpleLeftSlideViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic, readwrite) UIViewController *leftViewController;
@property (strong, nonatomic, readwrite) UIViewController *contentViewController;

@property (nonatomic, strong) UIView *childControllerContainerView;
@property (strong, nonatomic) UIView *containerView;

@property (assign, nonatomic) CGRect startPanRect;
@property (assign, nonatomic) CGFloat animatedDuration;
@property (assign, nonatomic, readonly) BOOL scaleContainView;//是否开启缩放效果

@property (assign, nonatomic) XPQDrawerSideStatus slideStatus;//抽屉效果打开状态
@property (strong, nonatomic) UIButton *contentButton;
@property (assign, nonatomic) CGFloat panVelocityXAnimationThreshold;
@property (assign, nonatomic) CGFloat animationVelocity;

@end

@implementation SimpleLeftSlideViewController

- (instancetype)initWithLeftViewController:(UIViewController *)leftViewController contentViewController:(UIViewController *)contentViewController {
    self = [super init];
    if (self) {
        self.animatedDuration = XPQDrawerMinimumAnimationDuration;
        self.maximumLeftDrawerWidth = XPQDrawerDefaultWidth;
        self.panVelocityXAnimationThreshold = XPQDrawerPanVelocityXAnimationThreshold;
        self.animationVelocity = XPQDrawerDefaultAnimationVelocity;
        
        [self setLeftViewController:leftViewController];
        [self setContentViewController:contentViewController];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addGestureContainView];
    self.contentButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectNull];
        [button addTarget:self action:@selector(closeLeftSlideView) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
}

- (void)setLeftViewController:(UIViewController *)leftViewController {
    if (leftViewController) {
        _leftViewController = leftViewController;
        [self addChildViewController:leftViewController];
        leftViewController.view.frame = leftViewController.leftVisibleDrawerFrame;
        [self.childControllerContainerView addSubview:leftViewController.view];
        [self.childControllerContainerView sendSubviewToBack:leftViewController.view];
    }
}

- (void)setContentViewController:(UIViewController *)contentViewController {
    if (contentViewController) {
        _contentViewController = contentViewController;
        [self addChildViewController:_contentViewController];
        [self.containerView addSubview:contentViewController.view];
        [self.childControllerContainerView bringSubviewToFront:self.containerView];
    }
}

// 添加拖动手势
- (void)addGestureContainView
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
}

// 这个响应手势的回调是个关键的地方，涉及拖动距离的计算方法，即手势开始时的containerView的origin.x加上手势拖动的位移translationOffsetX（向左拖动值为负数，向右拖动值为正数），滑动的最大位移maximumLeftDrawerWidth可重新制定；手势结束后，通过判断containerView的origin.x是否大于等于maximumLeftDrawerWidth的一半或者是x轴方向的速度是否大于panVelocityXAnimationThreshold，决定open或close。
- (void)handlePanGestureAction:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan: {
            self.startPanRect = self.containerView.frame;//手势开始时的初始frame
            break;
        }
        case UIGestureRecognizerStateChanged: {
            self.view.userInteractionEnabled = NO;
            CGRect newFrame = self.startPanRect;
            CGFloat translationOffsetX = [gesture translationInView:gesture.view].x;
            newFrame.origin.x = [self roundedOriginXForDrawerConstriants:CGRectGetMinX(self.startPanRect) + translationOffsetX];//计算滑动距离
            newFrame = CGRectIntegral(newFrame);
            
            CGFloat offsetX = newFrame.origin.x;
            self.containerView.transform = CGAffineTransformMakeTranslation(offsetX, 0);
            
            if (self.scaleContainView) {
                CGFloat scale = 1 - (1 - self.contentViewScaleValue) * (offsetX / self.maximumLeftDrawerWidth);
                self.containerView.transform = CGAffineTransformScale(self.containerView.transform, scale, scale);
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.startPanRect = CGRectNull;
            CGPoint velocity = [gesture velocityInView:gesture.view];
            [self finishAnimationForPanGestureWithXVelocity:velocity.x];
            self.view.userInteractionEnabled = YES;
            break;
        }
        default:
            break;
    }
}

- (CGFloat)roundedOriginXForDrawerConstriants:(CGFloat)originX
{
    return MIN(MAX(originX, 0), self.maximumLeftDrawerWidth);
}

- (BOOL)scaleContainView
{
    return self.contentViewScaleValue > 0;
}

// 打开抽屉后，在containerView上添加的button，点击按钮执行closeLeftSlideView方法关闭效果。
- (void)addContentButton
{
    if (self.contentButton.superview) {
        return;
    }
    
    self.contentButton.frame = self.containerView.bounds;
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView addSubview:self.contentButton];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self.contentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
        if (navigationController.viewControllers.count > 1 && navigationController.interactivePopGestureRecognizer.enabled) {
            return NO;
        }
    }
    
    return YES;
}

// 打开抽屉
- (void)openLeftSlideView
{
    [self openLeftSlideViewWithVelocity:self.animationVelocity animated:YES complete:^(BOOL finished) {
        self.slideStatus = XPQDrawerSideStatusOpen;
        [self addContentButton];
    }];
}

- (void)openLeftSlideViewWithVelocity:(CGFloat)velocity animated:(BOOL)animated complete:(void (^)(BOOL finished))complete
{
    CGRect newFrame;
    CGRect oldFrame = self.containerView.frame;
    newFrame = self.containerView.frame;
    newFrame.origin.x = self.maximumLeftDrawerWidth;
    
    CGFloat distance = ABS(CGRectGetMinX(oldFrame) - newFrame.origin.x);
    NSTimeInterval duration = MAX(distance/ABS(velocity), XPQDrawerMinimumAnimationDuration);
    
    [UIView animateWithDuration:animated ? duration : 0.f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.maximumLeftDrawerWidth, 0);
        if (self.scaleContainView) {
            self.containerView.transform = CGAffineTransformScale(self.containerView.transform, self.contentViewScaleValue, self.contentViewScaleValue);
        }
    } completion:^(BOOL finished) {
        if (complete) {
            complete(finished);
        }
    }];
}

// 关闭抽屉
- (void)closeLeftSlideView
{
    [self closeLeftSlideViewWithVelocity:self.animationVelocity animated:YES complete:^(BOOL finished) {
        self.slideStatus = XPQDrawerSideStatusClosed;
        [self.contentButton removeFromSuperview];
    }];
}

- (void)closeLeftSlideViewWithVelocity:(CGFloat)velocity animated:(BOOL)animated complete:(void (^)(BOOL finished))complete
{
    CGFloat distance = CGRectGetMinX(self.containerView.frame);
    NSTimeInterval duration = MAX(distance/ABS(velocity), XPQDrawerMinimumAnimationDuration);
    
    [UIView animateWithDuration:animated ? duration : 0.f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (complete) {
            complete(finished);
        }
    }];
}

// 手势结束状态判断
- (void)finishAnimationForPanGestureWithXVelocity:(CGFloat)xVelocity
{
    CGFloat midOffsetX = self.maximumLeftDrawerWidth / 2;
    CGFloat animationVelocity = MAX(ABS(xVelocity), self.panVelocityXAnimationThreshold * 2);
    CGFloat currentOffsetX = CGRectGetMinX(self.containerView.frame);
    
    if (xVelocity > self.panVelocityXAnimationThreshold) {
        [self openLeftSlideViewWithVelocity:animationVelocity animated:YES complete:^(BOOL finished) {
            self.slideStatus = XPQDrawerSideStatusOpen;
            [self addContentButton];
        }];
    }
    else if (xVelocity < -self.panVelocityXAnimationThreshold) {
        [self closeLeftSlideViewWithVelocity:animationVelocity animated:YES complete:^(BOOL finished) {
            self.slideStatus = XPQDrawerSideStatusClosed;
            [self.contentButton removeFromSuperview];
        }];
    }
    else if (currentOffsetX < midOffsetX) {
        [self closeLeftSlideView];
    }
    else {
        [self openLeftSlideView];
    }
}

- (NSTimeInterval)animationDurationForAnimationDistance:(CGFloat)distance
{
    return MAX((distance/self.animationVelocity), XPQDrawerMinimumAnimationDuration);
}


- (void)setMaximumLeftDrawerWidth:(CGFloat)width animated:(BOOL)animated complete:(void (^)(BOOL))complete {
    NSParameterAssert(width > 0);
    
    if (self.slideStatus == XPQDrawerSideStatusOpen) {
        CGFloat originalWidth = _maximumLeftDrawerWidth;
        _maximumLeftDrawerWidth = width;
        
        CGFloat distance = width - originalWidth;
        CGFloat duration = [self animationDurationForAnimationDistance:ABS(distance)];
        UIViewController *slideViewController = self.leftViewController;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.containerView.transform = CGAffineTransformTranslate(self.containerView.transform, distance, 0);
            slideViewController.view.frame = slideViewController.leftVisibleDrawerFrame;
        } completion:^(BOOL finished) {
            if (complete) {
                complete(finished);
            }
        }];
    }
}


- (UIView *)childControllerContainerView {
    if (!_childControllerContainerView) {
        CGRect childContainerViewFrame = self.view.bounds;
        _childControllerContainerView = [[UIView alloc] initWithFrame:childContainerViewFrame];
        _childControllerContainerView.backgroundColor = [UIColor clearColor];
        _childControllerContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_childControllerContainerView];
    }
    return _childControllerContainerView;
}

- (UIView *)containerView {
    if (!_containerView) {
        CGRect contentFrame = self.childControllerContainerView.bounds;
        _containerView = [[UIView alloc] initWithFrame:contentFrame];
        _containerView.backgroundColor = [UIColor clearColor];
        [self.childControllerContainerView addSubview:_containerView];
    }
    return _containerView;
}

@end
