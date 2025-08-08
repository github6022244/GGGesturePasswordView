#import "UIImage+GGResize.h"

@implementation UIImage (GGResize)

- (UIImage *)gg_resizedToFitSize:(CGSize)size {
    // 计算缩放比例
    CGFloat widthRatio = size.width / self.size.width;
    CGFloat heightRatio = size.height / self.size.height;
    CGFloat scaleRatio = MIN(widthRatio, heightRatio);
    
    // 计算新尺寸
    CGSize scaledSize = CGSizeMake(self.size.width * scaleRatio, self.size.height * scaleRatio);
    
    // 绘制缩放后的图片
    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

// 生成带边框的默认点图片（修复颜色创建方法错误）
- (UIImage *)defaultPointImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    // 绘制外圈
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [color setFill];
    [outerPath fill];
    
    // 绘制边框 - 修复颜色创建方法
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, 1, 1)];
    borderPath.lineWidth = 2;
    // 使用正确的方法创建带透明度的颜色
    UIColor *borderColor = [color colorWithAlphaComponent:0.5];
    [borderColor setStroke];
    [borderPath stroke];
    
    // 绘制内圈 - 修复颜色创建方法
    CGFloat innerRadius = size.width * 0.25;
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:innerRadius
                                                        startAngle:0
                                                          endAngle:2*M_PI
                                                         clockwise:YES];
    // 使用正确的方法创建带透明度的颜色
    UIColor *innerColor = [color colorWithAlphaComponent:0.8];
    [innerColor setFill];
    [innerPath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
