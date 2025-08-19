#import "GGGestureAutoLayoutInitTestViewController.h"

@interface GGGestureAutoLayoutInitTestViewController ()

@property (nonatomic, strong) GGGesturePasswordView *gestureView;

@end

@implementation GGGestureAutoLayoutInitTestViewController

+ (instancetype)testController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"自动布局初始化测试";
    
    [self setupGestureViewWithAutoLayout];
    [self setupTestButtons];
}

/**
 使用自动布局方式创建手势视图（测试核心）
 */
- (void)setupGestureViewWithAutoLayout {
    // 测试init初始化方式
    GGGesturePasswordView *gestureView = [[GGGesturePasswordView alloc] init];
    gestureView.translatesAutoresizingMaskIntoConstraints = NO;
    gestureView.delegate = self;
    gestureView.normalLineColor = [UIColor systemBlueColor];
    gestureView.padding = UIEdgeInsetsMake(20, 20, 20, 20);
    self.gestureView = gestureView;
    [self.view addSubview:gestureView];
    
    // 添加自动布局约束
    [NSLayoutConstraint activateConstraints:@[
        [gestureView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:40],
        [gestureView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [gestureView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [gestureView.heightAnchor constraintEqualToAnchor:gestureView.widthAnchor] // 正方形
    ]];
    
    // 延迟显示一个预设手势，测试布局完成后的显示
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [gestureView showGestureWithPassword:@"1,2,3,6,9"];
    });
    
    // 添加测试说明
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descLabel.text = @"测试点：使用init+自动布局创建，应正确显示手势点和预设轨迹";
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.numberOfLines = 0;
    [self.view addSubview:descLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [descLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [descLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [descLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

- (void)setupTestButtons {
    // 清除按钮
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    [clearButton setTitle:@"清除" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearGesture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
    
    // 显示预设手势按钮
    UIButton *showButton = [UIButton buttonWithType:UIButtonTypeSystem];
    showButton.translatesAutoresizingMaskIntoConstraints = NO;
    [showButton setTitle:@"显示预设手势" forState:UIControlStateNormal];
    [showButton addTarget:self action:@selector(showPresetGesture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [clearButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-80],
        [clearButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-80],
        
        [showButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-80],
        [showButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:80]
    ]];
}

#pragma mark - 按钮事件
- (void)clearGesture:(UIButton *)sender {
    [self.gestureView clearPassword];
}

- (void)showPresetGesture:(UIButton *)sender {
    [self.gestureView showGestureWithPassword:@"1,4,7,8,9"];
}

#pragma mark - GGGesturePasswordViewDelegate
- (void)gesturePasswordView:(GGGesturePasswordView *)view withPassword:(NSString *)password {
    NSLog(@"检测到密码：%@", password);
}

@end
