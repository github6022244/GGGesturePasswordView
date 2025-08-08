#import "NSUserDefaults+GGGesture.h"

static NSString *const kGGGesturePasswordKey = @"kGGGesturePasswordKey";

@implementation NSUserDefaults (GGGesture)

- (void)setGGGesturePassword:(NSString *)password {
    if (password) {
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:kGGGesturePasswordKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGGGesturePasswordKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)ggGesturePassword {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kGGGesturePasswordKey];
}

- (void)removeGGGesturePassword {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGGGesturePasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
    
