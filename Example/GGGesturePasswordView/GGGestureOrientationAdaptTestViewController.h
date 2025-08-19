#import <UIKit/UIKit.h>
#import <GGGesturePasswordView.h>

NS_ASSUME_NONNULL_BEGIN

/// 测试手势密码视图在横竖屏旋转时的适配表现
@interface GGGestureOrientationAdaptTestViewController : UIViewController <GGGesturePasswordViewDelegate>

/// 创建测试控制器实例
+ (instancetype)testController;

@end

NS_ASSUME_NONNULL_END
