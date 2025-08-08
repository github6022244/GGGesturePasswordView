#import "GGGesturePasswordView.h"

// 常量定义：集中管理固定值，便于维护和修改
static const CGFloat kGGGestureDefaultLineWidth = 1.2f;         // 默认线宽
static const CGFloat kGGGestureDefaultButtonSpacing = 15.0f;    // 默认点之间的间距
static const NSInteger kGGGestureTotalPointsCount = 9;           // 手势点总数（3x3网格）
static const CGFloat kGGGesturePointDetectionRadiusScale = 1.2f;// 点的检测半径缩放比例（扩大检测范围）
static const CGFloat kGGGestureInnerCircleRadiusScale = 1.0f/6.0f;// 内圈半径相对于点大小的比例
static const CGFloat kGGGestureDefaultErrorResetDelay = 0.5f;   // 错误状态自动重置的延迟时间（秒）

#pragma mark - 手势点模型定义
/**
 手势点模型，用于存储单个点的位置、标识和选中状态
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
@property (nonatomic, assign) CGFloat buttonSizeInternal;
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
    [self setupPoints];         // 初始化9个手势点
    
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
    self.buttonSpacing = kGGGestureDefaultButtonSpacing;
    self.padding = UIEdgeInsetsZero;
    
    // 设置背景色
    self.backgroundColor = [UIColor whiteColor];
    
    // 初始化状态变量
    self.allowsDrawingLine = YES;  // 默认允许绘制线条
    self.hasValidStartPoint = NO;  // 初始无有效起始点
    self.maxNodeCount = kGGGestureTotalPointsCount; // 默认最大连接数为总点数
    
    // 初始化数组（指定容量提升性能）
    self.pointsArray = [NSMutableArray arrayWithCapacity:kGGGestureTotalPointsCount];
    self.selectedPointsArray = [NSMutableArray array];
}

/**
 初始化9个手势点的位置和属性
 */
- (void)setupPoints {
    [self calculateButtonSize];   // 先计算点的大小
    
    [self.pointsArray removeAllObjects];  // 清空已有数据
    
    // 如果点的大小无效（<=0），则不创建点
    if (self.buttonSizeInternal <= 0) {
        return;
    }
    
    // 计算3x3网格的起始位置（水平和垂直居中）
    CGFloat totalWidth = 3 * self.buttonSizeInternal + 2 * self.buttonSpacing;
    CGFloat startX = self.padding.left + (CGRectGetWidth(self.bounds) - self.padding.left - self.padding.right - totalWidth) / 2.0f;
    
    CGFloat totalHeight = 3 * self.buttonSizeInternal + 2 * self.buttonSpacing;
    CGFloat startY = self.padding.top + (CGRectGetHeight(self.bounds) - self.padding.top - self.padding.bottom - totalHeight) / 2.0f;
    
    // 创建9个点（3行3列）
    for (NSInteger i = 0; i < kGGGestureTotalPointsCount; i++) {
        GGGesturePoint *point = [[GGGesturePoint alloc] init];
        point.tag = i + 1;       // 标签从1开始（1-9）
        point.selected = NO;     // 初始未选中
        
        // 计算行列位置（0-2行，0-2列）
        NSInteger row = i / 3;
        NSInteger col = i % 3;
        
        // 计算中心点坐标
        CGFloat centerX = startX + col * (self.buttonSizeInternal + self.buttonSpacing) + self.buttonSizeInternal / 2.0f;
        CGFloat centerY = startY + row * (self.buttonSizeInternal + self.buttonSpacing) + self.buttonSizeInternal / 2.0f;
        point.center = CGPointMake(centerX, centerY);
        
        [self.pointsArray addObject:point];
    }
}

/**
 计算手势点的大小（根据视图尺寸和间距自动适配）
 */
- (void)calculateButtonSize {
    // 计算可用宽度和高度（扣除边距）
    CGFloat availableWidth = CGRectGetWidth(self.bounds) - self.padding.left - self.padding.right;
    CGFloat availableHeight = CGRectGetHeight(self.bounds) - self.padding.top - self.padding.bottom;
    
    // 计算基于宽度和高度的最大可能点大小（3个点+2个间距）
    CGFloat maxWidthBased = (availableWidth - 2 * self.buttonSpacing) / 3.0f;
    CGFloat maxHeightBased = (availableHeight - 2 * self.buttonSpacing) / 3.0f;
    
    // 取较小值作为点的大小（确保点能完整显示）
    self.buttonSizeInternal = MIN(maxWidthBased, maxHeightBased);
    // 确保点的大小不为负数
    self.buttonSizeInternal = MAX(self.buttonSizeInternal, 0.0f);
}

#pragma mark - 布局更新
/**
 布局变化时重新计算点的位置并刷新视图
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupPoints];  // 重新计算点的位置
    [self setNeedsDisplay];  // 触发重绘
}

#pragma mark - 触摸事件处理
/**
 触摸开始时的处理（判断是否点击到手势点）
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.allowsDrawingLine) return;
    
    self.hasValidStartPoint = NO;
    
    // 检查是否已达到最大连接数，如果是则不处理新的触摸
    if (self.inErrorState || self.buttonSizeInternal <= 0 || self.selectedPointsArray.count >= self.maxNodeCount) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (![self isPointInsideView:point]) {
        return;
    }
    
    GGGesturePoint *selectedPoint = [self pointContainingPoint:point];
    if (selectedPoint) {
        self.touching = YES;
        self.hasValidStartPoint = YES;
        selectedPoint.selected = YES;
        [self.selectedPointsArray addObject:selectedPoint];
        self.currentPoint = point;
        
        [self setNeedsDisplay];
    }
}

/**
 触摸移动时的处理（更新动态线条和选中状态）
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.allowsDrawingLine || !self.hasValidStartPoint) return;
    
    if (!self.touching || self.inErrorState || self.buttonSizeInternal <= 0) {
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
    
    // 只有在未达到最大连接数时才检查新点
    if (self.selectedPointsArray.count < self.maxNodeCount) {
        GGGesturePoint *selectedPoint = [self pointContainingPoint:self.currentPoint];
        if (selectedPoint && !selectedPoint.selected) {
            selectedPoint.selected = YES;
            [self.selectedPointsArray addObject:selectedPoint];
            
            // 检查是否达到最大连接数，如果是则结束手势
            if (self.selectedPointsArray.count == self.maxNodeCount) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self touchesEnded:touches withEvent:event];
                    return;
                });
            }
        }
    }
    
    [self setNeedsDisplay];
}

/**
 触摸结束时的处理（生成密码并回调代理）
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.allowsDrawingLine || !self.hasValidStartPoint) return;
    
    if (!self.touching || self.inErrorState || self.buttonSizeInternal <= 0) {
        [self resetTouchState];
        return;
    }
    
    // 标记为结束触摸
    self.touching = NO;
    
    // 确保最后一个点正确显示选中状态
    [self setNeedsDisplay];
    
    // 通知代理生成密码
    if (self.selectedPointsArray.count > 0) {
        [self notifyDelegateWithPassword];
    } else {
        [self resetTouchState];
    }
}

/**
 触摸被取消时的处理（如电话打断）
 */
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.allowsDrawingLine && self.hasValidStartPoint) {
        self.touching = NO;
        // 如果无选中点，重置状态
        if (self.selectedPointsArray.count == 0) {
            [self resetTouchState];
        }
        [self setNeedsDisplay];
    }
}

#pragma mark - 状态管理
/**
 重置触摸相关状态（用于手势结束或取消时）
 */
- (void)resetTouchState {
    self.touching = NO;
    self.hasValidStartPoint = NO;
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
- (GGGesturePoint *)pointContainingPoint:(CGPoint)point {
    // 计算检测半径（点大小的一半乘以缩放比例，扩大检测范围）
    CGFloat radius = self.buttonSizeInternal / 2.0f * kGGGesturePointDetectionRadiusScale;
    
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
        NSLog(@"[GesturePassword] 没有选中任何点，无法生成密码");
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
    if (self.buttonSizeInternal <= 0) return;
    
    // 判断是否需要绘制已选点的连线
    BOOL shouldDrawLines = (self.selectedPointsArray.count > 0);
    // 判断是否需要绘制动态线条（从最后一个选中点到当前触摸点）
    BOOL shouldDrawDynamicLine = self.allowsDrawingLine && self.touching && self.selectedPointsArray.count < self.maxNodeCount;
    
    // 绘制线条
    if (shouldDrawLines) {
        [self drawGestureLinesWithDynamicExtension:shouldDrawDynamicLine];
    }
    
    // 绘制所有手势点（确保最后一个点正确显示选中状态）
    [self drawAllPoints];
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
- (void)drawAllPoints {
    for (GGGesturePoint *point in self.pointsArray) {
        [self drawPoint:point];
    }
}

/**
 绘制单个手势点（根据状态使用图片或默认样式）
 @param point 要绘制的点
 */
- (void)drawPoint:(GGGesturePoint *)point {
    UIImage *image = [self imageForPoint:point];
    if (image) {
        [self drawPointWithImage:image atPoint:point];
    } else {
        [self drawDefaultPoint:point];
    }
}

/**
 根据点的状态获取对应的图片
 @param point 手势点
 @return 对应状态的图片
 */
- (UIImage *)imageForPoint:(GGGesturePoint *)point {
    if (self.inErrorState) {
        return self.disableButtonImage;
    } else if (point.selected) {
        return self.selectedButtonImage;
    } else {
        return self.normalButtonImage;
    }
}

/**
 使用图片绘制手势点
 @param image 要绘制的图片
 @param point 点的位置信息
 */
- (void)drawPointWithImage:(UIImage *)image atPoint:(GGGesturePoint *)point {
    CGRect frame = CGRectMake(
        point.center.x - self.buttonSizeInternal / 2.0f,
        point.center.y - self.buttonSizeInternal / 2.0f,
        self.buttonSizeInternal,
        self.buttonSizeInternal
    );
    [image drawInRect:frame];
}

/**
 绘制默认样式的手势点（无图片时使用）
 @param point 要绘制的点
 */
- (void)drawDefaultPoint:(GGGesturePoint *)point {
    CGFloat outerRadius = self.buttonSizeInternal / 2.0f;
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
                                                                   radius:self.buttonSizeInternal * kGGGestureInnerCircleRadiusScale
                                                               startAngle:0
                                                                 endAngle:2 * M_PI
                                                                clockwise:YES];
        [strokeColor setFill];
        [innerCircle fill];
    }
}

#pragma mark - 公共方法
/**
 获取当前输入的密码字符串
 @return 当前密码字符串（格式："1,2,3,6,9"），如果没有输入则返回nil
 */
- (NSString *)currentPassword {
    return [self generatePasswordString];
}

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
    [self showWrongPasswordUIAndResetUIAfterSeconds:kGGGestureDefaultErrorResetDelay];
}

/**
 显示错误状态UI并在默认时间后自动重置，带结束回调
 @param endBlock 重置完成后的回调
 */
- (void)showWrongPasswordUIAndAutoResetUIWithEndBlock:(void (^)(void))endBlock {
    [self showWrongPasswordUIAndResetUIAfterSeconds:kGGGestureDefaultErrorResetDelay endBlock:endBlock];
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
        NSLog(@"[GesturePassword] 传入的密码为nil，无法显示手势");
        return;
    }
    
    NSString *trimmedPassword = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedPassword.length == 0) {
        NSLog(@"[GesturePassword] 传入的密码为空或仅包含空白字符，无法显示手势");
        return;
    }
    
    // 解析密码
    NSArray<NSString *> *tagStrings = [self parsePasswordString:trimmedPassword];
    if (tagStrings.count == 0) {
        NSLog(@"[GesturePassword] 密码解析后没有有效点，无法显示手势");
        return;
    }
    
    // 限制显示的点数不超过最大连接数
    NSInteger maxDisplayCount = MIN(tagStrings.count, self.maxNodeCount);
    NSArray<NSString *> *limitedTagStrings = [tagStrings subarrayWithRange:NSMakeRange(0, maxDisplayCount)];
    
    // 选中对应点
    [self selectPointsWithTagStrings:limitedTagStrings];
    
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
                NSLog(@"[GesturePassword] 密码中包含空项，已忽略");
            }
        }
        
        NSLog(@"[GesturePassword] 解析逗号分隔格式密码，共 %lu 个有效项", (unsigned long)validComponents.count);
        return validComponents;
    } else {
        NSMutableArray<NSString *> *components = [NSMutableArray array];
        for (NSInteger i = 0; i < password.length; i++) {
            unichar charCode = [password characterAtIndex:i];
            [components addObject:[NSString stringWithCharacters:&charCode length:1]];
        }
        
        NSLog(@"[GesturePassword] 解析纯数字格式密码，共 %lu 个项", (unsigned long)components.count);
        return components;
    }
}

/**
 根据标签字符串数组选中对应的手势点
 @param tagStrings 点标签字符串数组
 */
- (void)selectPointsWithTagStrings:(NSArray<NSString *> *)tagStrings {
    NSInteger validCount = 0;
    
    for (NSString *tagStr in tagStrings) {
        NSInteger tag = [tagStr integerValue];
        
        // 验证范围
        if (tag < 1 || tag > kGGGestureTotalPointsCount) {
            NSLog(@"[GesturePassword] 无效的点编号: %@ (必须在1-%ld之间)", tagStr, (long)kGGGestureTotalPointsCount);
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
            NSLog(@"[GesturePassword] 点 %ld 已被选中或不存在，已跳过", (long)tag);
        }
    }
    
    NSLog(@"[GesturePassword] 密码解析完成，有效点数量: %ld", (long)validCount);
}

#pragma mark - Getters & Setters
/**
 公开的点大小属性（只读）
 @return 点的大小
 */
- (CGFloat)buttonSize {
    return self.buttonSizeInternal;
}

/**
 获取正常状态下的按钮图片（懒加载）
 @return 正常状态图片
 */
- (UIImage *)normalButtonImage {
    if (!_normalButtonImage) {
        _normalButtonImage = [UIImage imageNamed:@"gesture_node_normal"];
    }
    return _normalButtonImage;
}

/**
 获取选中状态下的按钮图片（懒加载）
 @return 选中状态图片
 */
- (UIImage *)selectedButtonImage {
    if (!_selectedButtonImage) {
        _selectedButtonImage = [UIImage imageNamed:@"gesture_node_highlighted"];
    }
    return _selectedButtonImage;
}

/**
 获取错误状态下的按钮图片（懒加载）
 @return 错误状态图片
 */
- (UIImage *)disableButtonImage {
    if (!_disableButtonImage) {
        _disableButtonImage = [UIImage imageNamed:@"gesture_node_error"];
    }
    return _disableButtonImage;
}

/**
 设置点之间的间距（重写setter以更新布局）
 @param buttonSpacing 新的间距值
 */
- (void)setButtonSpacing:(CGFloat)buttonSpacing {
    if (_buttonSpacing != buttonSpacing) {
        _buttonSpacing = buttonSpacing;
        [self setupPoints];
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
        [self setupPoints];
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

/**
 设置最大连接点数量（重写setter以限制范围）
 @param maxNodeCount 最大连接点数量
 */
- (void)setMaxNodeCount:(NSInteger)maxNodeCount {
    // 确保最大连接数在有效范围内（1-9）
    NSInteger clampedValue = MAX(1, MIN(maxNodeCount, kGGGestureTotalPointsCount));
    if (_maxNodeCount != clampedValue) {
        _maxNodeCount = clampedValue;
        // 如果当前选中点数超过新的最大值，截断并更新UI
        if (self.selectedPointsArray.count > _maxNodeCount) {
            NSRange range = NSMakeRange(_maxNodeCount, self.selectedPointsArray.count - _maxNodeCount);
            NSArray<GGGesturePoint *> *pointsToDeselect = [self.selectedPointsArray subarrayWithRange:range];
            for (GGGesturePoint *point in pointsToDeselect) {
                point.selected = NO;
            }
            [self.selectedPointsArray removeObjectsInRange:range];
            [self setNeedsDisplay];
        }
    }
}

#pragma mark - 内存管理
- (void)dealloc {
    [self.resetTimer invalidate];
}

@end
