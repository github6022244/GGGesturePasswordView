#import "GGErrorStateViewController.h"

@interface GGErrorStateViewController ()

@property (nonatomic, strong) UIStackView *buttonStackView;
@property (nonatomic, strong) UIButton *showErrorButton;
@property (nonatomic, strong) UIButton *showErrorWithResetButton;
@property (nonatomic, strong) UIButton *showErrorWithCustomDelayButton;

@end

@implementation GGErrorStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAdditionalUI];
    [self updateStatusText:@"请尝试各种错误状态演示"];
    
    // 设置最大连接点数量为6
    self.gestureView.maxNodeCount = 6;
}

#pragma mark - 布局设置
- (void)setupAdditionalUI {
    // 禁用父类的重置按钮，使用自定义按钮
    self.resetButton.hidden = YES;
    
    // 创建演示按钮
    [self createButtons];
    
    // 创建按钮容器栈视图
    self.buttonStackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.showErrorButton,
        self.showErrorWithResetButton,
        self.showErrorWithCustomDelayButton
    ]];
    self.buttonStackView.axis = UILayoutConstraintAxisHorizontal;
    self.buttonStackView.alignment = UIStackViewAlignmentCenter;
    self.buttonStackView.distribution = UIStackViewDistributionFillEqually;
    self.buttonStackView.spacing = 12;
    self.buttonStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 添加到父类的内容视图中（假设父类有contentView属性）
    [self.view addSubview:self.buttonStackView];
    
    // 添加约束
    [self layoutUI];
}

- (void)createButtons {
    // 显示错误状态按钮
    self.showErrorButton = [self createDemoButtonWithTitle:@"显示错误状态"];
    [self.showErrorButton addTarget:self action:@selector(showErrorState:) forControlEvents:UIControlEventTouchUpInside];
    
    // 显示错误并自动重置按钮
    self.showErrorWithResetButton = [self createDemoButtonWithTitle:@"错误+自动重置"];
    [self.showErrorWithResetButton addTarget:self action:@selector(showErrorAndAutoReset:) forControlEvents:UIControlEventTouchUpInside];
    
    // 自定义延迟的错误状态按钮
    self.showErrorWithCustomDelayButton = [self createDemoButtonWithTitle:@"自定义延迟重置"];
    [self.showErrorWithCustomDelayButton addTarget:self action:@selector(showErrorWithCustomDelay:) forControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)createDemoButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.backgroundColor = [UIColor colorWithRed:0.1f green:0.5f blue:0.9f alpha:1.0f];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 6;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button sizeToFit];
    return button;
}

- (void)layoutUI {
    // 获取父类中的关键视图引用
    UIView *statusLabel = self.statusLabel;  // 状态标签
    UIView *gestureView = self.gestureView;  // 手势视图
    
    // 按钮栈视图约束：放在手势视图下方
    [NSLayoutConstraint activateConstraints:@[
        [self.buttonStackView.topAnchor constraintEqualToAnchor:gestureView.bottomAnchor constant:20],
        [self.buttonStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.buttonStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.buttonStackView.heightAnchor constraintEqualToConstant:44]
    ]];
    
    // 确保每个按钮有足够的宽度
    [self.showErrorButton.widthAnchor constraintGreaterThanOrEqualToConstant:100].active = YES;
    [self.showErrorWithResetButton.widthAnchor constraintGreaterThanOrEqualToConstant:100].active = YES;
    [self.showErrorWithCustomDelayButton.widthAnchor constraintGreaterThanOrEqualToConstant:100].active = YES;
    
    // 调整重置按钮位置（如果父类有重置按钮）
    if (self.resetButton) {
        [NSLayoutConstraint activateConstraints:@[
            [self.resetButton.topAnchor constraintEqualToAnchor:self.buttonStackView.bottomAnchor constant:16],
            [self.resetButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [self.resetButton.widthAnchor constraintGreaterThanOrEqualToConstant:120],
            [self.resetButton.heightAnchor constraintEqualToConstant:44]
        ]];
    }
}

#pragma mark - 按钮点击事件
- (IBAction)showErrorState:(UIButton *)sender {
    if ([self.gestureView currentPassword].length == 0) {
        [self updateStatusText:@"请先绘制一个手势" withColor:[UIColor orangeColor]];
        return;
    }
    
    [self.gestureView showWrongPasswordUI];
    [self updateStatusText:@"错误状态展示（不会自动重置）" withColor:self.gestureView.failedLineColor];
}

- (IBAction)showErrorAndAutoReset:(UIButton *)sender {
    if ([self.gestureView currentPassword].length == 0) {
        [self updateStatusText:@"请先绘制一个手势" withColor:[UIColor orangeColor]];
        return;
    }
    
    [self.gestureView showWrongPasswordUIAndAutoResetUIWithEndBlock:^{
        [self updateStatusText:@"错误状态已自动重置" withColor:[UIColor greenColor]];
    }];
    [self updateStatusText:@"错误状态展示（将自动重置）" withColor:self.gestureView.failedLineColor];
}

- (IBAction)showErrorWithCustomDelay:(UIButton *)sender {
    if ([self.gestureView currentPassword].length == 0) {
        [self updateStatusText:@"请先绘制一个手势" withColor:[UIColor orangeColor]];
        return;
    }
    
    CGFloat delay = 2.0; // 2秒延迟
    [self.gestureView showWrongPasswordUIAndResetUIAfterSeconds:delay endBlock:^{
        [self updateStatusText:@"自定义延迟的错误状态已重置" withColor:[UIColor greenColor]];
    }];
    [self updateStatusText:[NSString stringWithFormat:@"错误状态展示（%0.1f秒后重置）", delay] withColor:self.gestureView.failedLineColor];
}

#pragma mark - 手势密码代理方法
- (void)gesturePasswordView:(GGGesturePasswordView *)gesturePasswordView withPassword:(NSString *)password {
    [self updateStatusText:[NSString stringWithFormat:@"已输入手势: %@", password]];
}

#pragma mark - 父类方法重写
- (void)resetButtonTapped:(UIButton *)sender {
    // 自定义重置逻辑
    [self.gestureView clearPassword];
    [self updateStatusText:@"已重置，请尝试各种错误状态演示"];
}

#pragma mark - 布局适配
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 确保所有子视图布局正确更新
    [self.buttonStackView layoutIfNeeded];
}

@end
    
