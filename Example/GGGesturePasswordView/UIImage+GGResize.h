#import <UIKit/UIKit.h>

@interface UIImage (GGResize)

/**
 将图片缩放到指定大小
 @param size 目标大小
 @return 缩放后的图片
 */
- (UIImage *)gg_resizedToFitSize:(CGSize)size;

// 生成带边框的默认点图片（修复颜色创建方法错误）
- (UIImage *)defaultPointImageWithColor:(UIColor *)color size:(CGSize)size;

@end
