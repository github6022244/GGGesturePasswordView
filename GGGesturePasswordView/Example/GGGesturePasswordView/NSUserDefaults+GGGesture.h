#import <Foundation/Foundation.h>

@interface NSUserDefaults (GGGesture)

/** 保存手势密码 */
- (void)setGGGesturePassword:(NSString *)password;

/** 获取保存的手势密码 */
- (NSString *)ggGesturePassword;

/** 删除保存的手势密码 */
- (void)removeGGGesturePassword;

@end
    
