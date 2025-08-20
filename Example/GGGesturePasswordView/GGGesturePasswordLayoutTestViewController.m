#import "GGGesturePasswordLayoutTestViewController.h"
#import <GGGesturePasswordView.h>
#import <Masonry.h>

@interface GGGesturePasswordLayoutTestViewController ()
@property (nonatomic, strong) GGGesturePasswordView *gestureView;
@property (nonatomic, strong) UILabel *statusLabel; // 用于显示测试状态
@end

@implementation GGGesturePasswordLayoutTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"自动布局后显示密码测试";
    
    [self setupStatusLabel];
    [self setupGestureView];
    [self setupTestButtons];
}

#pragma mark - 核心测试视图搭建
- (void)setupGestureView {
    // 初始化手势视图（不设置frame，完全依赖Masonry布局）
    self.gestureView = [[GGGesturePasswordView alloc] init];
    self.gestureView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.gestureView.padding = UIEdgeInsetsMake(15, 15, 15, 15);
    [self.view addSubview:self.gestureView];
    
    // 关键：使用Masonry布局（模拟真实项目中的动态布局场景）
    [self.gestureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.statusLabel.mas_bottom).offset(30);
//        make.width.equalTo(self.view).multipliedBy(0.8); // 宽度为屏幕80%（动态变化）
        make.width.mas_equalTo(120.f);
        make.height.equalTo(self.gestureView.mas_width); // 正方形
    }];
    
    // 立即调用显示密码
    [self testImmediateShow];
}

#pragma mark - 测试按钮（触发不同时机的显示密码操作）
- (void)setupTestButtons {
    // 1. 布局后立即调用显示密码（测试核心优化点：无需手动layoutIfNeeded）
    UIButton *testImmediateBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [testImmediateBtn setTitle:@"布局后立即显示密码(默认)" forState:UIControlStateNormal];
    [testImmediateBtn addTarget:self action:@selector(testImmediateShow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testImmediateBtn];
    
    // 2. 延迟1秒调用（模拟异步场景，如网络请求后显示）
    UIButton *testDelayBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [testDelayBtn setTitle:@"延迟1秒显示密码" forState:UIControlStateNormal];
    [testDelayBtn addTarget:self action:@selector(testDelayShow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testDelayBtn];
    
    // 3. 旋转屏幕后显示（测试布局变化后是否正常）
    UIButton *testRotateBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [testRotateBtn setTitle:@"旋转屏幕后显示" forState:UIControlStateNormal];
    [testRotateBtn addTarget:self action:@selector(testRotateShow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testRotateBtn];
    
    // 4. 清除密码
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearBtn setTitle:@"清除密码" forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearBtn];
    
    // 按钮布局
    [testImmediateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gestureView.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
    }];
    
    [testDelayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(testImmediateBtn.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    [testRotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(testDelayBtn.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(testRotateBtn.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark - 状态提示标签
- (void)setupStatusLabel {
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.textColor = [UIColor darkGrayColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.text = @"测试说明：\n1. 点击按钮触发显示密码\n2. 若密码正常显示则优化生效\n3. 无需手动调用layoutIfNeeded";
    [self.view addSubview:self.statusLabel];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        make.left.right.equalTo(self.view).inset(20);
    }];
}

#pragma mark - 测试方法
// 测试1：布局后立即调用（核心场景）
- (void)testImmediateShow {
    // 关键：直接调用显示密码，不手动调用layoutIfNeeded
    [self.gestureView showGestureWithPassword:@"12369"];
    self.statusLabel.text = @"已调用showGestureWithPassword:\n未手动调用layoutIfNeeded\n若显示1-2-3-6-9则成功";
}

// 测试2：延迟调用（模拟异步场景）
- (void)testDelayShow {
    self.statusLabel.text = @"1秒后将显示密码...";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.gestureView showGestureWithPassword:@"14789"];
        self.statusLabel.text = @"延迟1秒调用后：\n若显示1-4-7-8-9则成功";
    });
}

// 测试3：旋转屏幕后调用（布局变化场景）
- (void)testRotateShow {
    self.statusLabel.text = @"请旋转屏幕后查看效果...";
    // 延迟执行，等待用户旋转屏幕
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.gestureView showGestureWithPassword:@"3579"];
        self.statusLabel.text = @"旋转后调用：\n若显示3-5-7-9则成功";
    });
}

// 清除密码
- (void)clearPassword {
    [self.gestureView clearPassword];
    self.statusLabel.text = @"已清除密码\n可重新测试";
}

@end
