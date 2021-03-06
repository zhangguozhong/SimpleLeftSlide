//
//  SimpleLeftViewController.m
//  SimpleLeftSlideDemo
//
//  Created by mannyi on 2017/6/7.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "SimpleLeftViewController.h"
#import "UIViewController+LeftSlide.h"
#import "ViewController.h"

@interface SimpleLeftViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation SimpleLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [@[@"150",@"180",@"200"] objectAtIndex:indexPath.row];
    return cell;
}

// 点击跳转新的视图
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    __weak typeof(self) weakSelf = self;
//    [self.leftSlideViewController setMaximumLeftDrawerWidth:[cell.textLabel.text doubleValue] animated:YES complete:^(BOOL finish) {
//        if (finish) {
//            NSLog(@"%f", weakSelf.leftSlideViewController.maximumLeftDrawerWidth);
//        }
//    }];
    
    
    UINavigationController *navigationController = (UINavigationController *)self.leftSlideViewController.contentViewController;
    ViewController *VC = [[ViewController alloc] init];
    [navigationController pushViewController:VC animated:NO];
    [self.leftSlideViewController closeLeftSlideView];
}


- (UITableView *)tableView
{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.bounces = NO;
        tableView.rowHeight = 44.f;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView = tableView;
    }
    return _tableView;
}

@end
