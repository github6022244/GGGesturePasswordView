#import <UIKit/UIKit.h>
#import <GGGesturePasswordView.h>

NS_ASSUME_NONNULL_BEGIN

/// 测试手势密码视图在自动布局初始化场景下的表现
@interface GGGestureAutoLayoutInitTestViewController : UIViewController <GGGesturePasswordViewDelegate>

/// 创建测试控制器实例
+ (instancetype)testController;

@end

NS_ASSUME_NONNULL_END
