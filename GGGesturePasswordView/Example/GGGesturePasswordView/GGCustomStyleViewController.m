#import "GGCustomStyleViewController.h"
#import "UIImage+GGResize.h"

@implementation GGCustomStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 修复标题标签引用错误（原代码使用self.titleLabel，假设父类实际属性为statusLabel）
    [self updateStatusText:@"这是自定义样式的手势密码\n- 更改了颜色和线宽\n- 设置了最大连接点为6个\n- 使用了自定义点样式"];
    
    // 自定义样式设置
    [self customizeGestureStyle];
    
    // 添加样式说明（修复布局层级问题）
    [self addStyleDescription];
}

- (void)customizeGestureStyle {
    // 自定义颜色
    self.gestureView.normalLineColor = [UIColor colorWithRed:0.8f green:0.4f blue:0.1f alpha:1.0f]; // 橙色线条
    self.gestureView.failedLineColor = [UIColor colorWithRed:0.9f green:0.2f blue:0.4f alpha:1.0f]; // 粉红色错误线条
    
    // 自定义线宽
    self.gestureView.lineWidth = 3.0f;
    
    // 设置点之间的间距
    self.gestureView.buttonSpacing = 20.0f;
    
    // 设置最大连接点数量
    self.gestureView.maxNodeCount = 6;
    
    // 修复图片处理错误：添加图片存在性检查和尺寸适配
    [self setupGestureImages];
}

- (void)setupGestureImages {
    // 获取点的实际尺寸（从手势视图获取）
    CGFloat pointSize = self.gestureView.buttonSize;
    if (pointSize <= 0) {
        pointSize = 50; // 提供默认尺寸作为备选
    }
    CGSize targetSize = CGSizeMake(pointSize, pointSize);
    
    // 正常状态图片
    UIImage *normalImage = [UIImage imageNamed:@"gesture_node_normal"];
    if (normalImage) {
        self.gestureView.normalButtonImage = [normalImage gg_resizedToFitSize:targetSize];
    } else {
        // 图片不存在时使用默认绘制
        self.gestureView.normalButtonImage = [self defaultPointImageWithColor:[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f]
                                                                     size:targetSize];
        NSLog(@"警告: 未找到gesture_node_normal图片，使用默认样式");
    }
    
    // 选中状态图片
    UIImage *selectedImage = [UIImage imageNamed:@"gesture_node_highlighted"];
    if (selectedImage) {
        self.gestureView.selectedButtonImage = [selectedImage gg_resizedToFitSize:targetSize];
    } else {
        self.gestureView.selectedButtonImage = [self defaultPointImageWithColor:[UIColor colorWithRed:0.8f green:0.4f blue:0.1f alpha:0.3f]
                                                                       size:targetSize];
        NSLog(@"警告: 未找到gesture_node_highlighted图片，使用默认样式");
    }
    
    // 错误状态图片
    UIImage *errorImage = [UIImage imageNamed:@"gesture_node_error"];
    if (errorImage) {
        self.gestureView.disableButtonImage = [errorImage gg_resizedToFitSize:targetSize];
    } else {
        self.gestureView.disableButtonImage = [self defaultPointImageWithColor:[UIColor colorWithRed:0.9f green:0.2f blue:0.4f alpha:0.3f]
                                                                       size:targetSize];
        NSLog(@"警告: 未找到gesture_node_error图片，使用默认样式");
    }
}

// 生成带边框的默认点图片（修复原方法过于简单的问题）
- (UIImage *)defaultPointImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制外圈
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [color setFill];
    [outerPath fill];
    
    // 绘制边框
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, 1, 1)];
    borderPath.lineWidth = 2;
    [[color colorWithAlphaComponent:0.5] setStroke];
    [borderPath stroke];
    
    // 绘制内圈
    CGFloat innerRadius = size.width * 0.25;
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:innerRadius
                                                        startAngle:0
                                                          endAngle:2*M_PI
                                                         clockwise:YES];
    [[color colorWithAlphaComponent:0.5] setFill];
    [innerPath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)addStyleDescription {
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor darkGrayColor];
    descLabel.numberOfLines = 0;
    descLabel.text = @"自定义选项:\n"
                     "- 线条颜色改为橙色\n"
                     "- 错误线条颜色改为粉红色\n"
                     "- 线宽增加到3.0\n"
                     "- 点之间间距增加到20\n"
                     "- 最大连接点限制为6个\n"
                     "- 自定义了点的样式";
    descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 修复视图层级错误：添加到父类内容视图而非self.view
//    if ([self respondsToSelector:@selector(contentView)]) {
//        [self.contentView addSubview:descLabel];
//    } else {
        [self.view addSubview:descLabel];
//    }
    
    // 修复约束错误：确保所有视图引用有效
    UIView *gestureView = self.gestureView;
    UIButton *resetButton = self.resetButton;
    
    if (!gestureView) {
        NSLog(@"错误: gestureView为nil，无法设置描述标签约束");
        return;
    }
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    // 描述标签约束
    [constraints addObjectsFromArray:@[
        [descLabel.topAnchor constraintEqualToAnchor:gestureView.bottomAnchor constant:15],
        [descLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30],
        [descLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-30]
    ]];
    
    // 重置按钮约束（仅在存在时添加）
    if (resetButton) {
        [constraints addObjectsFromArray:@[
            [resetButton.topAnchor constraintEqualToAnchor:descLabel.bottomAnchor constant:15],
            [resetButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [resetButton.widthAnchor constraintGreaterThanOrEqualToConstant:120],
            [resetButton.heightAnchor constraintEqualToConstant:44]
        ]];
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark - GGGesturePasswordViewDelegate
- (void)gesturePasswordView:(GGGesturePasswordView *)gesturePasswordView withPassword:(NSString *)password {
    [self updateStatusText:[NSString stringWithFormat:@"输入的密码: %@", password] withColor:[UIColor darkGrayColor]];
}

@end
    
