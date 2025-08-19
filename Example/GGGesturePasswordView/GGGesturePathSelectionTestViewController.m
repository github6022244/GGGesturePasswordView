#import "GGGesturePathSelectionTestViewController.h"
#import <GGGesturePasswordView.h>

@interface GGGesturePathSelectionTestViewController () <GGGesturePasswordViewDelegate>

@property (nonatomic, strong) GGGesturePasswordView *gestureTestView;
@property (nonatomic, strong) UILabel *testStatusLabel;
@property (nonatomic, strong) UISwitch *pathSelectionSwitch; // 控制路径选点功能的开关
@property (nonatomic, strong) UILabel *selectionModeLabel;   // 显示当前选点模式的标签

@end

@implementation GGGesturePathSelectionTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"手势路径选点功能测试";
    
    [self setupPathSelectionControls];
    [self setupGestureTestView];
    [self setupConstraints];
}

#pragma mark - 初始化测试控件
- (void)setupPathSelectionControls {
    // 状态提示标签：说明当前测试内容
    self.testStatusLabel = [[UILabel alloc] init];
    self.testStatusLabel.translatesAutoresizingMaskIntoConstraints = NO; // 禁用自动转换约束
    self.testStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.testStatusLabel.numberOfLines = 0;
    self.testStatusLabel.font = [UIFont systemFontOfSize:15];
    self.testStatusLabel.text = @"测试说明：\n1. 启用时，划过点会自动选中\n2. 禁用时，仅精确点击才会选中\n请绘制手势观察选点结果";
    [self.view addSubview:self.testStatusLabel];
    
    // 选点模式说明标签
    self.selectionModeLabel = [[UILabel alloc] init];
    self.selectionModeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectionModeLabel.font = [UIFont systemFontOfSize:14];
    self.selectionModeLabel.text = @"当前模式：路径自动选点（启用）";
    [self.view addSubview:self.selectionModeLabel];
    
    // 路径选点功能开关
    self.pathSelectionSwitch = [[UISwitch alloc] init];
    self.pathSelectionSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.pathSelectionSwitch.on = YES; // 默认启用路径选点
    [self.pathSelectionSwitch addTarget:self
                                 action:@selector(pathSelectionModeChanged:)
                       forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pathSelectionSwitch];
}

#pragma mark - 初始化测试用手势视图
- (void)setupGestureTestView {
    self.gestureTestView = [[GGGesturePasswordView alloc] init];
    self.gestureTestView.translatesAutoresizingMaskIntoConstraints = NO;
    self.gestureTestView.buttonSpacing = 35.f;
    self.gestureTestView.delegate = self;
    self.gestureTestView.shouldSelectPointsOnPath = YES; // 默认启用路径选点
    self.gestureTestView.maxNodeCount = 9; // 允许最大选点数量
    [self.view addSubview:self.gestureTestView];
}

#pragma mark - 设置系统原生约束
- (void)setupConstraints {
    // 使用系统 Auto Layout 约束
    NSLayoutConstraint *statusTop = [NSLayoutConstraint constraintWithItem:self.testStatusLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view.safeAreaLayoutGuide
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:20];
    
    NSLayoutConstraint *statusLeft = [NSLayoutConstraint constraintWithItem:self.testStatusLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:20];
    
    NSLayoutConstraint *statusRight = [NSLayoutConstraint constraintWithItem:self.testStatusLabel
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0
                                                                   constant:-20];
    
    // 模式标签约束
    NSLayoutConstraint *modeTop = [NSLayoutConstraint constraintWithItem:self.selectionModeLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.testStatusLabel
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:20];
    
    NSLayoutConstraint *modeLeft = [NSLayoutConstraint constraintWithItem:self.selectionModeLabel
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1.0
                                                                 constant:30];
    
    // 开关约束（与模式标签居中对齐）
    NSLayoutConstraint *switchCenterY = [NSLayoutConstraint constraintWithItem:self.pathSelectionSwitch
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectionModeLabel
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0
                                                                       constant:0];
    
    NSLayoutConstraint *switchLeft = [NSLayoutConstraint constraintWithItem:self.pathSelectionSwitch
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.selectionModeLabel
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:10];
    
    // 手势视图约束（正方形居中）
    NSLayoutConstraint *gestureTop = [NSLayoutConstraint constraintWithItem:self.gestureTestView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.pathSelectionSwitch
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:30];
    
    NSLayoutConstraint *gestureCenterX = [NSLayoutConstraint constraintWithItem:self.gestureTestView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0
                                                                        constant:0];
    
    NSLayoutConstraint *gestureWidth = [NSLayoutConstraint constraintWithItem:self.gestureTestView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.gestureTestView
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1.0
                                                                      constant:0]; // 宽高比1:1
    
    NSLayoutConstraint *gestureLeft = [NSLayoutConstraint constraintWithItem:self.gestureTestView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:40];
    
    NSLayoutConstraint *gestureRight = [NSLayoutConstraint constraintWithItem:self.gestureTestView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:-40];
    
    // 激活所有约束
    [NSLayoutConstraint activateConstraints:@[
        statusTop, statusLeft, statusRight,
        modeTop, modeLeft,
        switchCenterY, switchLeft,
        gestureTop, gestureCenterX, gestureWidth, gestureLeft, gestureRight
    ]];
}

#pragma mark - 路径选点模式切换
- (void)pathSelectionModeChanged:(UISwitch *)sender {
    self.gestureTestView.shouldSelectPointsOnPath = sender.on;
    self.selectionModeLabel.text = sender.on ?
        @"当前模式：路径自动选点（启用）" :
        @"当前模式：精确点击选点（禁用）";
    [self.gestureTestView clearPassword];
}

#pragma mark - GGGesturePasswordViewDelegate
- (void)gesturePasswordView:(GGGesturePasswordView *)view withPassword:(NSString *)password {
    NSArray *selectedTags = [password componentsSeparatedByString:@","];
    self.testStatusLabel.text = [NSString stringWithFormat:
                                @"选点结果：%@\n共选中 %ld 个点\n（%@）",
                                password,
                                (long)selectedTags.count,
                                self.selectionModeLabel.text];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view clearPassword];
        [self resetTestStatusLabel];
    });
}

#pragma mark - 辅助方法：重置测试状态标签
- (void)resetTestStatusLabel {
    self.testStatusLabel.text = @"测试说明：\n1. 启用时，划过点会自动选中\n2. 禁用时，仅精确点击才会选中\n请绘制手势观察选点结果";
}

@end
