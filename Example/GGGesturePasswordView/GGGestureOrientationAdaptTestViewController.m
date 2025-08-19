#import "GGGestureOrientationAdaptTestViewController.h"

@implementation GGGestureOrientationAdaptTestViewController

+ (instancetype)testController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"横竖屏适配测试";
    
    [self setupGestureView];
    [self setupRotationTips];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 视图出现后强制更新布局
    [self.view layoutIfNeeded];
}

- (void)setupGestureView {
    // 测试initWithFrame:CGRectZero初始化方式
    GGGesturePasswordView *gestureView = [[GGGesturePasswordView alloc] initWithFrame:CGRectZero];
    gestureView.translatesAutoresizingMaskIntoConstraints = NO;
    gestureView.delegate = self;
    gestureView.normalLineColor = [UIColor systemPurpleColor];
    gestureView.buttonSpacing = 20;
    gestureView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f]; // 添加背景色便于观察
    [self.view addSubview:gestureView];
    
    // 修复约束问题：设置明确的尺寸约束
    CGFloat aspectRatio = 1.0; // 正方形
    [NSLayoutConstraint activateConstraints:@[
        // 居中显示
        [gestureView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [gestureView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-50],
        
        // 设置最大宽度和高度，确保在各种屏幕尺寸上都能显示
        [gestureView.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor multiplier:0.8],
        [gestureView.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor multiplier:0.6],
        
        // 设置最小尺寸，确保视图可见
        [gestureView.widthAnchor constraintGreaterThanOrEqualToConstant:200],
        [gestureView.heightAnchor constraintGreaterThanOrEqualToConstant:200],
        
        // 保持正方形比例
        [gestureView.widthAnchor constraintEqualToAnchor:gestureView.heightAnchor multiplier:aspectRatio]
    ]];
    
    // 强制立即布局
    [gestureView setNeedsLayout];
    [gestureView layoutIfNeeded];
    
    // 延迟显示预设手势，确保布局完成
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [gestureView showGestureWithPassword:@"2,5,8,7,4,1"];
    });
}

- (void)setupRotationTips {
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    tipsLabel.text = @"测试点：旋转设备观察手势点布局变化，应自动调整保持居中";
    tipsLabel.font = [UIFont systemFontOfSize:15];
    tipsLabel.textColor = [UIColor darkGrayColor];
    tipsLabel.numberOfLines = 0;
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [tipsLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [tipsLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [tipsLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

#pragma mark - 屏幕旋转支持
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - 旋转时强制更新布局
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    [self.view setNeedsLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    [self.view layoutIfNeeded];
    
    // 旋转后重新显示预设手势，验证布局是否正确
    GGGesturePasswordView *gestureView = (GGGesturePasswordView *)[self.view viewWithTag:1001];
    if (gestureView) {
        [gestureView showGestureWithPassword:@"2,5,8,7,4,1"];
    }
}

//#pragma mark - GGGesturePasswordViewDelegate
//- (void)gesturePasswordView:(GGGesturePasswordView *)view withPassword:(NSString *)password {
//    NSLog(@"旋转测试 - 检测到密码：%@", password);
//    // 显示正确状态0.3秒后清除
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [view clearPassword];
//    });
//}

@end
