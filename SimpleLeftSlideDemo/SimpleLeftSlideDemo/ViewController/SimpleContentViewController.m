//
//  SimpleContentViewController.m
//  SimpleLeftSlideDemo
//
//  Created by mannyi on 2017/6/7.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "SimpleContentViewController.h"
#import "UIViewController+LeftSlide.h"

@interface SimpleContentViewController ()

@end

@implementation SimpleContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"测试视图";
    self.view.backgroundColor = [UIColor greenColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    UIBarButtonItem *testbarButton = [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStylePlain target:self action:@selector(showMenuController)];
    self.navigationItem.leftBarButtonItem = testbarButton;
}

- (void)showMenuController
{
    [self.leftSlideViewController openLeftSlideView];
}

@end
