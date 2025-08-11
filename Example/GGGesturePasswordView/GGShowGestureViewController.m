#import "GGShowGestureViewController.h"

@implementation GGShowGestureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"显示指定手势";
    [self updateStatusText:@"点击下方按钮显示预设手势"];
    
    // 添加预设手势按钮
    [self addGestureButtons];
}

- (void)addGestureButtons {
    // 预设手势数据
    NSArray *gestureData = @[
        @{@"title": @"手势1: 1-2-3-6-9", @"password": @"1,2,3,6,9"},
        @{@"title": @"手势2: 1-4-7-8-9", @"password": @"1,4,7,8,9"},
        @{@"title": @"手势3: 3-2-1-4-5", @"password": @"3,2,1,4,5"},
        @{@"title": @"手势4: 5-6-3-2-1", @"password": @"5,6,3,2,1"}
    ];
    
    // 创建按钮容器
    UIView *buttonContainer = [[UIView alloc] init];
    buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:buttonContainer belowSubview:self.resetButton];
    
    // 创建按钮
    CGFloat buttonHeight = 40.0f;
    CGFloat spacing = 10.0f;
    
    for (NSInteger i = 0; i < gestureData.count; i++) {
        NSDictionary *data = gestureData[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:data[@"title"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.titleLabel.numberOfLines = 0;
        [button addTarget:self action:@selector(showGesture:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundColor:[UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f]];
        button.layer.cornerRadius = 5.0f;
        button.tag = 100 + i;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [buttonContainer addSubview:button];
        
        // 按钮约束
        [NSLayoutConstraint activateConstraints:@[
            [button.leadingAnchor constraintEqualToAnchor:buttonContainer.leadingAnchor],
            [button.trailingAnchor constraintEqualToAnchor:buttonContainer.trailingAnchor],
            [button.heightAnchor constraintEqualToConstant:buttonHeight],
            [button.topAnchor constraintEqualToAnchor:buttonContainer.topAnchor constant:i * (buttonHeight + spacing)]
        ]];
    }
    
    // 容器约束
    [NSLayoutConstraint activateConstraints:@[
        [buttonContainer.topAnchor constraintEqualToAnchor:self.gestureView.bottomAnchor constant:20],
        [buttonContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30],
        [buttonContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-30],
        [self.resetButton.topAnchor constraintEqualToAnchor:buttonContainer.bottomAnchor constant:20]
    ]];
    
    // 设置容器高度
    CGFloat containerHeight = gestureData.count * buttonHeight + (gestureData.count - 1) * spacing;
    [buttonContainer.heightAnchor constraintEqualToConstant:containerHeight].active = YES;
}

- (void)showGesture:(UIButton *)sender {
    NSArray *gestureData = @[
        @{@"title": @"手势1: 1-2-3-6-9", @"password": @"1,2,3,6,9"},
        @{@"title": @"手势2: 1-4-7-8-9", @"password": @"1,4,7,8,9"},
        @{@"title": @"手势3: 3-2-1-4-5", @"password": @"3,2,1,4,5"},
        @{@"title": @"手势4: 5-6-3-2-1", @"password": @"5,6,3,2,1"}
    ];
    
    NSInteger index = sender.tag - 100;
    if (index >= 0 && index < gestureData.count) {
        NSString *password = gestureData[index][@"password"];
        [self.gestureView showGestureWithPassword:password];
        /// @warning 在这里重新指定不可绘制
        self.gestureView.allowsDrawingLine = NO;
        [self updateStatusText:[NSString stringWithFormat:@"显示预设手势: %@", password]];
    }
}

#pragma mark - 重写重置方法
- (void)resetButtonTapped:(UIButton *)sender {
    [super resetButtonTapped:sender];
    [self updateStatusText:@"点击下方按钮显示预设手势"];
}

#pragma mark - GGGesturePasswordViewDelegate
- (void)gesturePasswordView:(GGGesturePasswordView *)gesturePasswordView withPassword:(NSString *)password {
    [self updateStatusText:[NSString stringWithFormat:@"你绘制的手势: %@", password]];
}

@end
    
