#import <UIKit/UIKit.h>

@protocol GGGesturePasswordViewDelegate;

@interface GGGesturePasswordView : UIView

/** 代理对象 */
@property (nonatomic, weak) id<GGGesturePasswordViewDelegate> delegate;

/** 正常状态下的点图片 */
@property (nonatomic, strong) UIImage *normalNodeImage;

/** 选中状态下的点图片 */
@property (nonatomic, strong) UIImage *selectedNodeImage;

/** 错误状态下的点图片 */
@property (nonatomic, strong) UIImage *disableNodeImage;

/** 正常状态下的线条颜色 */
@property (nonatomic, strong) UIColor *normalLineColor;

/** 错误状态下的线条颜色 */
@property (nonatomic, strong) UIColor *failedLineColor;

/** 线条宽度 */
@property (nonatomic, assign) CGFloat lineWidth;

/** 点之间的间距 */
@property (nonatomic, assign) CGFloat nodeSpacing;

/** 边距 */
@property (nonatomic, assign) UIEdgeInsets padding;

/** 是否允许绘制线条 */
@property (nonatomic, assign) BOOL allowsDrawingLine;

/** 点的大小（只读） */
@property (nonatomic, assign, readonly) CGFloat nodeSize;

/**
 清除当前选中的密码状态，重置为初始状态
 */
- (void)clearPassword;

/**
 显示错误状态的UI（将点和线显示为错误颜色）
 */
- (void)showWrongPasswordUI;

/**
 显示错误状态UI并在默认时间后自动重置
 */
- (void)showWrongPasswordUIAndAutoResetUI;

/**
 显示错误状态UI并在默认时间后自动重置，带结束回调
 @param endBlock 重置完成后的回调
 */
- (void)showWrongPasswordUIAndAutoResetUIWithEndBlock:(void (^)(void))endBlock;

/**
 显示错误状态UI并在指定时间后自动重置
 @param seconds 延迟时间（秒）
 */
- (void)showWrongPasswordUIAndResetUIAfterSeconds:(CGFloat)seconds;

/**
 显示错误状态UI并在指定时间后自动重置，带结束回调
 @param seconds 延迟时间（秒）
 @param endBlock 重置完成后的回调
 */
- (void)showWrongPasswordUIAndResetUIAfterSeconds:(CGFloat)seconds endBlock:(void (^)(void))endBlock;

/**
 根据密码字符串显示对应的手势轨迹
 @param password 手势密码字符串（支持两种格式：1.纯数字如@"12369" 2.英文逗号分隔如@"1,2,3,6,9"）
 */
- (void)showGestureWithPassword:(NSString *)password;

@end

/**
 手势密码视图代理协议
 */
@protocol GGGesturePasswordViewDelegate <NSObject>

/**
 手势密码输入完成时的回调
 @param view 手势密码视图
 @param password 输入的密码字符串
 */
- (void)gesturePasswordView:(GGGesturePasswordView *)view withPassword:(NSString *)password;

@end
    
