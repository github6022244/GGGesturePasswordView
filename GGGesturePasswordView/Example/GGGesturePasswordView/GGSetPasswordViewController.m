#import "GGSetPasswordViewController.h"
#import "NSUserDefaults+GGGesture.h"

#pragma mark - 私有属性
@interface GGSetPasswordViewController ()
@property (nonatomic, copy) NSString *firstPassword;
@property (nonatomic, assign) BOOL isVerifying;
@end

@implementation GGSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"设置手势密码";
    [self updateStatusText:@"请绘制手势密码（至少4个点）"];
    
    // 设置最大连接点数量为9
    self.gestureView.maxNodeCount = 9;
}

@end

@implementation GGSetPasswordViewController (Private)

#pragma mark - GGGesturePasswordViewDelegate
- (void)gesturePasswordView:(GGGesturePasswordView *)gesturePasswordView withPassword:(NSString *)password {
    // 检查密码长度（至少4个点）
    NSArray *passwordArray = [password componentsSeparatedByString:@","];
    if (passwordArray.count < 4) {
        [self.gestureView showWrongPasswordUIAndAutoResetUIWithEndBlock:^{
            [self updateStatusText:@"密码太短，请至少连接4个点" withColor:[UIColor redColor]];
        }];
        return;
    }
    
    if (!self.isVerifying) {
        // 第一次输入密码
        self.firstPassword = password;
        self.isVerifying = YES;
        [self updateStatusText:@"请再次绘制相同的手势密码" withColor:[UIColor colorWithRed:0.2f green:0.7f blue:0.1f alpha:1.0f]];
        [self.gestureView clearPassword];
    } else {
        // 第二次输入密码，验证是否一致
        if ([password isEqualToString:self.firstPassword]) {
            // 两次输入一致，保存密码
            [[NSUserDefaults standardUserDefaults] setGGGesturePassword:password];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.gestureView clearPassword];
            [self updateStatusText:@"手势密码设置成功！" withColor:[UIColor colorWithRed:0.2f green:0.7f blue:0.1f alpha:1.0f]];
            
            // 延迟返回
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            // 两次输入不一致
            self.isVerifying = NO;
            self.firstPassword = nil;
            [self.gestureView showWrongPasswordUIAndAutoResetUIWithEndBlock:^{
                [self updateStatusText:@"两次输入不一致，请重新绘制" withColor:[UIColor redColor]];
            }];
        }
    }
}

@end
    
