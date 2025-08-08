//
//  GGFunctionListViewController.m
//  GGGesturePasswordView
//
//  Created by Wgh on 08/08/2025.
//  Copyright (c) 2025 Wgh. All rights reserved.
//

#import "GGFunctionListViewController.h"
#import "GGBaseDemoViewController.h"
#import "GGSetPasswordViewController.h"
#import "GGVerifyPasswordViewController.h"
#import "GGCustomStyleViewController.h"
#import "GGShowGestureViewController.h"
#import "GGErrorStateViewController.h"

@interface GGFunctionListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *functionItems;

@end

@implementation GGFunctionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self setupFunctionItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏导航栏底部阴影
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

#pragma mark - 初始化设置
- (void)setupNavigationBar {
    self.title = @"手势密码功能演示";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置导航栏样式
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = [UIColor colorWithRed:0.1f green:0.5f blue:0.9f alpha:1.0f];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                           NSFontAttributeName: [UIFont boldSystemFontOfSize:18]};
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.1f green:0.5f blue:0.9f alpha:1.0f];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                       NSFontAttributeName: [UIFont boldSystemFontOfSize:18]};
    }
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)setUpUI {
    [self setupNavigationBar];
    
    [self setupTableView];
}

- (void)setupTableView {
    // 创建表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // 注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FunctionCell"];
    
    [self.view addSubview:self.tableView];
}

- (void)setupFunctionItems {
    // 功能列表数据
    self.functionItems = @[
        @{@"title": @"1. 设置手势密码", @"vcClass": @"GGSetPasswordViewController"},
        @{@"title": @"2. 验证手势密码", @"vcClass": @"GGVerifyPasswordViewController"},
        @{@"title": @"3. 自定义样式", @"vcClass": @"GGCustomStyleViewController"},
        @{@"title": @"4. 显示指定手势", @"vcClass": @"GGShowGestureViewController"},
        @{@"title": @"5. 错误状态演示", @"vcClass": @"GGErrorStateViewController"}
    ];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.functionItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FunctionCell" forIndexPath:indexPath];
    
    NSDictionary *item = self.functionItems[indexPath.row];
    cell.textLabel.text = item[@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = self.view.backgroundColor;
    
    // 设置单元格分隔线边距
    if (@available(iOS 11.0, *)) {
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = NO;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = self.functionItems[indexPath.row];
    NSString *vcClassName = item[@"vcClass"];
    
    // 反射获取视图控制器类
    Class vcClass = NSClassFromString(vcClassName);
    if (vcClass && [vcClass isSubclassOfClass:[GGBaseDemoViewController class]]) {
        GGBaseDemoViewController *vc = [[vcClass alloc] init];
        vc.title = item[@"title"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"GGGesturePasswordView 演示应用";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor grayColor];
    [label sizeToFit];
    label.center = footerView.center;
    [footerView addSubview:label];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40.0f;
}

@end
