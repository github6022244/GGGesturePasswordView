//
//  GGGesturePasswordView.m
//  iOS
//
//  Created by GG on 2025/7/30.
//

#import "GGGesturePasswordView.h"

// 常量定义：使用更具体的命名，添加完整前缀避免冲突
static const CGFloat kGGGestureDefaultLineWidth = 1.2f;                  // 默认线宽
static const CGFloat kGGGestureNodeSpacing = 15.0f;                     // 手势点之间的间距
static const NSInteger kGGGestureTotalNodeCount = 9;                     // 手势点总数（3x3网格）
static const CGFloat kGGGestureNodeDetectionRadiusScale = 1.2f;          // 点的检测半径缩放比例
static const CGFloat kGGGestureNodeInnerCircleRadiusScale = 1.0f/6.0f;   // 内圈半径相对于点大小的比例
static const CGFloat kGGGestureErrorStateResetDelay = 0.5f;              // 错误状态自动重置的延迟时间（秒）
static NSString *const kGGGestureLogIdentifier = @"[GGGesturePassword]"; // 日志输出标识

#pragma mark - 手势点模型定义
/**
 手势点模型，存储单个点的位置、标识和选中状态
 */
@interface GGGesturePoint : NSObject
@property (nonatomic, assign) CGPoint center;   // 点的中心点坐标
@property (nonatomic, assign) NSInteger tag;    // 点的标识（1-9）
@property (nonatomic, assign, getter=isSelected) BOOL selected; // 是否被选中
@end

@implementation GGGesturePoint
@end

#pragma mark - 手势密码视图实现
@interface GGGesturePasswordView ()

/** 存储所有手势点的数组（共9个点） */
@property (nonatomic, strong) NSMutableArray<GGGesturePoint *> *pointsArray;
/** 存储当前选中的手势点的数组（按选中顺序排列） */
@property (nonatomic, strong) NSMutableArray<GGGesturePoint *> *selectedPointsArray;
/** 当前触摸点的坐标（用于绘制动态线条） */
@property (nonatomic, assign) CGPoint currentPoint;
/** 是否正在触摸（用于判断是否绘制动态线条） */
@property (nonatomic, assign, getter=isTouching) BOOL touching;
/** 是否处于错误状态（如密码输入错误时的UI状态） */
@property (nonatomic, assign, getter=isInErrorState) BOOL inErrorState;
/** 错误状态自动重置的计时器 */
@property (nonatomic, strong) NSTimer *resetTimer;
/** 内部存储的点的大小（计算后的值） */
@property (nonatomic, assign) CGFloat nodeSizeInternal;
/** 是否有有效的起始点（用于判断手势是否已开始） */
@property (nonatomic, assign) BOOL hasValidStartPoint;

@end

@implementation GGGesturePasswordView

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

/**
 统一初始化方法，抽取初始化逻辑避免重复代码
 */
- (void)commonInit {
    [self setupDefaultValues];  // 设置默认属性值
    [self setupGestureNodes];   // 初始化9个手势点
    
    // 启用用户交互（手势需要触摸事件）
    self.userInteractionEnabled = YES;
}

#pragma mark - 初始化设置
/**
 设置默认属性值（颜色、线宽、间距等）
 */
- (void)setupDefaultValues {
    // 设置默认线条颜色
    self.normalLineColor = [UIColor colorWithRed:0.2f green:0.6f blue:1.0f alpha:1.0f];
    self.failedLineColor = [UIColor redColor];
    
    // 设置默认线宽和间距
    self.lineWidth = kGGGestureDefaultLineWidth;
    self.nodeSpacing = kGGGestureNodeSpacing;
    self.padding = UIEdgeInsetsZero;
    
    // 设置背景色
    self.backgroundColor = [UIColor whiteColor];
    
    // 初始化状态变量
    self.allowsDrawingLine = YES;  // 默认允许绘制线条
    self.hasValidStartPoint = NO;  // 初始无有效起始点
    
    // 初始化数组（指定容量提升性能）
    self.pointsArray = [NSMutableArray arrayWithCapacity:kGGGestureTotalNodeCount];
    self.selectedPointsArray = [NSMutableArray array];
}

/**
 初始化9个手势点的位置和属性
 */
- (void)setupGestureNodes {
    [self calculateNodeSize];   // 先计算点的大小
    
    [self.pointsArray removeAllObjects];  // 清空已有数据
    
    // 如果点的大小无效（<=0），则不创建点
    if (self.nodeSizeInternal <= 0) {
        return;
    }
    
    // 计算3x3网格的起始位置（水平和垂直居中）
    CGFloat totalWidth = 3 * self.nodeSizeInternal + 2 * self.nodeSpacing;
    CGFloat startX = self.padding.left + (CGRectGetWidth(self.bounds) - self.padding.left - self.padding.right - totalWidth) / 2.0f;
    
    CGFloat totalHeight = 3 * self.nodeSizeInternal + 2 * self.nodeSpacing;
    CGFloat startY = self.padding.top + (CGRectGetHeight(self.bounds) - self.padding.top - self.padding.bottom - totalHeight) / 2.0f;
    
    // 创建9个点（3行3列）
    for (NSInteger i = 0; i < kGGGestureTotalNodeCount; i++) {
        GGGesturePoint *point = [[GGGesturePoint alloc] init];
        point.tag = i + 1;       // 标签从1开始（1-9）
        point.selected = NO;     // 初始未选中
        
        // 计算行列位置（0-2行，0-2列）
        NSInteger row = i / 3;
        NSInteger col = i % 3;
        
        // 计算中心点坐标
        CGFloat centerX = startX + col * (self.nodeSizeInternal + self.nodeSpacing) + self.nodeSizeInternal / 2.0f;
        CGFloat centerY = startY + row * (self.nodeSizeInternal + self.nodeSpacing) + self.nodeSizeInternal / 2.0f;
        point.center = CGPointMake(centerX, centerY);
        
        [self.pointsArray addObject:point];
    }
}

/**
 计算手势点的大小（根据视图尺寸和间距自动适配）
 */
- (void)calculateNodeSize {
    // 计算可用宽度和高度（扣除边距）
    CGFloat availableWidth = CGRectGetWidth(self.bounds) - self.padding.left - self.padding.right;
    CGFloat availableHeight = CGRectGetHeight(self.bounds) - self.padding.top - self.padding.bottom;
    
    // 计算基于宽度和高度的最大可能点大小（3个点+2个间距）
    CGFloat maxWidthBased = (availableWidth - 2 * self.nodeSpacing) / 3.0f;
    CGFloat maxHeightBased = (availableHeight - 2 * self.nodeSpacing) / 3.0f;
    
    // 取较小值作为点的大小（确保点能完整显示）
    self.nodeSizeInternal = MIN(maxWidthBased, maxHeightBased);
    // 确保点的大小不为负数
    self.nodeSizeInternal = MAX(self.nodeSizeInternal, 0.0f);
}

#pragma mark - 布局更新
/**
 布局变化时重新计算点的位置并刷新视图
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupGestureNodes];  // 重新计算点的位置
    [self setNeedsDisplay];    // 触发重绘
}

#pragma mark - 触摸事件处理
/**
 触摸开始时的处理（判断是否点击到手势点）
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 如果不允许绘制线条，直接返回
    if (!self.allowsDrawingLine) return;
    
    // 重置起始点状态
    self.hasValidStartPoint = NO;
    
    // 如果处于错误状态、点大小无效或已选满9个点，不处理触摸
    if (self.inErrorState || self.nodeSizeInternal <= 0 || self.selectedPointsArray.count >= kGGGestureTotalNodeCount) {
        return;
    }
    
    // 获取触摸点坐标
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // 如果触摸点在视图外，不处理
    if (![self isPointInsideView:point]) {
        return;
    }
    
    // 检查是否触摸到某个手势点
    GGGesturePoint *selectedPoint = [self nodeContainingPoint:point];
    if (selectedPoint) {
        self.touching = YES;              // 标记为正在触摸
        self.hasValidStartPoint = YES;    // 标记有有效起始点
        selectedPoint.selected = YES;     // 选中该点
        [self.selectedPointsArray addObject:selectedPoint];  // 加入选中数组
        self.currentPoint = point;        // 记录当前触摸点
        
        [self setNeedsDisplay];  // 触发重绘
    }
}

/**
 触摸移动时的处理（更新动态线条和选中状态）
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 如果不允许绘制线条或无有效起始点，直接返回
    if (!self.allowsDrawingLine || !self.hasValidStartPoint) return;
    
    // 如果不在触摸状态、处于错误状态、点大小无效或已选满9个点，不处理
    if (!self.touching || self.inErrorState || self.nodeSizeInternal <= 0 ||
        self.selectedPointsArray.count >= kGGGestureTotalNodeCount) {
        return;
    }
    
    // 获取当前触摸点坐标
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // 如果触摸点移出视图，结束手势
    if (![self isPointInsideView:point]) {
        [self touchesEnded:touches withEvent:event];
        return;
    }
    
    // 更新当前触摸点坐标
    self.currentPoint = point;
    
    // 检查是否触摸到新的手势点
    GGGesturePoint *selectedPoint = [self nodeContainingPoint:self.currentPoint];
    if (selectedPoint && !selectedPoint.selected) {
        selectedPoint.selected = YES;  // 选中新点
        [self.selectedPointsArray addObject:selectedPoint];  // 加入选中数组
        
        // 如果已选满9个点，结束手势
        if (self.selectedPointsArray.count >= kGGGestureTotalNodeCount) {
            [self touchesEnded:touches withEvent:event];
            return;
        }
    }
    
    [self setNeedsDisplay];  // 触发重绘
}

/**
 触摸结束时的处理（生成密码并回调代理）
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 如果不允许绘制线条或无有效起始点，直接返回
    if (!self.allowsDrawingLine || !self.hasValidStartPoint) return;
    
    // 如果不在触摸状态、处于错误状态或点大小无效，重置状态
    if (!self.touching || self.inErrorState || self.nodeSizeInternal <= 0) {
        [self resetTouchState];
        return;
    }
    
    // 标记为结束触摸
    self.touching = NO;
    
    // 如果有选中的点，通知代理生成密码
    if (self.selectedPointsArray.count > 0) {
        [self notifyDelegateWithPassword];
    } else {
        [self resetTouchState];  // 无选中点时重置状态
    }
    
    [self setNeedsDisplay];  // 触发重绘
}

/**
 触摸被取消时的处理（如电话打断）
 */
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 如果允许绘制线条且有有效起始点，处理取消逻辑
    if (self.allowsDrawingLine && self.hasValidStartPoint) {
        self.touching = NO;  // 标记为结束触摸
        // 如果无选中点，重置状态
        if (self.selectedPointsArray.count == 0) {
            [self resetTouchState];
        }
        [self setNeedsDisplay];  // 触发重绘
    }
}

#pragma mark - 状态管理
/**
 重置触摸相关状态（用于手势结束或取消时）
 */
- (void)resetTouchState {
    self.touching = NO;             // 结束触摸状态
    self.hasValidStartPoint = NO;   // 清除有效起始点标记
}

#pragma mark - 辅助方法
/**
 判断点是否在当前视图内部（边界检查）
 @param point 要判断的点（相对于当前视图的坐标）
 @return 是否在视图内部
 */
- (BOOL)isPointInsideView:(CGPoint)point {
    return point.x >= 0 && point.x <= CGRectGetWidth(self.bounds) &&
           point.y >= 0 && point.y <= CGRectGetHeight(self.bounds);
}

/**
 检查指定点是否在某个手势点的检测范围内
 @param point 触摸点坐标
 @return 被触摸的手势点（如果有）
 */
- (GGGesturePoint *)nodeContainingPoint:(CGPoint)point {
    // 计算检测半径（点大小的一半乘以缩放比例，扩大检测范围）
    CGFloat radius = self.nodeSizeInternal / 2.0f * kGGGestureNodeDetectionRadiusScale;
    
    // 遍历所有手势点，判断距离是否在检测范围内
    for (GGGesturePoint *p in self.pointsArray) {
        CGFloat distance = hypotf(point.x - p.center.x, point.y - p.center.y);
        if (distance <= radius) {
            return p;
        }
    }
    return nil;
}

/**
 生成密码字符串并通知代理
 */
- (void)notifyDelegateWithPassword {
    NSString *password = [self generatePasswordString];
    // 如果密码有效且代理实现了方法，回调代理
    if (password.length > 0 && [self.delegate respondsToSelector:@selector(gesturePasswordView:withPassword:)]) {
        [self.delegate gesturePasswordView:self withPassword:password];
    }
}

/**
 根据选中的点生成密码字符串（格式："1,2,3,6,9"）
 @return 生成的密码字符串
 */
- (NSString *)generatePasswordString {
    if (self.selectedPointsArray.count == 0) {
        NSLog(@"%@ 没有选中任何点，无法生成密码", kGGGestureLogIdentifier);
        return nil;
    }
    
    NSMutableString *password = [NSMutableString string];
    // 拼接选中点的标签（用逗号分隔）
    for (NSInteger i = 0; i < self.selectedPointsArray.count; i++) {
        GGGesturePoint *point = self.selectedPointsArray[i];
        if (i == 0) {
            [password appendFormat:@"%ld", (long)point.tag];
        } else {
            [password appendFormat:@",%ld", (long)point.tag];
        }
    }
    
    return password;
}

#pragma mark - 绘制逻辑
/**
 重绘视图（绘制线条和手势点）
 */
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 如果点大小无效，不绘制
    if (self.nodeSizeInternal <= 0) return;
    
    // 判断是否需要绘制已选点的连线
    BOOL shouldDrawLines = (self.selectedPointsArray.count > 0);
    // 判断是否需要绘制动态线条（从最后一个选中点到当前触摸点）
    BOOL shouldDrawDynamicLine = self.allowsDrawingLine && self.touching && self.selectedPointsArray.count < kGGGestureTotalNodeCount;
    
    // 绘制线条
    if (shouldDrawLines) {
        [self drawGestureLinesWithDynamicExtension:shouldDrawDynamicLine];
    }
    
    // 绘制所有手势点
    [self drawAllNodes];
}

/**
 绘制手势连线（已选点之间的固定线 + 到当前触摸点的动态线）
 @param dynamic 是否需要绘制动态线
 */
- (void)drawGestureLinesWithDynamicExtension:(BOOL)dynamic {
    UIBezierPath *path = [UIBezierPath bezierPath];
    // 设置线条属性
    path.lineWidth = self.lineWidth;
    path.lineCapStyle = kCGLineCapRound;  // 线条端点圆润
    path.lineJoinStyle = kCGLineJoinRound; // 线条连接处圆润
    
    // 根据状态选择线条颜色（错误状态为红色，正常为默认色）
    UIColor *lineColor = self.inErrorState ? self.failedLineColor : self.normalLineColor;
    [lineColor setStroke];
    
    // 绘制已选中点之间的连线
    for (NSInteger i = 0; i < self.selectedPointsArray.count; i++) {
        GGGesturePoint *point = self.selectedPointsArray[i];
        if (i == 0) {
            [path moveToPoint:point.center];  // 起点
        } else {
            [path addLineToPoint:point.center];  // 连线
        }
    }
    
    // 绘制到当前触摸点的动态线（如果需要）
    if (dynamic) {
        [path addLineToPoint:self.currentPoint];
    }
    
    [path stroke];  // 绘制路径
}

/**
 绘制所有手势点
 */
- (void)drawAllNodes {
    for (GGGesturePoint *point in self.pointsArray) {
        [self drawNode:point];
    }
}

/**
 绘制单个手势点（根据状态使用图片或默认样式）
 @param point 要绘制的点
 */
- (void)drawNode:(GGGesturePoint *)point {
    UIImage *image = [self imageForNode:point];
    if (image) {
        [self drawNodeWithImage:image atPoint:point];
    } else {
        [self drawDefaultNode:point];
    }
}

/**
 根据点的状态获取对应的图片
 @param point 手势点
 @return 对应状态的图片
 */
- (UIImage *)imageForNode:(GGGesturePoint *)point {
    if (self.inErrorState) {
        return self.disableNodeImage;
    } else if (point.selected) {
        return self.selectedNodeImage;
    } else {
        return self.normalNodeImage;
    }
}

/**
 使用图片绘制手势点
 @param image 要绘制的图片
 @param point 点的位置信息
 */
- (void)drawNodeWithImage:(UIImage *)image atPoint:(GGGesturePoint *)point {
    CGRect frame = CGRectMake(
        point.center.x - self.nodeSizeInternal / 2.0f,
        point.center.y - self.nodeSizeInternal / 2.0f,
        self.nodeSizeInternal,
        self.nodeSizeInternal
    );
    [image drawInRect:frame];
}

/**
 绘制默认样式的手势点（无图片时使用）
 @param point 要绘制的点
 */
- (void)drawDefaultNode:(GGGesturePoint *)point {
    CGFloat outerRadius = self.nodeSizeInternal / 2.0f;
    UIColor *fillColor;
    UIColor *strokeColor;
    
    // 根据状态设置颜色
    if (self.inErrorState) {
        fillColor = [self.failedLineColor colorWithAlphaComponent:0.2f];
        strokeColor = self.failedLineColor;
    } else if (point.selected) {
        fillColor = [self.normalLineColor colorWithAlphaComponent:0.2f];
        strokeColor = self.normalLineColor;
    } else {
        fillColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        strokeColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
    }
    
    // 绘制外圈
    UIBezierPath *outerCircle = [UIBezierPath bezierPathWithArcCenter:point.center
                                                              radius:outerRadius
                                                          startAngle:0
                                                            endAngle:2 * M_PI
                                                           clockwise:YES];
    [fillColor setFill];
    [strokeColor setStroke];
    outerCircle.lineWidth = 2.0f;
    [outerCircle fill];
    [outerCircle stroke];
    
    // 绘制内圈（选中或错误状态）
    if (point.selected || self.inErrorState) {
        UIBezierPath *innerCircle = [UIBezierPath bezierPathWithArcCenter:point.center
                                                                   radius:self.nodeSizeInternal * kGGGestureNodeInnerCircleRadiusScale
                                                               startAngle:0
                                                                 endAngle:2 * M_PI
                                                                clockwise:YES];
        [strokeColor setFill];
        [innerCircle fill];
    }
}

#pragma mark - 公共方法
/**
 清除当前选中的密码状态，重置为初始状态
 */
- (void)clearPassword {
    for (GGGesturePoint *point in self.pointsArray) {
        point.selected = NO;
    }
    [self.selectedPointsArray removeAllObjects];
    [self resetTouchState];
    self.inErrorState = NO;
    self.userInteractionEnabled = YES;
    self.allowsDrawingLine = YES;
    
    [self.resetTimer invalidate];
    self.resetTimer = nil;
    
    [self setNeedsDisplay];
}

/**
 显示错误状态的UI（将点和线显示为错误颜色）
 */
- (void)showWrongPasswordUI {
    self.inErrorState = YES;
    self.userInteractionEnabled = NO;
    [self setNeedsDisplay];
}

/**
 显示错误状态UI并在默认时间后自动重置
 */
- (void)showWrongPasswordUIAndAutoResetUI {
    [self showWrongPasswordUIAndResetUIAfterSeconds:kGGGestureErrorStateResetDelay];
}

/**
 显示错误状态UI并在默认时间后自动重置，带结束回调
 @param endBlock 重置完成后的回调
 */
- (void)showWrongPasswordUIAndAutoResetUIWithEndBlock:(void (^)(void))endBlock {
    [self showWrongPasswordUIAndResetUIAfterSeconds:kGGGestureErrorStateResetDelay endBlock:endBlock];
}

/**
 显示错误状态UI并在指定时间后自动重置
 @param seconds 延迟时间（秒）
 */
- (void)showWrongPasswordUIAndResetUIAfterSeconds:(CGFloat)seconds {
    [self showWrongPasswordUIAndResetUIAfterSeconds:seconds endBlock:nil];
}

/**
 显示错误状态UI并在指定时间后自动重置，带结束回调
 @param seconds 延迟时间（秒）
 @param endBlock 重置完成后的回调
 */
- (void)showWrongPasswordUIAndResetUIAfterSeconds:(CGFloat)seconds endBlock:(void (^)(void))endBlock {
    [self showWrongPasswordUI];
    
    if (seconds <= 0) return;
    
    [self.resetTimer invalidate];
    
    self.resetTimer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                      repeats:NO
                                                        block:^(NSTimer * _Nonnull timer) {
        [self clearPassword];
        if (endBlock) {
            endBlock();
        }
    }];
}

/**
 根据密码字符串显示对应的手势轨迹
 @param password 手势密码字符串（支持两种格式：1.纯数字如@"12369" 2.英文逗号分隔如@"1,2,3,6,9"）
 */
- (void)showGestureWithPassword:(NSString *)password {
    [self clearPassword];
    
    // 非空校验
    if (!password) {
        NSLog(@"%@ 传入的密码为nil，无法显示手势", kGGGestureLogIdentifier);
        return;
    }
    
    NSString *trimmedPassword = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedPassword.length == 0) {
        NSLog(@"%@ 传入的密码为空或仅包含空白字符，无法显示手势", kGGGestureLogIdentifier);
        return;
    }
    
    // 解析密码
    NSArray<NSString *> *tagStrings = [self parsePasswordString:trimmedPassword];
    if (tagStrings.count == 0) {
        NSLog(@"%@ 密码解析后没有有效点，无法显示手势", kGGGestureLogIdentifier);
        return;
    }
    
    // 选中对应点
    [self selectNodesWithTagStrings:tagStrings];
    
    // 设置结束点
    if (self.selectedPointsArray.count > 0) {
        GGGesturePoint *lastPoint = self.selectedPointsArray.lastObject;
        self.currentPoint = lastPoint.center;
    }
    
    // 重绘
    self.touching = NO;
    [self setNeedsDisplay];
}

#pragma mark - 密码解析
/**
 解析密码字符串，支持两种格式：纯数字和逗号分隔
 @param password 要解析的密码字符串
 @return 解析后的点标签数组
 */
- (NSArray<NSString *> *)parsePasswordString:(NSString *)password {
    if ([password containsString:@","]) {
        NSArray<NSString *> *components = [password componentsSeparatedByString:@","];
        NSMutableArray<NSString *> *validComponents = [NSMutableArray array];
        
        for (NSString *component in components) {
            NSString *trimmed = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (trimmed.length > 0) {
                [validComponents addObject:trimmed];
            } else {
                NSLog(@"%@ 密码中包含空项，已忽略", kGGGestureLogIdentifier);
            }
        }
        
        NSLog(@"%@ 解析逗号分隔格式密码，共 %lu 个有效项", kGGGestureLogIdentifier, (unsigned long)validComponents.count);
        return validComponents;
    } else {
        NSMutableArray<NSString *> *components = [NSMutableArray array];
        for (NSInteger i = 0; i < password.length; i++) {
            unichar charCode = [password characterAtIndex:i];
            [components addObject:[NSString stringWithCharacters:&charCode length:1]];
        }
        
        NSLog(@"%@ 解析纯数字格式密码，共 %lu 个项", kGGGestureLogIdentifier, (unsigned long)components.count);
        return components;
    }
}

/**
 根据标签字符串数组选中对应的手势点
 @param tagStrings 点标签字符串数组
 */
- (void)selectNodesWithTagStrings:(NSArray<NSString *> *)tagStrings {
    NSInteger validCount = 0;
    
    for (NSString *tagStr in tagStrings) {
        NSInteger tag = [tagStr integerValue];
        
        // 验证范围
        if (tag < 1 || tag > kGGGestureTotalNodeCount) {
            NSLog(@"%@ 无效的点编号: %@ (必须在1-%ld之间)", kGGGestureLogIdentifier, tagStr, (long)kGGGestureTotalNodeCount);
            continue;
        }
        
        // 查找并选中点
        BOOL found = NO;
        for (GGGesturePoint *point in self.pointsArray) {
            if (point.tag == tag && !point.selected) {
                point.selected = YES;
                [self.selectedPointsArray addObject:point];
                validCount++;
                found = YES;
                break;
            }
        }
        
        if (!found) {
            NSLog(@"%@ 点 %ld 已被选中或不存在，已跳过", kGGGestureLogIdentifier, (long)tag);
        }
    }
    
    NSLog(@"%@ 密码解析完成，有效点数量: %ld", kGGGestureLogIdentifier, (long)validCount);
}

#pragma mark - Getters & Setters
/**
 公开的点大小属性（只读）
 @return 点的大小
 */
- (CGFloat)nodeSize {
    return self.nodeSizeInternal;
}

/**
 获取正常状态下的点图片（懒加载）
 @return 正常状态图片
 */
- (UIImage *)normalNodeImage {
    if (!_normalNodeImage) {
        _normalNodeImage = [UIImage imageNamed:@"gesture_node_normal"];
    }
    return _normalNodeImage;
}

/**
 获取选中状态下的点图片（懒加载）
 @return 选中状态图片
 */
- (UIImage *)selectedNodeImage {
    if (!_selectedNodeImage) {
        _selectedNodeImage = [UIImage imageNamed:@"gesture_node_highlighted"];
    }
    return _selectedNodeImage;
}

/**
 获取错误状态下的点图片（懒加载）
 @return 错误状态图片
 */
- (UIImage *)disableNodeImage {
    if (!_disableNodeImage) {
        _disableNodeImage = [UIImage imageNamed:@"gesture_node_error"];
    }
    return _disableNodeImage;
}

/**
 设置点之间的间距（重写setter以更新布局）
 @param nodeSpacing 新的间距值
 */
- (void)setNodeSpacing:(CGFloat)nodeSpacing {
    if (_nodeSpacing != nodeSpacing) {
        _nodeSpacing = nodeSpacing;
        [self setupGestureNodes];
        [self setNeedsDisplay];
    }
}

/**
 设置边距（重写setter以更新布局）
 @param padding 新的边距值
 */
- (void)setPadding:(UIEdgeInsets)padding {
    if (!UIEdgeInsetsEqualToEdgeInsets(_padding, padding)) {
        _padding = padding;
        [self setupGestureNodes];
        [self setNeedsDisplay];
    }
}

/**
 设置线宽（重写setter以更新绘制）
 @param lineWidth 新的线宽值
 */
- (void)setLineWidth:(CGFloat)lineWidth {
    if (_lineWidth != lineWidth) {
        _lineWidth = lineWidth;
        [self setNeedsDisplay];
    }
}

/**
 设置是否允许绘制线条（重写setter以更新绘制）
 @param allowsDrawingLine 是否允许绘制
 */
- (void)setAllowsDrawingLine:(BOOL)allowsDrawingLine {
    if (_allowsDrawingLine != allowsDrawingLine) {
        _allowsDrawingLine = allowsDrawingLine;
        [self setNeedsDisplay];
    }
}

#pragma mark - 内存管理
- (void)dealloc {
    [self.resetTimer invalidate];
}

@end
    
