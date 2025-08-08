#import "GGVerifyPasswordViewController.h"
#import "NSUserDefaults+GGGesture.h"
#import "GGFunctionListViewController.h"

@implementation GGVerifyPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"验证手势密码";
    
    // 检查是否已设置密码
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] ggGesturePassword];
    if (!savedPassword || savedPassword.length == 0) {
        [self updateStatusText:@"请先设置手势密码" withColor:[UIColor redColor]];
        self.gestureView.allowsDrawingLine = NO;
        
        // 添加设置密码按钮
        UIButton *setupButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [setupButton setTitle:@"去设置" forState:UIControlStateNormal];
        setupButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [setupButton addTarget:self action:@selector(goToSetupPassword) forControlEvents:UIControlEventTouchUpInside];
        [setupButton setBackgroundColor:[UIColor colorWithRed:0.2f green:0.6f blue:1.0f alpha:1.0f]];
        [setupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        setupButton.layer.cornerRadius = 5.0f;
        setupButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:setupButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [setupButton.topAnchor constraintEqualToAnchor:self.resetButton.bottomAnchor constant:15],
            [setupButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [setupButton.widthAnchor constraintEqualToConstant:100],
            [setupButton.heightAnchor constraintEqualToConstant:40]
        ]];
    } else {
        [self updateStatusText:@"请绘制已设置的手势密码"];
    }
}

- (void)goToSetupPassword {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[GGFunctionListViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

#pragma mark - GGGesturePasswordViewDelegate
- (void)gesturePasswordView:(GGGesturePasswordView *)gesturePasswordView withPassword:(NSString *)password {
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] ggGesturePassword];
    
    if ([password isEqualToString:savedPassword]) {
        // 验证成功
        [self updateStatusText:@"验证成功！" withColor:[UIColor colorWithRed:0.2f green:0.7f blue:0.1f alpha:1.0f]];
        
        // 显示成功状态
        for (UIView *subview in self.gestureView.subviews) {
            subview.tintColor = [UIColor colorWithRed:0.2f green:0.7f blue:0.1f alpha:1.0f];
        }
        
        // 延迟返回
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } else {
        // 验证失败
        [self.gestureView showWrongPasswordUIAndAutoResetUIWithEndBlock:^{
            [self updateStatusText:@"验证失败，请重新绘制" withColor:[UIColor redColor]];
        }];
    }
}

@end
    
