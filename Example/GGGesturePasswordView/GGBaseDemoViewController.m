#import "GGBaseDemoViewController.h"

@implementation GGBaseDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)setupUI {
    // 配置导航栏
    [self setupNavigationBar];
    
    // 创建标题标签
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    // 创建状态标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont systemFontOfSize:15];
    self.statusLabel.textColor = [UIColor grayColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    [self.view addSubview:self.statusLabel];
    
    // 创建手势密码视图
    self.gestureView.delegate = self;
    self.gestureView.normalLineColor = [UIColor colorWithRed:0.2f green:0.6f blue:1.0f alpha:1.0f];
    self.gestureView.failedLineColor = [UIColor redColor];
    self.gestureView.lineWidth = 2.0f;
    [self.view addSubview:self.gestureView];
    
    // 创建重置按钮
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.resetButton setTitle:@"重置" forState:UIControlStateNormal];
    self.resetButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.resetButton addTarget:self action:@selector(resetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.resetButton setBackgroundColor:[UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f]];
    self.resetButton.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.resetButton];
    
    // 布局约束
    [self setupConstraints];
}

- (void)setupNavigationBar {
    // 隐藏导航栏底部阴影
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)setupConstraints {
    // 禁用 autoresizing
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.gestureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 标题标签约束
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
    
    // 状态标签约束
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:15],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-30]
    ]];
    
    // 手势视图约束 (宽高比 1:1)
    [NSLayoutConstraint activateConstraints:@[
        [self.gestureView.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:20],
        [self.gestureView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.gestureView.widthAnchor constraintEqualToAnchor:self.gestureView.heightAnchor],
        [self.gestureView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.8]
    ]];
    
    // 重置按钮约束
    [NSLayoutConstraint activateConstraints:@[
        [self.resetButton.topAnchor constraintEqualToAnchor:self.gestureView.bottomAnchor constant:30],
        [self.resetButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.resetButton.widthAnchor constraintEqualToConstant:100],
        [self.resetButton.heightAnchor constraintEqualToConstant:40]
    ]];
}

- (void)updateStatusText:(NSString *)text {
    [self updateStatusText:text withColor:[UIColor grayColor]];
}

- (void)updateStatusText:(NSString *)text withColor:(UIColor *)color {
    self.statusLabel.text = text;
    self.statusLabel.textColor = color;
}

- (void)resetButtonTapped:(UIButton *)sender {
    [self.gestureView clearPassword];
    [self updateStatusText:@"请绘制手势密码"];
}

#pragma mark - GGGesturePasswordViewDelegate
- (void)gesturePasswordView:(GGGesturePasswordView *)gesturePasswordView withPassword:(NSString *)password {
    // 子类实现具体逻辑
}

#pragma mark ------------------------- set / get -------------------------
- (GGGesturePasswordView *)gestureView {
    if (!_gestureView) {
        _gestureView = [[GGGesturePasswordView alloc] init];
    }
    
    return _gestureView;
}

@end
    
