#import <UIKit/UIKit.h>
#import "GGGesturePasswordView.h"

@interface GGBaseDemoViewController : UIViewController <GGGesturePasswordViewDelegate>

/** 标题标签 */
@property (nonatomic, strong) UILabel *titleLabel;

/** 状态标签 */
@property (nonatomic, strong) UILabel *statusLabel;

/** 手势密码视图 */
@property (nonatomic, strong) GGGesturePasswordView *gestureView;

/** 返回按钮 */
@property (nonatomic, strong) UIButton *backButton;

/** 重置按钮 */
@property (nonatomic, strong) UIButton *resetButton;

/** 初始化UI布局 */
- (void)setupUI;

/** 更新状态文本 */
- (void)updateStatusText:(NSString *)text;

/** 更新状态文本并指定颜色 */
- (void)updateStatusText:(NSString *)text withColor:(UIColor *)color;

/** 重置按钮点击事件 */
- (void)resetButtonTapped:(UIButton *)sender;

@end
    
